# Estado — actualizado 07/11/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 6 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- Emuladores Auth/Firestore con `--dart-define=USE_EMULATORS=true` y datos exportados; B1 (Google), B2 (4 consultas, índices) y B3 (editar/borrar con reglas, probado por REST) cerrados
- B4: cámara/galería con `PhotoFailure`; compresión en isolate con progreso (800→600→400 px, base64 <300 KB); `Proof` en `live_sessions/{id}/proofs/{uid}` con reglas de solo participantes; miniatura y `SessionDetailScreen`; permisos Android e iOS; README «Fotos de prueba» con pesos reales (133→62 KB, 4K 2401→94 KB)
- B4 probado contra la nube en Android y Chrome (Rules Playground ajeno denegado / propio permitido); tabla en `docs/pruebas.md` y capturas en `docs/capturas/fase1b/`
- `CreateSessionScreen` (validada, regla `create` estricta, aviso sin red) con botón en Ahora; nombre del creador desde el perfil
- Sin red: `.timeout` de 10 s con aviso al crear sesión y al guardar la prueba
- Rutas: inicial en `/` (atrás ya no muestra «Ruta no válida»); `sessionDetail` con `SessionDetailArgs`
- `flutter analyze` limpio y 22 pruebas en verde (07/11); 94 commits

## En curso
- Sin commit: nombre del creador desde el perfil, `categoryLabel` en Ahora y `.timeout` al guardar la prueba

## Siguiente
1. B5 · `geolocator` al publicar la sesión, con permiso pedido en ese momento y sus 3 errores (denegado, GPS apagado, tiempo agotado) sin dejar la pantalla colgada
2. B5 · Guardar `GeoPoint` (aproximado, 2 decimales) + `locationAt` y leerlo tipado; media página GPS/red/combinado en el README; filas 20 de `docs/pruebas.md`
3. B6 · `flutter_map` + OSM con atribución y `userAgentPackageName`, centrado en el usuario, marcador → `sessionDetail`
4. B6 · «Cerca de mí» ordenada por distancia en isolate con progreso; README de qué va en isolate y por qué
5. B7 · Hosting con URL (deploy lo hace Aitor), README de arranque, filas 19–22 de la tabla, etiqueta `fase-1b` y PDF
6. H1 · Documentación de arquitectura y alcance

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [x] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [x] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [x] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores y datos exportados (hecho); faltan comandos en el README, Hosting con URL y tabla de pruebas (casi hecha) (1,0)

## Decisiones pendientes
- Pruebas contra la nube: el profesor confirmó en persona que no puntúa los emuladores; se mantienen funcionando. Blaze no hace falta (Spark basta)
- Web: la compresión congela ~1,5 s sin pintar el diálogo; mejora opcional (dejar pintar antes de comprimir) solo si sobra tiempo
- `pacts` y `badges` no están en `emulator-data/`; comentario «TEMPORAL» de sus reglas sin corregir
- Unirse a sesiones (fase 2): ampliar la regla `update` para `participantIds` y pasar `deleteSession` a `WriteBatch`
- Textos como literales, sin `l10n`; visibilidad `friends` sin `friendships` todavía

## Bloqueos
- Ninguno técnico. Plazo: 6 días para 4 puntos (B5, B6, B7) más H1, ~4,5 días de trabajo: 1,5 días de margen
