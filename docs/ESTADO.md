# Estado — actualizado 17/10/2026

**Fase actual:** 1 · Arranque · entrega **18/10/2026** (confirmado por Aitor; el H0 y la propuesta siguen el mismo plazo)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- Tema claro/oscuro (`AppTheme` + `CodoColors`, Onest) y cristal (`GlassSurface`, `GlassButton`, `CodoBackground`)
- Splash con imagen de URL (3 estados) y destino según sesión y «onboarding visto» (`startupRoute`, probado); onboarding de 3 páginas
- Acceso y registro: `AuthService` + `AuthFailure` + `AuthScreen` (un mensaje por `AuthError`); cerrar sesión desde Perfil
- Modelos `Profile`, `Pact` y `Medal` con lectores seguros y pruebas de casos malos; `FirestoreAdmin` con `withConverter` + 3 repositorios (streams)
- Barra inferior (`CodoNavBar`, `HomeScreen` con `IndexedStack`), `PactsScreen` con detalle, Perfil con `MedalGrid`; rutas con `onGenerateRoute` y `PactDetailArgs`
- 6 `pacts` y 6 `badges` subidos; reglas de solo lectura comprobadas (IA.md 006)
- `docs/pruebas.md` (26 pruebas Android/web) y capturas: web (17) y Android (12) en `assets/images/capturas/`
- Docs de cierre de fase 1 (17/10): ESTADO, README, pruebas e IA.md (tabla de agentes, entradas 006 y 007)
- `flutter analyze` limpio y 16 pruebas en verde (17/10); 35 commits
- **PDF de entrega de la fase 1 hecho** (17/10, por Aitor en otro chat); solo falta enviarlo antes del 18/10
- IA.md sin huecos `[COMPLETAR]`/`[AITOR]`; espacios del onboarding y URL real del splash ya commiteados (en `master`)

## En curso
- **Rama `feat/ui-fondos`** (fuera de la entrega; `master` queda como entrega de la fase 1, el merge se hace después): login con vídeo de fondo en bucle (`LoginVideoBackground`, `assets/videos/`, dependencia `video_player`; mismo vídeo oscuro en claro y oscuro, hoja del formulario según el modo, columna de 480 px en web), fondo de red de puntos tras las 5 secciones (`HomeBackground`), logo con esquinas redondeadas y transparencia, imágenes en WebP en `assets/images/imagenes_app/`
- Sin commit en esa rama: assets (`.webp`, vídeo, logo), `pubspec.yaml`, `pubspec.lock` y `GeneratedPluginRegistrant.swift`; commit propuesto: `chore(assets): imágenes en WebP, vídeo ligero del login y video_player`
- UI aparcada para después de lo anterior (se valoran una a una; lista en la memoria del proyecto): paleta con tinte azul y acento cian, botones con degradado, tarjetas de pacto con barra segmentada, barra inferior flotante. Pendiente también: ilustración del choque de puños (`splash_codo_*.webp`) en onboarding y estados vacíos, e icono del móvil con el logo nuevo

## Siguiente
1. Enviar el PDF (antes del 18/10) y, ya en `feat/ui-fondos`, traer `master` (`git merge master`) tras la entrega
2. Commitear los assets de la rama y probar login y Home en web y Android, en claro y oscuro
3. Mejoras de UI una a una (ilustración, icono, paleta, botones, tarjetas)
4. Traducir errores de Firestore a un fallo de dominio en Pactos y medallas (fuera del checklist)
5. Hallazgos de los agentes (fase 2): registro no atómico con `currentUser!`; pruebas de `AuthService`, `Pact.fromFirestore` y `PactsScreen`

## Checklist de la fase 1
- [x] Estructura de carpetas + README explicado (`lib/l10n/` llega en la fase 2) · [x] 15+ commits repartidos (llevamos 35)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez
- [x] Firebase documentado (README) · [x] Registro y acceso con errores tratados · [x] Cerrar sesión y cancelar suscripciones
- [x] Colecciones de perfiles y contenido (≥6 documentos) · [x] `withConverter` (en `FirestoreAdmin`)
- [x] Rutas con nombre y paso de parámetros · [x] Barra inferior (lista de pactos + cuadrícula de medallas, 4 estados)
- [x] Tabla de pruebas Android/web con capturas · [x] Guía de arranque en el README · [x] PDF de entrega (hecho el 17/10; falta enviarlo)

## Decisiones pendientes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` como alternativa (ya en el README)
- Cerrado en `feat/ui-fondos`: la carpeta pasó a `assets/images/imagenes_app/` (sin espacio), en WebP, y declarada en `pubspec.yaml` junto a `assets/videos/`. Queda decidir si las capturas (`assets/images/capturas/`) siguen en el paquete de la app
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con el fondo gris actual y el botón principal al 85→65 %
- Fase 2: `AppLocalizations` y `lib/l10n/`; `pacts` con participantes y reglas; `Profile.copyWith`; unicidad de `displayName`; `badges` → `medals` solo si sobra tiempo

## Bloqueos
- Ninguno técnico. Riesgo de plazo bajo: el PDF está hecho; solo falta enviarlo antes del 18/10
- Cuidado: la rama `feat/ui-fondos` tiene commits que referencian assets sin commitear; hasta commitear los assets no compila en un clon limpio
