# CLAUDE.md — Codo

App Flutter, proyecto integrado de 2.º DAM (autor: Aitor). Motiva a cumplir objetivos **acompañado**:
- **Ahora**: publicas la tarea que estás haciendo y tus amigos se unen; al terminar, foto como prueba.
- **Pacto** (principal): reto entre dos personas con check-in diario validado por el compañero. Si uno falla, pierden los dos.
- Secciones: Hoy · Ahora · Pactos · Amigos · Perfil. XP → niveles; medallas. Cobros: Comodín (consumible) y Codo Plus (pago único).

## Estado actual del proyecto
@docs/ESTADO.md

## Documentos de consulta (léelos solo si la tarea los necesita)
- `docs/decisiones_producto.md`: mecánicas, modelo de datos, cobros y alcance. Úsalo ante dudas de producto.
- `docs/requisitos.md`: checklist obligatorio del proyecto. Úsalo para comprobar qué falta.
- `README.md`, `IA.md`: no hace falta leerlos para programar.

## Cómo trabajamos
- **Aitor escribe el código.** Tú revisas, explicas y propones el **cambio mínimo**. Código completo solo si lo pide, y explicado. En la defensa tiene que explicar cada línea sin IA.
- Si hay alternativas, nombra la descartada y el motivo.
- Revisiones, en este orden: bugs y seguridad → rúbrica → arquitectura → ideas.
- **No hagas commit ni push**: propón el mensaje (`tipo(ámbito): qué`, en español; tipos `feat|fix|refactor|test|docs|chore`).
- Avisa si algo pone en riesgo un hito o amplía el alcance.
- Español al hablar; código en inglés y comentarios en español.

## Ahorra contexto
- Respuestas breves y al grano; sin repetir código que no cambia (indica fichero y línea).
- Busca con Grep/Glob antes de abrir ficheros; lee solo el fragmento necesario.
- Para explorar mucho código, usa un subagente y quédate con la conclusión.
- No releas documentos que ya están en la conversación.

## Arquitectura
`view → repository → (Drift local | admin remoto)`. Las vistas (pantallas) escuchan streams del repositorio y nunca acceden a datos directamente.
```
lib/ app/ (MaterialApp, rutas, tema) · l10n/ · models/ · admins/ · repositories/ · screens/<sección>/ · widgets/ · utils/
test/ · server/ (fase 3, Dart shelf) · docs/
```
Stack: Firebase (Auth, Firestore `withConverter`, FCM, Remote Config, Crashlytics, App Check) · Drift · isolates · Dart shelf + WebSocket en Cloud Run · Supabase · Play Billing · AdMob + UMP.
Las normas detalladas de cada capa están en `.claude/rules/` y se cargan solas al tocar esos ficheros.

## No tocar
- Secretos: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, `key.properties`, `*.jks`, `.env*`. Si hacen falta, que los gestione Aitor.
- `signingConfigs` y `applicationId` en `android/app/build.gradle.kts`.
- Generados (`*.g.dart`, `GeneratedPluginRegistrant*`) y las carpetas `ios/ macos/ linux/ windows/`.
- No ejecutes `flutter upgrade`, no añadas dependencias sin proponerlo y no desactives pruebas.

## Comandos
`flutter pub get` · `flutter run` · `flutter run -d chrome` · `flutter analyze` (limpio antes de cada commit) · `flutter test` · `dart run build_runner build -d` (Drift) · `flutter build appbundle --release`

## Al terminar una sesión
Recuerda a Aitor que ejecute `/cierre` para actualizar `docs/ESTADO.md` y preparar la entrada de `IA.md`.
