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

## En curso
- Sin commit: docs, capturas (Android sin añadir a git), espacios del onboarding y URL buena del splash (en HEAD está la URL falsa `nada.jpg` de la captura de error)
- Onboarding (`onboarding_screen.dart:179-180`): sigue faltando un espacio («tusamigos»)
- IA.md: huecos [COMPLETAR] (006: fecha, qué pedí, qué me dio; 007: resultado y 35/36 commits) y [AITOR] (004, 006, 007)

## Siguiente
1. Añadir el espacio de «tus amigos» y hacer los commits propuestos
2. Rellenar los [COMPLETAR] y [AITOR] de IA.md
3. PDF de entrega y envío (18/10)
4. Traducir errores de Firestore a un fallo de dominio en Pactos y medallas (fuera del checklist)
5. Hallazgos de los agentes (fase 2): registro no atómico con `currentUser!`; pruebas de `AuthService`, `Pact.fromFirestore` y `PactsScreen`

## Checklist de la fase 1
- [x] Estructura de carpetas + README explicado (`lib/l10n/` llega en la fase 2) · [x] 15+ commits repartidos (llevamos 35)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez
- [x] Firebase documentado (README) · [x] Registro y acceso con errores tratados · [x] Cerrar sesión y cancelar suscripciones
- [x] Colecciones de perfiles y contenido (≥6 documentos) · [x] `withConverter` (en `FirestoreAdmin`)
- [x] Rutas con nombre y paso de parámetros · [x] Barra inferior (lista de pactos + cuadrícula de medallas, 4 estados)
- [x] Tabla de pruebas Android/web con capturas · [x] Guía de arranque en el README · [ ] PDF de entrega (falta hacerlo y enviarlo)

## Decisiones pendientes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` como alternativa (ya en el README)
- Carpeta `assets/images/imagenes app/` (4 fondos .jpg) sin añadir a git ni a `pubspec.yaml`: decidir si entra y con otro nombre (sin espacio)
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con el fondo gris actual y el botón principal al 85→65 %
- Fase 2: `AppLocalizations` y `lib/l10n/`; `pacts` con participantes y reglas; `Profile.copyWith`; unicidad de `displayName`; `badges` → `medals` solo si sobra tiempo

## Bloqueos
- Ninguno técnico. Riesgo de plazo medio: queda 1 día y falta el PDF; los commits y la corrección del onboarding son ~15 min
