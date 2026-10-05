---
paths:
  - "lib/views/**/*.dart"
  - "lib/widgets/**/*.dart"
---
# Vistas (pantallas) y widgets

- **Nombres:** una carpeta por sección o flujo (`lib/views/pacts/`), fichero en `snake_case` acabado en `_view` (`pact_detail_view.dart`) y clase `PactDetailView`. Las piezas reutilizables entre varias vistas van en `lib/widgets/`.
- **Capas:** ningún widget llama a `FirebaseAuth.instance`, `FirebaseFirestore.instance` ni a Drift. Los datos se piden al repositorio (o al servicio) inyectado con `provider` y se escucha su `Stream`.
- **Estados:** toda vista que pide datos pinta cuatro casos: cargando, vacío, error (con botón Reintentar) y datos. Trata `waiting`, `hasError` y lista vacía por separado.
- **Errores:** llegan como enum de dominio (`AuthError`…). El texto para el usuario se decide aquí, nunca en servicios ni repositorios.
- **Textos:** con `AppLocalizations` (ES/EN), no como literales en español.
- **Tema:** colores y tamaños de letra salen del tema (`Theme.of(context)` y `CodoColors` cuando exista); nada de `Color(0x…)`, `Colors.xxx` ni `fontSize` a mano, para que sirva en claro y oscuro.
- **Accesibilidad:** objetivos táctiles ≥ 48 dp, `Semantics` o `tooltip` en iconos sin texto, el estado nunca solo por color y sin alturas fijas con texto dentro (usa `Flexible`/`Expanded`) para que la letra grande no se corte.
- **Ciclo de vida:** cancela en `dispose` lo que abras (`StreamSubscription`, controllers). Tras un `await`, comprueba `mounted` antes de usar `context` o `setState`.
- **`provider`:** en `build` usa `context.watch` o `Consumer`; en callbacks (`onPressed`) usa `context.read`.
