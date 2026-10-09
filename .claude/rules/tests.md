---
paths:
  - "test/**/*.dart"
---
# Pruebas

- Nunca desactives, comentes ni borres una prueba para que pase: se arregla el código o se explica en el commit por qué cambia la prueba.
- Cada funcionalidad lleva al menos un caso malo: sin red, dato que falta o corrupto, credenciales incorrectas, doble toque.
- Nada de red ni Firebase real: se inyecta un falso (los admins reciben sus dependencias por constructor). Si hace falta un paquete de falsos, se propone antes de añadirlo.
- Nombre de la prueba = qué hace y qué espera, en inglés como el resto del código.
- Cada prueba debe poder fallar por un error en el código: no pruebes que «el framework funciona».
- `flutter analyze` y `flutter test` limpios antes de cada commit.
