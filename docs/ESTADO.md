# Estado — actualizado 01/11/2026

**Fase actual:** 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11; quedan 12 días). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)
**Fase 1:** cerrada y entregada (18/10)

## Hecho
- Fase 1 completa; `feat/ui-fondos` fusionada (28/10); entorno agéntico con 5 agentes, 3 skills, `/cierre` y rules por capa
- Emuladores Auth 9099 / Firestore 8080 / UI 4000 con `--dart-define=USE_EMULATORS=true`, conectados antes de `runApp`; cleartext solo en `src/debug`
- B1: Google en web (`signInWithPopup`) y Android (`google_sign_in` 7), cancelación como `AuthError.cancelled` sin aviso, `getOrCreateProfile`, README con SHA y cliente OAuth
- B2: modelo `LiveSession`, seed de 4 usuarios y 24 sesiones exportado en `emulator-data/`, `LiveSessionRepository` con las 4 consultas y 3 índices en `firestore.indexes.json`
- B2: Ahora con chips (Recientes / categoría) y `StreamBuilder` con 4 estados; Historial (Perfil → «Mi historial») con paginación «Cargar más» y filtro por rango con `showDateRangePicker`
- `SafeArea` en `HomeScreen` para las 5 pestañas; `provider` quitado de `pubspec.yaml` y de las rules (01/11: cada pantalla crea su repositorio en su `State`)
- `flutter analyze` limpio y 16 pruebas en verde (01/11); 70 commits

## En curso
- B2: README con la justificación snapshots/get de cada pantalla
- Pruebas de `readOptionalDate` y `readEnum` sin escribir
- IA.md: entrada 010 (Google) escrita sin commit; 011 (sesiones y consultas) y 012 (pantallas de consultas) pendientes

## Siguiente
1. B2 · README snapshots/get (Ahora escucha; Historial lee una vez) y cerrar B2
2. B3 · Editar descripción y duración, terminar sesión, el `delete` (sesión vacía o `proofs` propio), reglas de `update`/`delete` y prueba con dos usuarios
3. B4 · Foto: cámara/galería, isolate con progreso y base64 en `proofs` (2 puntos)
4. B5 · `geolocator` con sus 3 errores, posición redondeada y comparación en el README
5. B6 · Mapa `flutter_map` + OSM y «cerca de mí» en isolate
6. B7 · README de emuladores, Hosting con URL, tabla de pruebas y etiqueta `fase-1b`

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [x] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [ ] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75) (falta el README)
- [ ] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores (hecho) y datos exportados (hecho); faltan comandos en el README, Hosting con URL y tabla de pruebas (1,0)

## Decisiones pendientes
- B3: qué se borra con `delete` si una sesión con participantes no se borra (decidido 29/10: el creador la termina): sesión propia vacía o `proofs` propio
- Nube vs emuladores: se puede desarrollar en la nube (plan Spark), pero se corrige con emuladores (`fase1b.md` l. 74); confirmar con el profesor lo del plan Blaze
- `pacts` y `badges` no están en `emulator-data/` (Pactos y Perfil vacíos en local)
- Precisión de la ubicación (seed: 2 decimales, ~1 km) y visibilidad `friends` en reglas (aún sin `friendships`)
- `firebase deploy --only firestore:indexes,firestore:rules` (lo ejecuta Aitor) y `firebase_options.dart`/`google-services.json` entregados aparte
- Textos de las pantallas nuevas como literales: no hay `l10n` todavía (la rule de pantallas lo pide)

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 12 días para 8,5 de 10 puntos sin cerrar (B2 solo a falta del README; B4–B6 = 5 puntos sin empezar) y H1 el mismo día
