---
paths:
  - "lib/**/*location*.dart"
  - "lib/**/*photo*.dart"
  - "lib/**/*image*.dart"
  - "lib/**/*map*.dart"
  - "lib/**/*isolate*.dart"
---
# Cámara, ubicación, mapa e isolates (fase 1b)

Convención de nombres para que esta regla se cargue sola: `location_*`, `photo_*`/`image_*`, `*_map_*` y `*_isolate.dart`.

- **Permisos:** se piden en el momento de usarlos, con un texto que explique para qué. Declarados en cada plataforma (Android, iOS y web).
- **Denegación:** cámara y ubicación denegadas, GPS apagado y tiempo de espera agotado se tratan por separado, con un mensaje que diga qué hacer. Ninguno deja la pantalla colgada. El resultado llega como enum de dominio; el texto se decide en la pantalla.
- **Privacidad:** la posición que se guarda es aproximada (redondeada) y opcional, como `GeoPoint` + `Timestamp`. La posición exacta solo vive en el móvil para centrar el mapa y calcular distancias, y nunca se guarda en el perfil.
- **Foto:** compresión en un isolate (`compute` o `Isolate.run`) con progreso hacia la interfaz. Miniatura < 300 KB en base64 en el documento aparte `proofs` (límite de 1 MB por documento), nunca en el documento de la sesión.
- **Isolates:** solo para trabajo pesado y sin acceder a plugins ni a `context`. El README dice qué va en isolate y qué no, y por qué.
- **Mapa:** `flutter_map` sobre OpenStreetMap con atribución visible y `userAgentPackageName` puesto. Un marcador por sesión pública con ubicación; tocar un marcador abre el detalle.
- **Ciclo de vida:** cancela suscripciones (`Geolocator` streams) y controllers en `dispose` y comprueba `mounted` tras cada `await`.
