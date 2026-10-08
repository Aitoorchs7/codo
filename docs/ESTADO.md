# Estado — actualizado 08/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** (coincide con H0, la propuesta; ese documento lo prepara Aitor aparte)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repositorio en GitHub (`Aitoorchs7/codo`) y `.gitignore` con los secretos
- CLAUDE.md, IA.md, README y decisiones de producto (borrador v1)
- Entorno agéntico: 5 agentes, 3 skills, rules por capa, `/cierre` y permisos (`docs/AGENTES_Y_SKILLS.md`)
- `provider` como gestión de estado; Firebase conectado (Auth + Firestore); `AuthService` + `AuthFailure` con errores tratados, en `lib/admins/`
- Carpetas de `lib/` (`screens/` y `admins/` confirmadas) y rutas con nombre: `AppRoutes` (constantes + tabla `routes`)
- Onboarding, lógica: `_finish` guarda «visto» con `PreferencesAdmin` y va a `/login`; `LoginScreen` vacía

## En curso
- Onboarding, interfaz: `PageView` de 3 páginas, puntos, Saltar → `_finish`, Siguiente → `_next`
- `flutter analyze` con 21 incidencias: import roto en `auth_service.dart` (`services` → `admins`) y falta `AppTheme`; `flutter test` no compila por lo mismo
- Tema: `app_theme.dart` y `colors.dart` están en el otro PC sin commit (llegan el 09/10)

## Siguiente
1. Traer el tema del otro PC, borrar el `app_theme.darty.dart` vacío y dejar `analyze` y `test` limpios
2. Terminar el onboarding y probarlo en Chrome (con prueba unitaria de `PreferencesAdmin`)
3. Splash con imagen de URL (carga/error); destino según `isOnboardingSeen()`: onboarding o acceso
4. Acceso y registro con un mensaje por cada `AuthError`; cerrar sesión
5. `models/` + `withConverter` + repositorios + datos de ejemplo (`users`, `pacts` ≥ 6, `badges`)
6. Barra inferior (lista + cuadrícula, 3 estados); después README (Firebase, arranque) y tabla de pruebas

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado (README listo; faltan `.gitkeep` en `l10n/`, `utils/` y `widgets/` para que git las suba) · [ ] 15+ commits repartidos (llevamos 11)
- [ ] Splash con imagen de URL y estados · [ ] Onboarding de 3 pantallas, saltable, solo la primera vez (falta la interfaz y que el splash lea el «visto»)
- [ ] Firebase documentado · [ ] Registro y acceso con errores tratados (servicio hecho; faltan pantallas) · [ ] Cerrar sesión y cancelar suscripciones (`signOut` hecho)
- [ ] Colecciones de perfiles y contenido (≥6 documentos) · [ ] `withConverter`
- [ ] Rutas con nombre y paso de parámetros (nombres hechos; falta `onGenerateRoute` con argumentos) · [ ] Barra inferior (lista + cuadrícula, 3 estados)
- [ ] Tabla de pruebas Android/web · [ ] Guía de arranque en el README

## Decisiones pendientes
- Qué alimenta la cuadrícula: medallas (`badges`, recomendado) o plantillas (Supabase, `docs/decisiones_producto.md` §8) → antes de la barra inferior
- Preguntar al profesor si `DataHolder` (singleton) y `FirebaseAdmin` son obligatorios. Propuesta: `DataHolder` dentro del `MultiProvider` y `ProfileRepository` sin duplicarlo
- Cómo ejecuta el proyecto quien evalúe: `firebase_options.dart` y `google-services.json` no están en el repo → documentar `flutterfire configure` en el README
- Textos ES/EN: `AppLocalizations` ya o en la fase 2 (recomendado: literales en español y migrar en la fase 2)
- Los ❓ de `docs/decisiones_producto.md` (precios, niveles, edad mínima): no bloquean la fase 1

## Bloqueos
- `app.dart` no compila hasta tener `app_theme.dart` y `colors.dart` (otro PC, 09/10); `firebase_options.dart` y `google-services.json` también hay que pasarlos al otro PC
