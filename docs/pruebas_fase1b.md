# Registro de pruebas — Fase 1b

**Probó:** Aitor · **Android:** emulador · **Navegador:** Google Chrome (`flutter run -d chrome`) · **Contra:** Firebase en la nube (el profesor confirmó que no puntúa las pruebas en emuladores; los emuladores siguen funcionando, ver fila 31 y el README).

Las columnas «qué pasó», «diferencias» y «captura» las rellena Aitor tras probar. Una prueba sin hacer no tiene resultado.
Las capturas van en `docs/capturas/fase1b/`, una por plataforma cuando el resultado sea distinto. Las pruebas de B4 y de crear sesión se hicieron el 07/11 (antes estaban en `docs/pruebas.md`).

## B1 · Acceso con Google
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 1 | Google la primera vez | Entrar con una cuenta de Google que nunca ha entrado | Entra a Home y se crea `users/{uid}` (visible en la UI del emulador, puerto 4000) | | | | |
| 2 | Google con perfil existente | Cerrar sesión y volver a entrar con la misma cuenta | Entra y recupera el mismo perfil, sin duplicarlo | | | | |
| 3 | Cancelar Google | Abrir el selector de cuentas y cerrarlo (atrás / cerrar la ventana emergente) | Vuelve al acceso **sin mensaje de error** | | | | |
| 4 | Google sin conexión | Modo avión (Android) / DevTools → Network → Offline (web) y pulsar Google | Mensaje de error de red, sin quedarse cargando | | | | |

## B2 · Consultas
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 5 | Ahora · Recientes | Abrir Ahora con los datos del seed | Sesiones activas públicas, las más recientes primero y con límite | | | | |
| 6 | Ahora · filtro por categoría | Pulsar cada chip de categoría | Solo sesiones de esa categoría (`where` con dos condiciones) | | | | |
| 7 | Ahora en directo (snapshots) | Con Ahora abierta, cambiar el `status` de una sesión en la UI del emulador | La lista se actualiza sola, sin recargar | | | | |
| 8 | Ahora vacío | Filtrar por una categoría sin sesiones activas | «Ahora mismo no hay nadie con una sesión abierta» | | | | |
| 9 | Ahora con error | Parar el emulador de Firestore con la pantalla abierta | «No se pudieron cargar las sesiones» + «Reintentar» | | | | |
| 10 | Historial paginado | Perfil → Mi historial → «Cargar más» hasta el final | Cada página trae las siguientes sin repetir; al final desaparece el botón | | | | |
| 11 | Historial por rango de fechas | Icono de filtro → elegir un rango con sesiones | Solo sesiones entre esas fechas (incluido el último día) | | | | |
| 12 | Rango sin resultados | Elegir un rango sin sesiones | «No hay sesiones entre esas fechas»; «Quitar filtro» vuelve a la lista | | | | |
| 13 | Historial sin conexión | Modo avión y abrir Mi historial | «No se pudo cargar el historial» + «Reintentar», que funciona al volver la red | Lista cargada: las pruebas ya vistas salen de la caché y las demás con icono de error | Lista cargada; primero salieron las pruebas ya vistas y la que no tenía, con error; en otra entrada salieron todas con error | No sale el error con «Reintentar»: Firestore sirve la lista desde la caché. En web la caché es solo de memoria y no siempre conserva las miniaturas | `p15_web_historial_sin_red` |

## B3 · Editar y borrar
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 14 | Editar lo propio | Historial → ⋮ → Editar, cambiar descripción y duración → Guardar | Se guarda y la lista lo muestra | | | | |
| 15 | Validación al editar | Descripción vacía / duración 0 o 500 | «Escribe qué estás haciendo» / «Entre 1 y 480 minutos»; no se guarda | | | | |
| 16 | Terminar una sesión | ⋮ → Terminar en una sesión en curso | Pasa a «Terminada» con `endedAt` | | | | |
| 17 | Borrar lo propio | ⋮ → Borrar → confirmar | Pide confirmación («No se puede deshacer») y desaparece | | | | |
| 18 | Borrar con participantes | ⋮ → Borrar en una sesión con más participantes | SnackBar «No puedes modificar esta sesión»; la sesión sigue | | | | |
| 19 | Editar lo ajeno | Petición REST al emulador con el token de otro usuario (Leo sobre la sesión de Ana) | 403 de las reglas | — | — | Probado el 04/11: Ana 200, Leo 403. Captura de la pestaña Requests | |
| 20 | Cambiar `creatorId` | Petición REST que modifica `creatorId` | 403 (`affectedKeys`) | — | — | Probado el 04/11 | |
| 21 | Editar sin conexión | Modo avión → editar y guardar | SnackBar «Sin conexión. Inténtalo de nuevo» o el cambio queda pendiente y se sube al volver la red (anotar cuál) | | | | |

## B4 · Foto de prueba
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 22 | Foto con cámara | ⋮ → Añadir prueba → Hacer foto | Diálogo «Preparando la foto» con progreso, «Prueba guardada» y miniatura en la lista | 133 KB → 62 KB, barra de progreso y «Prueba guardada» | Abre el selector de archivos | El navegador de escritorio no abre la webcam con `image_picker` | `p08_android_camara_133_62` |
| 23 | Foto de la galería | ⋮ → Añadir prueba → Elegir de la galería | Igual que 22 | 133 KB → 62 KB | Fotos grandes: 2401 KB → 94 KB (4K) y 1908 KB → 61 KB |  | `p09_web_galeria_1908_61` |
| 24 | Cancelar la foto | Abrir cámara o galería y volver atrás | Vuelve sin error ni diálogo colgado | Correcto: no pasa nada | Correcto | Ninguna |  |
| 25 | Cámara denegada | Denegar el permiso (o Ajustes → Apps → Codo → Permisos → Cámara: No permitir) | Mensaje que dice cómo activarlo y ofrece la galería; la app no se cuelga | «Sin permiso de cámara. Actívalo en Ajustes > Aplicaciones > Codo > Permisos, o elige una foto de la galería»; la galería sigue funcionando | — | En web no se pide permiso de cámara: se usa el selector de archivos | `p13_android_camara_denegada` |
| 26 | La interfaz no se congela | Elegir una foto grande y mover la pantalla mientras se comprime | El progreso avanza y la pantalla responde | La barra sigue sin tirones | Se congela ~1,5 s sin barra y después sale la vista previa | En web no hay isolates: se comprime en el hilo que pinta (README, «Fotos de prueba») |  |
| 27 | Tamaño de la miniatura | Ver `proofs/{uid}` en la UI del emulador | Campo `image` en base64 < 300 KB; la sesión no tiene la foto | Miniatura de 62 KB (≈ 83 KB en base64) | Máximo medido 94 KB (≈ 125 KB en base64) | Pesos medidos en las pruebas 22 y 23; el base64 ocupa 4/3 del JPEG |  |
| 28 | Detalle con prueba | Tocar una sesión con prueba | Pantalla de detalle con la foto | Correcto: foto grande; sin prueba, «Todavía no hay prueba de esta sesión» | Correcto | Ninguna |  |
| 29 | Prueba de otro usuario | Leer `proofs` de una sesión en la que no participas (REST con otro token) | 403; en la app, «Solo los participantes de la sesión pueden ver la prueba» | Rules Playground: lectura con UID `leo-falso` denegada; con el UID del dueño, permitida | — | Probado en la consola de Firebase | `p06_reglas_ajena_denegada`, `p07_reglas_propia_permitida` |
| 30 | Foto sin conexión | Modo avión → hacer la foto y guardar | Mensaje de error de red o se sube al volver la red (anotar cuál); sin diálogo colgado | Aviso a los 10 s, miniatura desde la caché y se sube al volver la red | Aviso a los 10 s; al volver la red aparecen las miniaturas | Antes del arreglo se quedaba sin responder (hallazgo 2) | `p16_web_prueba_*` |

## B5 · Ubicación
Antes de probar en Android: fijar una posición en ⋯ → Location → *Set location*. Para repetir una denegación, restablecer el permiso (Android: Ajustes → Apps → Codo → Permisos; Chrome: candado de la barra de direcciones).

| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 34 | Publicar con ubicación | Activar «Compartir ubicación aproximada» → permitir → Empezar sesión | Se publica; en Firestore, `location` con 2 decimales y `locationAt` como `Timestamp` | Se publica al instante en Firestore y aparece en Ahora con todos sus datos | Pide el permiso de ubicación y se publica igual que en Android | En los dos, varias sesiones creadas en el mismo sitio comparten el punto redondeado y en el mapa solo se ve un marcador (límite conocido, ver README) | |
| 35 | Publicar sin ubicación | Dejar la opción apagada y publicar | No se pide permiso y el documento no tiene `location` ni `locationAt` | | | | |
| 36 | Permiso denegado | Activar la opción → «No permitir» | «Sin permiso de ubicación…»; el botón vuelve a estar activo y se puede publicar apagando la opción | | | | |
| 37 | Denegado para siempre | Android: denegar dos veces. Chrome: bloquear en el candado | «Ubicación bloqueada…» con botón «Ajustes» que abre los ajustes de la app | | | | |
| 38 | GPS apagado | Desactivar la ubicación del sistema y publicar con la opción activa | «Activa el GPS para compartir la ubicación»; sin quedarse en «Publicando…» | | — | En el navegador no hay servicio que apagar | |
| 39 | Tiempo agotado | Emulador sin posición fijada (antes de *Set location*) | A los 10 s, «No se pudo obtener la ubicación…»; sin quedarse en «Publicando…» | | | | |
| 40 | Posición no disponible | Chrome: DevTools → ⋮ → More tools → Sensors → Location → *Location unavailable* | Mensaje de error y el botón vuelve a estar activo | — | | | |

## B6 · Mapa y «Cerca de mí»
Antes: 3 o más sesiones públicas con ubicación en sitios distintos (en Android, cambiando *Set location* entre una y otra) y alguna sin ubicación.

| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 41 | Mapa de OSM | Ahora → icono del mapa | Teselas de OpenStreetMap, se puede mover y hacer zoom; «OpenStreetMap contributors» visible | | | | |
| 42 | Marcadores | Mirar el mapa con las sesiones de prueba | Un marcador por sesión pública con ubicación; las que no tienen ubicación no salen | | | | |
| 43 | Marcador → detalle | Tocar un marcador | Abre el detalle de esa sesión (la foto solo si eres participante) | | | | |
| 44 | Centrado en el usuario | Abrir el mapa con permiso de ubicación | El mapa se mueve a tu posición y aparece tu marcador | | | | |
| 45 | Mapa sin permiso | Denegar la ubicación y abrir el mapa | Se queda en Madrid con aviso; «Cerca de mí» desactivado; el mapa sigue funcionando | | | | |
| 46 | «Cerca de mí» ordenada | Mapa con tu posición → «Cerca de mí» | Lista de la más cercana a la más lejana con «≈ X km»; tocar una fila abre el detalle | | | | |
| 47 | Progreso y tiempo | Abrir «Cerca de mí» tres veces y mirar la terminal | Barra de progreso sin congelar la pantalla; `debugPrint` con los ms (ver README) | 73 / 61 / 57 ms | 22 / 17 / 17 ms | Android usa isolate y tarda más: el coste es arrancarlo | |
| 48 | Nadie cerca | «Cerca de mí» sin sesiones con ubicación | «Nadie cerca ha compartido su ubicación» | | | | |
| 49 | Mapa sin conexión | Modo avión (Android) / DevTools → Offline (web) y abrir el mapa | No se cuelga: teselas que no cargan y marcadores de la caché de Firestore (anotar qué se ve) | | | | |

## B7 · Emuladores y Hosting
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 31 | Arranque contra emuladores | Seguir solo los comandos del README en un clon limpio | Arranca con los datos importados (24 sesiones) | | | | |
| 32 | Sin la bandera | `flutter run` sin `--dart-define` | Se conecta a la nube, no a los emuladores (anotar qué se ve) | | | | |
| 33 | URL pública de Hosting | Abrir <https://codo-941ac.web.app> en otro navegador o en incógnito | Carga la app y deja entrar | — | | | |

## Crear sesión y navegación (07/11)
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 50 | Publicar una sesión | Ahora → Nueva sesión → Empezar sesión | Aparece al momento en Ahora | Correcto | Correcto | Ninguna | |
| 51 | Sesión no pública | Interruptor «Pública» apagado | No sale en Ahora | Correcto | Correcto | Ninguna | |
| 52 | Sale en Mi historial | Perfil → Mi historial | Salen las sesiones creadas | Correcto | Correcto | Ninguna | |
| 53 | Validación al crear | Descripción vacía / 0 minutos | Mensaje bajo cada campo, no se publica | Correcto | Correcto | Ninguna | |
| 54 | Crear sin red | Modo avión → crear sesión | Aviso «se publicará al recuperar la red» y la sesión sale en Ahora | Correcto: sale desde la caché local y se sube al volver la red | Correcto | Compensación de latencia de Firestore | `p05_android_crear_sin_red_*` |
| 55 | «Atrás» desde Home | Pulsar atrás en Home | Sale de la app | Correcto tras el arreglo | — | Antes mostraba «Ruta no válida» (hallazgo 1) | |

## Hallazgos
1. **Fila 55: «atrás» mostraba «Ruta no válida».** `initialRoute` era `/splash`; Flutter apila también `/` debajo y, como no existía, generaba la página de error. Se cambió la ruta del splash a `/`.
2. **Fila 30: guardar la prueba sin red se quedaba sin responder.** Firestore guarda la escritura en local y el `Future` no termina hasta que vuelve la red. Se añadió un `.timeout` de 10 s con aviso, igual que al crear sesión.
3. **Al revisar las capturas:** las sesiones salían con «Sin nombre» o con el nombre vacío porque `displayName` de la cuenta llegaba `null` o `""`. Ahora el nombre sale del perfil (`users/{uid}`).
4. **Fila 26:** la congelación en web es la diferencia esperada entre plataformas; en Android el isolate mantiene la interfaz fluida.

## Diferencias entre plataformas observadas (07/11)
- Cámara: en el navegador de escritorio se abre el selector de archivos.
- Compresión: en web congela la pantalla ~1,5 s; en Android la barra avanza.
- Permisos: en web no hay permiso de cámara que denegar.
- Sin red: Android conserva en disco las pruebas ya vistas; en web la caché es solo de memoria.

## Diferencias entre plataformas a vigilar
- **Cámara en el navegador:** `image_picker` abre el selector de archivos (o la webcam en algunos navegadores). Anotar lo que pase en Chrome.
- **Isolates en web:** no hay isolates reales y la compresión corre en el hilo principal, así que la prueba 26 puede ir peor en el navegador. Es esperado y se explica en el README.
- **Permisos:** en Android se gestionan en Ajustes de la app; en web, en el candado de la barra de direcciones. Para repetir una denegación hay que restablecerlos.
- **Google en web:** ventana emergente (puede bloquearla el navegador); en Android, la hoja de cuentas del sistema.
- **Sin conexión:** Firestore tiene caché local, así que unas operaciones fallan y otras se quedan pendientes. Anotar el comportamiento real de cada una.
- **Anchos de pantalla, teclado y tipografías:** en web se puede redimensionar; revisar que nada se desborde.
- **GPS en el emulador** (para B5): la posición se fija en Extended controls → Location.
