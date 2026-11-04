# Estado — actualizado 04/11/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 9 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; `feat/ui-fondos` fusionada (28/10); entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- Emuladores Auth 9099 / Firestore 8080 / UI 4000 con `--dart-define=USE_EMULATORS=true`, conectados antes de `runApp`; cleartext solo en `src/debug`
- B1: Google en web y Android, cancelación sin aviso, `getOrCreateProfile`, README con SHA y cliente OAuth
- B2: seed de 24 sesiones, 4 consultas en `LiveSessionRepository`, 3 índices; Ahora (chips + `StreamBuilder`) e Historial (paginación + rango); README con tabla de consultas y snapshots/get
- B3: `updateSession`/`finishSession`/`deleteSession` con `SessionFailure`; menú ⋮ en el Historial, `EditSessionDialog` validado, confirmación al borrar y SnackBar de error
- B3: reglas `update` (solo creador, `affectedKeys` y límites 140 car./480 min) y `delete` (solo creador y sin participantes); probado por REST: Ana 200, Leo 403 al editar y borrar, cambiar `creatorId` 403 (04/11)
- `SafeArea` en `HomeScreen`; `provider` retirado (cada pantalla crea su repositorio en su `State`)
- `flutter analyze` limpio y 16 pruebas en verde (04/11); 75 commits

## En curso
- README: el bloque de reglas copiado está desfasado (sin `update`/`delete`); sustituir por un resumen que remita a `firestore.rules`
- Capturas del 403 y de la pestaña Requests del emulador para la tabla de pruebas
- Pruebas de `readOptionalDate` y `readEnum` sin escribir; IA.md entrada 012 (B3) pendiente

## Siguiente
1. B4 · Proponer dependencias (`image_picker`, `image`), permisos Android/web y denegación con mensaje
2. B4 · Compresión en isolate con progreso (`Isolate.spawn` + `SendPort`), base64 <300 KB en `proofs`, verla en lista y detalle, README del límite de 1 MB
3. B5 · `geolocator` con sus 3 errores, `GeoPoint` + `Timestamp` y comparación de tecnologías en el README
4. B6 · Mapa `flutter_map` + OSM centrado en el usuario y «cerca de mí» en isolate
5. B7 · README de emuladores, Hosting con URL, tabla de pruebas (permisos denegados, sin conexión), etiqueta `fase-1b` y PDF
6. H1 · Documentación de arquitectura y alcance

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [x] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [x] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores (hecho) y datos exportados (hecho); faltan comandos en el README, Hosting con URL y tabla de pruebas (1,0)

## Decisiones pendientes
- Nube vs emuladores: se puede desarrollar en la nube (plan Spark), pero se corrige con emuladores (`fase1b.md` l. 74); confirmar con el profesor lo del plan Blaze
- B4: en web no hay isolates reales (`compute` corre en el hilo principal); explicarlo en el README
- `pacts` y `badges` no están en `emulator-data/`; comentario «TEMPORAL» de sus reglas sin corregir
- Precisión de la ubicación (seed: 2 decimales, ~1 km) y visibilidad `friends` en reglas (aún sin `friendships`)
- Unirse a sesiones (fase 2) obligará a ampliar la regla `update` para `participantIds`
- `firebase deploy --only firestore:indexes,firestore:rules` (lo ejecuta Aitor); textos como literales, sin `l10n`

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 9 días para 6 de 10 puntos (B4–B6 = 5 puntos sin empezar, B7 a medias) y H1 el mismo día
