# IA.md — Bitácora de uso de IA

Registro de cómo uso asistentes, agentes y skills en Codo. No se apunta todo, **solo lo que decidió algo**: una arquitectura, una corrección, una idea aceptada o descartada.

**Herramientas:** Claude (chat del proyecto y Claude Code en el repositorio), con los agentes y skills de `.claude/`.
**Regla personal:** no acepto código que no sepa explicar. Si la IA propone algo, lo entiendo, lo adapto y lo escribo yo.

## Formato de cada entrada
```
### NNN · AAAA-MM-DD · Título corto
- **Fase / hito:**
- **Qué pedí:**
- **Qué me dio:**
- **Qué corregí o descarté, y por qué:**
- **Resultado (commit / fichero):**
```

---

### 001 · 2026-10-03 · Organizar el proyecto y la parte agéntica
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** que estudiara los documentos del proyecto (enunciado, cronograma, rúbricas, guía de publicación y fases 1–4) y me ayudara a organizar cómo trabajar con IA: las instrucciones del proyecto en Claude, la documentación de contexto y los ficheros base del repositorio (`CLAUDE.md`, `IA.md`, `README.md` y la carpeta `.claude/`).
- **Qué me dio:** resúmenes en Markdown de los requisitos por fase con su puntuación, unas instrucciones de trabajo (yo escribo el código; la IA revisa, explica y propone el cambio mínimo), un borrador de decisiones de producto y estos tres ficheros.
- **Qué corregí o descarté, y por qué:**
  - La IA propuso un **límite de puntos por día** contra las trampas. **Lo descarté**: castiga al usuario que un día se levanta productivo.
  - Me quedé con la verificación social (el compañero valida el check-in) y con la foto hecha en el momento.
  - Decidí que **en un pacto pierden los dos** si uno falla, y que la parte **Ahora** sea sobre todo con amigos.
- **Resultado:** `CLAUDE.md`, `IA.md`, `README.md` y `docs/decisiones_producto.md` (borrador v1).

---

### 002 · 2026-10-08 · Rutas con nombre y «onboarding visto»
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** cómo pasar de página en el onboarding y cómo terminarlo (`_finish`) guardando que ya se ha visto; dónde va cada cosa en las carpetas.
- **Qué me dio:** explicación de `PageController`, de `routes` frente a `onGenerateRoute`, de `shared_preferences` y de `async`/`await`/`mounted`; revisión de `app.dart` y de `_finish`; valoración del patrón de «admins» del profesor.
- **Qué corregí o descarté, y por qué:**
  - Mi primer `_finish` no guardaba nada (variables locales que desaparecen). Lo pasé a una clase `PreferencesAdmin`, fuera de la pantalla, para que el splash lea lo mismo.
  - Mantengo `screens/` aunque los documentos decían `views/`, porque empecé el proyecto con `screens/` y quería tener todo igual.
  - La IA propuso dejar las preferencias en `services/`. Lo moví todo a `admins/`, incluido `AuthService`, porque lo pide el profesor y me parece más claro.
  - `DataHolder` y `FirebaseAdmin` no son obligatorios (confirmado el 16/10): trabajo con `FirestoreAdmin` y repositorios, por decisión mía.
- **Resultado:** `lib/admins/preferences_admin.dart`, `lib/app/app_routes.dart`, `lib/screens/onboarding/onboarding_screen.dart`.

---

### 003 · 2026-10-10 · Diseño visual del onboarding (cristal, fondo azul, fuente)
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** replicar el diseño del onboarding del lienzo con los colores del tema; luego un cristal «más natural» (luz en el borde, interior transparente), fondo azul y la tipografía igual que en el diseño.
- **Qué me dio:** explicación de `Theme`/`ThemeExtension`, `LinearGradient`, `Scaffold`/`SafeArea`, `AnimatedContainer`, `CustomPainter`; los widgets `GlassSurface` y `GlassButton`; diagnóstico del error de `google_fonts` y de un margen de 40 en vez de 24.
- **Qué corregí o descarté, y por qué:**
  - Pedí más naturalidad: la IA había puesto luz y reflejos dentro del cristal; pasé la luz al borde.
  - Elegí yo el fondo azul marino, aunque se sale de la paleta grafito.
  - `google_fonts` 9 daba error de tipos (`material_ui`): bajé a la 6.3.3 y descarté migrar todo el proyecto.
  - La IA propuso un `outlinedButtonTheme` para «Saltar»; no sabe desenfocar, así que lo sustituí por `GlassButton`.
- **Resultado:** `lib/widgets/glass_surface.dart`, `lib/widgets/glass_button.dart`, `lib/widgets/codo_background.dart`, `lib/app/app_theme.dart`, `lib/screens/onboarding/onboarding_screen.dart`.


### 004 · 2026-10-12 · Perfil en Firestore, modelos y repositorios
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** guardar el perfil al registrarme y mostrarlo en Home; después los modelos de pactos y medallas con sus repositorios. Pedí ir «paso a paso» y no copiar ficheros enteros.
- **Qué me dio:** explicación de `withConverter` (el traductor, no la orden de guardar), `Future`/`Stream`, `FutureBuilder` y sus estados, lectores seguros de campos, `Pact` con `progress`, `FirestoreAdmin`, los repositorios y pruebas de casos malos.
- **Qué corregí o descarté, y por qué:**
  - Mi primer `saveProfile` no escribía nada (faltaba `.set`), usaba otra colección (`"profiles"`) y `currentUser!`. Lo rehíce con `_col.doc(profile.uid).set(profile)`.
  - Para `Medal` copié `Pact` con sus campos; lo corregí y añadí yo `imageUrl` para las imágenes de la cuadrícula.
  - La IA propuso `displayName` = parte del correo antes de la `@`. Después lo cambiaremos en fases posteriores.
  - Dejé los datos de ejemplo sin subir y el commit para más adelante, para no precipitarme.
- **Resultado:** `lib/models/`, `lib/admins/firestore_admin.dart`, `lib/repositories/`, `lib/screens/home/home_screen.dart`, `test/field_readers_test.dart`.

### 005 · 2026-10-14 · Barra inferior, pactos, medallas y rutas con argumentos
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** la barra de navegación con las 5 secciones, la lista de pactos y la cuadrícula de medallas desde Firestore, y un detalle de pacto con rutas con nombre. Fuimos «paso a paso».
- **Qué me dio:** el esquema (barra «tonta» + estado en Home, `IndexedStack`, `StreamBuilder` con 4 estados, `GridView`), revisiones de mi código y el diseño de `onGenerateRoute` con una clase de argumentos.
- **Qué corregí o descarté, y por qué:**
  - Mi primera barra no compilaba (`setState` en un `StatelessWidget`, `BottomNavigationBar` con parámetros que no existen). La rehíce con `NavigationBar` y el estado en Home.
  - En `onTap` llamé a `pushNamed` en vez de pasar una función, y en `PactsScreen` añadí un parámetro `pacts` que sobraba. Ambos corregidos tras la revisión.
  - Unifiqué el nombre en `medal` (la colección sigue siendo `badges`, porque renombrarla exige tocar reglas y repetir el seed).
  - No amplié la fecha del «modo prueba» de las reglas de Firestore: añadí reglas con sesión iniciada.
  - Descarté `go_router` (dependencia no aprobada) y leer los argumentos con un cast.
  - Una vez pedí que la IA terminara por mí el final del `build` del Perfil (SizedBox y botón de cerrar sesión).
- **Resultado:** commits 6942884, b01f246, 7de54d5 y 8b08716; `lib/widgets/codo_nav_bar.dart`, `lib/screens/{home,pacts,profile}/`, `lib/app/app_routes.dart`.

### 006 · 2026-10-16 · Auditoría de la fase 1 y plan de entrega
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** Pedi que hiciéramos un seguimiento de lo que llevamos hecho en la app para reflejarlo en el pdf
- **Qué me dio:** me dio la estructura de las carpetas para guardar las capturas de assets/images/capturas
- **Qué corregí o descarté, y por qué:** nada
- **Resultado:** capturas en `assets/images/capturas/web` y `assets/images/capturas/android`, `flutter analyze` limpio, 16 pruebas en verde y reglas de Firestore comprobadas.

### 007 · 2026-10-16 · Primer uso de tres agentes
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** ejecutar `revisor-codo`, `auditor-rubrica` y `tester-codo` sobre el repositorio.
- **Qué me dio:**
  - El registro no es atómico y usa `currentUser!`.
  - Faltan pruebas de `AuthService`, `Pact.fromFirestore` y `PactsScreen`.
  - La cancelación de suscripciones es implícita (la hace `StreamBuilder`).
  - 35 commits en total.
  - La invitación del profesor estaba pendiente en ese momento.
- **Qué corregí o descarté, y por qué:** dije de usar algunos agentes para perfeccionar partes de la práctica y usamos 3 de los que tenemos.
- **Resultado:** tres agentes de `claude/agents` usados cada uno con su respuesta de su acción.

### 008 · 2026-10-28 · Inicio de la fase 1b y merge de la rama de UI
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** qué tenía de la fase 1 que sirviera para la 1b y qué faltaba, un plan por bloques y si fusionaba `feat/ui-fondos` ahora o más tarde.
- **Qué me dio:** una tabla de lo que había y lo que faltaba en cada bloque, un plan en 7 pasos empezando por los emuladores, y la recomendación de fusionar ya porque la rama toca las pantallas de la 1b. Al revisar el merge, avisó de que el conflicto de `ESTADO.md` se había resuelto con la versión antigua y había perdido la 1b, y de que `fase1b.md` y `hitos.md` no habían entrado en el commit.
- **Qué corregí o descarté, y por qué:** hice el merge yo antes de que me lo propusiera. Recuperé `ESTADO.md` de master y elegí qué versión de `IA.md` quedaba. [AITOR: ¿la de 7 entradas, por qué?]
- **Resultado:** `master` con la UI integrada y los documentos de la 1b en el repo (`74cf2c4`, `41d4cd1`, `01a0b43`).

### 009 · 2026-10-28 · Emuladores de Auth y Firestore con `--dart-define`
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** conectar los emuladores sin un booleano escrito a mano.
- **Qué me dio:** `firebase init`, `bool.fromEnvironment('USE_EMULATORS')`, el host `10.0.2.2` en Android y `localhost` en web, y `usesCleartextTraffic` solo en `src/debug`. Descartó el booleano a mano (lo prohíbe la rúbrica), `.env` y `network_security_config` (más ficheros para el mismo resultado).
- **Qué corregí o descarté, y por qué:**
  - El comando `firebase init firestore emulators` que me dio la IA fallaba, porque el CLI solo acepta una función por comando.
  - Borré las 13 skills de Firebase que instaló `init`, porque son de terceros y no tenían que ver con Codo.
  - La IA me corrigió a mí: puse la conexión después de `runApp` y la moví antes.
  - Localicé el puerto 8080 ocupado por un emulador anterior. En Android fallaba hasta que lo lancé con la bandera y recompilé.
- **Qué aprendí / puedo explicar:** `--dart-define` fija una constante al compilar. Los emuladores tienen que conectarse antes del primer uso de Auth o Firestore, y por eso van antes de `runApp`.
- **Resultado:** registro probado contra los emuladores en Chrome y en el emulador Android (`7aad081`, `fe564f0` y el commit del arreglo).

### 010 · 2026-10-29 · Inicio de sesión con Google (B1)
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** inicio de sesión con Google en web y Android con el perfil ligado, y entender para qué sirven las huellas SHA.
- **Qué me dio:** dos caminos según la plataforma (`signInWithPopup` en web y `google_sign_in` en Android), la cancelación como un caso propio sin aviso y un método para crear o recuperar el perfil. Descartó `google_sign_in` en web y `signInWithProvider` en Android.
- **Qué corregí o descarté, y por qué:**
  - Usé sus revisiones para ajustar la estructura del método y de la pantalla hasta que `flutter analyze` salió limpio.
  - En Android me faltaba el cliente OAuth en `google-services.json`; lo localicé con un mensaje de depuración y lo resolví volviendo a descargarlo. Descarté escribir el id del cliente en el código para no dejar configuración en el repo.
- **Qué aprendí / puedo explicar:** Google identifica la app Android por su firma (SHA) y la web por su dominio; el token de Google se convierte en credencial de Firebase.
- **Resultado:** Google funcionando en Chrome y en el emulador Android; README con SHA y OAuth (`f2a28ee`, `ea088a7`, `4e56c0e`).

### 011 · 2026-11-01 · Pantallas de las consultas: Ahora e Historial (B2)
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** mostrar en pantalla las 4 consultas de `live_sessions` y saber si necesitaba un repositorio nuevo para Ahora.
- **Qué me dio:** reutilizar `LiveSessionRepository` (un repositorio por colección, no por pantalla); Ahora con chips y `StreamBuilder`; una pantalla `HistoryScreen` con «Cargar más» y filtro por fechas, descartando meterla en Perfil o hacer dos pantallas.
- **Qué corregí o descarté, y por qué:**
  - Las rules pedían `provider`, pero ninguna pantalla lo usaba: lo quité de las rules y de `pubspec.yaml` por coherencia y para no ampliar el alcance.
  - Vi en el móvil que la barra de estado tapaba las pestañas; lo arreglé con un `SafeArea` en `HomeScreen` en vez de en cada pestaña.
  - Pregunté si podía trabajar solo en la nube; mantuve los emuladores porque la rúbrica se corrige con ellos.
  - La revisión encontró dos fallos míos en los chips (`_category == _category` y `category!` con «Recientes») y los corregí.
- **Qué aprendí / puedo explicar:** el stream se crea en `initState` y al cambiar de filtro, nunca en `build`. El historial usa `get` porque son datos pasados, y la lista la guarda el State porque cada página se añade a la anterior.
- **Resultado:** las 4 consultas visibles en pantalla con sus 4 estados; falta el README de snapshots/get.

### 012 · 2026-11-04 · Editar, terminar y borrar sesiones con reglas (B3)
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** editar y borrar mis sesiones, y que las reglas impidan tocar las de otros aunque la app no lo ofrezca.
- **Qué me dio:** me propuso las reglas `update` (solo el creador, solo ciertos campos con `affectedKeys`, con límites) y `delete` (solo el creador y sin participantes); `SessionFailure` con un `_guard` en el repositorio; y un menú ⋮ con diálogo de edición y confirmación de borrado. Para probar las reglas me propuso peticiones REST al emulador en vez de tests con `@firebase/rules-unit-testing` (Node y dependencias nuevas). 
- - **Qué corregí o descarté, y por qué:**
  - Hice B3 antes que el mapa para ir en orden de la rúbrica, aunque la IA proponía B5 primero.
  - En la prueba me salía un 500: el token de PowerShell estaba vacío, y en otra terminal faltaba `$doc`. Lo resolví comprobando `$token.Length` antes de cada petición.
- **Qué aprendí / puedo explicar:** `resource` es el documento guardado y `request.resource` cómo quedaría. El creador se comprueba en el guardado para que nadie se apropie de una sesión cambiando `creatorId`.
- **Resultado:** Ana edita su sesión (200); Leo recibe 403 al editar y al borrar; cambiar `creatorId` da 403.

### 013 · 2026-11-07 · Foto de prueba: cámara o galería, isolate y `proofs` (B4)
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** hacer o elegir una foto al terminar una sesión, comprimirla sin congelar la app y guardarla para que solo la vean los participantes.
- **Qué me dio:** me propuso `image_picker` + `image`, un `PhotoAdmin` que traduce los errores de permiso a `PhotoFailure`, la compresión con `Isolate.spawn` + `SendPort` para tener progreso (descartando `compute`, que solo devuelve el final), la subcolección `live_sessions/{id}/proofs/{uid}` con reglas de solo participantes, la miniatura con caché por sesión y una pantalla de detalle. También me propuso un test con una imagen de ruido puro.
- **Qué corregí o descarté, y por qué:**
  - Cambié la decisión de producto de «solo cámara»: la rúbrica pide cámara **y** galería.
  - Cuando la IA añadió las dependencias y el permiso por su cuenta, se lo hice deshacer: los añadí yo para poder defenderlos.
  - El test falló: con 800 px el ruido no bajaba de 300 KB ni a calidad 40. Se añadieron reintentos a 600 y 400 px.
- **Qué aprendí / puedo explicar:** un isolate no comparte memoria y solo habla por mensajes. Una imagen lisa habría pasado el test sin probar nada; el peor caso es el que encuentra el fallo.
- **Resultado:** 6 tests del compresor en verde; la prueba se guarda y se ve en la lista y en el detalle.

### 014 · 2026-11-07 · Pantalla de crear sesión y pruebas en la nube
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** poder probar B4 contra la nube, donde no había ninguna sesión.
- **Qué me dio:** primero me propuso crear 3 documentos a mano en la consola, porque subir el seed crearía cuentas reales con una contraseña que está en el repo. Para las reglas me propuso el Rules Playground en vez de REST.
- **Qué corregí o descarté, y por qué:**
  - Descarté los documentos a mano y pedí una pantalla mínima de crear sesión: hace falta igualmente y es la base de B5 (la ubicación se lee al publicar).
  - Hago las pruebas en la nube porque el profesor me confirmó en persona que no puntúa los emuladores; los dejo funcionando.
- **Qué aprendí / puedo explicar:** sin red, Firestore guarda la escritura y el `Future` no termina hasta que vuelve, así que hace falta un `.timeout` para que la pantalla no se quede colgada.
- **Resultado:** las sesiones se crean desde Ahora y aparecen al momento por el `snapshots()`.

### 015 · 2026-11-07 · Pruebas de B4 en Android y Chrome, y fallos encontrados
- **Fase / hito:** Fase 1b / H1.
- **Qué pedí:** guía paso a paso para probar B4 contra la nube (Rules Playground, Android y Chrome) y montar la tabla de pruebas.
- **Qué me dio:** me propuso las filas con su resultado esperado, cómo rellenar el Rules Playground, y los arreglos de lo que falló: la ruta inicial en `/`, el nombre del creador desde el perfil y un `.timeout` de 10 s al guardar la prueba sin red.
- **Qué corregí o descarté, y por qué:**
  - El fallo del botón atrás («Ruta no válida») lo encontré yo usando la app, no estaba en la lista de pruebas.
  - Al principio la A9 parecía no funcionar: no había hecho hot restart y la app seguía con el código anterior.
- **Qué aprendí / puedo explicar:** sin red, Firestore guarda la escritura en local y la enseña al momento (compensación de latencia), pero el `Future` no termina hasta que vuelve la red. En web no hay isolate y la compresión congela la pantalla.
- **Resultado:** 18 filas probadas en `docs/pruebas.md`; B4 cerrado.

### 016 · 2026-11-10 · Ubicación al publicar una sesión (B5)
- **Fase / hito:** Fase 1b.
- **Qué pedí:** cómo leer la posición con geolocator, tratar los fallos sin colgar la pantalla y guardarla como GeoPoint + Timestamp.
- **Qué me propuso:** un esqueleto de `LocationAdmin` con cláusulas de guarda, un `switch` con un mensaje por error, redondear a 2 decimales en `toFirestore` y la sección del README (GPS / red / combinado).
- **Qué corregí o descarté, y por qué:**
  - Mi primera versión metía los `throw` en un `try` cuyo `catch` convertía `deniedForever` en `denied`; me lo marcó la revisión y lo rehíce.
  - El esqueleto usaba parámetros de geolocator anteriores a la v14; `flutter analyze` lo detectó y pasé a `LocationSettings`.
  - Al probar en el emulador, varias sesiones salían en California: `LocationAccuracy.low` devolvía una posición vieja. Cambié a `medium` y uso `pos.timestamp` como `locationAt` para que diga cuándo se midió.
  - Elegí `COARSE` y no `FINE`: la posición se guarda redondeada y no hace falta más.

### 017 · 2026-11-10 · Mapa de sesiones con flutter_map (B6)
- **Fase / hito:** Fase 1b.
- **Qué pedí:** el mapa con OSM en pasos pequeños: base, marcadores y centrado en el usuario.
- **Qué me dio:** el `FlutterMap` con sus capas (teselas, marcadores, atribución); después me sugirió el `StreamBuilder` de sesiones públicas y un `MapController` para moverlo.
- **Qué corregí o descarté, y por qué:**
  - Puse los avisos de carga y error dentro de las capas del mapa en vez de en el `Stack`, y faltaba el `mapController:`; lo corregí tras la revisión.
  - Descarté Google Maps (clave y facturación) y el clustering de marcadores por tiempo: queda como límite conocido.
  - Pregunté por Blaze y protección contra bots: lo dejo para la fase 2–3; Spark corta al llegar a la cuota y no cobra.
- **Qué aprendí / puedo explicar:** `children` de `FlutterMap` es una pila de capas en orden de dibujo, y la posición exacta del usuario solo vive en el `State`, nunca en Firestore.

---

## Agentes y skills propios
| Nombre | Tipo | Creado | Qué tarea repetida resuelve | ¿Usado? | Trabajo ahorrado (medido) |
|---|---|---|---|---|---|
| `revisor-codo` | Agente | 05/10/2026 | Revisar los cambios antes de un commit y ordenar los hallazgos | Sí, 16/10/2026 (~1 min) | Por estimar |
| `auditor-rubrica` | Agente | 05/10/2026 | Comprobar el repositorio contra el checklist y la rúbrica de la fase | Sí, 16/10/2026 (~1 min) | Por estimar |
| `tester-codo` | Agente | 05/10/2026 | Proponer casos de prueba (también los malos) y ejecutar `analyze` y `test` | Sí, 16/10/2026 (~35 s; no pudo ejecutar Flutter) | Por estimar |
| `auditor-ui` | Agente | 05/10/2026 | Revisar pantallas contra la paleta, los 4 estados, claro/oscuro y accesibilidad | No, todavía | — |
| `tribunal-defensa` | Agente | 05/10/2026 | Simular las preguntas del tribunal sobre código real | No, todavía | — |
| `commits` | Skill | 05/10/2026 | Agrupar los cambios en commits pequeños y proponer los mensajes | No, todavía | — |
| `tabla-pruebas` | Skill | 05/10/2026 | Preparar la tabla de pruebas Android/web para el PDF | No, todavía | — |
| `bitacora-ia` | Skill | 05/10/2026 | Redactar las entradas de este fichero | No, todavía | — |
| `/cierre` | Comando | 05/10/2026 | Cerrar la sesión: actualizar `docs/ESTADO.md` y proponer la entrada de `IA.md` | No, todavía | — |

Los tres agentes usados se ejecutaron desde Claude con las instrucciones de `.claude/agents`. Los tiempos son aproximados. «Creado» es la fecha del commit que los añadió.
