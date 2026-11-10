# Estado — actualizado 10/11/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 3 días). Coincide con H1, ya documentado (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- B1–B4 cerrados y probados contra la nube en Android y Chrome (detalle en `docs/pruebas_fase1b.md` y `docs/capturas/fase1b/`)
- H1: `docs/h1_arquitectura.md` (arquitectura, tecnologías, requisitos, alcance e ingresos) y decisiones de producto v1.2
- B5: `LocationAdmin` (`geolocator`, `COARSE`, `LocationAccuracy.medium`, 10 s) con 5 fallos de dominio (`denied`, `deniedForever` con botón Ajustes, `serviceDisabled`, `timeout`, `unavailable`); interruptor opcional al publicar; `GeoPoint` redondeado a 2 decimales en `toFirestore` + `locationAt` = `pos.timestamp`; sección «Ubicación» en el README; filas 34–40 en la tabla
- B6 (mapa): `SessionsMapScreen` con `flutter_map` + OSM, atribución y `userAgentPackageName`; marcadores de sesiones públicas con ubicación → `sessionDetail`; centrado en el usuario con `MapController` (Madrid si falla) y su marcador; botón en Ahora
- `flutter analyze` limpio y 22 pruebas en verde (10/11); 109 commits

## En curso
- Sin commit: `devtools_options.yaml`, `docs/seguridad_auditoria.md` y la skill `.claude/skills/rls/`

## Siguiente
1. README: cambiar `LocationAccuracy.low` por `medium` en «Ubicación» (con el motivo: `low` devolvía posiciones viejas) y anotar los marcadores apilados como límite conocido
2. B6 · «Cerca de mí» ordenada por distancia en isolate con progreso + README de qué va en isolate y por qué
3. B5/B6 · Rellenar resultados de las filas 34–40 (y las de B6) con capturas en Android y Chrome
4. B7 · Comandos de arranque en el README, Hosting con URL (deploy lo hace Aitor) y filas 31–33
5. Etiqueta `fase-1b` y PDF de entrega

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [x] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [x] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [x] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [x] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5) (corregir `low`→`medium` en el README)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5) (mapa hecho; falta «cerca de mí» en isolate y su README)
- [ ] B7 Emuladores y datos exportados (hecho); faltan comandos en el README, Hosting con URL y resultados de la tabla (1,0)

## Decisiones pendientes
- Auditoría de seguridad (`docs/seguridad_auditoria.md`, 4 altas): sobre todo, las fotos de prueba **conservan el GPS del EXIF** (contradice la regla de privacidad; afecta a B4) y `friends` no se aplica en las reglas. Decidir qué se arregla antes del 13 y qué pasa a la fase 2
- Marcadores en el mismo punto (redondeo a ~1 km) se apilan: agrupar con `flutter_map_marker_cluster` en la fase 2
- App Check y límites por usuario: fase 2–3 (Spark corta al llegar a la cuota, no cobra; Blaze solo para el servidor de la fase 3)
- Web: la compresión congela ~1,5 s sin pintar el diálogo; mejora opcional solo si sobra tiempo
- `pacts` y `badges` no están en `emulator-data/`; comentario «TEMPORAL» de sus reglas sin corregir
- Unirse a sesiones (fase 2): ampliar la regla `update` para `participantIds` y pasar `deleteSession` a `WriteBatch`
- Textos como literales, sin `l10n`

## Bloqueos
- Ninguno técnico. Plazo: 3 días para 2,5 puntos (resto de B6 y B7) más la entrega; ~1,5 días de trabajo, 1,5 de margen
