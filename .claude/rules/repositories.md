---
paths:
  - "lib/repositories/**/*.dart"
---
# Repositorios

- Son la **única puerta de datos** de la UI: devuelven modelos de `models/`, nunca `DocumentSnapshot`, `Map` ni tipos del SDK.
- Exponen `Stream<T>` para lo que cambia y `Future<T>` para acciones puntuales.
- Eligen la fuente (Drift en local o servicio remoto); la pantalla no lo sabe. En la fase 1 solo hay remoto.
- Reciben sus servicios por constructor, con parámetro opcional para poder probarlos con un falso (como `AuthService`).
- Si abren una suscripción propia, la cancelan en un método `dispose`/`close`.
- No importan `package:flutter/material.dart` ni usan `BuildContext`.
- Los errores salen como fallos de dominio (`AuthFailure`…), nunca como texto.
