# Decisiones de producto — Codo

Estado: **borrador v1.1 (18/10/2026)**. Se cerrará en H1 (13/11/2026). Lo marcado con ❓ está pendiente. Cambios de la v1.1: ubicación, mapa y fotos para la fase 1b (sección 4, 5, 7, 8, 11 y 12).

## 1. Propuesta de valor
**En una frase:** Codo te ayuda a cumplir tus objetivos haciéndolos acompañado: ahora mismo con quien está haciendo lo mismo, o durante días con un pacto con un amigo.

**En un párrafo:** las apps de organización se abandonan porque cumplir solo cuesta. Codo convierte los objetivos en algo compartido. En **Ahora**, publicas lo que estás haciendo en este momento y tus amigos se unen haciendo lo mismo. En **Pacto**, te comprometes con otra persona a un reto de la duración que elijáis, con un check-in diario. Si uno falla, pierden los dos. Lo que mueve la app no son los puntos, sino no fallar a quien va contigo y aprender de gente con tus mismos objetivos.

## 2. Público
Jóvenes y adultos (estudiantes, opositores, gente que entrena o quiere crear hábitos) que se motivan más en compañía. **No dirigida a menores de 13 años.** ❓ Edad mínima concreta en la ficha de Play (recomendación: 16+, por fotos, ubicación y contacto con otros usuarios).

**Personas tipo**
- **Lucía, 20, estudiante de DAM.** Le cuesta ponerse a estudiar sola por la tarde. Abre Ahora, ve que dos amigas están estudiando y se une. Al terminar sube la foto de sus apuntes.
- **Marcos, 27, quiere volver al gimnasio.** Hace un pacto de 30 días con un amigo: "entrenar 4 días por semana". El check-in del compañero le recuerda que, si falla, pierden los dos.

## 3. Secciones (barra inferior, 5)
| Sección | Qué es | Pantalla principal |
|---|---|---|
| **Hoy** | Tu día de un vistazo, con la parte de "organizar la vida" | Objetivos de hoy (lista personal sencilla y offline), check-ins de pacto pendientes, amigos que están en Ahora y botón "Empezar ahora" |
| **Ahora** (nombre provisional; candidato: *Codo a codo*) | Tareas en directo y acompañadas | Sesiones activas de amigos (y públicas) en tiempo real, filtros por categoría, **vista de mapa y lista «cerca de mí»** de sesiones públicas, botón **+** para publicar la tuya y opción de **unirte** a cualquier sesión que veas |
| **Pactos** | Retos con otra persona | Lista de tus pactos activos con su progreso, invitaciones, tablón de pactos abiertos, catálogo de plantillas en **cuadrícula** y botón **+** para crear un pacto |
| **Amigos** | Lo social y la competición sana | Ranking entre amigos (semana/mes/total), solicitudes y búsqueda de usuarios |
| **Perfil** | Identidad y progreso | Nivel, medallas en **cuadrícula**, **historial de sesiones (por rango de fechas y paginado)**, ajustes y Codo Plus |

Fase 1 pide una lista y una cuadrícula desde Firestore: la lista son los pactos y la cuadrícula, el catálogo de plantillas o las medallas.

## 4. Mecánicas
### Ahora
- Publicas una sesión con el botón **+**: categoría (estudiar, entrenar, leer, trabajar, otro), descripción corta y duración prevista. **Opcionalmente añades tu ubicación aproximada** (ver más abajo).
- **Visibilidad:** por defecto la ven los **amigos**. Opcionalmente, **pública** por categoría.
  - *Por qué amigos primero:* con amigos hay compromiso real, hace falta menos moderación y se evita el problema de las salas vacías cuando hay pocos usuarios. La opción pública le da vida a la app cuando crezca.
- **Unirse a una sesión (decisión, se desarrolla):** desde la lista o el detalle de una sesión, pulsas **Unirme** y entras como participante haciendo lo mismo. Todos ven en tiempo real quién está, quién se une y cuánto le queda. Puedes **salir** cuando quieras. Al terminar, cada participante sube su propia prueba y recibe su XP según el tiempo que haya estado dentro.
- **Editar y borrar:** el creador puede editar la descripción y la duración de su sesión y borrarla (con confirmación). Nadie más puede tocarla y las reglas de Firestore lo impiden aunque la interfaz no lo ofrezca. ❓ Qué pasa al borrar una sesión que ya tiene participantes (¿solo se permite si está vacía, o se cancela para todos?).
- **Prueba al terminar:** foto hecha con la cámara en el momento (no desde la galería), con sello de hora, y una frase opcional. La ven solo los participantes de esa sesión.
- **Recompensa:** XP según el tiempo. Una sesión larga (❓ umbral, por ejemplo más de 2 h) da medalla.

### Ubicación, mapa y «cerca de mí» (decisión 18/10/2026, fase 1b)
- La **ubicación es opcional** y solo se pide cuando el usuario quiere añadirla a una sesión o abrir «cerca de mí», con una explicación del porqué. Si la deniega, la app funciona igual (permiso denegado, GPS apagado y tiempo agotado tratados).
- La posición que se guarda en la sesión es **aproximada** (redondeada, ❓ precisión, por ejemplo ~500 m–1 km), nunca la exacta, como `GeoPoint` con su `Timestamp`. La posición exacta del usuario solo se usa en el móvil para calcular distancias y centrar el mapa; **no se guarda en el perfil**.
- **El mapa muestra solo sesiones públicas con ubicación.** Las sesiones de amigos aparecen en la lista, no en el mapa. ❓ Si los amigos ven la posición aproximada de una sesión de amigos.
- **«Cerca de mí»:** lista de sesiones públicas ordenada por distancia al usuario, calculada en un isolate con progreso hacia la interfaz.
- Mapa con **flutter_map sobre OpenStreetMap** (gratis, sin clave): atribución visible y `userAgentPackageName` puesto. Tocar un marcador abre el detalle de la sesión.
- Remote Config puede desactivar el mapa público sin publicar.

### Pacto (la parte principal)
- Lo creas con el botón **+** desde cero, o desde una plantilla del catálogo: objetivo, duración (la que quieras), frecuencia de check-in (diaria) y con quién.
- **Con quién:** un amigo (invitación) o cualquier usuario que lo acepte desde el **tablón de pactos abiertos**.
- **Check-in diario:** foto y nota que muestran que estás más cerca del objetivo. El compañero lo ve y puede darle el **visto bueno** o pedir explicación. Los pactos **no llevan ubicación**.
- **Si uno no hace el check-in del día y no usa un comodín, el pacto se rompe y pierden los dos.**
- **Al completarlo:** XP para los dos, medalla del objetivo cumplido en el perfil y opción de compartirlo.
- ❓ Pactos de más de 2 personas → ampliación.
- ❓ ¿El "pedir explicación" del compañero puede llegar a invalidar el check-in, o solo es social?

### Puntos, niveles y medallas
- **XP** → **niveles con nombre propio** (❓ nombres por decidir; ejemplo: Arranque, En marcha, Constante, Imparable, Leyenda).
- **Medallas** = objetivos cumplidos: pacto completado, sesión larga, primeras veces, etc. Se muestran en el perfil.
- La XP de un pacto **solo se entrega al completarlo**. Si se rompe, nadie la recibe.
- Los puntos **no se compran nunca** y el ranking es **entre amigos**: no hay premio externo que incentive hacer trampa.

### Anti-trampas (decisión)
Es imposible demostrar que alguien no está viendo una serie, así que se diseña para que hacer trampa no compense:
1. Los puntos tienen poco valor fuera de ti: ranking entre amigos y sin premios.
2. Verificación social: el compañero de pacto ve y valida tus check-ins.
3. Fricción ligera: foto de cámara en el momento, con sello de hora.

Descartado: límite de puntos por día, porque corta las alas a quien un día está muy productivo. Pospuesto a v2: detectar si el usuario sale de la app durante la sesión.

## 5. Privacidad y moderación (MVP)
- **Denunciar y bloquear** usuarios y contenido (obligatorio por las normas de Google Play para contenido de usuarios), y un rol de administración para revisar denuncias.
- Las fotos solo las ven los participantes de esa sesión o pacto, y se **borran al terminar**. ❓ Plazo exacto (por ejemplo, 7 días después de terminar).
- **Las fotos se guardan como miniatura base64 (menos de 300 KB) en un documento aparte, legible solo por los participantes** (subcolección `proofs`), nunca en el documento de la sesión, porque una sesión pública la puede leer cualquiera. Firebase Storage no se usa: exigiría plan Blaze y la fase 1b no lo pide. Borrar la foto = borrar ese documento.
- **Ubicación:** opcional, aproximada y solo visible en el mapa si la sesión es pública. No se guarda la posición exacta ni el historial de posiciones. Se declara en la política de privacidad y en el formulario de seguridad de los datos (ubicación aproximada: para qué, si se comparte).
- Todo esto queda declarado en la política de privacidad y en el formulario de seguridad de los datos.

## 6. Modelo de ingresos
| Producto | Tipo Play Billing | Qué da | Precio orientativo ❓ |
|---|---|---|---|
| **Comodín** (packs de 1/3/5) | Consumible | Saltarte un día de check-in sin romper el pacto | 0,99 € / 2,49 € / 3,99 € |
| **Codo Plus** | Permanente (pago único) | Sin anuncios, pactos activos ilimitados (gratis: ❓ 3) y estadísticas | 4,99 € |

- Se valida en el servidor antes de conceder nada, se puede restaurar y lo comprado se sincroniza.
- **Anuncios (AdMob, de prueba, con consentimiento RGPD):** banner en Amigos/Hoy e intersticial al terminar una sesión de Ahora, nunca durante. ❓ Anuncio con recompensa: ver uno = 1 comodín, como máximo 1 por semana.
- Con Plus desaparecen todos los anuncios.
- No hay azar a cambio de dinero ni puntos de pago.

## 7. Mapa de requisitos → funcionalidad de Codo
| Requisito | Cómo lo cumple Codo |
|---|---|
| 5 secciones, carga/vacío/error | Hoy, Ahora, Pactos, Amigos, Perfil |
| Splash con imagen de URL, onboarding de 3 pantallas | Onboarding: 1 Ahora, 2 Pacto, 3 Niveles y medallas |
| Correo + Google, recuperar contraseña, perfil con foto, borrar cuenta (app + web) | Cuenta Firebase, perfil con avatar y nivel. **Google en fase 1b**: perfil creado la primera vez y recuperado si ya existía |
| **Consultas (fase 1b): where con dos condiciones, orderBy con limit, rango de fechas, paginación** | Sobre `live_sessions` (≥20 documentos de prueba): filtro por categoría + visibilidad pública (Ahora), sesiones recientes con límite (Ahora), historial por rango de fechas y paginado con `startAfterDocument` (Perfil). Índice compuesto en `firestore.indexes.json` |
| **Snapshots o get según pantalla (fase 1b)** | Lista de Ahora y presencia: snapshots (en directo). Historial del Perfil y detalle: get una vez. Se justifica en el README |
| **Editar y borrar lo propio (fase 1b)** | Editar y borrar tus sesiones con confirmación y estado de error; reglas impiden tocar lo ajeno |
| **Cámara y galería, permisos, compresión en isolate (fase 1b)** | Foto de prueba de sesión y de check-in. Cámara obligatoria en la prueba; galería en foto de perfil. Compresión en isolate con progreso, miniatura <300 KB en base64 |
| **GPS, GeoPoint, comparación de tecnologías (fase 1b)** | Ubicación opcional aproximada en la sesión. README con media página: GPS, red, proveedor combinado |
| **Mapa y «cerca de mí» (fase 1b)** | flutter_map + OSM con marcador por sesión pública con ubicación. Lista ordenada por distancia en isolate |
| **Emuladores y hosting (fase 1b)** | Emuladores de Auth y Firestore con `--dart-define`, datos de prueba exportados al repo. Firebase Hosting con URL pública en el README |
| Persistencia offline + sincronización + no se pierde al reinstalar | Objetivos de Hoy, pactos y check-ins en Drift, con cola de cambios hacia Firestore |
| Exportar/importar copia JSON/CSV en un isolate | Exportar historial de pactos, check-ins y objetivos |
| Ranking/catálogo relacional con filtros y orden | Ranking de XP entre amigos (semana/mes/total) y catálogo de plantillas (categoría, duración) en Supabase |
| API propia con al menos 4 operaciones | Crear y aceptar pacto, registrar check-in, unirse a una sesión de Ahora, cerrar sesión de Ahora y otorgar XP, validar compra |
| 50 peticiones concurrentes sin duplicar | Muchos check-ins o uniones a la vez sin duplicar participantes ni XP |
| WebSocket propio | Presencia en Ahora: quién está, quién se une y tiempo restante. Check-in del compañero en vivo |
| Push que abre la pantalla correcta | Invitación a pacto, compañero hizo check-in, recordatorio de check-in antes de medianoche, amigo empezó una sesión |
| Validación de compras en servidor y en transacción | Comodines y Plus registrados junto con lo que conceden |
| Roles y reglas de seguridad | Usuario (solo lo suyo y lo de sus pactos/sesiones) y admin (denuncias) |
| Remote Config | Activar/desactivar Ahora público, mapa público, tablón abierto y anuncio con recompensa |
| Deep links + compartir + valoración | Enlace de invitación a pacto, compartir medalla, pedir valoración tras el primer pacto completado |
| Sonido y animaciones con sentido | Sonido y animación al completar check-in, pacto y subida de nivel. Se silencian en ajustes |
| Claro/oscuro, ES/EN, accesibilidad | Transversal |

## 8. Modelo de datos inicial (borrador)
- **Local (Drift):** `daily_goals`, `pacts`, `pact_members`, `checkins` y `pending_changes` (cola de sincronización). ❓ Validar relaciones en fase 2.
- **Firestore:** `users`, `friendships`, `pacts` (con su subcolección `checkins`), `live_sessions` (con sus `participants` y una subcolección `proofs` solo legible por participantes) y `reports`.
  - `live_sessions`: creador, categoría, descripción, visibilidad (`friends`/`public`), inicio, duración prevista, estado y **ubicación aproximada opcional (`GeoPoint` + `Timestamp`)**.
  - `proofs/{uid}`: miniatura base64 (<300 KB, límite de 1 MB por documento), frase opcional y sello de hora.
  - El mismo patrón de foto base64 se usa en los `checkins` de los pactos.
- **Supabase/PostgreSQL:** `purchases`, `entitlements` (comodines, Plus), `xp_events` (para el ranking) y `pact_templates` (catálogo).
- **Servicio (Dart shelf en Cloud Run ❓ o Cloud Functions):** API, WebSocket de presencia, verificación de compras y envío de FCM.
- **Entornos:** emuladores locales de Auth y Firestore conectados por `--dart-define`; datos de prueba exportados al repo. Hosting de Firebase para la versión web.

## 9. Alcance
**MVP (lo que se compromete en H1):** todo lo de las secciones 3 a 7. Ahora con visibilidad amigos/pública, **crear, editar, borrar y unirse a sesiones**, **ubicación opcional aproximada, mapa de sesiones públicas y «cerca de mí»**, pactos de 2 personas con amigo o desde el tablón, check-in diario con validación del compañero, comodines, Plus, niveles y medallas, y denuncia/bloqueo.

**Ampliaciones (si sobra tiempo):** pactos de grupo (3 o más), estadísticas avanzadas de Plus, más plantillas, rachas personales en Hoy y recordatorios inteligentes.

**Fuera (v2):** detección de salir de la app durante la sesión, suscripción mensual, chat libre entre usuarios.

> Ojo: el alcance de H1 no se puede rebajar después. Ante la duda, una cosa va a ampliaciones.

## 10. Riesgos
- **Alcance grande para trabajar solo 4–7 h por semana:** priorizar Pacto y que Ahora sea simple.
- **H1 y la fase 1b caen el mismo día (13/11/2026):** cerrar la documentación de H1 (diagrama, alcance, CLAUDE.md) antes de la última semana de la 1b.
- **Moderación de fotos de desconocidos:** visibilidad restringida, borrado automático y denuncias.
- **Privacidad de la ubicación:** opcional, aproximada y solo en sesiones públicas. Revisar que la política de privacidad y la seguridad de datos de Play coincidan con el código.
- **Fotos en documentos de Firestore:** el límite de 1 MB por documento obliga a comprimir; las reglas deben impedir que un no participante lea `proofs`.
- **Arranque en frío** (pocos usuarios, salas vacías, mapa vacío): por eso los amigos van primero.
- **Romper el pacto por un olvido frustra:** recordatorio push y comodines.

## 11. Registro de decisiones
| Decisión | Alternativa descartada | Por qué |
|---|---|---|
| Ranking entre amigos, puntos no comprables | Ranking global con premios | Con premios, la gente spamea actividades falsas |
| Verificación social + foto de cámara | Sin ninguna verificación | Sin nada, los puntos no significan nada |
| Sin límite de puntos diario | Tope diario y rendimiento decreciente | Penaliza al usuario que un día es muy productivo |
| Detección de salir de la app → v2 | Incluirla en el MVP | Alcance. Se deja como mejora |
| En un pacto, si uno falla pierden los dos | Solo pierde quien falla | La responsabilidad compartida es lo que motiva |
| XP del pacto solo al completarlo | XP por cada check-in | Coherente con "pierden los dos" |
| Ahora con amigos primero | Solo con desconocidos | Compromiso real, menos moderación, sin salas vacías |
| Unirse a sesiones de Ahora entra en el MVP (04/10/2026) | Ahora solo para mirar quién está, sin poder unirse | "Hacerlo acompañado" es la propuesta de valor de Ahora; sin unirse, Ahora sería un simple tablón de estados |
| Crear sesiones y pactos con un botón + en su pestaña (04/10/2026) | Solo desde Hoy o solo desde plantillas | Es la acción principal de cada pestaña y debe estar siempre a mano |
| Comodín (consumible) + Plus (pago único) | Vender puntos o niveles | Comprar puntos rompe la confianza en el sistema |
| Fotos visibles solo a participantes y borradas al terminar | Fotos públicas en el perfil | Privacidad y RGPD |

## 12. Decisiones de la fase 1b (18/10/2026)
| Decisión | Alternativa descartada | Por qué |
|---|---|---|
| El contenido con foto y posición de la fase 1b son las **sesiones de Ahora** | Perfil del usuario o pactos | Ahora tiene la lista pública que cubre las cuatro consultas y el mapa; la posición de un pacto no aporta nada |
| Ubicación **opcional y aproximada**; no se guarda la exacta ni en el perfil | Guardar la posición exacta de todos | Privacidad y RGPD; la ubicación exacta de desconocidos es un riesgo real (público 16+) |
| En el mapa solo sesiones **públicas** con ubicación | Mostrar también las de amigos | Menos exposición; las de amigos ya están en la lista |
| Foto como base64 en documento aparte `proofs`, solo participantes | Foto dentro del documento de la sesión; Firebase Storage | El documento de una sesión pública lo lee cualquiera; Storage exige plan Blaze y la fase no lo pide |
| Mapa con flutter_map + OpenStreetMap | Google Maps | Gratis, sin clave de API ni Blaze; puntúa igual |
| Foto de prueba solo con cámara; galería para el perfil | Permitir galería en la prueba | Coherente con la anti-trampa: foto hecha en el momento |
