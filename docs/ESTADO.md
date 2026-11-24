# Estado — actualizado 16/11/2026

**Fase actual:** 3 · El servicio, entrega **20/12/2026** (H3, etiqueta `fase-3`); va **antes** que la Fase 2 (17/01/2027). Plazos cambiados el 24/11. En paralelo: actividad AI2 de PSP en la rama `feat/ai2-red-isolates`. Rúbrica y plan por días: `docs/fase3.md`. Fechas: `docs/hitos.md`
**Fases 1 y 1b:** cerradas y entregadas (18/10 y 15/11, etiqueta `fase-1b` en `c019f4c`)

## Hecho
- Fase 1 y 1b completas (B1–B7 de 1b, tabla de pruebas de 55 filas y PDF en `docs/entrega/`); H1 documentado; auditoría en `docs/seguridad_auditoria.md`
- Entorno agéntico: 5 agentes, 4 skills (incluida `rls`), `/cierre` y rules por capa
- Fase 3 planificada: `docs/fase3.md` (8 bloques, puntos y días) y fechas corregidas en `docs/hitos.md`
- Proyecto en **plan Blaze** con presupuesto y alerta de 5 €
- `functions/` en Python 3.14 (`python314`), emulador de Functions en el 5001, `set_global_options(max_instances=3, region="europe-west1")`; venv y `*.local` fuera de git
- `flutter analyze` limpio y 26 pruebas en verde (16/11); 130 commits

## En curso
- Nada de código. Sin commit: `docs/fase3.md`, `docs/hitos.md` y este ESTADO

## Siguiente
1. B1: typedef de función propio y closure con estado en el proyecto; anotarlos en el README con `map`/`where`/`fold`/`sort` y los callbacks que ya hay
2. B2: cliente de Open-Meteo (`http`, `fromJson`, timeout, reintento, estados) con URL por `--dart-define`
3. B3 + B4: `joinSession` (`on_call`) con plazas en `@firestore.transactional` y script de 50 llamadas con y sin transacción
4. B3: función de Firestore (XP al crear prueba, cierra V-03) y programada (cerrar pactos caducados)
5. Decidir el caso de Stripe (propuesta: donación de prueba) antes del 25/11
6. Crear el subagente revisor del servidor (cliente que miente, dos llamadas a la vez)

## Checklist fase 3 (10 puntos; detalle en `docs/fase3.md`)
- [ ] B1 Funciones como valores (0,5) (hay callbacks y `sort`/`fold`; falta typedef de función, closure y README)
- [ ] B2 API REST pública con estados y `--dart-define` (1,0)
- [ ] B3 Tres funciones Python (HTTP, Firestore, programada) + README FaaS (1,25) (solo `functions/` inicializado)
- [ ] B4 Transacción en el servidor + script de 50 llamadas + README (1,5)
- [ ] B5 FCM: permiso, token, `onTokenRefresh`, 3 estados, abrir pantalla, envío desde función (1,5)
- [ ] B5b Stripe prueba: PaymentIntent, webhook con firma y transacción, pago rechazado (1,5)
- [ ] B6 WebSocket Dart (`shelf`) + cliente, 2 clientes y reconexión (1,25)
- [ ] B7 Desplegado, ruta de salud, colección de peticiones y registros (0,75) (Blaze activo)
- [ ] B8 Diagrama de 4 modelos, commits pequeños, `fase-3` y `.gitignore` (0,75)

## Decisiones pendientes
- Caso de Stripe: Comodín y Plus son digitales (Play Billing, fase 4); propuesta de donación de prueba
- Auditoría: quedan V-01 (`friends` sin aplicar en reglas) y V-03 (XP/medallas escritos por el usuario; se resuelve con la función de Firestore)
- Freno al abuso (16/11): en la fase 3, usuario identificado obligatorio y validación en cada función. App Check, límite por usuario y bloqueo automático, en la **fase 4**; apagar la facturación por presupuesto se descarta porque tumba Hosting y Firestore
- Unirse a sesiones: se hará con `joinSession` en el servidor (B4); revisar la regla `update` de `participantIds` y pasar `deleteSession` a `WriteBatch`
- Miniatura en `proofs` y no en la sesión: preparar la respuesta para la defensa
- Pendiente para la fase 2: clustering de marcadores, `pacts` y `badges` en `emulator-data/`, comentario «TEMPORAL» de sus reglas; Drift aún no está en `pubspec.yaml`

## Bloqueos
- Ninguno. Con los nuevos plazos (Fase 3 el 20/12 y Fase 2 el 17/01) el riesgo de calendario baja
