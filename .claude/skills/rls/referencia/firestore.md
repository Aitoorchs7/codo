# Reglas de Firestore en Codo: convenciones

Ejemplo completo y probado: [`firestore.objetivo.rules`](firestore.objetivo.rules). Lo que sigue explica por qué tiene esa forma.

## 1. Forma del fichero

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 1. Helpers comunes (una sola vez, arriba)
    // 2. Un bloque por colección, en el orden de FirestoreAdmin
    // 3. Las subcolecciones, anidadas dentro de su padre
  }
}
```

Cada bloque de colección, siempre en este orden:

```
// ---------- ruta/{id} ----------
// Leer: … · Crear: … · Editar: … · Borrar: …      ← resumen en una línea por operación
match /ruta/{id} {
  function …                // funciones propias de la colección
  allow get: …
  allow list: …
  allow create: …
  allow update: …
  allow delete: …
  match /hija/{id2} { … }
}
```

- Una operación que nadie puede hacer **no se escribe** (se deniega sola). No pongas `allow x: if false`.
- `get` y `list` separados aunque hoy coincidan (`allow get, list:` si son idénticas). `list` es la que permite volcar la colección.
- Comentarios en español que digan **qué impide** la condición, no qué hace.

## 2. Helpers comunes (nombres fijos)

| Helper | Devuelve |
|---|---|
| `signedIn()` | hay sesión |
| `isOwner(uid)` | hay sesión y es ese uid |
| `incoming()` | el documento como quedaría (`request.resource.data`) |
| `existing()` | el documento como está (`resource.data`) |
| `changedKeys()` | claves que cambian entre uno y otro |
| `hasKeys(required, optional)` | esquema cerrado: todas las obligatorias y ninguna de más |
| `isText(v, min, max)` | string con longitud en rango |
| `isIntIn(v, min, max)` | entero en rango |

No crees otro helper con otro nombre para lo mismo. Las funciones propias de una colección se llaman `valid<Cosa>(d)`, `canSee(d)` o `is<Rol>()` y reciben el mapa `d`, para servir igual con `incoming()` y con `existing()`.

## 3. Recetas por tipo de campo

| Campo | Condición |
|---|---|
| Texto | `isText(d.description, 1, 140)` |
| Entero | `isIntIn(d.durationMinutes, 1, 480)` (`is int` rechaza decimales; `is number` no) |
| Enumerado | `d.category in ['study', 'train', 'read', 'work', 'other']` (los mismos nombres que el `enum` de Dart) |
| Dueño | `d.creatorId == request.auth.uid` |
| Lista de un solo uid | `d.participantIds == [request.auth.uid]` |
| Hora del servidor | `d.createdAt == request.time` (el cliente manda `FieldValue.serverTimestamp()`) |
| Hora del cliente acotada | `d.startedAt is timestamp && d.startedAt <= request.time + duration.value(5, 'm')` |
| Nulo al nacer | `d.endedAt == null` |
| Opcional | `!('bio' in d) \|\| isText(d.bio, 0, 160)` |
| URL | `isText(d.photoUrl, 9, 500) && d.photoUrl.matches('https://.*')` |
| Punto geográfico | `d.location is latlng`; métodos `.latitude()` y `.longitude()` |
| Redondeo a 2 decimales | `math.abs(v * 100 - math.round(v * 100)) < 0.001` |
| Valor inicial fijo | `d.xp == 0`, `d.badges.size() == 0`, `d.status == 'active'` |

**Hora del cliente o del servidor:** si la app tiene que funcionar sin red, una escritura en cola llega con `request.time` de cuando se sincroniza. Por eso `startedAt` se acota (pasado sí, futuro no) y `createdAt`/`endedAt` usan la hora del servidor, que la cola resuelve sola.

## 4. Patrones de propiedad

| Patrón | Cuándo | Condición base |
|---|---|---|
| Documento del usuario | `users/{uid}` | `isOwner(uid)` |
| Campo de creador | `live_sessions` | `existing().creatorId == request.auth.uid` |
| Lista de miembros | sesiones con participantes, pactos | `request.auth.uid in existing().memberIds` |
| Pertenencia al padre | `proofs`, `checkins` | `get(/databases/$(database)/documents/<padre>/$(id)).data.<lista>` |
| Catálogo | `badges`, plantillas | `allow get, list: if signedIn();` y ninguna escritura |
| Solo servidor | compras, derechos, eventos de XP | ninguna regla de escritura; escribe el servidor con Admin SDK, que no pasa por reglas |
| Rol de administrador | moderación (`reports`) | `request.auth.token.admin == true` (*custom claim* puesto por el servidor), nunca un campo del perfil |

## 5. Patrones de `update`

- **Siempre** `changedKeys().hasOnly([...])` y, además, validar el contenido resultante: `incoming()` en un `update` es el documento ya fusionado, no solo lo que mandó el cliente.
- **Transiciones de estado explícitas**, una rama por transición:
  ```
  && (
    !changedKeys().hasAny(['status', 'endedAt'])          // a) solo contenido
    || (existing().status == 'active'                      // b) terminar
        && incoming().status == 'finished'
        && incoming().endedAt == request.time)
  )
  ```
- **Campos del servidor:** no aparecen en la lista de `hasOnly`, y en `create` tienen su valor inicial fijo.
- **Unirse o salir de una lista (fase 2):** la lista solo puede cambiar en el propio uid. Esbozo **sin probar**; decide antes con Aitor si «unirse» va por reglas o por la API propia (está en la lista de operaciones del servidor por la prueba de 50 peticiones a la vez):
  ```
  incoming().participantIds.toSet().difference(existing().participantIds.toSet())
    == [request.auth.uid].toSet()
  ```
  Rama aparte de la del creador, con `changedKeys().hasOnly(['participantIds'])`, y con sus casos de prueba (unirse dos veces, meter a otro, sacar a otro, que el creador se salga).

## 6. Consultas y reglas tienen que encajar

Las reglas no filtran resultados: si la consulta *podría* devolver un documento que la regla no deja leer, se rechaza entera. Cada `list` va con su consulta.

| Consulta (`live_session_repository.dart`) | Filtro que la hace válida | Condición de la regla que cumple |
|---|---|---|
| `watchPublicByCategory` | `visibility == 'public'` | `d.visibility == 'public'` |
| `watchRecentPublic` | `visibility == 'public'` | `d.visibility == 'public'` |
| `getHistoryBetween` | `creatorId == uid` | `d.creatorId == request.auth.uid` |
| `getHistoryPage` | `creatorId == uid` | `d.creatorId == request.auth.uid` |

Al añadir una consulta (mapa, «cerca de mí», sesiones de amigos), añade su fila y su caso «App:» en las pruebas. Para limitar el volcado: `request.query.limit <= N` en `list`, que obliga a que **todas** las consultas lleven `.limit()` (hoy dos no lo llevan).

## 7. Trampas conocidas

- **`hasOnly` no exige que estén todas.** `keys().hasOnly(['a','b'])` acepta un documento vacío. Para esquema cerrado, `hasAll` y `hasOnly` juntos: usa `hasKeys`.
- **Campo que falta = error = denegado.** Leer `d.campo` cuando no existe hace fallar la condición entera. Para opcionales, `'campo' in d` primero.
- **`delete` no tiene `request.resource`.** Usa solo `existing()`.
- **`create` no tiene `resource`.** `changedKeys()` solo vale en `update`.
- **`get()` del padre cuesta una lectura facturada** por evaluación, aunque se deniegue. Máximo 10 llamadas de acceso por petición o consulta y 20 en lecturas múltiples, transacciones y lotes; pasarse es un «permiso denegado».
- **Padre borrado:** `get(...).data` de un documento que no existe da error y deniega. Es lo correcto (falla en cerrado), pero deja huérfanos legibles por nadie: el borrado del padre tiene que borrar antes las hijas.
- **Las reglas de un padre no se heredan.** Una subcolección sin `match` propio está cerrada.
- **Admin SDK y consola se saltan las reglas.** Lo que escriba el servidor hay que validarlo en el servidor.
- **El emulador con token `owner` también se las salta.** Los datos importados con `--import` no se validan.
- **Límites de tamaño:** las reglas no pueden mirar el tamaño del documento, solo el de cada campo. Sin esquema cerrado, un documento admite hasta 1 MB de campos inventados.
- **El Rules Playground** de la consola simula peticiones sueltas; no reproduce las consultas de la app con sus filtros. Para eso están los casos «App:» de `pruebas/rules_test.py`.

## 8. Cuando lleguen App Check y el correo verificado

- Correo verificado para escribir: `request.auth.token.email_verified == true` (las cuentas de Google ya lo traen).
- App Check se exige desde la consola (*enforcement*), no desde las reglas.

## 9. Colecciones previstas

De `docs/decisiones_producto.md` §8. Son el punto de partida de la ficha, no decisiones tomadas: confírmalas con Aitor.

| Ruta | Leer | Escribir | Dudas a resolver |
|---|---|---|---|
| `users/{uid}` | dueño | dueño, sin `xp` ni `badges` | Amigos y ranking necesitan nombre y avatar de otros: documento público aparte (`profiles_public/{uid}`) o vía API |
| `friendships/{id}` | las dos partes | solicitud: quien la envía; aceptar: el otro | Forma del id (par ordenado de uids) para poder usar `exists()` |
| `pacts/{id}` | miembros (`memberIds`) | crear y aceptar van por la API | Qué campos, si alguno, edita el cliente |
| `pacts/{id}/checkins/{id}` | miembros del pacto | el autor crea el suyo; el compañero solo cambia el campo de validación | Foto base64 como en `proofs`; un check-in por día |
| `live_sessions/{id}/participants/{uid}` | quien pueda ver la sesión | el propio uid, o el servidor | Sustituye o acompaña a `participantIds` |
| `reports/{id}` | administrador | crear: cualquier usuario con sesión, a su nombre; nada más | Nadie lee sus propias denuncias ni las ajenas |
