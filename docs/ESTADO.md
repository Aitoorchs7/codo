# Estado — actualizado 29/10/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 15 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; `feat/ui-fondos` fusionada (28/10); entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- Emuladores Auth 9099 / Firestore 8080 / UI 4000 con `--dart-define=USE_EMULATORS=true`, conectados antes de `runApp`; cleartext solo en `src/debug`
- B1: Google en web (`signInWithPopup`) y Android (`google_sign_in` 7), cancelación como `AuthError.cancelled` sin aviso, `getOrCreateProfile`, README con SHA y cliente OAuth
- B2: modelo `LiveSession` (enums por `.name`, ubicación como 2 `double` + `GeoPoint` en Firestore), getter y regla de `create` propia
- Seed con `--dart-define=SEED_DATA=true`: 4 usuarios `*@codo.test` y 24 sesiones (18 con ubicación); exportado en `emulator-data/`
- `LiveSessionRepository` con las 4 consultas (2 `snapshots`, 2 `get`, paginación de 4 con `startAfterDocument`) y 3 índices en `firestore.indexes.json`
- `flutter analyze` limpio y 16 pruebas en verde (29/10); 69 commits

## En curso
- B2: falta mostrar cada consulta en pantalla (Ahora: filtro por categoría y recientes; Perfil: historial por fechas y «Cargar más») y el README snapshots/get
- Pruebas de `readOptionalDate` y `readEnum` sin escribir
- IA.md: entradas 010 (Google) y 011 (sesiones y consultas) pendientes

## Siguiente
1. B2 · Pantallas de las 4 consultas con sus 4 estados y README de snapshots/get
2. B3 · Editar descripción y duración, terminar sesión, el `delete` (sesión vacía o `proofs` propio), reglas de `update`/`delete` y prueba con dos usuarios
3. B4 · Foto: cámara/galería, isolate con progreso y base64 en `proofs` (2 puntos)
4. B5 · `geolocator` con sus 3 errores, posición redondeada y comparación en el README
5. B6 · Mapa `flutter_map` + OSM y «cerca de mí» en isolate
6. B7 · README de emuladores, Hosting con URL, tabla de pruebas y etiqueta `fase-1b`

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [ ] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75) (faltan pantallas y README)
- [ ] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores (hecho) y datos exportados (hecho); faltan comandos en el README, Hosting con URL y tabla de pruebas (1,0)

## Decisiones pendientes
- B3: qué se borra con `delete` si una sesión con participantes no se borra (decidido 29/10: el creador la termina): sesión propia vacía o `proofs` propio
- `pacts` y `badges` no están en `emulator-data/` (Pactos y Perfil vacíos en local)
- Precisión de la ubicación (seed: 2 decimales, ~1 km) y visibilidad `friends` en reglas (aún sin `friendships`)
- `firebase deploy --only firestore:indexes,firestore:rules` (lo ejecuta Aitor) y `firebase_options.dart`/`google-services.json` entregados aparte
- `firestore.rules`: corregir el comentario «TEMPORAL» de `pacts`/`badges`; paleta en `docs/CODO_PALETA_COLORES.md`

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 15 días para 7 de 10 puntos (B4–B6 = 5 puntos sin empezar) y H1 el mismo día
