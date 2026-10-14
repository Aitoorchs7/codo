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
4. **Capturas:** pendientes en las dos plataformas.

## Diferencias entre plataformas observadas
- Tamaño de ventana y tipo de tema del sistema (esperado).
- El splash va más rápido en el navegador.
- En pantalla ancha la cuadrícula de medallas muestra más columnas.
- El botón «atrás» (hallazgo 2).
