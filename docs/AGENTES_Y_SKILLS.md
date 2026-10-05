# Agentes y skills propios de Codo

Todo vive en `.claude/` y está pensado para que otra persona pueda reutilizarlo copiando la carpeta. Los agentes **solo leen**: el código lo escribe siempre el autor del proyecto.

## Agentes (`.claude/agents/`)
| Agente | Para qué | Cuándo se usa | Puede editar |
|---|---|---|---|
| `revisor-codo` | Revisión de código con hallazgos ordenados (bugs y seguridad → rúbrica → arquitectura → ideas) | Antes de cada commit importante | No |
| `auditor-rubrica` | Compara el repo con el checklist de la fase y dice qué falta y el riesgo de fecha | Cada semana y 3-4 días antes de entregar | No |
| `auditor-ui` | Estados carga/vacío/error, paleta, claro/oscuro, accesibilidad, localización y capas en las pantallas | Al terminar una pantalla y antes de las capturas | No |
| `tester-codo` | Ejecuta `flutter analyze`/`test`, propone casos de prueba (incluidos los casos malos) y explica los fallos | Al terminar una funcionalidad y antes de probar en emulador/navegador | No (solo ejecuta comandos de lectura) |
| `tribunal-defensa` | Simula el tribunal: preguntas sobre código real, cambios en directo, justificación de decisiones | Una vez por semana desde la fase 2 | No |

Cómo invocarlos: pedirlo en lenguaje natural ("pasa el auditor de rúbrica") o con `@revisor-codo` en Claude Code. Cada agente trabaja en su propio contexto y devuelve solo el resumen, así no gasta la conversación principal.

## Skills (`.claude/skills/`)
| Skill | Para qué | Cómo se usa |
|---|---|---|
| `commits` | Agrupa los cambios y propone commits pequeños `tipo(ámbito): qué` sin hacerlos | `/commits` |
| `tabla-pruebas` | Prepara la tabla de pruebas Android/navegador sin inventar resultados | `/tabla-pruebas` |
| `bitacora-ia` | Borrador de entrada para `IA.md` | `/bitacora-ia` |

## Comando (`.claude/commands/`)
| Comando | Para qué | Quién lo lanza |
|---|---|---|
| `/cierre` | Actualiza `docs/ESTADO.md` y propone los commits (skill `commits`) y la entrada de `IA.md` (skill `bitacora-ia`). No hace commit ni escribe en `IA.md`. | Solo Aitor, al terminar la sesión |

## Rules por capa (`.claude/rules/`)
Se cargan solas cuando Claude lee ficheros que encajan con su `paths`, así que no gastan contexto el resto del tiempo. `CLAUDE.md` fija la arquitectura; las rules fijan cómo se escribe cada capa y están alineadas con los criterios de `auditor-ui` y `revisor-codo`.
| Fichero | Se carga al tocar | Fija |
|---|---|---|
| `views.md` | `lib/views/`, `lib/widgets/` | Nombres, sin acceso directo a datos, 4 estados, tema y accesibilidad, `dispose`, uso de `provider` |
| `repositories.md` | `lib/repositories/` | Única puerta de datos, devuelven modelos, `Stream`/`Future`, sin Flutter |
| `services.md` | `lib/services/` | Una fuente externa por servicio, dependencias inyectadas, excepciones del SDK → fallo de dominio |
| `models.md` | `lib/models/` | Inmutables, conversor para `withConverter`, datos corruptos |
| `app.md` | `lib/app/`, `lib/main.dart` | `main()` mínimo, `MultiProvider`, rutas con nombre (`AppRoutes`) y argumentos tipados |
| `tests.md` | `test/` | Casos malos, sin red real, nunca desactivar pruebas |

Aún no hay rules de Drift ni del servidor (`server/`): se escriben al empezar las fases 2 y 3.

## Permisos (`.claude/settings.json`)
Hace cumplir por la herramienta lo que `CLAUDE.md` dice en prosa. Cada regla de `Bash` tiene su gemela de `PowerShell`, porque en Windows Claude puede usar cualquiera de las dos terminales.
- **Permitido sin preguntar:** `flutter analyze`, `flutter test`, `flutter pub get` y git de solo lectura (`status`, `diff`, `log`, `show`).
- **Pregunta siempre:** editar `pubspec.yaml` (dependencias solo con propuesta previa) y `android/app/build.gradle.kts` (`signingConfigs`, `applicationId`).
- **Denegado:** `git commit`, `git push`, `flutter upgrade`; leer o editar secretos (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, `key.properties`, `*.jks`, `.env*`); editar generados (`*.g.dart`, `GeneratedPluginRegistrant*`) y las carpetas `ios/`, `macos/`, `linux/` y `windows/`.
- **Probado el 05/10/2026:** se deniegan leer rutas con nombre de secreto (con `Read`, `cat` y `Get-Content`), escribir en ellas (`Write` y redirecciones `>`), `Write` sobre un `*.g.dart` y `git commit` en las dos terminales, incluida la variante `git -C . commit`. Sin probar a propósito: `ios/`, `macos/`, `linux/` y `windows/`, para no tocarlas.
- **Límite conocido:** son barreras prácticas, no un blindaje. Solo reconocen comandos conocidos (`git`, `cat`, redirecciones…): un script o un programa que lea o escriba por su cuenta se las salta.

## Decisiones y descartes (por si preguntan en la defensa)
- **Agentes de solo lectura.** Descartado un agente que escriba código: rompe la autoría, que es eliminatoria.
- **Pocos y generales** en vez de uno por capa o por pantalla: cada descripción siempre cargada gasta contexto y son más difíciles de explicar.
- **Tres skills** para tareas repetitivas con formato fijo (commits, pruebas, bitácora). El resto se hace pidiéndolo en el chat.
- **Rules por capa con `paths`** (descartado: meterlo todo en `CLAUDE.md`): `CLAUDE.md` se carga siempre y las normas de una capa solo hacen falta al tocarla.
- **Permisos en `settings.json`** (descartado: confiar solo en la prosa de `CLAUDE.md`): la herramienta impide el commit, el push y el acceso a secretos aunque la IA se equivoque.
- **`git commit` y `git push` denegados, no «preguntar»**: un «sí» por despiste rompería la regla de que el autor hace sus commits.
- **Rutas con `Navigator` y `onGenerateRoute`** (descartado: `go_router`): no añade dependencia, cubre «rutas con nombre y parámetros» y se puede explicar línea a línea.
- **No instalar** plugins genéricos de ventas, finanzas, RR. HH. ni marketing: no son del proyecto y solo añaden ruido.
- **Pendiente para más adelante** (fases 3-4): `auditor-seguridad` (validación en servidor, compras idempotentes, secretos) y una skill `checklist-play-store` para la prueba cerrada.

## Registro de uso
Cada vez que uno de estos agentes o skills cambie una decisión o detecte un fallo real, anotar una entrada en `IA.md`.
