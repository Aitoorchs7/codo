# Fase 3 — El servicio

Fuente: Fase3_El_servicio.pdf. Instrumento PY: lo que se construye es parte del producto que se publica y defiende en marzo, no un ejercicio que se tira.

Entrega: **domingo 29/11/2026, 23:59** (hito **H3 · El servicio funcionando**). 8 sesiones + casa. **Se entrega antes que la Fase 2** (04/12, Aula 06/12): se adelantó para cerrar las aplicaciones antes de Flame. Lo que se guarde aquí en Firestore es lo que en la Fase 2 tendrá que sobrevivir sin conexión. La validación de compras pasa a la Fase 4.
Se entrega: repositorio con etiqueta **`fase-3`** + PDF corto al Aula con capturas, **diagrama** y **resultado del script concurrente**.
Objetivo: la app habla con una API de otros, tiene funciones propias en la nube que hacen lo que el móvil no puede hacer con garantías, cobra con Stripe (modo prueba), avisa con la app cerrada y mantiene un canal en tiempo real entre varios usuarios.

## Dónde corren las funciones (por este orden; los tres puntúan igual)
1. **Plan Blaze** con presupuesto y alerta configurados antes de desplegar, y `max_instances` en cada función. ← **elegido (16/11)**: presupuesto de 5 €, `max_instances=3`, `region="europe-west1"`
2. Emulator Suite (la programada se invoca a mano y se explica en el README)
3. Proyecto del profesor

Push no se emula: va a FCM real (gratuito). Stripe es para lo que **no** es digital dentro de la app (Comodín y Plus van con Play Billing en la Fase 4): si no se vende nada físico, un caso razonable (donación, entrada) explicado en el README. Ninguna credencial (cuenta de servicio, claves de Stripe, VAPID, ficheros de configuración) va al repo.

## Qué califica cada módulo
| Módulo | Criterio | Qué evidencia aquí |
|---|---|---|
| 0489 | RA2.e conexiones HTTP/HTTPS | Funciones como valores; la app como cliente de la API pública, de Stripe y de las notificaciones |
| 0489 | RA2.m documentación | README: infraestructura elegida, cómo se arranca y cómo se prueba |
| 0486 | RA4.a BD de objetos: ventajas e inconvenientes | Qué resuelve y qué no una base documental para lo que se hace en el servidor |
| 0486 | RA4.h transacciones | Transacciones de Firestore en el servidor: operación concurrente y pedido pagado |
| 0486 | RA4.k metodología | Etiqueta `fase-3` e historial de commits |
| 0490 | RA3.a escenarios de red | Qué partes necesitan comunicarse en red y por qué |
| 0490 | RA3.b roles cliente/servidor | Quién es cliente y quién servidor en cada pieza |
| 0490 | RA3.e sockets cliente | La app como cliente del WebSocket y de las notificaciones |
| 0490 | RA3.f servidor en red verificado | Servidor WebSocket propio, verificado |
| 0490 | RA3.g intercambio por sockets | Mensajes por el canal entre varios clientes |
| 0490 | RA3.i hilos, varios clientes | Varios clientes conectados a la vez |
| 0490 | RA3.j modelos de comunicación | Petición-respuesta, push, WebSocket y disparador, comparados y dibujados |
| 0490 | RA3.k depurar y documentar | Ruta de salud, colección de peticiones y registros |
| 0490 | RA3.l control de versiones | Etiqueta `fase-3` e historial |

## Bloques y puntos (total 10)
**Bloque 1 — Funciones como valores** (0489 RA2.e)
- En el proyecto, no en ejercicios: `typedef` de función propio, callback de hijo a padre (p. ej. `onSeleccionar`), `map`/`where`/`fold`/`sort` con funciones, y un closure que capture estado (contador o filtro configurable). El README señala dónde está cada uno (0,5)

**Bloque 2 — Una API REST de verdad** (0489 RA2.e)
- API pública por HTTPS con sentido en el producto: modelo con `fromJson`, tiempo de espera, un reintento y estados de carga/vacío/error. Ninguna URL ni clave en el código: `--dart-define` (1,0)

**Bloque 3 — Funciones serverless** (0490 RA3.a · RA3.b · RA3.j)
- Cloud Functions en **Python** con tres disparadores: HTTP (`https_fn.on_request` u `on_call`) que la app usa de verdad, Firestore (`on_document_created`/`updated`) y programada (`scheduler_fn.on_schedule`) que limpie o resuma (1,0)
- Media página en el README: qué es FaaS, quién es cliente y quién servidor en cada función, y comparación breve con AWS Lambda y Supabase Edge Functions (0,25)

**Bloque 4 — Transacciones** (0486 RA4.h · RA4.a)
- Operación del servidor con `@firestore.transactional` (contador, plazas, stock o nombre único). Un script lanza **≥ 50 llamadas a la vez** y demuestra que no se pierde ni duplica nada; después, lo mismo **sin** transacción para ver el fallo (1,0)
- README: por qué va en el servidor y no en el móvil, y qué da y qué no Firestore frente a una relacional para esta operación (0,5)

**Bloque 5 — Notificaciones push** (0489 RA2.e · 0490 RA3.e)
- FCM: permiso en el momento adecuado (Android 13+ y navegador), token en el perfil y actualizado con `onTokenRefresh`. Se recibe abierta, en segundo plano y cerrada, y al pulsar abre la pantalla que corresponde (1,0)
- La envía una función cuando pasa algo que importa al usuario, nunca a todos. Probado en móvil o emulador con Google Play (0,5)

**Bloque 5b — Stripe en modo prueba** (0489 RA2.e · 0486 RA4.h)
- Una función crea el PaymentIntent (o sesión de Checkout) con la clave secreta como **secreto de Functions**; la app muestra el pago (`flutter_stripe` en móvil, Checkout en web) y se paga con tarjeta de prueba (0,75)
- Webhook en otra función que **comprueba la firma** y solo entonces registra el pedido en una transacción. Probado con `stripe listen` y con un **pago rechazado**. La app no da nada por pagado hasta que lo dice el servidor (0,75)

**Bloque 6 — Tiempo real con sockets** (0490 RA3.e · RA3.f · RA3.g · RA3.i)
- Canal propio por WebSocket, servidor en Dart (`shelf` + `shelf_web_socket`), app como cliente (`web_socket_channel`) (1,0)
- Dos o más clientes a la vez ven lo mismo; si uno pierde la conexión, se reconecta solo y no se queda colgado (0,25)

**Bloque 7 — Desplegado y comprobado** (0490 RA3.k · 0489 RA2.m)
- Funciones funcionando en la infraestructura elegida y el README dice cuál y por qué. Ruta de salud, colección de peticiones (Bruno, Postman o script) y captura de los registros de una ejecución (0,75)

**Bloque 8 — Dibujado y versionado** (0490 RA3.j · RA3.l · 0486 RA4.k)
- Diagrama con los cuatro modelos (petición-respuesta, push, canal bidireccional, disparador) y una línea por cada uno sobre cuándo conviene (0,5)
- Commits pequeños, etiqueta `fase-3` y credenciales fuera con un `.gitignore` que lo demuestre (0,25)

## Cómo se corrige
- **Se mira funcionando**: se arranca desde la etiqueta `fase-3` siguiendo el README. Lo que no arranque, no está entregado.
- **Se intenta romper**: red cortada a mitad de llamada, servidor WebSocket cerrado con dos clientes, script concurrente.
- **La notificación se pulsa** con la app cerrada y debe abrir la pantalla correcta, no la de inicio.
- **El historial se lee**: ocho sesiones dejan rastro en los commits.
- **Autoría y agentes**: lo que no se sepa explicar no puntúa. En esta fase se crea un **agente o subagente que revise cada función del servidor** (¿y si el cliente miente?, ¿y si llegan dos llamadas a la vez?) y se anota en `IA.md` qué encontró.

## Plan para Codo (16/11)
| Bloque | Pts | Encaje en Codo | Días |
|---|---|---|---|
| B1 | 0,5 | Ya hay callbacks y `sort`/`fold`; falta typedef de función, closure y README | L16 |
| B2 | 1,0 | Open-Meteo (sin clave, usa la ubicación aproximada): el tiempo para la tarea de «Ahora» | M17–X18 |
| B3 + B4 | 2,75 | `joinSession` (`on_call`) con plazas en transacción; XP al crear una prueba (cierra V-03); programada que cierra pactos caducados | J19–V20 |
| B5 | 1,5 | Push al unirse un amigo a tu sesión o al hacer check-in tu compañero de pacto | S21–D22 |
| B6 | 1,25 | Estado en directo de los participantes de una sesión de «Ahora» | L23–M24 |
| B5b | 1,5 | Propuesta: donación de prueba (pendiente de decidir; Comodín y Plus van con Play Billing) | X25–J26 |
| B7 + agente | 0,75 | Ruta de salud, colección de Bruno, registros; subagente revisor del servidor | V27 |
| B8 + PDF | 0,75 | Diagrama, README, tabla de pruebas, PDF y etiqueta | S28–D29 |
