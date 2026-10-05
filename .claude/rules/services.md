---
paths:
  - "lib/services/**/*.dart"
---
# Servicios

- Cada servicio envuelve **una** fuente externa (Firebase Auth, Firestore, FCM, la API propia…) y no sabe nada de pantallas.
- Dependencias inyectadas con valor por defecto, para probarlo con un falso: `Servicio({Dep? dep}) : _dep = dep ?? Dep.instance;` (como `AuthService`).
- Traduce las excepciones del SDK (`FirebaseAuthException`, `FirebaseException`…) a un fallo de dominio con enum: patrón `AuthFailure(AuthError)`. Nunca dejes escapar el código crudo ni redactes un mensaje para el usuario.
- Si lee o escribe Firestore, usa `withConverter` con el conversor del modelo: de aquí sale siempre un modelo, no un `Map`.
- Sin `BuildContext`, sin `Navigator`, sin importar `package:flutter/material.dart`.
- Ni claves ni URLs privadas en el código: vienen de configuración que no está en el repositorio.
