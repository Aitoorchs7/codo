# Estado — actualizado 10/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** según README y este fichero (Aitor habla del 18/10: confirmar con el enunciado)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- `provider`; Firebase (Auth + Firestore); `AuthService` + `AuthFailure`; `Profile` + `ProfileRepository` con `withConverter` (aún sin usar)
- Carpetas de `lib/`, rutas con nombre (`AppRoutes`) y `PreferencesAdmin` («onboarding visto»)
- Tema claro/oscuro (`AppTheme` + `CodoColors`), fondo azul marino, Onest con `google_fonts` ^6.3.3 (la 9 rompe los tipos)
- Cristal: `CodoBackground`, `GlassSurface` (borde con `CustomPainter`) y `GlassButton` (principal y secundario)
- Onboarding, interfaz: 3 páginas con iconos provisionales, puntos animados, Saltar oculto en la última, texto a la izquierda
- Todo commiteado (18 commits en 7 días); `analyze` con 2 avisos; `test` pasa (solo prueba de humo)

## En curso
- Nada abierto. Diseño **congelado** hasta cerrar la checklist (tarjetas del onboarding, puntitos de fondo y sombra del cristal pasan a la fase 2)

## Siguiente
1. Limpiar avisos (import de `google_fonts` en onboarding, `_col`); renombrar el test; prueba de `PreferencesAdmin` con caso malo
2. Splash con imagen de URL (3 estados); destino según «visto» (revisar `isOnboardingSeen(bool)`: parece que no debería recibir parámetro)
3. Acceso y registro con un mensaje por `AuthError`; cerrar sesión
4. `models/` + `withConverter` en uso + repositorios + datos de ejemplo (`users`, `pacts` ≥ 6, `badges`)
5. `onGenerateRoute` con argumentos tipados + barra inferior (lista + cuadrícula, 3 estados)
6. README (Firebase y arranque) y tabla de pruebas Android/web

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado (faltan `.gitkeep` en `l10n/` y `utils/`) · [x] 15+ commits repartidos (18)
- [ ] Splash con imagen de URL y estados · [ ] Onboarding de 3 pantallas, saltable, solo la primera vez (interfaz hecha; falta que el splash lea el «visto»)
- [ ] Firebase documentado · [ ] Registro y acceso con errores tratados (servicio hecho; faltan pantallas) · [ ] Cerrar sesión y cancelar suscripciones (`signOut` hecho)
- [ ] Colecciones de perfiles y contenido (≥6 documentos) · [ ] `withConverter` (existe en `ProfileRepository`, sin usar)
- [ ] Rutas con nombre y paso de parámetros (falta `onGenerateRoute`) · [ ] Barra inferior (lista + cuadrícula, 3 estados)
- [ ] Tabla de pruebas Android/web · [ ] Guía de arranque en el README

## Decisiones pendientes
- Fecha de entrega: 16/10 (docs) o 18/10 (Aitor)
- Qué alimenta la cuadrícula: medallas (`badges`, recomendado) o plantillas (Supabase) → antes de la barra inferior
- `firebase_options.dart` y `google-services.json`: propuesta = entregarlos aparte al profesor + `flutterfire configure` como alternativa, documentado en el README
- Preguntar al profesor si `DataHolder` y `FirebaseAdmin` son obligatorios
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` y el lienzo con el fondo azul y el botón principal al 85→65 %
- Textos ES/EN: literales en español ahora, `AppLocalizations` en la fase 2

## Bloqueos
- Ninguno técnico. Riesgo de plazo: 12 puntos de la checklist sin hacer y ~33 h estimadas frente a 18–24 h disponibles
