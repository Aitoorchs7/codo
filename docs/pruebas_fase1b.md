# Registro de pruebas — Fase 1b

Pruebas manuales en **emulador Android** y en **navegador** (`flutter run -d chrome`), siempre contra los emuladores de Firebase:

```bash
firebase emulators:start --import=emulator-data
flutter run --dart-define=USE_EMULATORS=true
flutter run -d chrome --dart-define=USE_EMULATORS=true
```

Las columnas «qué pasó», «diferencias» y «captura» las rellena Aitor tras probar. Una prueba sin hacer no tiene resultado.
Las capturas van en `assets/capturas/`, una por plataforma cuando el resultado sea distinto.

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
| 13 | Historial sin conexión | Modo avión y abrir Mi historial | «No se pudo cargar el historial» + «Reintentar», que funciona al volver la red | | | | |

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
| 22 | Foto con cámara | ⋮ → Añadir prueba → Hacer foto | Diálogo «Preparando la foto» con progreso, «Prueba guardada» y miniatura en la lista | | | | |
| 23 | Foto de la galería | ⋮ → Añadir prueba → Elegir de la galería | Igual que 22 | | | | |
| 24 | Cancelar la foto | Abrir cámara o galería y volver atrás | Vuelve sin error ni diálogo colgado | | | | |
| 25 | Cámara denegada | Denegar el permiso (o Ajustes → Apps → Codo → Permisos → Cámara: No permitir) | Mensaje que dice cómo activarlo y ofrece la galería; la app no se cuelga | | | | |
| 26 | La interfaz no se congela | Elegir una foto grande y mover la pantalla mientras se comprime | El progreso avanza y la pantalla responde | | | | |
| 27 | Tamaño de la miniatura | Ver `proofs/{uid}` en la UI del emulador | Campo `image` en base64 < 300 KB; la sesión no tiene la foto | | | | |
| 28 | Detalle con prueba | Tocar una sesión con prueba | Pantalla de detalle con la foto | | | | |
| 29 | Prueba de otro usuario | Leer `proofs` de una sesión en la que no participas (REST con otro token) | 403; en la app, «Solo los participantes de la sesión pueden ver la prueba» | | | | |
| 30 | Foto sin conexión | Modo avión → hacer la foto y guardar | Mensaje de error de red o se sube al volver la red (anotar cuál); sin diálogo colgado | | | | |

## B5 · Ubicación
Antes de probar en Android: fijar una posición en ⋯ → Location → *Set location*. Para repetir una denegación, restablecer el permiso (Android: Ajustes → Apps → Codo → Permisos; Chrome: candado de la barra de direcciones).

| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 34 | Publicar con ubicación | Activar «Compartir ubicación aproximada» → permitir → Empezar sesión | Se publica; en Firestore, `location` con 2 decimales y `locationAt` como `Timestamp` | | | | |
| 35 | Publicar sin ubicación | Dejar la opción apagada y publicar | No se pide permiso y el documento no tiene `location` ni `locationAt` | | | | |
| 36 | Permiso denegado | Activar la opción → «No permitir» | «Sin permiso de ubicación…»; el botón vuelve a estar activo y se puede publicar apagando la opción | | | | |
| 37 | Denegado para siempre | Android: denegar dos veces. Chrome: bloquear en el candado | «Ubicación bloqueada…» con botón «Ajustes» que abre los ajustes de la app | | | | |
| 38 | GPS apagado | Desactivar la ubicación del sistema y publicar con la opción activa | «Activa el GPS para compartir la ubicación»; sin quedarse en «Publicando…» | | — | En el navegador no hay servicio que apagar | |
| 39 | Tiempo agotado | Emulador sin posición fijada (antes de *Set location*) | A los 10 s, «No se pudo obtener la ubicación…»; sin quedarse en «Publicando…» | | | | |
| 40 | Posición no disponible | Chrome: DevTools → ⋮ → More tools → Sensors → Location → *Location unavailable* | Mensaje de error y el botón vuelve a estar activo | — | | | |

## B6 · Mapa (pendiente: se añade cuando esté hecho)
- Mapa: marcadores, atribución de OpenStreetMap visible, tocar un marcador abre el detalle.
- «Cerca de mí»: orden por distancia y la pantalla se mueve mientras calcula.

## B7 · Emuladores y Hosting
| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 31 | Arranque contra emuladores | Seguir solo los comandos del README en un clon limpio | Arranca con los datos importados (24 sesiones) | | | | |
| 32 | Sin la bandera | `flutter run` sin `--dart-define` | Se conecta a la nube, no a los emuladores (anotar qué se ve) | | | | |
| 33 | URL pública de Hosting | Abrir la URL del README en otro navegador | Carga la app y deja entrar | — | | | |

## Diferencias entre plataformas a vigilar
- **Cámara en el navegador:** `image_picker` abre el selector de archivos (o la webcam en algunos navegadores). Anotar lo que pase en Chrome.
- **Isolates en web:** no hay isolates reales y la compresión corre en el hilo principal, así que la prueba 26 puede ir peor en el navegador. Es esperado y se explica en el README.
- **Permisos:** en Android se gestionan en Ajustes de la app; en web, en el candado de la barra de direcciones. Para repetir una denegación hay que restablecerlos.
- **Google en web:** ventana emergente (puede bloquearla el navegador); en Android, la hoja de cuentas del sistema.
- **Sin conexión:** Firestore tiene caché local, así que unas operaciones fallan y otras se quedan pendientes. Anotar el comportamiento real de cada una.
- **Anchos de pantalla, teclado y tipografías:** en web se puede redimensionar; revisar que nada se desborde.
- **GPS en el emulador** (para B5): la posición se fija en Extended controls → Location.
