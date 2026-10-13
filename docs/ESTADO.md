# Estado — actualizado 12/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** según README y este fichero (Aitor habla del 18/10: confirmar con el enunciado)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- Tema claro/oscuro (`AppTheme` + `CodoColors`, Onest con `google_fonts` ^6.3.3) y cristal (`GlassSurface`, `GlassButton`, `CodoBackground`)
- Splash con imagen de URL (3 estados) y destino según sesión y «onboarding visto» (`startupRoute`, probado); onboarding de 3 páginas
- Acceso y registro: `AuthService` + `AuthFailure` + `AuthScreen` (un mensaje por `AuthError`, probado en Chrome); cerrar sesión desde Home
- Modelos `Profile`, `Pact` y `Medal` (`badge.dart`, con `imageUrl`) con lectores seguros (`field_readers.dart`) y pruebas de casos malos
- `FirestoreAdmin` con `withConverter` (`users`, `pacts`, `badges`) + `ProfileRepository`, `PactRepository` y `MedalRepository` (streams)
- El perfil se crea en `users/{uid}` al registrarse (visto en la consola) y Home lo lee con 4 estados (cargando, error + Reintentar, sin perfil, dato)
- 20 commits en 9 días. **Sin commitear:** todo lo de hoy (~880 líneas); `analyze` limpio y `test` con 16 pruebas en verde

## En curso
- Datos de ejemplo: `lib/utils/example_data.dart` escrito pero **sin ejecutar** (no hay botón que llame a `seedSampleData`; `pacts` y `badges` vacías)
- `Profile` a medias: ya usa lectores y `Timestamp`; faltan constructor `const` y `photoUrl`/`bio` como `final`

## Siguiente
1. Commitear lo de hoy (varios commits) y terminar `Profile`
2. Subir los datos de ejemplo una vez (botón temporal con `kDebugMode`, que se borra): ≥ 6 `pacts` y ≥ 6 `badges`
3. Traducir los errores de Firestore a un fallo de dominio (como `AuthFailure`) y hacer la barra inferior: lista de pactos + cuadrícula de medallas, con 4 estados
4. `onGenerateRoute` con argumentos tipados (detalle de un pacto)
5. README (Firebase, arranque y entrega de `firebase_options.dart`/`google-services.json`), `.gitkeep` en `l10n/` y tabla de pruebas Android/web
6. Limpieza: textos del onboarding («Elegis», «haceis», «dia») y `outlinedButtonTheme` sin usar en `app_theme.dart`

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado (falta `.gitkeep` en `l10n/`) · [x] 15+ commits repartidos (20)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez (textos con faltas por corregir)
- [ ] Firebase documentado · [x] Registro y acceso con errores tratados · [ ] Cerrar sesión y cancelar suscripciones (`signOut` hecho; faltan las listas con streams)
- [ ] Colecciones de perfiles y contenido (≥6 documentos) (`users` se crea sola; faltan subir `pacts` y `badges`) · [x] `withConverter` (en uso en `FirestoreAdmin`)
- [ ] Rutas con nombre y paso de parámetros (falta `onGenerateRoute`) · [ ] Barra inferior (lista + cuadrícula, 3 estados)
- [ ] Tabla de pruebas Android/web · [ ] Guía de arranque en el README

## Decisiones pendientes
- Fecha de entrega: 16/10 (docs) o 18/10 (Aitor)
- `firebase_options.dart` y `google-services.json`: propuesta = entregarlos aparte al profesor + `flutterfire configure` como alternativa, documentado en el README
- Preguntar al profesor si `DataHolder` y `FirebaseAdmin` son obligatorios (ya existe `FirestoreAdmin`)
- Carpeta `assets/images/imagenes app/` (4 fondos .jpg) sin añadir a git ni a `pubspec.yaml`: decidir si entra y con otro nombre (sin espacio)
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` y el lienzo con el fondo gris actual y el botón principal al 85→65 %
- Textos ES/EN: literales en español ahora, `AppLocalizations` en la fase 2

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 8 puntos de la checklist sin hacer y ~14 h estimadas; quedan ~12 h hasta el 16/10 y ~18 h hasta el 18/10 (a 3 h/día)
