# Estado — actualizado 14/10/2026

**Fase actual:** 1 · Arranque · entrega **16/10/2026** según README y este fichero (Aitor habla del 18/10: confirmar con el enunciado)
**Siguiente hito:** H1 · 13/11/2026 (arquitectura, alcance y modelo de ingresos)

## Hecho
- Proyecto Flutter, repo GitHub (`Aitoorchs7/codo`), `.gitignore` con secretos, CLAUDE.md, IA.md, README, decisiones de producto (v1) y entorno agéntico
- Tema claro/oscuro (`AppTheme` + `CodoColors`, Onest) y cristal (`GlassSurface`, `GlassButton`, `CodoBackground`)
- Splash con imagen de URL (3 estados) y destino según sesión y «onboarding visto» (`startupRoute`, probado); onboarding de 3 páginas
- Acceso y registro: `AuthService` + `AuthFailure` + `AuthScreen` (un mensaje por `AuthError`); cerrar sesión desde Perfil
- Modelos `Profile`, `Pact` y `Medal` (`medal.dart`) con lectores seguros y pruebas de casos malos; `FirestoreAdmin` con `withConverter` + 3 repositorios (streams)
- Barra inferior: `CodoNavBar` (`NavigationBar`) y `HomeScreen` como carcasa con `IndexedStack` y 5 secciones (Hoy, Ahora y Amigos son placeholders)
- `PactsScreen`: lista con `StreamBuilder` y 4 estados; `PactDetailScreen` al pulsar una tarjeta
- Perfil: saludo (4 estados) + `MedalGrid` (`GridView`, 4 estados, imagen con carga y error) + cerrar sesión
- Rutas: `AppRoutes.onGenerateRoute` para todas, con `PactDetailArgs` tipado y pantalla de error
- Datos de ejemplo subidos y comprobados en la consola: 6 `pacts` y 6 `badges` (código usa `medal`; la colección y `users.badges` se quedan)
- 29 commits en 12 días, todo commiteado; `analyze` limpio y `test` con 16 pruebas en verde

## En curso
- `Profile` a medias: faltan constructor `const` y `photoUrl`/`bio` como `final`
- Botón temporal del seed en Perfil (`kDebugMode`): se borra al terminar. Reglas de Firestore: `pacts` y `badges` deben quedar solo de lectura

## Siguiente
1. Probar en Chrome el detalle de pacto y confirmar en la consola que las reglas de `pacts`/`badges` son solo lectura
2. README: sección «Configuración de Firebase» (qué ficheros, cómo conseguirlos, por qué no están) y `.gitkeep` en `l10n/`
3. Probar en Android y web (medallas, detalle, cerrar sesión, sin red) y rellenar la tabla de pruebas del README (skill `tabla-pruebas`)
4. Limpieza: textos del onboarding (línea 187: «Elegis», «haceis», «dia»), `Profile` (`const`/`final`) y borrar el botón del seed
5. Traducir los errores de Firestore a un fallo de dominio (como `AuthFailure`) en Pactos y medallas (fuera del checklist)
6. `/cierre`, commits y PDF de entrega

## Checklist de la fase 1
- [ ] Estructura de carpetas + README explicado (falta `.gitkeep` en `l10n/`) · [x] 15+ commits repartidos (29)
- [x] Splash con imagen de URL y estados · [x] Onboarding de 3 pantallas, saltable, solo la primera vez (textos con faltas por corregir)
- [ ] Firebase documentado (README: «Configuración de Firebase» sigue pendiente) · [x] Registro y acceso con errores tratados · [x] Cerrar sesión y cancelar suscripciones (los `StreamBuilder` cancelan al salir)
- [x] Colecciones de perfiles y contenido (≥6 documentos) (6 `pacts` y 6 `badges`) · [x] `withConverter` (en `FirestoreAdmin`)
- [x] Rutas con nombre y paso de parámetros (`onGenerateRoute` + `PactDetailArgs`) · [x] Barra inferior (lista de pactos + cuadrícula de medallas, 4 estados)
- [ ] Tabla de pruebas Android/web (README: «pendiente») · [ ] Guía de arranque en el README (falta el paso de Firebase)

## Decisiones pendientes
- Fecha de entrega: 16/10 (docs) o 18/10 (Aitor)
- `firebase_options.dart` y `google-services.json`: propuesta = entregarlos aparte al profesor + `flutterfire configure` como alternativa, documentado en el README
- Preguntar al profesor si `DataHolder` y `FirebaseAdmin` son obligatorios (ya existe `FirestoreAdmin`)
- Carpeta `assets/images/imagenes app/` (4 fondos .jpg) sin añadir a git ni a `pubspec.yaml`: decidir si entra y con otro nombre (sin espacio)
- Paleta: sincronizar `docs/CODO_PALETA_COLORES.md` y el lienzo con el fondo gris actual y el botón principal al 85→65 %
- Textos ES/EN: literales en español ahora, `AppLocalizations` en la fase 2
- Fase 2: `pacts` sin dueño y legible por cualquier usuario con sesión (añadir participantes y reglas); renombrar `badges` a `medals` en Firestore solo si sobra tiempo

## Bloqueos
- Ninguno técnico. Riesgo de plazo bajo: 4 puntos de la checklist sin hacer (~3 h: README/Firebase, tabla de pruebas, limpieza); quedan ~6 h hasta el 16/10 y ~12 h hasta el 18/10 (a 3 h/día)
