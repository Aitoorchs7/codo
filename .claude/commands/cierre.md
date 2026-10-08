---
description: Cierra la sesión: actualiza docs/ESTADO.md y propone los commits y la entrada de IA.md
disable-model-invocation: true
---
Cierra la sesión de trabajo de Codo. No hagas commit ni push y no escribas en `IA.md`: solo propones.

## 1. Qué ha cambiado
- Ejecuta `git status --short` y `git log --oneline` (fechas con `git log --format=%ad --date=short`). Lee solo los diffs que necesites.
- Compáralo con `docs/ESTADO.md`: qué está terminado, qué sigue abierto y qué no estaba previsto.

## 2. Actualiza `docs/ESTADO.md`
Léelo y edítalo; Aitor revisa el diff antes de aceptar.
- Título con la fecha de hoy (`dd/mm/aaaa`).
- **Hecho**: lo terminado, una línea por cosa. **En curso**: solo lo que sigue abierto. **Siguiente**: máximo 6 pasos, ordenados por dependencias.
- **Checklist**: marca `[x]` solo lo que esté **entero** y comprobado en el código. Si está a medias, déjalo `[ ]` y anota entre paréntesis lo que falta. Actualiza «llevamos N» con el número de commits.
- **Decisiones pendientes** y **Bloqueos**: añade lo nuevo y quita lo resuelto.
- Mantén el fichero por debajo de ~45 líneas: se carga entero en cada sesión (`@docs/ESTADO.md` en CLAUDE.md).

## 3. Bitácora
Si Aitor tomó una decisión con ayuda de la IA (eligió entre alternativas, descartó o corrigió una propuesta), usa la skill `bitacora-ia` para dar el borrador de la entrada de `IA.md`. Si se creó un agente, skill o comando nuevo, propón también su fila en la tabla «Agentes y skills propios» y deja «Trabajo ahorrado» para que lo mida él. Si no hubo ninguna decisión propia, dilo en vez de inventarla.

## 4. Commits
Ejecuta `flutter analyze` y `flutter test`; si alguno no sale limpio, avísalo primero (CLAUDE.md y `.claude/rules/tests.md` lo exigen antes de cada commit). Después usa la skill `commits` para proponer los commits de lo que siga sin commitear.

## 5. Resumen
Termina con 6 líneas como máximo: qué cambió en `ESTADO.md`, qué queda para la próxima sesión y si hay riesgo con la fecha de entrega (días que quedan frente a puntos de la checklist sin hacer).
