# Estado — actualizado 17/10/2026

**Fase actual:** 1 · Arranque · entrega **18/10/2026** (confirmado por Aitor; el H0 y la propuesta siguen el mismo plazo)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)
**Ramas:** `master` = entrega de la fase 1 (39 commits) · `feat/ui-fondos` = mejoras de UI (43 commits), sin mergear

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- Tema claro/oscuro (`AppTheme` + `CodoColors`, Onest) y cristal (`GlassSurface`, `GlassButton`, `CodoBackground`)
- Splash con imagen de URL (3 estados) y destino según sesión y «onboarding visto» (`startupRoute`, probado); onboarding de 3 páginas
- Acceso y registro: `AuthService` + `AuthFailure` + `AuthScreen` (un mensaje por `AuthError`); cerrar sesión desde Perfil
- Modelos `Profile`, `Pact` y `Medal` con lectores seguros y pruebas de casos malos; `FirestoreAdmin` con `withConverter` + 3 repositorios (streams)
- Barra inferior (`CodoNavBar`, `HomeScreen` con `IndexedStack`), `PactsScreen` con detalle, Perfil con `MedalGrid`; rutas con `onGenerateRoute` y `PactDetailArgs`
- 6 `pacts` y 6 `badges` subidos; reglas de solo lectura comprobadas; `docs/pruebas.md` (26 pruebas) y capturas web/Android
- IA.md sin huecos; espacios del onboarding y URL real del splash corregidos y commiteados
- **PDF de entrega de la fase 1 hecho** (17/10, en otro chat); falta solo enviarlo antes del 18/10
- `flutter analyze` limpio y 16 pruebas en verde (17/10, también en `feat/ui-fondos`)
- En `feat/ui-fondos`: login con vídeo en bucle (`LoginVideoBackground`, `video_player`; mismo vídeo oscuro en claro y oscuro; columna de 480 px en web), fondo de red de puntos tras las 5 secciones (`HomeBackground`), logo con transparencia, imágenes WebP en `assets/images/imagenes_app/`, paleta oscura azul-negro (cerrada: sin cian ni ámbar nuevos por ahora)

## En curso
- `feat/ui-fondos`, 4 ficheros sin commit: `GlassButton` se encoge al pulsar y vibra suave; los 4 `FilledButton` pasan a `GlassButton` (analyze y tests limpios)
- UI una a una; siguiente: tarjeta de pacto (recomendada: barra continua gruesa con degradado) y barra inferior flotante
- Pendiente de UI: ilustración del choque de puños (`splash_codo_*.webp`) en onboarding y estados vacíos; icono del móvil con el logo nuevo

## Siguiente
1. Enviar el PDF (antes del 18/10) y después `git merge master` en `feat/ui-fondos`
2. Commitear los 4 ficheros y probar login y Home en web y Android, en claro y oscuro (la vibración solo se nota en móvil real)
3. UI: tarjeta de pacto, barra inferior, ilustración e icono
4. Entrada 008 de IA.md al terminar la UI (correcciones: descartó `CustomPainter` para los rayos, fondos apaisados con recorte, mismo vídeo en ambos modos, revirtió el ajuste de zoom) y sincronizar la paleta
5. Mergear `feat/ui-fondos` a `master` cuando esté probada
6. Errores de Firestore a fallo de dominio y hallazgos de los agentes (fase 2: registro no atómico con `currentUser!`; pruebas de `AuthService`, `Pact.fromFirestore`, `PactsScreen`)

## Checklist de la fase 1
- [x] Estructura de carpetas + README explicado (`lib/l10n/` llega en la fase 2) · [x] 15+ commits repartidos (llevamos 39 en `master`)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez
- [x] Firebase documentado (README) · [x] Registro y acceso con errores tratados · [x] Cerrar sesión y cancelar suscripciones
- [x] Colecciones de perfiles y contenido (≥6 documentos) · [x] `withConverter` (en `FirestoreAdmin`)
- [x] Rutas con nombre y paso de parámetros · [x] Barra inferior (lista de pactos + cuadrícula de medallas, 4 estados)
- [x] Tabla de pruebas Android/web con capturas · [x] Guía de arranque en el README · [x] PDF de entrega (hecho; falta enviarlo)

## Decisiones pendientes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` como alternativa (ya en el README)
- Capturas (`assets/images/capturas/`): decidir si siguen en el paquete de la app (`assets/images/` las incluye)
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con el azul-negro oscuro actual y el botón principal al 85→65 %
- Fase 2: `AppLocalizations` y `lib/l10n/`; `pacts` con participantes y reglas; `Profile.copyWith`; unicidad de `displayName`; `badges` → `medals` solo si sobra tiempo

## Bloqueos
- Ninguno técnico. Riesgo de plazo bajo: el PDF está hecho; solo falta enviarlo antes del 18/10
