# Requisitos del producto — Proyecto integrado DAM 2026/27

Fuente: Enunciado_Proyecto_DAM.pdf (IES Newton-Salas). Es la lista contra la que se mide si el producto está completo.

## Qué hay que hacer
Una aplicación (o videojuego) en Flutter, publicada en Google Play, con todo lo de un producto real: cuentas de usuario, datos que no se pierden, servicio propio, notificaciones, cobros dentro de la app y anuncios. Algo que un desconocido instala desde la tienda, usa sin explicaciones y por lo que podría pagar.

Itinerario elegido: **Aplicación** → una necesidad real de un grupo de personas (organizarse, aprender, llevar la cuenta de algo, conocer gente con un interés común) que hoy se resuelve mal.

Modalidad: **individual** (Aitor).

## Módulos que evalúan
| Módulo | Qué mira |
|---|---|
| 0486 AD | Datos: persistencia local y remota, sincronización, offline, copias y exportación, catálogo/ranking relacional, capa de acceso a datos |
| 0489 PMDM | Producto en el móvil: interfaz, navegación, multimedia, permisos, empaquetado, firma, publicación en Google Play |
| 0490 PSP | Servicio: procesos e isolates, red, API o tiempo real con varios clientes, verificación de compras en servidor, seguridad del conjunto |

## Checklist de requisitos (todos obligatorios)

### Entrada y cuenta · 0489 · 0490
- [ ] Pantalla de arranque, icono adaptativo y nombre propios
- [ ] Presentación de la primera vez (onboarding), que se puede saltar
- [ ] Registro y acceso con correo y con Google
- [ ] Recuperar la contraseña
- [ ] Perfil editable con foto
- [ ] Borrar la cuenta desde la app **y** desde una página web (exigencia de Google Play)

### La experiencia · 0489
- [ ] Navegación completa con al menos **cinco secciones**
- [ ] Estados de carga, vacío y error en cada pantalla que pide datos
- [ ] Modo claro y oscuro
- [ ] Español e inglés
- [ ] Ajustes (idioma, notificaciones, sonido, privacidad)
- [ ] Sonido y animaciones con sentido, no de adorno
- [ ] Accesible con letra grande y lector de pantalla

### Los datos · 0486
- [ ] Persistencia local que funciona sin conexión
- [ ] Sincronización con el almacén remoto al recuperar la red
- [ ] Contenido del usuario que no se pierde al reinstalar
- [ ] Exportar y recuperar una copia de los datos del usuario
- [ ] Un marcador, ranking o catálogo en base de datos relacional

### El servicio · 0490
- [ ] Servicio propio o funciones en la nube que atienden a varios clientes a la vez
- [ ] Validación de las compras en el servidor
- [ ] Canal en tiempo real (multijugador, chat, marcador en vivo o avisos)
- [ ] Notificaciones push
- [ ] Trabajo pesado fuera del hilo de la interfaz (isolates)

### Cobros y anuncios · 0489 · 0490 · 0486
- [ ] Tienda o pantalla de pago con productos de Google Play Billing
- [ ] Restaurar compras
- [ ] Anuncios de prueba con consentimiento previo
- [ ] Lo comprado guardado y sincronizado

### Producto serio · 0490 · 0489
- [ ] Reglas de seguridad y roles; nada de claves en el repositorio
- [ ] Tráfico cifrado y comprobación de integridad de la app
- [ ] Registro de errores en producción
- [ ] Configuración remota para activar/desactivar funciones sin publicar
- [ ] Enlaces que abren la app en la pantalla correcta (deep links)
- [ ] Compartir contenido y pedir valoración en la tienda

### La tienda · 0489
- [ ] Paquete firmado (.aab) con clave propia, que **no** va al repositorio
- [ ] Ficha completa, capturas y gráfico destacado
- [ ] Política de privacidad publicada en una URL
- [ ] Declaración de seguridad de los datos y clasificación por edad
- [ ] Versión subida a la prueba cerrada, con probadores

## Cobros y anuncios — reglas
Mínimo:
- Al menos **dos productos** de Google Play Billing: uno **consumible** (monedas, créditos…) y uno **permanente o suscripción** (quitar anuncios, versión completa, ventaja mensual).
- Pantalla de pago clara con el **precio que devuelve la tienda**, nunca escrito a mano.
- Restaurar compras; lo comprado sigue al reinstalar o cambiar de móvil.
- La compra se **valida en el servidor** antes de entregar lo comprado.
- Anuncios de prueba de AdMob (banner, intersticial o recompensa) con **consentimiento RGPD previo**, y que desaparezcan al comprar la versión sin anuncios.

No se admite:
- Cajas de botín o azar a cambio de dinero.
- Precios engañosos o botones de pago disfrazados.
- Dirigir la app a menores de 13 años.

Todo en modo prueba (probadores con licencia, anuncios de prueba). Cobrar dinero real no se exige ni se evalúa.

## IA, agentes y skills (Nivel 2: uso libre con defensa)
Obligatorio en el repositorio:
- `CLAUDE.md` o `AGENTS.md` en la raíz: arquitectura, normas del proyecto y lo que el agente no debe tocar.
- Al menos **una skill propia** que resuelva una tarea repetida (crear pantalla con sus cuatro estados, añadir producto de pago, preparar versión para la tienda…).
- Al menos **un agente/subagente** con función concreta (revisar seguridad, escribir pruebas, revisar ficha de la tienda…) y su definición en el repo.
- Bitácora `IA.md`: qué pediste, qué te dio, qué corregiste y por qué (solo lo que decidió algo).

> En la defensa se puede pedir explicar cualquier línea y modificar el código sin asistente. Si no puedes explicar por qué una línea está ahí, no es tuya y no puntúa.

## Entregables
| Entregable | Obligatorio |
|---|---|
| Repositorio con historial repartido en el tiempo (profesor invitado desde el día 1) | sí |
| .aab firmado subido a la prueba cerrada de Google Play | sí |
| Ficha de la tienda, política de privacidad, seguridad de datos, clasificación por edad | sí |
| CLAUDE.md/AGENTS.md + al menos una skill y un agente propios | sí |
| Memoria del proyecto | sí |
| Manual técnico | sí |
| Manual de usuario | sí |
| Registro de pruebas | sí |
| Registro de seguridad y privacidad | sí |
| Bitácora IA.md | sí |
| Presentación del producto en PDF | sí |
| Declaración de autoría firmada | sí |
| Publicación en producción abierta | no (mérito) |
