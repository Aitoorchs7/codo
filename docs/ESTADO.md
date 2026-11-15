# Estado — actualizado 15/11/2026

**Fase actual:** 1b entregada (etiqueta `fase-1b` en `c019f4c`, subida a GitHub; PDF al Aula hoy 15/11). **Siguiente:** Fase 2 · Datos que duran, entrega **04/12/2026** (Aula: 06/12), junto con H2 · Prototipo con datos que duran (18/12). Fechas: `docs/hitos.md`
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; entorno agéntico con 5 agentes, 4 skills (incluida `rls`), `/cierre` y rules por capa
- B1–B4: Google, 4 consultas con índices, editar/borrar con reglas, foto en isolate con base64 < 300 KB; **EXIF (GPS) borrado al comprimir**, con prueba
- B5: `LocationAdmin` (`COARSE`, `medium`, 10 s) con 5 fallos de dominio; `GeoPoint` a 2 decimales + `locationAt` = `pos.timestamp`; README GPS/red/combinado
- B6: mapa `flutter_map` + OSM (atribución, `userAgentPackageName`, marcadores → detalle, centrado en el usuario); «Cerca de mí» en isolate con progreso y tiempos medidos (Android 57–73 ms con isolate, Chrome 17–22 ms sin él)
- B7: README de arranque con emuladores (`--dart-define`, `--import=emulator-data`) y Hosting en https://codo-941ac.web.app
- Tabla de pruebas única en `docs/pruebas_fase1b.md` (55 filas, Android y Chrome, con capturas) y PDF en `docs/entrega/`
- H1 documentado (`docs/h1_arquitectura.md`); auditoría de seguridad en `docs/seguridad_auditoria.md`
- `flutter analyze` limpio y 26 pruebas en verde (15/11); 126 commits

## En curso
- Nada de código. Sin commit: 2 capturas sin usar (`p9_android_ahora_emulador.png`, `p_ahora_con_ubicacion_desactivada.png`) y este ESTADO

## Siguiente
1. Subir el PDF `docs/entrega/Codo_fase1b_Aitor_Chicano.pdf` al Aula (hoy)
2. Leer el enunciado de la Fase 2 y su rúbrica; crear `docs/fase2.md` como se hizo con `fase1b.md`
3. Decidir qué hallazgos altos de la auditoría entran en la Fase 2 (V-01 `friends` en reglas, V-03 XP/medallas, V-04/V-05 abuso)
4. Añadir `pacts` y `badges` a `emulator-data/` y corregir el comentario «TEMPORAL» de sus reglas

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [x] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [x] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [x] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [x] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [x] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [x] B7 Emuladores con datos exportados, Hosting con URL y tabla de pruebas (1,0)

## Decisiones pendientes
- Auditoría (4 altas): V-02 (EXIF) resuelto; quedan `friends` sin aplicar en reglas, XP/medallas escritos por el usuario y freno al abuso (App Check en fase 2–3; Spark corta la cuota, no cobra)
- Miniatura en `proofs` y no en el documento de la sesión (la rúbrica dice «dentro del documento»): justificado en el README por el límite de 1 MB y la privacidad; preparar la respuesta para la defensa
- Marcadores en el mismo punto se apilan: clustering en la fase 2
- Web: la compresión congela ~1,5 s; mejora opcional
- Unirse a sesiones (fase 2): ampliar la regla `update` para `participantIds` y pasar `deleteSession` a `WriteBatch`
- Textos como literales, sin `l10n`

## Bloqueos
- Ninguno. Fase 2: 19 días hasta el 04/12
