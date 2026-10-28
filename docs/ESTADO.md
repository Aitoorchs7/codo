# Estado — actualizado 28/10/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 16 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1: repo (`Aitoorchs7/codo`), tema claro/oscuro y cristal, splash, onboarding, acceso/registro (`AuthService`), `Profile`/`Pact`/`Medal` con `withConverter`, barra inferior, pactos, perfil con medallas, rutas con argumentos; 6 `pacts` y 6 `badges`; `docs/pruebas.md` (26 pruebas)
- Entorno agéntico: 5 agentes, 3 skills, `/cierre`, rules por capa (incl. `device.md` para cámara/mapa/isolates) y permisos
- 28/10: `feat/ui-fondos` fusionada en `master` (vídeo de login, fondo de puntos, WebP, paleta azul-negro, GlassButton)
- 28/10: `firebase init`: `.firebaserc`, `firestore.rules` (bajadas de la consola), `firestore.indexes.json` (vacío) y emuladores Auth 9099 / Firestore 8080 / UI 4000
- 28/10: `main.dart` conecta los emuladores con `--dart-define=USE_EMULATORS=true` (10.0.2.2 en Android, localhost en web) antes de `runApp`; cleartext solo en `src/debug`. Registro probado en Chrome y en emulador Android
- `flutter analyze` limpio y 16 pruebas en verde (28/10); 56 commits

## En curso
- Sin commit: `main.dart` (emuladores antes de `runApp`) y manifest de depuración (cleartext)
- B7 a medias: faltan datos de prueba exportados e importables con un comando, comandos en el README, Hosting y tabla de pruebas
- IA.md: entrada 008 (decisiones de la 1b) y 009 (emuladores) pendientes

## Siguiente
1. Commit del arreglo de emuladores y sección «Emuladores» en el README (cómo arrancar, puertos, bandera)
2. B1 · Google en Android y web, perfil creado o recuperado, cancelación/error y SHA/OAuth en el README
3. B2 · Modelo `live_sessions` + ≥20 documentos en el emulador, `emulators:export` al repo (cierra la parte de datos de B7)
4. B2/B3 · Cuatro consultas, índice compuesto, editar/borrar con confirmación y reglas
5. B4 · Foto: cámara/galería, isolate con progreso y base64 en `proofs` (2 puntos)
6. B5/B6 · Ubicación, mapa y «cerca de mí»; luego Hosting, tabla de pruebas y etiqueta `fase-1b`

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [ ] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [ ] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [ ] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores con `--dart-define` (hecho), datos exportados, Hosting con URL, tabla de pruebas (1,0)

## Decisiones pendientes
- ❓ Confirmar las decisiones de la 1b propuestas por la IA: ubicación aproximada (precisión), `proofs` en base64, `flutter_map`; qué pasa al borrar una sesión con participantes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` (en el README)
- `firestore.rules`: corregir el comentario «TEMPORAL» de `pacts`/`badges` en B3
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con la paleta azul-negro
- Fase 2: `AppLocalizations`, `pacts` con participantes y reglas, `Profile.copyWith`

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 16 días para 9,5 de 10 puntos y H1 el mismo día; B1 y B2 tienen que estar esta semana
