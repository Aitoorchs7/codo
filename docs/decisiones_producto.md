# Decisiones de producto — Codo

Estado: **borrador v1 (03/10/2026)**. Se cerrará en H1 (13/11/2026). Lo marcado con ❓ está pendiente.

## 1. Propuesta de valor
**En una frase:** Codo te ayuda a cumplir tus objetivos haciéndolos acompañado: ahora mismo con quien está haciendo lo mismo, o durante días con un pacto con un amigo.

**En un párrafo:** las apps de organización se abandonan porque cumplir solo cuesta. Codo convierte los objetivos en algo compartido. En **Ahora**, publicas lo que estás haciendo en este momento y tus amigos se unen haciendo lo mismo. En **Pacto**, te comprometes con otra persona a un reto de la duración que elijáis, con un check-in diario. Si uno falla, pierden los dos. Lo que mueve la app no son los puntos, sino no fallar a quien va contigo y aprender de gente con tus mismos objetivos.

## 2. Público
Jóvenes y adultos (estudiantes, opositores, gente que entrena o quiere crear hábitos) que se motivan más en compañía. **No dirigida a menores de 13 años.** ❓ Edad mínima concreta en la ficha de Play (recomendación: 16+, por fotos y contacto con otros usuarios).

**Personas tipo**
- **Lucía, 20, estudiante de DAM.** Le cuesta ponerse a estudiar sola por la tarde. Abre Ahora, ve que dos amigas están estudiando y se une. Al terminar sube la foto de sus apuntes.
- **Marcos, 27, quiere volver al gimnasio.** Hace un pacto de 30 días con un amigo: "entrenar 4 días por semana". El check-in del compañero le recuerda que, si falla, pierden los dos.

## 3. Secciones (barra inferior, 5)
| Sección | Qué es | Pantalla principal |
|---|---|---|
| **Hoy** | Tu día de un vistazo, con la parte de "organizar la vida" | Objetivos de hoy (lista personal sencilla y offline), check-ins de pacto pendientes, amigos que están en Ahora y botón "Empezar ahora" |
| **Ahora** (nombre provisional; candidato: *Codo a codo*) | Tareas en directo y acompañadas | Sesiones activas de amigos (y públicas) en tiempo real, y botón para publicar la tuya |
| **Pactos** | Retos con otra persona | Lista de tus pactos activos con su progreso, invitaciones, tablón de pactos abiertos y catálogo de plantillas en **cuadrícula** |
| **Amigos** | Lo social y la competición sana | Ranking entre amigos (semana/mes/total), solicitudes y búsqueda de usuarios |
| **Perfil** | Identidad y progreso | Nivel, medallas en **cuadrícula**, historial, ajustes y Codo Plus |

Fase 1 pide una lista y una cuadrícula desde Firestore: la lista son los pactos y la cuadrícula, el catálogo de plantillas o las medallas.

## 4. Mecánicas
### Ahora
- Publicas una sesión: categoría (estudiar, entrenar, leer, trabajar, otro), descripción corta y duración prevista.
- **Visibilidad:** por defecto la ven los **amigos**. Opcionalmente, **pública** por categoría.
  - *Por qué amigos primero:* con amigos hay compromiso real, hace falta menos moderación y se evita el problema de las salas vacías cuando hay pocos usuarios. La opción pública le da vida a la app cuando crezca.
- Otros se unen y ven en tiempo real quién está y cuánto le queda.
- **Prueba al terminar:** foto hecha con la cámara en el momento (no desde la galería), con sello de hora, y una frase opcional. La ven solo los participantes de esa sesión.
- **Recompensa:** XP según el tiempo. Una sesión larga (❓ umbral, por ejemplo más de 2 h) da medalla.

### Pacto (la parte principal)
- Lo creas desde cero o desde una plantilla del catálogo: objetivo, duración (la que quieras), frecuencia de check-in (diaria) y con quién.
- **Con quién:** un amigo (invitación) o cualquier usuario que lo acepte desde el **tablón de pactos abiertos**.
- **Check-in diario:** foto y nota que muestran que estás más cerca del objetivo. El compañero lo ve y puede darle el **visto bueno** o pedir explicación.
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
| Correo + Google, recuperar contraseña, perfil con foto, borrar cuenta (app + web) | Cuenta Firebase, perfil con avatar y nivel |
| Persistencia offline + sincronización + no se pierde al reinstalar | Objetivos de Hoy, pactos y check-ins en Drift, con cola de cambios hacia Firestore |
| Exportar/importar copia JSON/CSV en un isolate | Exportar historial de pactos, check-ins y objetivos |
| Ranking/catálogo relacional con filtros y orden | Ranking de XP entre amigos (semana/mes/total) y catálogo de plantillas (categoría, duración) en Supabase |
| API propia con al menos 4 operaciones | Crear y aceptar pacto, registrar check-in, cerrar sesión de Ahora y otorgar XP, validar compra |
| 50 peticiones concurrentes sin duplicar | Muchos check-ins o uniones a la vez sin duplicar XP |
| WebSocket propio | Presencia en Ahora: quién está, quién se une y tiempo restante. Check-in del compañero en vivo |
| Push que abre la pantalla correcta | Invitación a pacto, compañero hizo check-in, recordatorio de check-in antes de medianoche, amigo empezó una sesión |
| Validación de compras en servidor y en transacción | Comodines y Plus registrados junto con lo que conceden |
| Roles y reglas de seguridad | Usuario (solo lo suyo y lo de sus pactos/sesiones) y admin (denuncias) |
| Remote Config | Activar/desactivar Ahora público, tablón abierto y anuncio con recompensa |
| Deep links + compartir + valoración | Enlace de invitación a pacto, compartir medalla, pedir valoración tras el primer pacto completado |
| Sonido y animaciones con sentido | Sonido y animación al completar check-in, pacto y subida de nivel. Se silencian en ajustes |
| Claro/oscuro, ES/EN, accesibilidad | Transversal |

## 8. Modelo de datos inicial (borrador)
- **Local (Drift):** `daily_goals`, `pacts`, `pact_members`, `checkins` y `pending_changes` (cola de sincronización). ❓ Validar relaciones en fase 2.
- **Firestore:** `users`, `friendships`, `pacts` (con su subcolección `checkins`), `live_sessions` y `reports`.
- **Supabase/PostgreSQL:** `purchases`, `entitlements` (comodines, Plus), `xp_events` (para el ranking) y `pact_templates` (catálogo).
- **Servicio (Dart shelf en Cloud Run ❓ o Cloud Functions):** API, WebSocket de presencia, verificación de compras y envío de FCM.

## 9. Alcance
**MVP (lo que se compromete en H1):** todo lo de las secciones 3 a 7. Ahora con visibilidad amigos/pública, pactos de 2 personas con amigo o desde el tablón, check-in diario con validación del compañero, comodines, Plus, niveles y medallas, y denuncia/bloqueo.

**Ampliaciones (si sobra tiempo):** pactos de grupo (3 o más), estadísticas avanzadas de Plus, más plantillas, rachas personales en Hoy y recordatorios inteligentes.

**Fuera (v2):** detección de salir de la app durante la sesión, suscripción mensual, chat libre entre usuarios.

> Ojo: el alcance de H1 no se puede rebajar después. Ante la duda, una cosa va a ampliaciones.

## 10. Riesgos
- **Alcance grande para trabajar solo 4–7 h por semana:** priorizar Pacto y que Ahora sea simple.
- **Moderación de fotos de desconocidos:** visibilidad restringida, borrado automático y denuncias.
- **Arranque en frío** (pocos usuarios, salas vacías): por eso los amigos van primero.
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
| Comodín (consumible) + Plus (pago único) | Vender puntos o niveles | Comprar puntos rompe la confianza en el sistema |
| Fotos visibles solo a participantes y borradas al terminar | Fotos públicas en el perfil | Privacidad y RGPD |
