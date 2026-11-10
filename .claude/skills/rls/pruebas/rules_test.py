"""Pruebas de las reglas de Firestore de Codo (skill `rls`).

Cada caso es «quién intenta qué» y lo que las reglas DEBEN hacer (el contrato).
Un caso que no cumple es un agujero abierto o una regla que rompe la app.

Uso, desde la raíz del repo:
    python .claude/skills/rls/pruebas/rules_test.py                 # prueba firestore.rules
    python .claude/skills/rls/pruebas/rules_test.py otra/ruta.rules # prueba unas candidatas

Necesita Firebase CLI, Java y Python 3. Arranca un emulador APARTE (proyecto
demo, puertos 9199 y 8181) en una carpeta temporal: no toca el proyecto real,
ni `emulator-data/`, ni el emulador de desarrollo (9099/8080).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path

PROJECT = "demo-codo-rls"
AUTH_PORT, FS_PORT = 9199, 8181
RESULT_FILE = "resultado.txt"


# --------------------------------------------------------------------------
# 1. Lanzador: copia las reglas a una carpeta temporal y arranca el emulador
# --------------------------------------------------------------------------
def launch() -> int:
    repo = Path(__file__).resolve().parents[4]  # .claude/skills/rls/pruebas/ → raíz
    rules = Path(sys.argv[1]) if len(sys.argv) > 1 else repo / "firestore.rules"
    if not rules.is_file():
        print(f"No existe el fichero de reglas: {rules}")
        return 2
    if shutil.which("firebase") is None:
        print("Falta Firebase CLI en el PATH (npm install -g firebase-tools).")
        return 2

    tmp = Path(tempfile.mkdtemp(prefix="codo-rls-"))
    try:
        shutil.copy(rules, tmp / "firestore.rules")
        shutil.copy(__file__, tmp / "rules_test.py")
        (tmp / "firebase.json").write_text(json.dumps({
            "firestore": {"rules": "firestore.rules"},
            "emulators": {
                "auth": {"port": AUTH_PORT},
                "firestore": {"port": FS_PORT},
                "ui": {"enabled": False},
                "singleProjectMode": True,
            },
        }))
        python = os.path.basename(sys.executable)
        cmd = (f"firebase emulators:exec --project {PROJECT} "
               f'--only auth,firestore "{python} -I rules_test.py"')
        env = dict(os.environ, CODO_RLS_RUN="1")
        done = subprocess.run(cmd, cwd=tmp, shell=True, env=env,
                              capture_output=True, text=True,
                              encoding="utf-8", errors="replace")
        print(f"Reglas probadas: {rules}\n")
        result = tmp / RESULT_FILE
        if result.is_file():
            print(result.read_text(encoding="utf-8"))
        else:
            # El emulador no llegó a ejecutar los casos: enseña por qué
            print("No se ejecutaron los casos. Salida de Firebase CLI:\n")
            print(done.stdout[-3000:], done.stderr[-2000:])
            return 2
        # Un error de sintaxis en las reglas hace que el emulador lo deniegue todo
        hints = [line for line in (done.stdout + done.stderr).splitlines()
                 if "rules" in line.lower() and "error" in line.lower()
                 and "rules_test.py" not in line]
        if hints:
            print("Avisos del emulador sobre las reglas:")
            print("\n".join(hints[:10]))
        return done.returncode
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# --------------------------------------------------------------------------
# 2. Cliente REST mínimo contra el emulador
# --------------------------------------------------------------------------
AUTH = f"http://127.0.0.1:{AUTH_PORT}/identitytoolkit.googleapis.com/v1"
ROOT = f"projects/{PROJECT}/databases/(default)/documents"
FS = f"http://127.0.0.1:{FS_PORT}/v1/{ROOT}"
ADMIN = "owner"  # con este token el emulador se salta las reglas (para sembrar)


def http(method, url, body=None, token=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read() or b"null")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors="replace")[:200]


def val(v):
    """Valor de Python → valor tipado de la API REST de Firestore."""
    if v is None: return {"nullValue": None}
    if isinstance(v, bool): return {"booleanValue": v}
    if isinstance(v, int): return {"integerValue": str(v)}
    if isinstance(v, float): return {"doubleValue": v}
    if isinstance(v, str): return {"stringValue": v}
    if isinstance(v, list): return {"arrayValue": {"values": [val(x) for x in v]}}
    if isinstance(v, datetime): return {"timestampValue": v.strftime("%Y-%m-%dT%H:%M:%SZ")}
    if isinstance(v, tuple): return {"geoPointValue": {"latitude": v[0], "longitude": v[1]}}
    raise TypeError(type(v))


def fields(d): return {k: val(v) for k, v in d.items()}


def signup(email):
    status, r = http("POST", f"{AUTH}/accounts:signUp?key=fake",
                     {"email": email, "password": "solo-emulador-123", "returnSecureToken": True})
    assert status == 200, r
    return r["localId"], r["idToken"]


def get(path, tok): return http("GET", f"{FS}/{path}", token=tok)[0]
def create(col, doc_id, d, tok): return http("POST", f"{FS}/{col}?documentId={doc_id}", {"fields": fields(d)}, tok)[0]
def set_(path, d, tok): return http("PATCH", f"{FS}/{path}", {"fields": fields(d)}, tok)[0]
def delete(path, tok): return http("DELETE", f"{FS}/{path}", token=tok)[0]


def update(path, d, tok):
    """Como `doc.update({...})`: solo toca esos campos y exige que el documento exista."""
    mask = "&".join("updateMask.fieldPaths=" + urllib.parse.quote(k) for k in d)
    return http("PATCH", f"{FS}/{path}?{mask}&currentDocument.exists=true", {"fields": fields(d)}, tok)[0]


def commit_ts(path, d, ts_field, tok, mask=None):
    """Escritura con `FieldValue.serverTimestamp()` en `ts_field`, como hace la app."""
    write = {"update": {"name": f"{ROOT}/{path}", "fields": fields(d)},
             "updateTransforms": [{"fieldPath": ts_field, "setToServerValue": "REQUEST_TIME"}]}
    if mask is not None:  # con máscara equivale a update(); sin ella, a set()
        write["updateMask"] = {"fieldPaths": mask}
        write["currentDocument"] = {"exists": True}
    return http("POST", f"{FS}:commit", {"writes": [write]}, tok)[0]


def query(col, tok, where=None, order=None, limit=None):
    """Consulta de lista. `where` es [(campo, operador, valor), ...]."""
    q = {"from": [{"collectionId": col}]}
    if where:
        fs = [{"fieldFilter": {"field": {"fieldPath": f}, "op": op, "value": val(v)}} for f, op, v in where]
        q["where"] = fs[0] if len(fs) == 1 else {"compositeFilter": {"op": "AND", "filters": fs}}
    if order:
        q["orderBy"] = [{"field": {"fieldPath": order}, "direction": "DESCENDING"}]
    if limit:
        q["limit"] = limit
    status, r = http("POST", f"{FS}:runQuery", {"structuredQuery": q}, tok)
    if status == 200 and isinstance(r, list) and r and "error" in r[0]:
        return 403
    return status


# --------------------------------------------------------------------------
# 3. Casos
# --------------------------------------------------------------------------
A, D = "permite", "deniega"


def run() -> int:
    now = datetime.now(timezone.utc)
    ana, tA = signup("ana@example.test")
    leo, tL = signup("leo@example.test")
    mar, tM = signup("mar@example.test")
    eve, tE = signup("eve@example.test")

    def session(uid, **over):
        """Documento tal y como lo escribe `LiveSession.toFirestore()`."""
        d = {"creatorId": uid, "creatorName": "Ana", "description": "Repaso",
             "startedAt": now - timedelta(minutes=5), "durationMinutes": 60,
             "category": "study", "visibility": "public", "status": "active",
             "participantIds": [uid], "endedAt": None}
        d.update(over)
        return d

    def profile(**over):
        """Documento tal y como lo escribe `Profile.toFirestore()`."""
        d = {"displayName": "Ana", "xp": 0, "badges": [], "createdAt": now}
        d.update(over)
        return d

    loc = {"location": (40.42, -3.70), "locationAt": now}

    # Datos de partida, escritos saltándose las reglas
    set_("live_sessions/s_pub", session(ana, **loc), ADMIN)
    set_("live_sessions/s_fri", session(ana, visibility="friends", **loc), ADMIN)
    set_("live_sessions/s_edit", session(ana), ADMIN)
    set_("live_sessions/s_fin", session(ana, status="finished", endedAt=now), ADMIN)
    set_("live_sessions/s_del", session(ana), ADMIN)
    set_(f"live_sessions/s_pub/proofs/{ana}", {"image": "AAAA", "createdAt": now}, ADMIN)
    set_(f"users/{ana}", profile(), ADMIN)
    set_(f"users/{leo}", profile(displayName="Leo"), ADMIN)
    set_("pacts/p1", {"title": "t", "createdAt": now}, ADMIN)
    set_("badges/b1", {"name": "n", "xpReward": 10}, ADMIN)

    proof_ana = f"live_sessions/s_pub/proofs/{ana}"
    year_2099 = datetime(2099, 1, 1, tzinfo=timezone.utc)

    # (id, hallazgo de docs/seguridad_auditoria.md o "", qué intenta, contrato, acción)
    # «App:» = operación que hace la app tal cual; si se deniega, la regla rompe la app.
    cases = [
        # ---- Lecturas ----
        ("R01", "", "Leo lee una sesión pública de Ana", A, lambda: get("live_sessions/s_pub", tL)),
        ("R02", "V-01", "Leo lee una sesión de solo amigos de Ana (con ubicación)", D, lambda: get("live_sessions/s_fri", tL)),
        ("R03", "", "Ana lee su propia sesión de amigos", A, lambda: get("live_sessions/s_fri", tA)),
        ("R04", "V-01", "Leo lista toda la colección sin filtros", D, lambda: query("live_sessions", tL)),
        ("R05", "V-01", "Leo consulta el historial de Ana (creatorId == ana)", D, lambda: query("live_sessions", tL, [("creatorId", "EQUAL", ana)], "startedAt", 4)),
        ("R06", "", "App: recientes públicas (visibility == public, orderBy, limit 10)", A, lambda: query("live_sessions", tL, [("visibility", "EQUAL", "public")], "startedAt", 10)),
        ("R07", "", "App: categoría + públicas", A, lambda: query("live_sessions", tL, [("category", "EQUAL", "study"), ("visibility", "EQUAL", "public")], "startedAt")),
        ("R08", "", "App: mi historial paginado (creatorId == yo, limit 4)", A, lambda: query("live_sessions", tA, [("creatorId", "EQUAL", ana)], "startedAt", 4)),
        ("R09", "", "App: mi historial por fechas", A, lambda: query("live_sessions", tA, [("creatorId", "EQUAL", ana), ("startedAt", "GREATER_THAN_OR_EQUAL", now - timedelta(days=30)), ("startedAt", "LESS_THAN", now + timedelta(days=1))], "startedAt")),
        ("R10", "", "Sin sesión: leer una sesión pública", D, lambda: get("live_sessions/s_pub", None)),
        ("R11", "", "Leo lee el perfil de Ana", D, lambda: get(f"users/{ana}", tL)),
        ("R12", "", "Leo (no participante) lee la prueba de Ana", D, lambda: get(proof_ana, tL)),
        ("R13", "", "App: Ana lee su prueba", A, lambda: get(proof_ana, tA)),
        ("R14", "", "App: listar pactos (datos de ejemplo, TEMPORAL)", A, lambda: query("pacts", tL)),
        ("R15", "", "Leo lista todos los perfiles", D, lambda: query("users", tL)),
        # ---- Perfil ----
        ("U01", "", "App: Mar crea su perfil (xp 0, sin medallas)", A, lambda: set_(f"users/{mar}", profile(displayName="Mar"), tM)),
        ("U02", "V-03", "Eve crea su perfil con xp 5000 y una medalla", D, lambda: set_(f"users/{eve}", profile(xp=5000, badges=["medal_5"]), tE)),
        ("U03", "V-03", "Ana se sube el xp a 999999", D, lambda: update(f"users/{ana}", {"xp": 999999}, tA)),
        ("U04", "V-03", "Ana se añade una medalla", D, lambda: update(f"users/{ana}", {"badges": ["medal_5"]}, tA)),
        ("U05", "", "App: Ana cambia su nombre", A, lambda: update(f"users/{ana}", {"displayName": "Ana B."}, tA)),
        ("U06", "V-03", "Ana añade un campo inventado (role: admin)", D, lambda: update(f"users/{ana}", {"role": "admin"}, tA)),
        ("U07", "V-03", "Ana guarda un nombre de 5000 caracteres", D, lambda: update(f"users/{ana}", {"displayName": "x" * 5000}, tA)),
        ("U08", "", "Leo edita el perfil de Ana", D, lambda: update(f"users/{ana}", {"displayName": "hack"}, tL)),
        # ---- Sesiones: crear ----
        ("C01", "", "App: crear sesión sin ubicación", A, lambda: create("live_sessions", "c01", session(ana), tA)),
        ("C02", "", "App: crear sesión pública con ubicación redondeada", A, lambda: create("live_sessions", "c02", session(ana, **loc), tA)),
        ("C03", "", "Crear a nombre de otro (creatorId = leo)", D, lambda: create("live_sessions", "c03", session(leo, participantIds=[ana]), tA)),
        ("C04", "", "Crear metiendo a otro como participante", D, lambda: create("live_sessions", "c04", session(ana, participantIds=[ana, leo]), tA)),
        ("C05", "V-05", "Crear con un campo extra de 200 KB", D, lambda: create("live_sessions", "c05", session(ana, junk="x" * 200_000), tA)),
        ("C06", "V-05", "Crear con creatorName de 5000 caracteres", D, lambda: create("live_sessions", "c06", session(ana, creatorName="x" * 5000), tA)),
        ("C07", "V-05", "Crear con startedAt en 2099 (queda fijada arriba en Ahora)", D, lambda: create("live_sessions", "c07", session(ana, startedAt=year_2099), tA)),
        ("C08", "V-05", "Crear con visibility y category inventadas", D, lambda: create("live_sessions", "c08", session(ana, visibility="secret", category="hack"), tA)),
        ("C09", "V-06", "Crear sesión de amigos con ubicación", D, lambda: create("live_sessions", "c09", session(ana, visibility="friends", **loc), tA)),
        ("C10", "V-06", "Crear con ubicación exacta (6 decimales)", D, lambda: create("live_sessions", "c10", session(ana, location=(40.416775, -3.703790), locationAt=now), tA)),
        ("C11", "V-05", "Crear una sesión que nace terminada", D, lambda: create("live_sessions", "c11", session(ana, status="finished", endedAt=now), tA)),
        ("C12", "", "Crear con descripción de 141 caracteres", D, lambda: create("live_sessions", "c12", session(ana, description="x" * 141), tA)),
        ("C13", "", "Crear con duración 0", D, lambda: create("live_sessions", "c13", session(ana, durationMinutes=0), tA)),
        ("C14", "", "App: sesión creada sin red hace 3 h (startedAt pasado)", A, lambda: create("live_sessions", "c14", session(ana, startedAt=now - timedelta(hours=3)), tA)),
        # ---- Sesiones: editar y borrar ----
        ("E01", "", "App: editar descripción y duración", A, lambda: update("live_sessions/s_edit", {"description": "Nuevo", "durationMinutes": 90}, tA)),
        ("E02", "V-07", "Editar dejando la descripción vacía", D, lambda: update("live_sessions/s_edit", {"description": ""}, tA)),
        ("E03", "V-07", "Editar con status inventado", D, lambda: update("live_sessions/s_edit", {"status": "banana"}, tA)),
        ("E04", "V-07", "Reabrir una sesión terminada (finished → active)", D, lambda: update("live_sessions/s_fin", {"status": "active"}, tA)),
        ("E05", "V-07", "Terminar poniendo endedAt a mano en el pasado", D, lambda: update("live_sessions/s_edit", {"status": "finished", "endedAt": now - timedelta(days=30)}, tA)),
        ("E06", "", "Cambiar creatorId de mi sesión", D, lambda: update("live_sessions/s_edit", {"creatorId": leo}, tA)),
        ("E07", "", "Cambiar visibility de mi sesión", D, lambda: update("live_sessions/s_edit", {"visibility": "friends"}, tA)),
        ("E08", "", "Añadir participantes a mano", D, lambda: update("live_sessions/s_edit", {"participantIds": [ana, leo]}, tA)),
        ("E09", "", "Leo edita la sesión de Ana", D, lambda: update("live_sessions/s_edit", {"description": "hack"}, tL)),
        ("E10", "", "Leo borra la sesión de Ana", D, lambda: delete("live_sessions/s_del", tL)),
        ("E11", "", "App: terminar (status finished + serverTimestamp)", A, lambda: commit_ts("live_sessions/s_edit", {"status": "finished"}, "endedAt", tA, mask=["status"])),
        ("E12", "", "App: editar la descripción de una sesión ya terminada", A, lambda: update("live_sessions/s_fin", {"description": "Hecho", "durationMinutes": 60}, tA)),
        ("E13", "", "App: borrar mi sesión", A, lambda: delete("live_sessions/s_del", tA)),
        # ---- Pruebas (fotos) ----
        ("P01", "", "App: guardar mi prueba (image + serverTimestamp)", A, lambda: commit_ts(proof_ana, {"image": "QUJD"}, "createdAt", tA)),
        ("P02", "", "Prueba con un campo extra", D, lambda: commit_ts(proof_ana, {"image": "QUJD", "extra": "x"}, "createdAt", tA)),
        ("P03", "", "Prueba de 307200 caracteres (justo el límite)", D, lambda: commit_ts(proof_ana, {"image": "A" * 307200}, "createdAt", tA)),
        ("P04", "", "App: prueba de 307199 caracteres", A, lambda: commit_ts(proof_ana, {"image": "A" * 307199}, "createdAt", tA)),
        ("P05", "", "Prueba con createdAt puesto por el cliente", D, lambda: set_(proof_ana, {"image": "QUJD", "createdAt": now - timedelta(days=1)}, tA)),
        ("P06", "", "Leo (no participante) sube su prueba a la sesión de Ana", D, lambda: commit_ts(f"live_sessions/s_pub/proofs/{leo}", {"image": "QUJD"}, "createdAt", tL)),
        ("P07", "", "Leo sobrescribe la prueba de Ana", D, lambda: commit_ts(proof_ana, {"image": "QUJD"}, "createdAt", tL)),
        ("P08", "", "Leo borra la prueba de Ana", D, lambda: delete(proof_ana, tL)),
        ("P09", "V-07", "Prueba con image vacía", D, lambda: commit_ts(f"live_sessions/s_fri/proofs/{ana}", {"image": ""}, "createdAt", tA)),
        # ---- Resto ----
        ("O01", "", "Escribir en pacts desde el cliente", D, lambda: set_("pacts/x", {"title": "hack"}, tA)),
        ("O02", "", "Escribir en badges desde el cliente", D, lambda: set_("badges/x", {"name": "hack"}, tA)),
        ("O03", "", "Escribir en una colección no declarada", D, lambda: set_("whatever/x", {"a": 1}, tA)),
        ("O04", "", "Leer una colección no declarada", D, lambda: get("whatever/x", tA)),
    ]

    lines, failed, odd = [], [], 0
    for case_id, finding, text, expected, action in cases:
        code = action()
        got = A if code == 200 else (D if code == 403 else f"HTTP {code}")
        ok = got == expected
        if not ok:
            failed.append(case_id)
        if got not in (A, D):
            odd += 1
        tag = f" [{finding}]" if finding and not ok else ""
        must = "" if ok else f" (debe: {expected})"
        lines.append(f"{'OK' if ok else 'XX'}  {case_id}  {got:8}{must}{tag}  {text}")
    lines.append("")
    lines.append(f"{len(cases) - len(failed)}/{len(cases)} casos cumplen el contrato.")
    if failed:
        lines.append("No cumplen: " + ", ".join(failed))
        lines.append("«permite (debe: deniega)» = agujero abierto. «deniega (debe: permite)» = la regla rompe la app.")
    if odd > len(cases) // 2:
        lines.append("Casi todo devuelve un HTTP que no es 200 ni 403: lo normal es que "
                     "las reglas no compilen (error de sintaxis). Revísalas antes de leer los casos.")
    Path(RESULT_FILE).write_text("\n".join(lines), encoding="utf-8")
    return 1 if failed else 0


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")  # la consola de Windows no es UTF-8
    sys.exit(run() if os.environ.get("CODO_RLS_RUN") else launch())
