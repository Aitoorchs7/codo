---
paths:
  - "lib/app/**/*.dart"
  - "lib/main.dart"
---
# App: arranque, rutas y tema

- `main()` solo inicializa (Firebase…) y llama a `runApp`: sin lógica de negocio.
- Los `provider` se registran en un único `MultiProvider` por encima de `MaterialApp`, y se crean una sola vez.
- **Rutas con nombre** en un único sitio (`AppRoutes`, constantes `static const`): ninguna pantalla escribe `'/algo'` a mano. Se resuelven con `onGenerateRoute`.
- Los argumentos de una ruta son una clase tipada, no un `Map`; la ruta comprueba que llegan y que son del tipo esperado.
- Tema claro y oscuro definidos aquí (`ThemeData` y la extensión `CodoColors`); las pantallas solo los consumen.
