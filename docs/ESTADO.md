# Estado — actualizado 03/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** (coincide con H0, la propuesta)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter creado y repositorio en GitHub (`Aitoorchs7/codo`)
- CLAUDE.md, IA.md, README, decisiones de producto (borrador v1) y configuración de `.claude/`
- `.gitignore` con los secretos

## En curso
- Configurar la parte agéntica (rules, comando `/cierre`)

## Siguiente
1. Decidir gestión de estado (`provider` o `riverpod`)
2. Crear la estructura de carpetas de `lib/` y explicarla en el README
3. Conectar Firebase (Auth + Firestore)
4. Splash con imagen de URL (carga/error) → onboarding de 3 pantallas → registro/acceso

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado · [ ] 15+ commits repartidos (llevamos 1)
- [ ] Splash con imagen de URL y estados · [ ] Onboarding de 3 pantallas, saltable, solo la primera vez
- [ ] Firebase documentado · [ ] Registro y acceso con errores tratados · [ ] Cerrar sesión y cancelar suscripciones
- [ ] Colecciones de perfiles y contenido (≥6 documentos) · [ ] `withConverter`
- [ ] Rutas con nombre y paso de parámetros · [ ] Barra inferior (lista + cuadrícula, 3 estados)
- [ ] Tabla de pruebas Android/web · [ ] Guía de arranque en el README

## Decisiones pendientes
- Gestión de estado · los ❓ de `docs/decisiones_producto.md` (precios, nombres de niveles, edad mínima)

## Bloqueos
- Ninguno
