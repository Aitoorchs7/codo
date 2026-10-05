# Estado — actualizado 05/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** (coincide con H0, la propuesta; ese documento lo prepara Aitor aparte)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repositorio en GitHub (`Aitoorchs7/codo`) y `.gitignore` con los secretos
- CLAUDE.md, IA.md, README y decisiones de producto (borrador v1)
- Entorno agéntico: 5 agentes y 3 skills (`docs/AGENTES_Y_SKILLS.md`), rules por capa, `/cierre` y permisos en `.claude/settings.json`
- Gestión de estado: `provider`
- Firebase conectado (Auth + Firestore, `initializeApp`) y `AuthService` + `AuthFailure` con errores tratados (solo servicio, aún sin pantallas)

## En curso
- Ítems 1 y 2 de la checklist: carpetas de `lib/`, `MultiProvider` y rutas con nombre

## Siguiente
1. Splash con imagen de URL (carga/error); decide el destino: onboarding, acceso o inicio
2. Onboarding de 3 pantallas (`shared_preferences` para el «ya visto»)
3. Pantallas de acceso y registro con un mensaje por cada `AuthError`; cerrar sesión
4. `models/` + `withConverter` + servicios y repositorios + datos de ejemplo (`users`, `pacts` ≥ 6, `badges`)
5. Barra inferior de 5 secciones: lista (pactos) y cuadrícula (medallas), con 3 estados
6. README: Firebase documentado y guía de arranque; tabla de pruebas Android/web

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado (README listo; faltan las carpetas) · [ ] 15+ commits repartidos (llevamos 5)
- [ ] Splash con imagen de URL y estados · [ ] Onboarding de 3 pantallas, saltable, solo la primera vez
- [ ] Firebase documentado · [ ] Registro y acceso con errores tratados (servicio hecho; faltan pantallas) · [ ] Cerrar sesión y cancelar suscripciones (`signOut` hecho)
- [ ] Colecciones de perfiles y contenido (≥6 documentos) · [ ] `withConverter`
- [ ] Rutas con nombre y paso de parámetros · [ ] Barra inferior (lista + cuadrícula, 3 estados)
- [ ] Tabla de pruebas Android/web · [ ] Guía de arranque en el README

## Decisiones pendientes
- Qué alimenta la cuadrícula: medallas (`badges`, recomendado) o plantillas (hoy asignadas a Supabase, `docs/decisiones_producto.md` §8) → antes de la barra inferior
- Cómo ejecuta el proyecto quien evalúe: `firebase_options.dart` y `google-services.json` no están en el repo → documentar `flutterfire configure` en el README
- Textos ES/EN: montar `AppLocalizations` ya (recomendado, antes de la primera pantalla con texto) o dejarlo para la fase 2
- Los ❓ de `docs/decisiones_producto.md` (precios, nombres de niveles, edad mínima): no bloquean la fase 1

## Bloqueos
- Ninguno
