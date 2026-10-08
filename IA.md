# IA.md — Bitácora de uso de IA

Registro de cómo uso asistentes, agentes y skills en Codo. No se apunta todo, **solo lo que decidió algo**: una arquitectura, una corrección, una idea aceptada o descartada.

**Herramientas:** Claude (chat del proyecto y Claude Code en el repositorio), con los agentes y skills de `.claude/`.
**Regla personal:** no acepto código que no sepa explicar. Si la IA propone algo, lo entiendo, lo adapto y lo escribo yo.

## Formato de cada entrada
```
### NNN · AAAA-MM-DD · Título corto
- **Fase / hito:**
- **Qué pedí:**
- **Qué me dio:**
- **Qué corregí o descarté, y por qué:**
- **Resultado (commit / fichero):**
```

---

### 001 · 2026-10-03 · Organizar el proyecto y la parte agéntica
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** que estudiara los documentos del proyecto (enunciado, cronograma, rúbricas, guía de publicación y fases 1–4) y me ayudara a organizar cómo trabajar con IA: las instrucciones del proyecto en Claude, la documentación de contexto y los ficheros base del repositorio (`CLAUDE.md`, `IA.md`, `README.md` y la carpeta `.claude/`).
- **Qué me dio:** resúmenes en Markdown de los requisitos por fase con su puntuación, unas instrucciones de trabajo (yo escribo el código; la IA revisa, explica y propone el cambio mínimo), un borrador de decisiones de producto y estos tres ficheros.
- **Qué corregí o descarté, y por qué:**
  - La IA propuso un **límite de puntos por día** contra las trampas. **Lo descarté**: castiga al usuario que un día se levanta productivo.
  - Me quedé con la verificación social (el compañero valida el check-in) y con la foto hecha en el momento.
  - Decidí que **en un pacto pierden los dos** si uno falla, y que la parte **Ahora** sea sobre todo con amigos.
- **Resultado:** `CLAUDE.md`, `IA.md`, `README.md` y `docs/decisiones_producto.md` (borrador v1).

---

### 002 · 2026-10-08 · Rutas con nombre y «onboarding visto»
- **Fase / hito:** Fase 1 / H0.
- **Qué pedí:** cómo pasar de página en el onboarding y cómo terminarlo (`_finish`) guardando que ya se ha visto; dónde va cada cosa en las carpetas.
- **Qué me dio:** explicación de `PageController`, de `routes` frente a `onGenerateRoute`, de `shared_preferences` y de `async`/`await`/`mounted`; revisión de `app.dart` y de `_finish`; valoración del patrón de «admins» del profesor.
- **Qué corregí o descarté, y por qué:**
  - Mi primer `_finish` no guardaba nada (variables locales que desaparecen). Lo pasé a una clase `PreferencesAdmin`, fuera de la pantalla, para que el splash lea lo mismo.
  - Mantengo `screens/` aunque los documentos decían `views/` [tu motivo].
  - La IA propuso dejar las preferencias en `services/`. Lo moví todo a `admins/`, incluido `AuthService`, porque lo pide el profesor y me parece más claro.
  - `DataHolder` y `FirebaseAdmin` quedan pendientes de preguntar al profesor [confirma si lo decides].
- **Resultado:** `lib/admins/preferences_admin.dart`, `lib/app/app_routes.dart`, `lib/screens/onboarding/onboarding_screen.dart`.

## Agentes y skills propios
| Nombre | Tipo | Creado | Qué tarea repetida resuelve | Trabajo ahorrado (medido) |
|---|---|---|---|---|
| — | — | — | — | — |
