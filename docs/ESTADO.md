# Estado — actualizado 15/10/2026

**Fase actual:** 1 · Arranque · entrega **18/10/2026** (confirmado por Aitor; el H0 y la propuesta siguen el mismo plazo)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- Tema claro/oscuro (`AppTheme` + `CodoColors`, Onest) y cristal (`GlassSurface`, `GlassButton`, `CodoBackground`)
- Splash con imagen de URL (3 estados) y destino según sesión y «onboarding visto» (`startupRoute`, probado); onboarding de 3 páginas
- Acceso y registro: `AuthService` + `AuthFailure` + `AuthScreen` (un mensaje por `AuthError`); cerrar sesión desde Perfil
- Modelos `Profile` (campos `final`, constructor `const`), `Pact` y `Medal` con lectores seguros y pruebas de casos malos; `FirestoreAdmin` con `withConverter` + 3 repositorios (streams)
- Barra inferior (`CodoNavBar`, `HomeScreen` con `IndexedStack`), `PactsScreen` con detalle, Perfil con `MedalGrid`; rutas con `onGenerateRoute` y `PactDetailArgs`
- 6 `pacts` y 6 `badges` subidos y comprobados (código usa `medal`; la colección y `users.badges` se quedan); botón del seed eliminado (`utils/example_data.dart` se queda)
- README: guía de arranque con «Configuración de Firebase» y resumen de pruebas; `docs/pruebas.md` con 26 pruebas manuales Android/web (14/10)
- 34 commits en 12 días; `test` con 16 pruebas en verde

## En curso
- `flutter analyze` NO está limpio: 2 imports sin usar en `profile_screen.dart` (líneas 6-7: `example_data.dart` y `foundation.dart`)
- Onboarding (`onboarding_screen.dart:187-189`): faltan espacios entre cadenas («día.Si», «Poreso»)

## Siguiente
1. Arreglar los 2 imports y los espacios del onboarding; `analyze` limpio y commit
2. Comprobar en la consola que las reglas de `pacts`/`badges` son solo lectura
3. Capturas de pantalla (Android y web) para el PDF
4. ~~Confirmar la fecha de entrega~~ → 18/10 (hecho)
5. PDF de entrega
6. Traducir errores de Firestore a un fallo de dominio en Pactos y medallas (fuera del checklist)

## Checklist de la fase 1
- [x] Estructura de carpetas + README explicado (`lib/l10n/` aún no existe: se crea con la localización de la fase 2) · [x] 15+ commits repartidos (34)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez (falta arreglar espacios del texto)
- [x] Firebase documentado (README) · [x] Registro y acceso con errores tratados · [x] Cerrar sesión y cancelar suscripciones
- [x] Colecciones de perfiles y contenido (≥6 documentos) · [x] `withConverter` (en `FirestoreAdmin`)
- [x] Rutas con nombre y paso de parámetros · [x] Barra inferior (lista de pactos + cuadrícula de medallas, 4 estados)
- [x] Tabla de pruebas Android/web (README + `docs/pruebas.md`; faltan capturas) · [x] Guía de arranque en el README

## Decisiones pendientes
- `firebase_options.dart` y `google-services.json`: entregarlos aparte al profesor + `flutterfire configure` como alternativa (ya en el README)
- Resuelto: `DataHolder` y `FirebaseAdmin` NO son obligatorios; su función se cubre con `FirestoreAdmin` + repositorios + `provider`
- Carpeta `assets/images/imagenes app/` (4 fondos .jpg) sin añadir a git ni a `pubspec.yaml`: decidir si entra y con otro nombre (sin espacio)
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` con el fondo gris actual y el botón principal al 85→65 %
- Textos ES/EN: literales en español ahora, `AppLocalizations` y `lib/l10n/` en la fase 2
- Fase 2: `pacts` sin dueño y legible por cualquier usuario con sesión (participantes y reglas); `Profile.copyWith` al hacer editar perfil; unicidad de `displayName` en Firestore; renombrar `badges` a `medals` solo si sobra tiempo

## Bloqueos
- Ninguno técnico. Riesgo de plazo bajo: solo quedan correcciones de ~15 min, capturas y PDF; ~6 h hasta el 16/10
