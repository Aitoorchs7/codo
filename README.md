<p align="center">
  <img src="assets/images/logo.png" alt="Logo de Codo" width="140"/>
</p>

<h1 align="center">Codo</h1>
<p align="center"><b>Cumple tus objetivos acompañado.</b><br/>
Hazlo ahora con quien está haciendo lo mismo, o comprométete con un amigo en un pacto.</p>

<p align="center">
Flutter · Firebase · Drift · Dart shelf · Supabase · Google Play
</p>

---

## 🎯 El problema
Las apps de organización se abandonan: apuntar tareas es fácil, pero cumplirlas solo cuesta. En compañía cuesta menos. Por eso estudiamos en biblioteca y quedamos para ir al gimnasio.

**Codo convierte tus objetivos en algo compartido.**

## ✨ Cómo funciona

### ⏱️ Ahora — haz tareas acompañado en directo
Publicas lo que vas a hacer y tus amigos se unen haciendo lo mismo. Ves en tiempo real quién está y cuánto le queda.

```mermaid
flowchart LR
    A[Publico: Estudiar 1 h] --> B[Mis amigos lo ven en directo]
    B --> C[Se unen y lo hacen también]
    C --> D[Al terminar: foto en el momento]
    D --> E[+XP y, si fue larga, medalla]
```

### 🤝 Pacto — un reto con alguien que no te deja tirar la toalla
Eliges un objetivo y una duración, y lo haces con un amigo o con alguien del tablón de pactos abiertos. Cada día los dos hacéis check-in con una prueba de avance, y el compañero la valida. **Si uno falla, pierden los dos.**

```mermaid
stateDiagram-v2
    [*] --> Propuesto: creo el pacto
    Propuesto --> Activo: el otro acepta
    Activo --> Activo: los dos hacen check-in
    Activo --> Activo: uno usa un comodín
    Activo --> Roto: alguien no hace check-in
    Activo --> Completado: se llega al final
    Completado --> [*]: XP + medalla para los dos
    Roto --> [*]: nadie gana XP
```

### 📱 Secciones
| Hoy | Ahora | Pactos | Amigos | Perfil |
|:---:|:---:|:---:|:---:|:---:|
| Tus objetivos del día, check-ins pendientes y quién está activo | Sesiones en directo de tus amigos | Tus pactos, invitaciones, tablón y plantillas | Ranking entre amigos y solicitudes | Nivel, medallas, ajustes y Codo Plus |
| _captura pendiente_ | _captura pendiente_ | _captura pendiente_ | _captura pendiente_ | _captura pendiente_ |

> **En la fase 1** están hechas **Pactos** (lista y detalle) y **Perfil** (medallas y cerrar sesión). Hoy, Ahora y Amigos ya tienen su sitio en la barra inferior, pero son pantallas vacías hasta las fases siguientes.

### 🏅 Progreso
- **XP → niveles** con nombre propio.
- **Medallas** por objetivos cumplidos: pactos completados, sesiones largas…
- El ranking es **entre amigos** y los puntos **no se compran**. Así hacer trampa no tiene premio.

### 💎 Codo Plus y comodines
| Producto | Tipo | Qué da |
|---|---|---|
| Comodín | Consumible | Saltarte un día de check-in sin romper el pacto |
| Codo Plus | Pago único | Sin anuncios, pactos ilimitados y estadísticas |

---

## 🏗️ Arquitectura

```mermaid
flowchart TB
    UI[Pantallas y widgets] --> R[Repositorios]
    R --> L[(Drift · local, offline)]
    R --> S[Admins]
    S --> FB[Firebase: Auth · Firestore · FCM · Remote Config]
    S --> API[Servicio propio Dart shelf · REST + WebSocket]
    API --> SQL[(Supabase · compras, XP, catálogo)]
    API --> GP[Google Play Developer API]
```

### Estructura de carpetas y por qué está dividida así
```
lib/
├── app/           # MaterialApp, rutas con nombre, tema
├── l10n/          # Textos ES/EN
├── models/        # Clases de dominio y sus conversores
├── admins/        # Hablan con fuentes externas: Firebase, almacenamiento, preferencias del móvil, API, Billing…
├── repositories/  # Única puerta de datos para la UI
├── screens/       # Las pantallas, una carpeta por sección o flujo
├── widgets/       # Piezas reutilizables
└── utils/         # Funciones sueltas sin pantalla (p. ej. a qué ruta ir al arrancar) y datos de ejemplo
```
Cada capa tiene una única responsabilidad. **Las pantallas no saben de dónde vienen los datos**: se los pide al repositorio, que decide si los lee de la base de datos local o de la nube. Así puedo cambiar Firestore por otra fuente, o probar la lógica con una base de datos en memoria, sin tocar la interfaz. Los **modelos** están separados para que la app trabaje con objetos tipados y no con mapas sueltos.

### Navegación y pantallas
- El onboarding solo sale la primera vez: «visto» se guarda con `shared_preferences` (clave `onboarding_seen`) en `PreferencesAdmin`, y el splash lo lee y decide el destino con `startupRoute()`.
- `HomeScreen` es la carcasa de la app: una barra inferior (`CodoNavBar`, el `NavigationBar` de Material 3) y un `IndexedStack` con las 5 secciones, que conserva el estado de cada una al cambiar de pestaña.
- Las rutas con nombre están en un único sitio (`AppRoutes`) y se resuelven con `onGenerateRoute`. Los argumentos viajan en una clase tipada (`PactDetailArgs`); si llegan mal o la ruta no existe, se muestra una pantalla de error en vez de romper.
- Toda pantalla que pide datos pinta cuatro casos: cargando, vacío, error con «Reintentar» y datos (por ejemplo `PactsScreen` y `MedalGrid`). Las listas escuchan un `Stream` del repositorio con `StreamBuilder`, que cancela la suscripción al cerrar la pantalla.

### Datos en Firestore
Un único admin (`FirestoreAdmin`) conoce Firestore y entrega cada colección con su conversor (`withConverter`), de modo que de ahí salen siempre modelos y nunca mapas. Los modelos leen cada campo con funciones seguras (`field_readers.dart`): si un dato falta o tiene otro tipo, usan un valor por defecto en vez de romper la pantalla.

| Colección | Documento | Campos | Modelo |
|---|---|---|---|
| `users` | id = `uid` de la cuenta (se crea al registrarse) | `displayName`, `xp`, `badges`, `createdAt`, `photoUrl?`, `bio?` | `Profile` |
| `pacts` | un pacto | `title`, `partnerName`, `daysDone`, `daysTotal`, `createdAt` | `Pact` |
| `badges` | una medalla del catálogo | `name`, `description`, `xpReward`, `imageUrl` | `Medal` |
| `live_sessions` | una sesión de «Ahora» | `creatorId`, `creatorName`, `category`, `description`, `visibility`, `startedAt`, `durationMinutes`, `status`, `participantIds`, `location?` (`GeoPoint`), `locationAt?`, `endedAt?` | `LiveSession` |
| `live_sessions/{id}/proofs` | id = `uid` del participante (una prueba por persona y sesión) | `image` (JPEG en base64, < 300 KB), `createdAt` | `Proof` |

En el código el concepto se llama **medalla** (`Medal`, `MedalRepository`, `Profile.medals`), pero la colección y la clave del perfil se guardan como `badges`: el conversor del modelo es el único sitio que conoce ese nombre.

**Reglas de Firestore:** están en [`firestore.rules`](firestore.rules), que carga el emulador y se despliega con `firebase deploy --only firestore:rules`. Resumen:

| Ruta | Leer | Crear | Editar | Borrar |
|---|---|---|---|---|
| `users/{uid}` | solo el dueño | solo el dueño | solo el dueño | solo el dueño |
| `pacts`, `badges` | cualquier usuario con sesión (temporal, para el seed) | — | — | — |
| `live_sessions/{id}` | cualquier usuario con sesión | solo a tu nombre (`creatorId`) | solo el creador; solo `description` (≤ 140 car.), `durationMinutes` (1–480), `status` y `endedAt` | solo el creador y si nadie más se ha unido |
| `live_sessions/{id}/proofs/{uid}` | solo los participantes de la sesión | solo la tuya, siendo participante; solo `image` (< 300 KB) y `createdAt` (hora del servidor) | igual que crear | solo la tuya |

Las reglas se probaron por REST contra el emulador: Ana edita su sesión (200); Leo intenta editarla, borrarla o cambiarle el `creatorId` y recibe 403.
### Consultas: escuchar o leer una vez
Las sesiones (`live_sessions`) se consultan de cuatro maneras, todas en `LiveSessionRepository`:

| Consulta | Pantalla | Cómo se pide | Modo |
|---|---|---|---|
| `where` con dos condiciones: públicas de una categoría | Ahora (chip de categoría) | `category ==` y `visibility ==`, ordenadas por `startedAt` | `snapshots` |
| `orderBy` + `limit`: las 10 públicas más recientes | Ahora (chip «Recientes») | `visibility ==`, `orderBy startedAt` y `limit(10)` | `snapshots` |
| Rango sobre una fecha: mi historial entre dos días | Perfil → Mi historial (calendario) | `creatorId ==`, `startedAt >=` y `startedAt <` | `get` |
| Paginación: mi historial de 4 en 4 | Perfil → Mi historial («Cargar más») | `startAfterDocument` del último documento leído | `get` |

**Por qué cada una:**
- **Ahora escucha (`snapshots`)**: son sesiones en directo. Mientras miras la lista alguien empieza o termina una tarea, y la lista tiene que cambiar sola sin recargar. El stream se abre al entrar y al cambiar de chip, nunca en cada `build`, para no abrir una consulta nueva en cada repintado.
- **El historial lee una vez (`get`)**: son sesiones terminadas que ya no cambian. Escucharlas gastaría lecturas y batería para nada. Además, la paginación encaja con `get`: cada página se pide solo cuando el usuario pulsa «Cargar más».

**Índices compuestos:** las consultas que combinan un `where` con un `orderBy` sobre otro campo necesitan índice. Los tres están declarados en `firestore.indexes.json` (no creados a mano en la consola) y se despliegan con `firebase deploy --only firestore:indexes`. El emulador no los exige, pero el Firestore real sí.

### Fotos de prueba
Al terminar una sesión se puede añadir una foto como prueba (Perfil → Mi historial → ⋮ → «Añadir prueba»), hecha con la cámara o elegida de la galería.

**Flujo:** `PhotoAdmin` abre la cámara o la galería (`image_picker`) → `PhotoCompressor` la reduce en un isolate mientras la pantalla muestra una barra de progreso → vista previa con el peso antes y después → `LiveSessionRepository.saveProof` la guarda en base64 en `live_sessions/{id}/proofs/{uid}`. El Historial enseña una miniatura en cada fila y, al tocarla, la pantalla de detalle muestra la foto en grande.

**Por qué se comprime antes de guardar:**
- Firestore no admite documentos de más de **1 MiB** (1.048.576 bytes). Una foto de cámara de un móvil actual ocupa entre 2 y 5 MB: ni siquiera cabe.
- El base64 ocupa **4/3** de los bytes originales (cada 3 bytes se escriben como 4 caracteres). Por eso el límite de 300 KB se mide sobre el texto base64 y no sobre el JPEG: deja margen de sobra hasta el 1 MiB.
- Cada vez que alguien lee el documento se descarga entera. Cuanto más pequeña, menos datos móviles y menos espera.
- Ejemplo medido en el emulador: foto de cámara **[rellenar: X KB → Y KB]**; foto de galería **[rellenar: X KB → Y KB]**.

**Cómo se comprime (`lib/utils/photo_compressor.dart`):** se decodifica la imagen con el paquete `image`, se endereza según su EXIF (las fotos de cámara vienen giradas), se reduce para que el lado mayor mida como mucho 800 px y se codifica en JPEG probando calidades 85, 70, 55 y 40 hasta que el base64 baja de 300 KB. Si ni con calidad 40 lo consigue, repite con 600 px y después con 400 px; solo si tampoco así baja, la pantalla avisa de que pruebe con otra foto. La prueba `test/photo_compressor_test.dart` lo comprueba con el peor caso para JPEG, una imagen de ruido puro: con 800 px se queda en 404 KB incluso a calidad 40, y la compresión la deja en 600 px y unos 295 KB.

**Por qué en un isolate y con `Isolate.spawn`:** decodificar y recomprimir una foto de 12 megapíxeles tarda lo bastante como para congelar la interfaz si se hace en el hilo principal. El isolate tiene su propia memoria y se comunica solo por mensajes: recibe los bytes y un `SendPort`, y envía números (`0.3`, `0.5`…) para el progreso y al final el JPEG. `compute` o `Isolate.run` serían más cortos, pero solo devuelven el resultado al final, sin mensajes intermedios para la barra.

**En el navegador no hay isolates reales:** en web, Dart no puede crear hilos con memoria propia, así que la compresión se hace en el hilo principal (`kIsWeb`) y la barra solo avanza a saltos. La lógica es la misma función (`compressSync`), que además se puede probar sin isolate.

**Por qué en `proofs` y no en el documento de la sesión:** el documento de la sesión lo lee todo el mundo en «Ahora»; si llevara la foto, cada fila de esa lista descargaría hasta 300 KB. En una subcolección aparte solo se descarga cuando hace falta verla, y las reglas pueden decidir quién la lee: **solo los participantes**, mientras que la sesión es pública.

**Permisos y denegación:**
- Android: `CAMERA` en `AndroidManifest.xml`. La galería usa el selector de fotos del sistema y no necesita permiso.
- iOS: `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription` en `ios/Runner/Info.plist`.
- Navegador: `image_picker` abre el selector de archivos; en el móvil ofrece también la cámara.
- Si se deniega el permiso, el SnackBar dice qué hacer: «Actívalo en Ajustes > Aplicaciones > Codo > Permisos, o elige una foto de la galería». Tras dos negativas Android ya no vuelve a preguntar, así que Ajustes es la única salida.

**Costes y límites conocidos:**
- Cada página del Historial hace 4 lecturas más, una por miniatura, y la regla de `proofs` hace otra (`get` de la sesión para comprobar los participantes). Con páginas de 4 es asumible.
- Borrar un documento en Firestore no borra sus subcolecciones: `deleteSession` borra primero la prueba y después la sesión. No son atómicas; cuando en la fase 2 la gente pueda unirse a sesiones se cambiará a un `WriteBatch`.

---

## 🚀 Guía de arranque (en un equipo limpio)

### Requisitos
- Flutter SDK estable (Dart ^3.13). Compruébalo con `flutter doctor`.
- Android Studio con un emulador Android (API 34 o superior) o un móvil con depuración USB.
- Google Chrome (para la versión web).

### Pasos
```bash
git clone https://github.com/Aitoorchs7/codo.git
cd codo
flutter pub get
```

### Configuración de Firebase
La app necesita dos ficheros que **no están en el repositorio** (ver la tabla de abajo): `android/app/google-services.json` y `lib/firebase_options.dart`. Hay dos maneras de tenerlos:

**A. Usar el proyecto de Firebase de Codo (recomendada para corregir).** El autor entrega los dos ficheros por separado. Cópialos en sus rutas y la app se conecta al proyecto de Codo, que ya tiene los datos de ejemplo (6 pactos y 6 medallas).

**B. Usar tu propio proyecto de Firebase.**
1. En la [consola de Firebase](https://console.firebase.google.com) crea un proyecto.
2. **Authentication** → Método de acceso → activa **Correo electrónico/contraseña**.
3. **Firestore Database** → crea la base de datos y pega las reglas de la sección «Datos en Firestore».
4. Instala la CLI de Firebase y FlutterFire, inicia sesión y configura el proyecto desde la carpeta del repositorio. Esto genera los dos ficheros:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Sube los datos de ejemplo con `seedSampleData()` (`lib/utils/example_data.dart`). Es seguro repetirlo: usa ids fijos y no duplica. Mientras lo haces, las reglas deben permitir `write` en `pacts` y `badges`; vuelve a dejarlas solo en lectura al terminar.
### Inicio de sesión con Google
- **Web:** usa la ventana emergente de Firebase (`signInWithPopup`). Solo necesita que el dominio esté en *Authentication → Settings → Dominios autorizados* (`localhost` y el de Hosting vienen por defecto).
- **Android:** usa `google_sign_in`, que muestra el selector de cuentas del móvil. Google solo acepta la petición si la app está firmada con una clave registrada, así que hay que añadir sus **huellas SHA-1 y SHA-256**:
  ```bash
  keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
  
### Ejecutar
```bash
flutter run              # emulador o móvil Android
flutter run -d chrome    # navegador
flutter test             # pruebas
```
**Primer arranque:** en la pantalla de acceso, regístrate con un correo y una contraseña. Se crea tu perfil en `users/{uid}` y entras en la app.

### Ficheros que NO están en el repositorio (y por qué)
| Fichero | Para qué sirve | Por qué no se sube |
|---|---|---|
| `android/app/google-services.json` | Conectar Android con Firebase | Identifica el proyecto de Firebase; se mantiene fuera por seguridad |
| `lib/firebase_options.dart` | Datos del proyecto Firebase para todas las plataformas (lo genera `flutterfire configure`) | Identifica el proyecto de Firebase; se mantiene fuera por seguridad |
| `android/key.properties`, `*.jks` | Firmar el .aab de release | Quien tenga la clave podría publicar versiones en mi nombre |
| `.env` | URLs y claves del servicio propio | Son credenciales |

---

## 🧪 Pruebas
**Automáticas** (16 pruebas con `flutter test`, sin Firebase real): ruta de arranque según sesión y onboarding, preferencias con valor corrupto, un mensaje por cada error de acceso, lectores seguros de campos y progreso de un pacto con datos extremos.

**Manuales** en Android y web. Registro completo (26 pruebas, 14/10/2026) en [`docs/pruebas.md`](docs/pruebas.md). Resumen:

| Qué se probó | Esperado | Resultado Android | Resultado web |
|---|---|---|---|
| Splash con imagen y con URL rota | Imagen o estado de error, y sigue navegando | Correcto | Correcto (más rápido) |
| Onboarding: primera vez, no se repite, «Saltar» | 3 páginas solo la primera vez | Correcto | Correcto |
| Registro: correo usado, contraseña débil, correo inválido | Un mensaje concreto por error | Correcto | Correcto |
| Acceso, sesión persistente y cerrar sesión | Entra, conserva la sesión y «atrás» no vuelve a Home | Correcto | Correcto |
| Barra inferior | Cambia de sección y conserva el estado | Correcto | Correcto |
| Pactos y medallas: datos, vacío, error, imagen rota | 4 estados sin romper | Correcto (la carga no llega a verse, va muy rápido) | Correcto |
| Detalle de pacto | Abre el pacto correcto y vuelve | Correcto | Correcto |
| Tema claro/oscuro, letra grande, ancho de ventana | Todo legible, sin desbordes | Correcto | Correcto |

**Diferencias:** tras cerrar sesión, Android muestra dos avisos `PERMISSION_DENIED` en el log y el navegador ninguno (no se ven en pantalla; ver hallazgo 1 de `docs/pruebas.md`). «Atrás» sale de la app en Android y no hace nada en web.

## 🤖 Trabajo con IA
Este proyecto se desarrolla con asistentes de IA, de forma documentada:
- [`CLAUDE.md`](CLAUDE.md): arquitectura, normas y lo que el agente no debe tocar.
- [`.claude/`](.claude): agentes, skills y comandos propios.
- [`IA.md`](IA.md): bitácora de qué pedí, qué me dio y qué corregí.

## 🗺️ Estado del proyecto
- [X] **Fase 1** · Arranque: splash, onboarding, cuenta, Firestore, navegación (18/10/2026). Hecho: splash, onboarding, acceso, Firestore, barra inferior, pactos, medallas y rutas con argumentos. Pruebas Android/web hechas. Falta: PDF de entrega y envío
- [ ] **Fase 2** · Datos que duran: Drift, sincronización, copias (04/12/2026)
- [ ] **Fase 3** · Servicio: API, WebSocket, notificaciones, validación de compras (29/01/2027)
- [ ] **Fase 4** · Cobrar y publicar: Billing, AdMob, seguridad, Google Play (19/02/2027)

---
<p align="center">Proyecto integrado de 2.º DAM · IES Newton-Salas · 2026/27 · Aitor</p>
