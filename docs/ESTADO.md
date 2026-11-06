# Estado — actualizado 07/11/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 6 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- Emuladores Auth/Firestore con `--dart-define=USE_EMULATORS=true` y datos exportados; B1 (Google), B2 (4 consultas, índices) y B3 (editar/borrar con reglas, probado por REST) cerrados
- B4: `PhotoAdmin` (cámara/galería, `PhotoFailure` con mensaje que dice qué hacer), permiso `CAMERA` y claves de iOS en `Info.plist`
- B4: `PhotoCompressor` en isolate (`Isolate.spawn` + `SendPort`) con barra de progreso; 800→600→400 px y calidades 85–40 hasta base64 <300 KB; en web, en el hilo principal
- B4: modelo `Proof` en `live_sessions/{id}/proofs/{uid}`; reglas: leen solo participantes, cada uno escribe la suya (<300 KB, `createdAt` del servidor); `deleteSession` borra antes la prueba
- B4: miniatura con caché por sesión en el Historial y `SessionDetailScreen` (4 estados, permiso denegado sin «Reintentar»)
- B4: README «Fotos de prueba» (1 MiB, 4/3 del base64, isolate, web, permisos, costes) y bloque de reglas sustituido por tabla resumen
- `CreateSessionScreen` (validada, `.timeout` sin red) con botón en Ahora; regla `create` estricta; `sessionDetail` con ruta con nombre y `SessionDetailArgs`
- `flutter analyze` limpio y 22 pruebas en verde (07/11); 88 commits

## En curso
- Pruebas de B4 contra la nube: Rules Playground (ajeno denegado / propio permitido), Android A1–A9, Chrome W1–W5, mover la pantalla durante la compresión
- README: pesos reales «X KB → Y KB» por rellenar; cambiar «medido en el emulador» por «en el móvil»
- `sesion_detail_screen.dart` mal escrito: renombrar a `session_detail_screen.dart`

## Siguiente
1. B4 · Desplegar reglas e índices (`firebase deploy --only firestore:rules,firestore:indexes`, lo hace Aitor), crear sesiones desde la app y hacer las pruebas manuales
2. B4 · Montar la tabla con `tabla-pruebas`; si guardar la prueba sin red no avisa (A9/W5), añadir `.timeout` como en crear sesión
3. B5 · `geolocator` al publicar la sesión, con sus 3 errores; `GeoPoint` + `Timestamp`; comparación GPS/red/combinado en el README
4. B6 · `flutter_map` + OSM centrado en el usuario, marcador → `sessionDetail`, «cerca de mí» en isolate
5. B7 · Hosting con URL, tabla de pruebas completa, etiqueta `fase-1b` y PDF
6. H1 · Documentación de arquitectura y alcance

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [x] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [x] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0) (código y README hechos; faltan pruebas manuales y pesos reales)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores y datos exportados (hecho); faltan comandos en el README, Hosting con URL y tabla de pruebas (1,0)

## Decisiones pendientes
- Pruebas contra la nube: el profesor confirmó en persona que no puntúa los emuladores; la rúbrica escrita (`fase1b.md` l. 70 y 74) sigue pidiéndolos, se mantienen funcionando. Blaze no hace falta (Spark basta)
- `pacts` y `badges` no están en `emulator-data/`; comentario «TEMPORAL» de sus reglas sin corregir
- Unirse a sesiones (fase 2): ampliar la regla `update` para `participantIds` y pasar `deleteSession` a `WriteBatch`
- Textos como literales, sin `l10n`; visibilidad `friends` sin `friendships` todavía

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 6 días para ~4,5 puntos (cierre de B4, B5, B6, B7) más H1; sin margen si se pierde un día
