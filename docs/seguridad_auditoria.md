# Auditoría de seguridad — Codo

**Fecha:** 10/11/2026 · **Commit auditado:** `7914213` (rama `master`) · **Autor de la auditoría:** Claude (IA), a petición de Aitor. No se ha modificado ningún fichero del proyecto; este documento y la skill `rls` son lo único nuevo.

## 1. Alcance y método

**Qué se ha revisado:** `firestore.rules`, `firestore.indexes.json`, `firebase.json`, todo `lib/` (admins, modelos, repositorios, pantallas, utilidades), manifiestos de Android, `build.gradle.kts`, `web/index.html`, `.gitignore`, `.claude/settings.json`, datos exportados del emulador y el historial completo de git.

**Cómo se ha comprobado:**
- **Reglas:** 63 casos ejecutados por REST contra un emulador aislado (proyecto `demo-`, puertos 9199/8181, sin tocar el proyecto real ni `emulator-data/`). Cada caso es «quién intenta qué» y si las reglas lo permiten. Los casos están en `.claude/skills/rls/pruebas/rules_test.py` y se pueden repetir (ver anexo A).
- **Fotos:** un script temporal pasó una foto con GPS en el EXIF por la misma cadena que `compressSync` (`decodeImage → bakeOrientation → copyResize → encodeJpg`) con `image 4.12.0`, la versión de `pubspec.lock`.
- **Secretos:** búsqueda por nombre de fichero y por patrón de clave (`AIza`) en todos los commits de todas las ramas.

**Qué no se ha podido ver** (no está en el repo; lista de comprobación en la sección 5): la consola de Firebase y de Google Cloud, las reglas realmente desplegadas, `google-services.json` y `firebase_options.dart` (lectura denegada a propósito en `settings.json`), y la compilación de iOS.

**Severidad:** se valora como si la app se publicara hoy en Play tal cual. *Alta*: un usuario cualquiera accede a datos de otros o rompe la integridad del sistema. *Media*: hace falta una condición más, o el daño es limitado, o bloquea la publicación. *Baja*: defensa en profundidad o robustez.

## 2. Resumen

| | Alta | Media | Baja |
|---|---|---|---|
| Hallazgos | 4 | 7 | 7 |

**Lo más importante:**
1. **La visibilidad «solo amigos» no existe en el servidor.** Cualquier persona con una cuenta lee todas las sesiones de todos, con su ubicación y el historial completo de cada usuario (V-01).
2. **Las fotos de prueba conservan el GPS exacto del EXIF** tras la compresión (V-02). Contradice la norma de producto «no se guarda la posición exacta».
3. **Cada usuario puede ponerse el XP y las medallas que quiera** (V-03).
4. **No hay freno al abuso:** registro abierto sin verificar, sin App Check y con documentos de tamaño libre (V-04, V-05).

**Lo que está bien:** no hay ni ha habido secretos en el repo; las reglas cierran todo por defecto; nadie puede editar ni borrar lo ajeno; las fotos solo las leen los participantes; los permisos del móvil son los mínimos; los emuladores solo se activan en compilación. Detalle en la sección 4.

**Veredicto:** la base es sólida y los fallos se concentran en reglas que validan *quién* escribe pero no *qué* escribe ni *qué* se lee. No es publicable en Play todavía, y la mayoría del trabajo que falta ya está planificado para las fases 2 a 4. Ninguno de los hallazgos afecta a la rúbrica de la fase 1b.

## 3. Vulnerabilidades

Las líneas son las del commit `7914213`. «Prueba» es el identificador del caso en el anexo A.

### Alta

#### V-01 · Cualquier usuario lee todas las sesiones, incluidas las de «solo amigos»
- **Dónde:** `firestore.rules:15` — `allow read: if request.auth != null;`
- **Qué pasa:** el filtro `visibility == 'public'` solo está en las consultas del cliente (`live_session_repository.dart:27` y `:36`). Las reglas no lo exigen, así que quien se salte la app (REST, otro cliente) lee cualquier documento.
- **Cómo se explota:** crear una cuenta con correo y contraseña (es libre) y pedir la colección entera, o `where creatorId == <uid>` para sacar el historial de una persona: qué hace, a qué horas y, si compartió ubicación, en qué zona de ~1 km.
- **Prueba:** R02, R04 y R05 se permiten hoy.
- **Impacto:** privacidad. Permite reconstruir rutinas de un usuario concreto (público 16+). Incumple `docs/decisiones_producto.md` §5.
- **Arreglo mínimo:** sustituir la línea 15 por una lectura condicionada (pública, o tuya, o participas). Las cuatro consultas actuales siguen funcionando sin cambiar el cliente (R06–R09 probadas). Bloque completo en `.claude/skills/rls/referencia/firestore.objetivo.rules`.
- **Ojo para B6:** el mapa y «cerca de mí» tendrán que filtrar por `visibility == 'public'` en la consulta; si no, la regla la rechazará entera (las reglas no filtran, aceptan o rechazan la consulta).

#### V-02 · Las fotos de prueba conservan el EXIF (GPS exacto, modelo de móvil, fecha)
- **Dónde:** `lib/utils/photo_compressor.dart:55-64`.
- **Qué pasa:** `bakeOrientation` y `copyResize` copian los metadatos de la foto original y `encodeJpg` los vuelve a escribir. Verificado: una foto con GPS 40.416775, -3.703790 sale de la cadena con el mismo GPS.
- **Cuándo ocurre:** foto hecha con una cámara que geoetiqueta, y cualquier foto de la galería en web (el navegador entrega el fichero intacto).
- **Impacto:** hoy la prueba solo la ve su autor, porque no existe «unirse». En cuanto exista (fase 2), cada participante de una sesión pública podrá sacar el punto exacto donde se hizo la foto, que suele ser una casa. La app pide `ACCESS_COARSE_LOCATION` precisamente para no tener ese dato.
- **Arreglo mínimo:** una línea tras `photo_compressor.dart:57`: `image.exif = img.ExifData();`. Verificado en las dos ramas (con y sin redimensionar): el GPS desaparece. Añadir un caso a `test/photo_compressor_test.dart` que lo compruebe.
- **Las pruebas ya subidas** a la nube antes del arreglo conservan su EXIF: borrarlas o volver a subirlas.

#### V-03 · XP, medallas y cualquier campo del perfil los escribe el propio usuario
- **Dónde:** `firestore.rules:6` — `allow read, write` para el dueño, sin validar nada.
- **Cómo se explota:** un `PATCH` a `users/{miUid}` con `xp: 999999` o `badges: [...]`. También admite campos inventados y textos de hasta 1 MB.
- **Prueba:** U02, U03, U04, U06 y U07 se permiten hoy.
- **Impacto:** integridad. Hoy el XP no se usa para nada; con niveles y ranking (fase 3) el sistema deja de ser creíble. Un campo inventado tipo `role: admin` se vuelve escalada de privilegios el día que alguna regla lo consulte.
- **Arreglo mínimo:** separar `create` (xp 0, sin medallas, esquema cerrado), `update` (solo `displayName`, `photoUrl`, `bio`) y `delete`. `ProfileRepository.saveProfile` ya crea con `xp: 0` y `medals: []`, así que el cliente no cambia (U01 y U05 probadas). El XP lo concederá el servidor (Admin SDK, que no pasa por reglas).

#### V-04 · Sin control de abuso: registro libre, sin App Check y lecturas sin límite
- **Dónde:** no hay `firebase_app_check` en `pubspec.yaml`; `auth_service.dart:31-43` registra sin verificar el correo; `firestore.rules:15` permite listar la colección entera.
- **Cómo se explota:** un script crea cuentas y publica miles de sesiones, o lee en bucle. En el plan Spark la cuota diaria (50 000 lecturas, 20 000 escrituras) se agota y **la app deja de funcionar para todos hasta el día siguiente**; en Blaze, se paga.
- **Impacto:** disponibilidad, coste y spam en «Ahora».
- **Arreglo:** App Check (Play Integrity en Android, reCAPTCHA en web) con *enforcement* en Firestore y Auth; exigir correo verificado para escribir (`request.auth.token.email_verified`); `limit()` en todas las consultas y `request.query.limit` en las reglas; alerta de presupuesto. App Check ya figura en la arquitectura de H1: es trabajo de fase 4, pero **bloquea la publicación**.

### Media

#### V-05 · Al crear una sesión solo se validan 4 de sus 12 campos
- **Dónde:** `firestore.rules:17-25`. No hay `keys().hasOnly(...)`.
- **Qué se cuela (pruebas C05–C08 y C11):** campos extra de cualquier tamaño (200 KB probado; el límite es 1 MB por documento, y ese documento lo descarga la lista «Ahora» de todos los usuarios); `creatorName` libre (5000 caracteres, o «Soporte Codo»); `category` y `visibility` inventadas; `startedAt` en 2099, que deja la sesión fijada arriba en «Ahora» porque se ordena por esa fecha; sesiones que nacen ya terminadas.
- **Arreglo:** esquema cerrado en `create` (lista de claves obligatorias y opcionales, tipo y rango de cada una). Probado que la app sigue creando igual (C01, C02, C14).
- **Efecto secundario:** `seedLiveSessions` crea sesiones ya terminadas y dejaría de pasar por reglas (C11). Los datos exportados (`--import=emulator-data`) no pasan por reglas y siguen valiendo.

#### V-06 · Ubicación en sesiones de «solo amigos» y precisión solo en el cliente
- **Dónde:** `create_session_screen.dart:176-189` (los dos interruptores son independientes) y `firestore.rules:17-25` (no valida `location`).
- **Qué pasa:** `docs/decisiones_producto.md` dice «ubicación solo en sesiones públicas», pero la pantalla permite sesión de amigos con ubicación y las reglas la aceptan (C09). El redondeo a 2 decimales solo vive en `live_session.dart:92,100`; un cliente modificado guarda la posición exacta (C10).
- **Impacto:** lo que haga la app tiene que coincidir con la política de privacidad y con el formulario de seguridad de datos de Play. Combinado con V-01, la ubicación de sesiones «privadas» es legible por cualquiera.
- **Arreglo:** en la pantalla, desactivar el interruptor de ubicación cuando la sesión no es pública; en reglas, `location` solo si `visibility == 'public'`, tipo `latlng` y redondeada.

#### V-07 · Al editar una sesión no se validan `status`, `endedAt` ni el texto vacío
- **Dónde:** `firestore.rules:27-35`.
- **Qué se cuela (E02–E05, P09):** descripción vacía (al crear se exige `size() > 0`, al editar no); `status` con cualquier valor; reabrir una sesión terminada; `endedAt` con una fecha a mano; prueba con `image` vacía.
- **Impacto:** hoy, datos incoherentes. Cuando el XP dependa del tiempo de sesión, es la vía para falsearlo.
- **Arreglo:** dos ramas en `update`: (a) solo contenido, el estado no se toca; (b) terminar: de `active` a `finished` con `endedAt == request.time`. `finishSession` ya usa `serverTimestamp` (E11 probada).

#### V-08 · `pacts` legible por cualquier usuario y sembrado abriendo la escritura en producción
- **Dónde:** `firestore.rules:8-10` (comentario «TEMPORAL»), `pact_repository.dart:9` (lista todos los pactos, sin filtrar por usuario) y `README.md:231` (pide permitir `write` en `pacts` y `badges` mientras se siembra).
- **Impacto:** hoy son datos de ejemplo. Con pactos reales (fase 2), todos verían los pactos de todos. Abrir la escritura a mano en el proyecto real es un paso que se olvida revertir.
- **Arreglo:** al modelar los pactos reales, `memberIds` en el documento y lectura solo para miembros, con la consulta filtrando por `memberIds array-contains uid`. Sembrar desde la consola o con el emulador, nunca relajando las reglas desplegadas.

#### V-09 · La compilación de *release* se firma con la clave de depuración
- **Dónde:** `android/app/build.gradle.kts:35-41`.
- **Impacto:** Play rechaza un bundle firmado en depuración, y el almacén de depuración tiene una contraseña pública (`android`). Bloquea la publicación, no es explotable hoy.
- **Arreglo (fase 4, lo hace Aitor):** `signingConfigs` con `key.properties` fuera del repo, Play App Signing, y registrar en Firebase el SHA-1/SHA-256 de la clave de subida **y** el de la clave de Play (si no, Google Sign-In falla en la versión de la tienda). Compilar con `--obfuscate --split-debug-info`. Decidir el `applicationId` definitivo antes: no se puede cambiar después de publicar.

#### V-10 · Faltan borrar cuenta, recuperar contraseña y verificar el correo
- **Dónde:** `auth_service.dart` (solo `signIn`, `register`, `signInWithGoogle`, `signOut`).
- **Impacto:** Play exige poder borrar la cuenta y sus datos desde la app y desde una web. Sin verificación, cualquiera registra un correo ajeno. Contraseña mínima de 6 caracteres (`auth_screen.dart:52`).
- **Arreglo:** ya previsto en `decisiones_producto.md` («recuperar contraseña, borrar cuenta (app + web)»). Al borrar la cuenta hay que borrar también `users/{uid}`, sus sesiones y sus pruebas; las reglas ya lo permiten al dueño. Subir el mínimo a 8 en la política de contraseñas de la consola.

#### V-11 · Las reglas no tienen pruebas automáticas
- **Dónde:** `test/` no contiene nada de reglas; se probaron a mano por REST y en el Rules Playground.
- **Impacto:** la fase 2 tiene que ampliar la regla `update` para `participantIds` (unirse a sesiones). Es el cambio con más riesgo del proyecto y hoy nada avisaría de una regresión.
- **Arreglo:** la skill `rls` trae 63 casos ejecutables (anexo A). Cada regla nueva añade sus casos.

### Baja

| Id | Qué | Dónde | Arreglo |
|---|---|---|---|
| V-12 | La imagen de la prueba se decodifica sin red de seguridad: `base64Decode` puede lanzar dentro de `build` y `Image.memory` no tiene `errorBuilder` ni tamaño máximo de decodificación. Cuando otros participantes suban pruebas, una imagen manipulada (o enorme al descomprimir) rompería la pantalla de los demás | `proof.dart:15`, `session_detail_screen.dart:60-63`, `history_screen.dart:300-303` | `errorBuilder` y `cacheWidth` en `Image.memory`; decodificar el base64 fuera de `build` con `try` |
| V-13 | Peticiones a un tercero sin declarar: la pantalla de arranque descarga una imagen de `picsum.photos` en cada inicio y las medallas también. Ese servidor recibe la IP de cada usuario | `splash_screen.dart:52-53`, `medal_grid.dart:82`, `example_data.dart:67-102` | Imágenes como *assets* o en Hosting antes de publicar |
| V-14 | Cerrar sesión no limpia la caché local de Firestore ni la sesión de Google. En un móvil compartido, lo que quedó en caché del usuario anterior sigue en el dispositivo | `auth_service.dart:45`, `profile_screen.dart:31-40` | En `signOut`: `GoogleSignIn.instance.signOut()` y `terminate()` + `clearPersistence()` de Firestore |
| V-15 | `.gitignore` cubre `.env` pero no `.env.*`, ni cuentas de servicio (`*service-account*.json`), ni `*.p12`. `emulator-data/auth_export/accounts.json` lleva la contraseña de prueba en claro (formato del emulador), igual que `example_data.dart:113` | `.gitignore:50-55` | Ampliar patrones antes de la fase 3 (el servidor traerá cuentas de servicio). Comprobar que esas cuentas `@codo.test` no existen en el proyecto real |
| V-16 | Si falla la creación del perfil tras registrarse, la excepción no se captura (solo `AuthFailure`) y queda una cuenta sin perfil; al entrar con correo no se repara. Además la pantalla usa `FirebaseAuth.instance` directamente | `auth_screen.dart:85-94` | Usar el `User` que devuelve `register` y `getOrCreateProfile` también al entrar con correo |
| V-17 | Las rutas no comprueban si hay sesión. No expone datos (lo impiden las reglas), pero en web una URL directa puede pintar pantallas vacías o con error. Sin cabeceras de seguridad porque aún no hay `hosting` en `firebase.json` | `app_routes.dart:21-46`, `firebase.json` | Al añadir Hosting (B7): cabeceras `X-Content-Type-Options`, `X-Frame-Options: DENY` y `Referrer-Policy` |
| V-18 | `android:allowBackup` sin declarar (por defecto, activo) y `debugPrint` del error también en *release* | `AndroidManifest.xml:5-8`, `history_screen.dart:78` | `allowBackup="false"` o reglas de extracción; quitar el `debugPrint` al integrar Crashlytics |

## 4. Fortalezas

| Id | Qué está bien | Evidencia |
|---|---|---|
| F-01 | **Cerrado por defecto.** No hay comodines `{document=**}`; lo no declarado se deniega; `pacts` y `badges` no admiten escritura desde el cliente | Casos O01–O04, R15 |
| F-02 | **Nadie toca lo ajeno.** El creador se ata a `request.auth.uid` al crear, y `affectedKeys().hasOnly(...)` impide cambiar `creatorId`, `participantIds` o `visibility` al editar | C03, C04, E06–E10 |
| F-03 | **Fotos bien aisladas.** Subcolección aparte, lectura solo de participantes (comprobando el documento padre), esquema cerrado, tamaño máximo y hora del servidor obligatoria. Si la sesión desaparece, la regla falla en cerrado | R12, P02–P08 |
| F-04 | **Ningún secreto en el repo ni en su historial.** `google-services.json`, `firebase_options.dart` y claves están ignorados y nunca se han subido; no aparece ninguna clave `AIza` en ningún commit | `git log --all` por nombre y por contenido |
| F-05 | **Barreras para la IA en `settings.json`:** leer o editar secretos, `git commit`, `git push` y `firebase deploy` están denegados por la herramienta, no solo por escrito | `.claude/settings.json:24-59` |
| F-06 | **Emuladores solo en compilación.** `bool.fromEnvironment` es constante: en *release* la rama del emulador y el sembrado se eliminan y no hay interruptor en ejecución | `main.dart:21-29` |
| F-07 | **Ubicación mínima por diseño.** Solo `ACCESS_COARSE_LOCATION` (el sistema no puede dar la exacta), precisión baja, redondeo en un único punto, opcional, pedida en el momento de usarla y nunca en el perfil | `AndroidManifest.xml:4`, `location_admin.dart:37-42`, `live_session.dart:91-100` |
| F-08 | **Permisos mínimos.** Solo cámara y ubicación aproximada; la galería usa el selector del sistema; una sola actividad exportada; tráfico sin cifrar solo en depuración | `AndroidManifest.xml`, `debug/AndroidManifest.xml` |
| F-09 | **Errores de acceso sin pistas.** «Usuario no existe» y «contraseña incorrecta» dan el mismo mensaje; nunca llega a la pantalla el texto crudo del SDK; no se registran credenciales | `auth_service.dart:47-62` |
| F-10 | **Lectura defensiva de datos.** `field_readers.dart` comprueba el tipo de cada campo y usa un valor por defecto; un documento malicioso no rompe la app. Con pruebas | `field_readers.dart`, `test/field_readers_test.dart` |
| F-11 | **Una sola puerta a Firestore.** `FirestoreAdmin` con `withConverter`; las pantallas no tocan la base de datos (una excepción, V-16). Todas las rutas de datos se auditan en un fichero | `firestore_admin.dart` |
| F-12 | **Límites iguales en cliente y servidor** (140 caracteres, 1–480 minutos, 300 KB), y la foto fuera del documento que lee todo el mundo | `create_session_screen.dart:146,171`, `photo_compressor.dart:9`, `firestore.rules:54` |
| F-13 | **Dependencias contenidas y fijadas.** Once paquetes, `pubspec.lock` en el repo, sin SDK de analítica ni anuncios todavía | `pubspec.yaml`, `pubspec.lock` |
| F-14 | **Acceso con Google por los SDK oficiales**, sin guardar ni manipular tokens a mano | `auth_service.dart:64-91` |
| F-15 | **Decisiones de seguridad escritas antes de programar:** compras validadas en servidor, fotos solo para participantes, ubicación aproximada, denuncia y bloqueo | `docs/decisiones_producto.md` §5 y §10 |

## 5. Lo que hay que comprobar en la consola (no se ve desde el repo)

- [ ] **Las reglas desplegadas son las de `firestore.rules`.** El README dice «pega las reglas»: si se pegaron a mano, pueden haberse quedado atrás, o con el `write` temporal de `pacts`/`badges` abierto.
- [ ] Clave de API de Android restringida al paquete y al SHA; clave web restringida por dominio (*HTTP referrer*). Las claves de Firebase son identificadores públicos, pero sin restricción sirven para gastar cuota de otras API.
- [ ] Authentication → dominios autorizados: solo los tuyos y `localhost`.
- [ ] Protección contra enumeración de correos activada y política de contraseñas (mínimo 8).
- [ ] No existen en el proyecto real las cuentas `ana/leo/marta/iker@codo.test` con la contraseña del sembrado.
- [ ] Alerta de presupuesto y de uso de cuota.
- [ ] Si el repositorio de GitHub es público: los datos de `emulator-data/` y las capturas de `docs/` no contienen datos reales.

## 6. Requisitos de Play ligados a seguridad

Para la fase 4; no son fallos del código de hoy.
- Política de privacidad pública y formulario de **seguridad de los datos** coherentes con el código: ubicación aproximada, fotos, correo, identificadores. V-02, V-06 y V-13 son justo los puntos donde hoy no coincidirían.
- **Borrado de cuenta** desde la app y desde una URL (V-10).
- **Contenido generado por usuarios** (textos y fotos entre desconocidos): denuncia y bloqueo dentro de la app y normas de uso. Previsto como `reports`.
- Firma de *release* y Play App Signing (V-09). App Check con Play Integrity (V-04).

## 7. Orden recomendado

No amplía el alcance de la fase 1b; lo único que conviene hacer ya es lo que cuesta minutos y está fresco.

| Cuándo | Qué | Esfuerzo |
|---|---|---|
| **Ahora, si sobra media hora** | V-02 (una línea y una prueba) · V-01 (cambiar la regla de lectura; cliente intacto) · V-06 en la pantalla (desactivar el interruptor) | Bajo. Hay que actualizar la tabla de reglas de `README.md:117-122` |
| **Fase 2** (unirse, pactos, Drift) | V-03, V-05, V-07, V-08, V-11, V-12, V-16. Toda regla nueva, con la skill `rls` | Medio |
| **Fase 3** (servidor, Supabase) | XP y medallas solo desde el servidor · RLS de Supabase · V-15 antes de crear la primera cuenta de servicio | Medio |
| **Fase 4** (Play) | V-04, V-09, V-10, V-13, V-14, V-17, V-18 y las secciones 5 y 6 | Alto |

**Riesgo de plazo:** quedan 3 días para la entrega de la 1b con B6 y B7 abiertos. Si V-01 se aplica ahora, hay que volver a pasar las filas de la tabla de pruebas que tocan «Ahora» e Historial.

## Anexo A · Casos de prueba de reglas

Ejecutar desde la raíz (necesita Firebase CLI, Java y Python 3; usa un emulador aparte y no toca datos):

```bash
python .claude/skills/rls/pruebas/rules_test.py
```

Para probar unas reglas candidatas sin tocar `firestore.rules`: `python .claude/skills/rls/pruebas/rules_test.py ruta/al/fichero.rules`.

Resultado el 10/11/2026: **con las reglas actuales, 43 de 63 casos cumplen el contrato; los 20 que fallan son los hallazgos abiertos.** Con las reglas objetivo (`.claude/skills/rls/referencia/firestore.objetivo.rules`) cumplen los 63.

| Caso | Qué intenta | Hoy | Debe | Hallazgo |
|---|---|---|---|---|
| R02 | Leo lee una sesión de solo amigos de Ana, con ubicación | permite | denegar | V-01 |
| R04 | Leo lista toda la colección de sesiones | permite | denegar | V-01 |
| R05 | Leo consulta el historial de Ana | permite | denegar | V-01 |
| U02 | Crear el perfil con xp 5000 y una medalla | permite | denegar | V-03 |
| U03 | Subirse el xp a 999999 | permite | denegar | V-03 |
| U04 | Añadirse una medalla | permite | denegar | V-03 |
| U06 | Añadir un campo inventado (`role: admin`) | permite | denegar | V-03 |
| U07 | Nombre de 5000 caracteres | permite | denegar | V-03 |
| C05 | Sesión con un campo extra de 200 KB | permite | denegar | V-05 |
| C06 | `creatorName` de 5000 caracteres | permite | denegar | V-05 |
| C07 | `startedAt` en 2099 | permite | denegar | V-05 |
| C08 | `visibility` y `category` inventadas | permite | denegar | V-05 |
| C09 | Sesión de amigos con ubicación | permite | denegar | V-06 |
| C10 | Ubicación exacta (6 decimales) | permite | denegar | V-06 |
| C11 | Sesión que nace terminada | permite | denegar | V-05 |
| E02 | Editar dejando la descripción vacía | permite | denegar | V-07 |
| E03 | `status` inventado | permite | denegar | V-07 |
| E04 | Reabrir una sesión terminada | permite | denegar | V-07 |
| E05 | Terminar con `endedAt` a mano en el pasado | permite | denegar | V-07 |
| P09 | Prueba con `image` vacía | permite | denegar | V-07 |

Los otros 43 casos (19 operaciones legítimas de la app que deben permitirse y 24 ataques que ya se deniegan) están en el script, con su descripción.
