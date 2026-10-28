# Estado — actualizado 18/10/2026

**Fase actual:** 1 · Arranque · cierra en el Aula **hoy 18/10, 23:59** (falta el PDF). Después empieza la fase 1b
**Siguiente:** Fase 1b · Fotos, posición y consultas · entrega **13/11/2026** (Aula: 15/11). **Coincide con H1** (arquitectura, alcance, CLAUDE.md): cerrar la documentación de H1 antes de la última semana de la 1b (fechas: `docs/hitos.md`; rúbrica: `docs/fase1b.md`)

## Hecho
- Fase 1 hecha salvo el PDF: repo (`Aitoorchs7/codo`), tema claro/oscuro y cristal, splash, onboarding, acceso/registro (`AuthService`), `Profile`/`Pact`/`Medal` con `withConverter`, barra inferior, pactos con detalle, perfil con medallas y rutas con argumentos
- 6 `pacts` y 6 `badges` subidos con reglas de solo lectura comprobadas (IA.md 006); `docs/pruebas.md` (26 pruebas) y capturas en `assets/images/capturas/`
- Entorno agéntico: 5 agentes, 3 skills, `/cierre`, rules por capa y permisos en `settings.json`
- 18/10: contexto de la 1b (`docs/fase1b.md`, `docs/hitos.md`) y decisiones de producto v1.1 (ubicación, mapa y fotos)
- `flutter analyze` limpio y 16 pruebas en verde (17/10); 35 commits
- 28/10: feat/ui-fondos fusionada (vídeo de login, fondo de puntos, WebP, paleta azul-negro, GlassButton)

## En curso (fase 1, hoy)
- Sin commit: docs, capturas Android, espacios del onboarding y URL buena del splash (en HEAD está la URL falsa `nada.jpg`)
- Onboarding (`onboarding_screen.dart:179-180`): falta un espacio («tusamigos»)
- IA.md: [COMPLETAR] (006, 007) y [AITOR] (004, 006, 007); entrada 008 pendiente (decisiones de la 1b)
- PDF de entrega y envío

## Siguiente
1. Cerrar la fase 1: commits, IA.md, PDF y envío (hoy)
2. 1b · Emuladores de Auth y Firestore con `--dart-define` y ≥20 `live_sessions` de prueba (B7, base de lo demás)
3. 1b · Google en Android y web, con perfil ligado y SHA/OAuth en el README (B1)
4. 1b · Cuatro consultas, `firestore.indexes.json`, editar/borrar y reglas (B2, B3)
5. 1b · Foto: cámara/galería, isolate con progreso y base64 en `proofs` (B4, 2 puntos)
6. 1b · Ubicación, mapa y «cerca de mí» (B5, B6); Hosting y tabla de pruebas al final (B7)

## Checklist fase 1b (10 puntos; detalle en `docs/fase1b.md`)
- [ ] B1 Google en Android y web, perfil ligado, SHA/OAuth y .gitignore (1,5)
- [ ] B2 ≥20 documentos, 4 consultas, índice en `firestore.indexes.json`, snapshots/get justificado (1,75)
- [ ] B3 Editar y borrar lo propio; las reglas lo impiden con lo ajeno (0,75)
- [ ] B4 Cámara/galería, isolate con progreso, base64 <300 KB (2,0)
- [ ] B5 `geolocator`, `GeoPoint`+`Timestamp`, comparación en el README (1,5)
- [ ] B6 `flutter_map` + OSM, «cerca de mí» en isolate (1,5)
- [ ] B7 Emuladores con `--dart-define`, Hosting con URL, tabla de pruebas (1,0)
Checklist fase 1: todo [x] salvo el PDF de entrega

## Decisiones pendientes
- ❓ Confirmar las decisiones de la 1b propuestas por la IA: ubicación aproximada, `proofs` en base64, `flutter_map`; precisión de la ubicación; qué pasa al borrar una sesión con participantes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` (en el README)
- `assets/images/imagenes app/` (4 fondos .jpg) sin añadir a git ni a `pubspec.yaml`: decidir si entra y con otro nombre
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con el fondo gris actual
- Fase 2: `AppLocalizations`, `pacts` con participantes y reglas, `Profile.copyWith`

## Bloqueos
- Ninguno técnico. Riesgo de plazo: hoy cierra la fase 1 (PDF) y el 13/11 coinciden la 1b y H1
