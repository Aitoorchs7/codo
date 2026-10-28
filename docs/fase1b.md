# Fase 1b — Fotos, posición y consultas

Fuente: proyecto_fase1b.pdf. Instrumento PY: lo que se construye es parte del producto que se publica y defiende en marzo, no un ejercicio que se tira.

Apertura: **09/10/2026**. Entrega: **13/11/2026** (cierre en el Aula Virtual: domingo 15/11/2026, 23:59). 8 sesiones + casa. Empieza al entregar la Fase 1. **Coincide en fecha con H1** (13/11/2026). Alimenta H2 (18/12/2026) junto con la Fase 2.
Se entrega: repositorio con etiqueta **`fase-1b`** + PDF corto al Aula Virtual con capturas, **URL del hosting** y tabla de pruebas.
Objetivo: la app empieza a parecerse a una de verdad. Se entra con Google, el contenido se consulta de varias maneras y se edita, cada cosa lleva foto hecha con el móvil y una posición, hay un mapa con dónde está todo, y la app se abre desde una URL pública. Todo se desarrolla contra emuladores locales, sin gastar cuota ni ensuciar datos de nadie.

Se trabaja sobre el proyecto propio. En un juego el contenido con foto y posición puede ser el perfil, un nivel creado por el usuario o un marcador en el mundo real; en una aplicación, lo que maneje la función central. Los ejemplos de clase usan la app de mensajes y perfiles; las piezas son las mismas.

## Herramientas (todo gratuito; sin tarjeta, sin plan Blaze, sin clave de API)
- Mapa: **flutter_map** sobre OpenStreetMap.
- Posición: **geolocator**.
- Foto: **miniatura guardada en el propio documento** (base64).
- Hosting y emuladores del plan gratuito de Firebase.
- Quien ya tenga clave de Google Maps o Storage activado puede usarlos con la misma puntuación; no es mérito ni obligación.

## Qué califica cada módulo
| Módulo | Criterio | Qué evidencia aquí |
|---|---|---|
| 0489 | RA2.b ventanas, menús, alertas, controles | Pantallas de acceso con Google, mapa, detalle y confirmaciones |
| 0489 | RA2.d sensores | GPS y cámara |
| 0489 | RA2.g pruebas en emuladores | Emulador Android, navegador y emuladores de Firebase |
| 0489 | RA2.j tecnologías de localización | Comparación breve en el README: GPS, red y proveedor combinado |
| 0489 | RA2.k mapas | Mapa con un marcador por documento |
| 0489 | RA2.l datos de localización | Posición del usuario leída, guardada y usada para ordenar |
| 0489 | RA2.m documentación | README: configuración, emuladores, hosting y URL pública |
| 0489 | RA2.n permisos | Cámara, galería y localización declarados; denegación tratada |
| 0486 | RA4.b conexiones | Sesión de Google ligada al perfil; conexión a los emuladores |
| 0486 | RA4.d persistencia de objetos estructurados | GeoPoint, Timestamp y miniatura dentro del documento |
| 0486 | RA4.e consultas | Cuatro consultas distintas en pantalla |
| 0486 | RA4.f modificar objetos | Editar y borrar documentos propios |
| 0486 | RA4.g lenguaje de consultas BBDDOO | where, orderBy, limit, rango, paginación e índice compuesto |
| 0486 | RA4.i probar y documentar | Tabla de pruebas y datos de prueba exportados |
| 0490 | RA2.a situaciones útiles para varios hilos | El README dice qué va en isolate y qué no, y por qué |
| 0490 | RA2.c programar varios hilos | Compresión de la foto y cálculo de distancias en un isolate |
| 0490 | RA2.e compartir info entre hilos | Progreso comunicado del isolate a la interfaz |

0489 RA3.b y RA3.c (captura y conversión multimedia) y 0490 RA4.h (despliegue en la nube) son del segundo trimestre. La cámara y el hosting se hacen y se califican ahora por los criterios de la tabla; el mismo trabajo se acreditará en la UT04 de cada módulo.

Los puntos suman 10 entre los tres módulos. Cada módulo toma solo sus bloques y los lleva a 10 para su nota. Si no cursas un módulo, la parte que le corresponde se te entrega resuelta y no se califica. Ningún criterio de un módulo depende de lo que hagas en otro.

## Bloques y puntos (total 10)
**Bloque 1 — Entrar con Google** (0489 RA2.b · 0486 RA4.b)
- Acceso con Google funcionando en **Android y en navegador**, con la **cancelación y el error tratados**, y la cuenta ligada al perfil de Firestore: si entra alguien nuevo se le crea el perfil; si ya existía se recupera (1,0)
- **Huellas SHA y cliente OAuth documentados** en el README, y ficheros de configuración fuera del repo con un **.gitignore que lo demuestre**. Una clave subida a GitHub es una clave quemada (0,5)

**Bloque 2 — Consultas que responden preguntas** (0486 RA4.e · RA4.g · RA4.d)
- Colección de contenido con **al menos veinte documentos** y **cuatro consultas distintas**, cada una en una pantalla o filtro: **where con dos condiciones**, **orderBy con limit**, **rango sobre una fecha** y **paginación con startAfterDocument**. El índice compuesto, declarado en **firestore.indexes.json** y no creado a mano desde la consola (1,25)
- Cada pantalla decide entre **escuchar (snapshots)** y **leer una vez (get)**, y el README dice por qué en cada caso. Escucharlo todo siempre no es una decisión (0,5)

**Bloque 3 — Modificar y borrar** (0486 RA4.f)
- Editar y borrar documentos propios con **update y delete**, con **confirmación antes de borrar** y **estado de error** si falla. Lo ajeno no se puede tocar, y **las reglas lo impiden aunque la interfaz no lo ofrezca** (0,75)

**Bloque 4 — Una foto desde la cámara o la galería** (0489 RA2.n · RA2.d · 0490 RA2.c · 0486 RA4.d)
- Elegir imagen desde **cámara y galería**, con permisos declarados en cada plataforma y **denegación tratada con un mensaje que diga qué hacer**. En navegador, la cámara que haya o la galería (0,75)
- **Comprimir en un isolate** (compute o Isolate.run) sin congelar la interfaz, con **indicador de progreso**. Se comprueba moviendo la pantalla durante la compresión (0,75)
- Guardar la miniatura resultante, **de menos de 300 KB, como base64 dentro del documento de Firestore**, y mostrarla en lista y detalle. El README explica el **límite de 1 MB por documento** y por qué se comprime antes (0,5)

**Bloque 5 — Dónde estoy** (0489 RA2.l · RA2.j · RA2.n · 0486 RA4.d)
- Leer la posición con **geolocator**, con el permiso pedido en el momento adecuado, y tratados **permiso denegado, GPS apagado y tiempo de espera agotado**. Ninguno deja la pantalla colgada (0,75)
- Guardar la posición como **GeoPoint con su Timestamp** en el documento del contenido o del perfil, y leerla de vuelta tipada (0,5)
- **Media página en el README** comparando tecnologías de localización: GPS, red y proveedor combinado; precisión, consumo y cuándo usar cada una (0,25)

**Bloque 6 — El mapa** (0489 RA2.k · 0490 RA2.e · RA2.a)
- Mapa con **flutter_map sobre teselas de OpenStreetMap**, un marcador por documento con posición, centrado en el usuario, **atribución a OpenStreetMap visible** y **userAgentPackageName puesto** (lo exige su política de uso). Tocar un marcador abre el detalle (1,0)
- Lista **«cerca de mí»** ordenada por distancia al usuario, **calculada en un isolate que comunica el progreso a la interfaz**. El README dice qué se hizo en isolate, qué no y por qué: ordenar veinte documentos no lo necesita; se hace para medirlo y saberlo (0,5)

**Bloque 7 — En local y en la web** (0489 RA2.g · RA2.m · 0486 RA4.i)
- **Emuladores de Auth y Firestore** conectados por una **bandera de compilación (--dart-define)**, nunca por un booleano a mano, con **datos de prueba exportados al repo e importables con un solo comando** (0,5)
- App desplegada en **Firebase Hosting** con su **URL pública en el README**, y tabla de pruebas en Android y en navegador que incluya **permisos denegados y trabajo sin conexión** (0,5)

## Cómo se corrige
- **Se mira funcionando:** se abre el repo en la etiqueta `fase-1b`, se arranca contra los emuladores siguiendo el README y se usa la app. Lo que no arranque con tus instrucciones, no está entregado.
- **Los permisos se niegan:** se prueba diciendo que no a cámara y localización, y con el GPS apagado. Una app que solo funciona cuando el usuario dice que sí a todo está a medias.
- **La interfaz no se congela:** durante la compresión y el cálculo de distancias se mueve la pantalla. Si se queda clavada, el isolate no hace su trabajo.
- **El historial se lee:** ocho sesiones dejan rastro en los commits. Un volcado la última tarde no condena por sí solo, pero se pregunta.
- **Autoría:** si no puedes explicar por qué una línea está ahí, no es tuya y no puntúa. Se puede usar IA y hay que anotarlo en IA.md.

## Lo que viene después
Cada actividad añade una capa y ninguna se tira.
| Fase | Qué añade | Entrega | Módulo que más califica |
|---|---|---|---|
| 1 · Arranque | Entrada, identidad, datos y navegación | 16/10/2026 | 0489 PMDM |
| **1b · Fotos, posición y consultas** | Google, consultas, cámara, mapa, hosting y emuladores | 13/11/2026 | 0489 PMDM |
| 2 · Datos que duran | Persistencia local, sincronización y trabajo sin conexión | 04/12/2026 | 0486 AD |
| 3 · El servicio | Servidor propio, tiempo real, notificaciones y validación de compras | 29/01/2027 | 0490 PSP |
| 4 · Cobrar y publicar | Compras, anuncios, seguridad, paquete firmado y prueba cerrada | 19/02/2027 | los tres |

La Fase 2 ya está publicada y se puede ir adelantando: lo que se guarde ahora en Firestore es lo que allí tendrá que sobrevivir sin conexión.
