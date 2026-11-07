# Registro de pruebas — Fase 1

**Fecha:** 14/10/2026 · **Probó:** Aitor
**Android:** emulador `sdk gphone16k x86 64`, Android 17 (API 37) · **Navegador:** Google Chrome 154 (`flutter run -d chrome`)
Los resultados son los que Aitor dio al probar. Donde dio un solo resultado para las dos plataformas, se repite en ambas columnas y se anota en «Diferencias / notas».

| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android | Navegador | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 1 | Splash con imagen | Arrancar con red | Se ve la imagen y después navega según sesión | Correcto | Correcto | Solo cambian el tamaño y el tipo de tema, es normal | |
| 2 | Splash con URL rota | Cambiar la URL por una falsa o quitar la red | Estado de error de imagen, sin romper, y sigue navegando | Sale «No se pudo cargar la imagen» | Igual | En el navegador va más rápido | |
| 3 | Onboarding la primera vez | Borrar datos de la app / ventana de incógnito | Salen las 3 páginas | Se muestra correctamente | Igual | Ninguna | |
| 4 | Onboarding no se repite | Verlo, cerrar y reabrir | Va directo al acceso | No se repite | No se repite | Ninguna | |
| 5 | Onboarding «Saltar» | Primera vez, pulsar Saltar | Va al acceso y la segunda vez no aparece | Correcto | Correcto | Ninguna | |
| 6 | Registro: correo ya usado | Registrar un correo existente | Mensaje concreto de ese error | «Este correo ya tiene cuenta» y ofrece entrar | Igual | Ninguna | |
| 7 | Registro: contraseña débil | Menos de 6 caracteres | Mensaje concreto de contraseña débil | Indica el mínimo de 6 caracteres | Igual | Ninguna | |
| 8 | Registro: correo inválido | Texto sin `@` | Mensaje concreto de correo inválido | Correcto | Correcto | Ninguna | |
| 9 | Registro correcto | Correo nuevo y contraseña válida | Entra a la app y aparece `users/{uid}` en la consola | Entra directamente; aparece en Authentication y en Firestore | Igual | Ninguna | |
| 10 | Acceso: credenciales incorrectas | Contraseña equivocada | Mensaje concreto, sin entrar | «Correo o contraseña incorrectos, revísalos e inténtalo de nuevo» | Igual | Resultado dado en común para ambas plataformas | |
| 11 | Acceso correcto | Credenciales válidas | Entra a Home | Entra | Entra | Sin diferencias | |
| 12 | Sesión persistente | Con sesión, cerrar la app y reabrir | Va directo a Home | Entra directo a Home sin pasar por el acceso | Igual | Resultado dado en común para ambas plataformas | |
| 13 | Cerrar sesión | Perfil → Cerrar sesión, luego «atrás» | Vuelve al acceso y atrás no regresa a Home | Se queda en el acceso | Se queda en el acceso | Sin diferencias | |
| 14 | Sin errores tras cerrar sesión | Cerrar sesión con la consola de `flutter run` visible | Ningún error de Firestore | Salen 2 avisos `PERMISSION_DENIED` de Firestore (`badges` y `pacts`) | No se observó ningún error | Avisos del SDK, no visibles para el usuario. Ver «Hallazgos» | |
| 15 | Barra inferior | Pulsar las 5 pestañas y volver | Cambia de sección y conserva el scroll | Conserva el scroll y el estado al volver | Igual | «Atrás»: en Android sale de la app; en web no deja volver | |
| 16 | Pactos con datos | Con los 6 pactos subidos | Lista de 6 tarjetas completas | Aparecen todos los pactos | Igual | Resultado dado en común para ambas plataformas | |
| 17 | Pactos cargando | Red lenta (Slow 3G / emulador) | Se ve el indicador de carga | Carga casi al instante, sin llegar a verse el indicador | Igual | Estado de carga sin comprobar visualmente | |
| 18 | Pactos vacío | Borrar los documentos de `pacts` | «Todavía no hay pactos.» | Con datos salen los pactos; al borrarlos se vació sola, sin recargar, y no queda ninguno | Igual | Aitor confirma que el caso funciona | |
| 19 | Pactos error | Regla `allow read: if false;` en `pacts` | Mensaje de error + «Reintentar» | Sale el error | Sale el error | Aitor confirma que funciona como pide el caso | |
| 20 | Medallas con datos | Perfil con las 6 subidas | Cuadrícula con imagen, nombre y XP | Salen perfectamente | Salen perfectamente | En ordenador caben más columnas en horizontal | |
| 21 | Medallas con imagen rota | `imageUrl` falsa en una medalla | Icono de trofeo | Sale el icono de la copa al instante | Igual | Ninguna | |
| 22 | Medallas cargando, vacío y error | Igual que 17, 18 y 19 en `badges` | Mismos estados que Pactos | Cargan al instante; vacío y error se comportan como en Pactos | Igual | Aitor lo confirma | |
| 23 | Detalle de pacto | Tocar una tarjeta | Abre el pacto correcto y la flecha vuelve | Se abre la pantalla encima de la lista, sin fallos | Igual | Ninguna | |
| 24 | Modo claro y oscuro | Cambiar el tema del sistema | Todo legible en ambos modos | Cambia el tema con el sistema | Igual | Ninguna | |
| 25 | Letra grande | Opciones de accesibilidad | Sin desbordamientos | La letra se amplía según las opciones y funciona | Igual | Ninguna | |
| 26 | Ancho de pantalla (web) | Redimensionar la ventana | La cuadrícula cambia de columnas y nada se rompe | — | Se redimensiona y se coloca todo bien | Solo aplica al navegador | |

## Hallazgos
1. **Fila 14: avisos de Firestore al cerrar sesión (Android).** En el log aparecen dos `PERMISSION_DENIED` (`Listen ... badges` y `Listen ... pacts`). Al cerrar sesión, durante unos instantes las dos suscripciones siguen vivas sin usuario y las reglas las rechazan. No se ve en pantalla y no es un fallo de la app: son avisos del SDK. Se probó navegar antes de cerrar sesión y los avisos siguen saliendo, porque `pushNamedAndRemoveUntil` mantiene la pantalla antigua viva hasta que acaba la animación (~300 ms) y las suscripciones no se cancelan antes. Se mantiene el orden original (cerrar sesión y luego navegar), que además no deja al usuario con la sesión abierta si `signOut` fallara.
2. **Fila 15: «atrás» no es igual.** En Android, desde la pantalla principal «atrás» sale de la app (lo normal). En web no hay nada a donde volver porque la pila de rutas solo tiene `Home`.
3. **Fila 17: el estado de carga no se ha visto.** Firestore responde casi al instante; queda anotado como no comprobado visualmente.
4. **Capturas:** hechas. Web (17) en `assets/images/capturas/web` y Android (12) en `assets/images/capturas/android`.
5. **Capturas que faltan o no coinciden.** El splash con error no se capturó en Android porque la imagen carga demasiado rápido (`android_02_splash_error.png` no muestra el mensaje de error); está capturado en web (`web_02_splash.png`) y es el mismo código. Los textos del onboarding se corrigieron después de hacer las capturas (faltaban espacios) y esas capturas no se repitieron.

## Diferencias entre plataformas observadas
- Tamaño de ventana y tipo de tema del sistema (esperado).
- El splash va más rápido en el navegador.
- En pantalla ancha la cuadrícula de medallas muestra más columnas.
- El botón «atrás» (hallazgo 2).

---

# Registro de pruebas — Fase 1b

**Fecha:** 07/11/2026 · **Probó:** Aitor · **Contra:** Firebase en la nube (el profesor confirmó que no puntúa las pruebas en emuladores)
**Android:** emulador · **Navegador:** Google Chrome (`flutter run -d chrome`) · **Capturas:** `docs/capturas/fase1b/`

| # | Qué se prueba | Cómo provocarlo | Resultado esperado | Android | Navegador | Diferencias / notas | Captura |
|---|---|---|---|---|---|---|---|
| 1 | Publicar una sesión | Ahora → Nueva sesión → Empezar sesión | Aparece al momento en Ahora | Correcto | Correcto | Ninguna | |
| 2 | Sesión no pública | Interruptor «Pública» apagado | No sale en Ahora | Correcto | Correcto | Ninguna | |
| 3 | Sale en Mi historial | Perfil → Mi historial | Salen las sesiones creadas | Correcto | Correcto | Ninguna | |
| 4 | Validación al crear | Descripción vacía / 0 minutos | Mensaje bajo cada campo, no se publica | Correcto | Correcto | Ninguna | |
| 5 | Crear sin red | Modo avión → crear sesión | Aviso «se publicará al recuperar la red» y la sesión sale en Ahora | Correcto: sale desde la caché local y se sube al volver la red | Correcto | Compensación de latencia de Firestore | `p05_android_crear_sin_red_*` |
| 6 | Reglas: leer la prueba de otro | Rules Playground, `get` en `live_sessions/{id}/proofs/{uid}` con UID `leo-falso` | Denegado | Se rechazó la lectura simulada | — | Probado en la consola de Firebase | `p06_reglas_ajena_denegada` |
| 7 | Reglas: leer la prueba propia | Rules Playground con el uid del dueño | Permitido | Se autorizó la lectura simulada | — | Probado en la consola de Firebase | `p07_reglas_propia_permitida` |
| 8 | Foto con cámara | Mi historial → ⋮ → Añadir prueba → Hacer foto | Barra, peso antes/después y «Prueba guardada» | 133 KB → 62 KB, guardada | Abre el selector de archivos | El navegador de escritorio no abre la webcam con `image_picker` | `p08_android_camara_133_62` |
| 9 | Foto de galería | Añadir prueba → Elegir de la galería | Igual que 8 | 133 KB → 62 KB | Fotos grandes: 2401 KB → 94 KB (4K) y 1908 KB → 61 KB | | `p09_web_galeria_1908_61` |
| 10 | Cancelar la elección | Cerrar la cámara o el selector sin elegir | No pasa nada | Correcto | Correcto | Ninguna | |
| 11 | Compresión moviendo la pantalla | Girar el emulador o hacer scroll mientras comprime | La barra sigue sin tirones | La barra sigue sin tirones | Se congela ~1,5 s sin barra y después sale la vista previa | En web no hay isolates: se comprime en el hilo que pinta (README, «Fotos de prueba») | |
| 12 | Detalle con y sin prueba | Tocar una fila del historial | Foto grande / «Todavía no hay prueba de esta sesión» | Correcto | Correcto | Ninguna | |
| 13 | Cámara denegada | Ajustes → Aplicaciones → codo → Permisos → Cámara → No permitir | SnackBar que dice qué hacer | «Sin permiso de cámara. Actívalo en Ajustes > Aplicaciones > Codo > Permisos, o elige una foto de la galería» | — | En web no se pide permiso: se usa el selector de archivos | `p13_android_camara_denegada` |
| 14 | Galería con la cámara denegada | Tras 13 → Elegir de la galería | Funciona | Correcto | — | La galería no necesita permiso | |
| 15 | Historial sin red | Modo avión / DevTools → Red → Sin conexión | No se rompe | Lista cargada; las pruebas ya vistas salen de la caché y las demás con icono de error | Lista cargada; primero salieron las pruebas ya vistas y la que no tenía con error; en otra entrada salieron todas con error | En web la caché es solo de memoria y no siempre conserva las miniaturas | `p15_web_historial_sin_red` |
| 16 | Guardar prueba sin red | Sin red → Guardar → esperar 10 s | Aviso «la prueba se subirá al recuperar la red» y se sube al volver | Aviso a los 10 s, miniatura desde la caché, se sube al volver | Aviso a los 10 s; al volver la red aparecen las miniaturas | Antes del arreglo se quedaba sin responder | `p16_web_prueba_*` |
| 17 | «Atrás» desde Home | Pulsar atrás en Home | Sale de la app | Correcto tras el arreglo | — | Antes mostraba «Ruta no válida» (ver hallazgo 1) | |
| 18 | Editar y borrar lo ajeno (B3) | REST contra el emulador con el token de Leo | 403 | 403 al editar, al borrar y al cambiar `creatorId` (04/11) | — | Probado en el emulador | `../b3_ana_200.png` |
| 19 | Google: éxito · cancelar · error | | | | | | |
| 20 | Ubicación: éxito · denegada · GPS apagado · tiempo agotado | | | | | | |
| 21 | Mapa y «cerca de mí» | | | | | | |
| 22 | URL pública de Hosting | | | | | | |

## Hallazgos (fase 1b)
1. **Fila 17: «atrás» mostraba «Ruta no válida».** `initialRoute` era `/splash`; Flutter apila también `/` debajo y, como no existía, generaba la página de error. Se cambió la ruta del splash a `/`.
2. **Fila 16: guardar la prueba sin red se quedaba sin responder.** Firestore guarda la escritura en local y el `Future` no termina hasta que vuelve la red. Se añadió un `.timeout` de 10 s con aviso, igual que al crear sesión.
3. **Fallo encontrado al revisar las capturas:** las sesiones salían con «Sin nombre» o con el nombre vacío porque `displayName` de la cuenta llegaba `null` o `""`. Ahora el nombre sale del perfil (`users/{uid}`).
4. **Fila 11:** la congelación en web es la diferencia esperada entre plataformas; en Android el isolate mantiene la interfaz fluida.

## Diferencias entre plataformas observadas (fase 1b)
- Cámara: en el navegador de escritorio se abre el selector de archivos.
- Compresión: en web congela la pantalla ~1,5 s; en Android la barra avanza.
- Permisos: en web no hay permiso de cámara que denegar.
- Sin red: Android conserva en disco las pruebas ya vistas; en web la caché es solo de memoria.
