---
name: commits
description: Propone commits pequeños con mensajes claros agrupando los cambios sin commit. Úsala cuando Aitor diga "commits", "qué commiteo" o termine un trozo de trabajo. No hace el commit.
---
# Proponer commits

El historial se evalúa y debe verse repartido en el tiempo (≥ 15 commits en la fase 1), con mensajes descriptivos.

## Pasos
1. Ejecuta `git status --short` y `git diff --stat` (y `git diff` de los ficheros que haga falta para entender el cambio).
2. Agrupa los cambios por **una sola intención** cada grupo. Si un fichero mezcla dos intenciones, avísalo y sugiere `git add -p`.
3. Para cada grupo da:
   - Los ficheros: `git add <rutas>`.
   - El mensaje con el formato `tipo(ámbito): qué` en español, imperativo, ≤ 72 caracteres.
   - Tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`.
   - Ámbitos habituales: `splash`, `onboarding`, `auth`, `firestore`, `routes`, `nav`, `theme`, `docs`.
4. Orden recomendado: primero lo que otros cambios necesitan (modelos, servicios), luego pantallas, luego docs.

## Avisos obligatorios
- **Nunca** propongas añadir `google-services.json`, `firebase_options.dart`, `*.jks`, `key.properties` ni `.env`. Si aparecen en `git status`, avisa de que hay que ponerlos en `.gitignore`.
- Si el cambio es enorme (más de ~300 líneas o más de 3 intenciones), propón dividirlo en varios commits en lugar de uno.
- No agrupes cosas solo para "gastar" menos commits ni propongas commits vacíos para inflar el número.

## Reglas
- NO ejecutes `git commit` ni `git push`: lo hace Aitor.
- Si hay una entrada de IA.md pendiente, recuérdalo al final (una línea).
