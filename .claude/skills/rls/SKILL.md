---
name: rls
description: Diseña, revisa y prueba el control de acceso por documento o fila de Codo de forma consistente. Hoy son las reglas de Firestore (`firestore.rules`); desde la fase 3, también las políticas RLS de Supabase. Úsala cuando Aitor diga «RLS», «reglas», «permisos» o «quién puede leer o escribir»; al añadir o cambiar una colección, tabla, campo o consulta; y antes de desplegar reglas. No despliega, no hace commit y no edita `firestore.rules` salvo que Aitor lo pida.
---
# RLS de Codo: reglas de Firestore y políticas de Supabase

«RLS» (*row level security*) es el nombre de Supabase/PostgreSQL. En Firestore lo mismo se llama **reglas de seguridad**: el servidor decide, documento a documento, quién lee y quién escribe. En Codo el cliente habla directamente con Firestore, así que las reglas son la única frontera: la app se puede saltar con una petición REST.

El objetivo de la skill es que cualquier regla nueva tenga la misma forma, las mismas garantías y sus pruebas, la escriba quien la escriba.

## Contrato (no se negocia)

1. **Cerrado por defecto.** Lo que no se declara se deniega. Nunca `match /{document=**}`, nunca `allow ... if true`, nunca `if request.auth != null` a secas sobre datos de usuarios.
2. **La identidad sale del token** (`request.auth.uid`), nunca de un campo que mande el cliente.
3. **Se valida quién escribe y qué escribe.** Esquema cerrado (claves obligatorias y opcionales), tipo y rango de cada campo. Estar autenticado no es estar autorizado.
4. **Una regla por operación:** `get`, `list`, `create`, `update` y `delete` por separado. Nunca `allow write`.
5. **Campos del servidor:** `xp`, `badges`, compras, derechos (*entitlements*) y resultados de validación no los escribe nunca el cliente.
6. **Campos inmutables** tras crear (dueño, fecha de inicio, visibilidad…): `changedKeys().hasOnly([...])` con la lista de lo que sí cambia.
7. **La hora la pone el servidor** (`request.time`), o se acota contra él.
8. **Las reglas no filtran:** aceptan o rechazan la consulta entera. Cada regla de `list` va con la consulta del repositorio que la cumple.
9. **Los límites coinciden** en la pantalla, en la regla y en la tabla del README.
10. **Sin pruebas no hay regla:** cada cambio añade sus casos a `pruebas/rules_test.py`, los que deben pasar y los que deben fallar.
11. **Privacidad de producto:** ubicación solo en sesiones públicas y redondeada; fotos solo para participantes; nada exacto ni en el perfil.

## Pasos

1. **Lee lo que hay.** `firestore.rules` entero, [`referencia/firestore.md`](referencia/firestore.md) y, si la colección aparece en `docs/seguridad_auditoria.md`, sus hallazgos abiertos. Para dudas de producto, `docs/decisiones_producto.md` §5 y §8. Para Supabase, [`referencia/supabase.md`](referencia/supabase.md).
2. **Rellena la ficha de acceso** (plantilla abajo). Si una casilla no se puede rellenar, es una decisión de producto: pregúntasela a Aitor con opciones, no la inventes.
3. **Escribe el bloque** con la forma canónica de `referencia/firestore.md` y los *helpers* comunes. El ejemplo completo y probado es [`referencia/firestore.objetivo.rules`](referencia/firestore.objetivo.rules).
4. **Escribe los casos de prueba** en `pruebas/rules_test.py`. Mínimo por operación: la operación exacta que hace la app (debe permitirse) y, denegados, otro usuario, sin sesión y el cliente que miente (campo de más, tipo incorrecto, fuera de rango, campo inmutable, campo del servidor).
5. **Pasa las pruebas contra una copia candidata**, no contra `firestore.rules`:
   ```bash
   python .claude/skills/rls/pruebas/rules_test.py ruta/candidata.rules
   ```
   Guarda la candidata en la carpeta temporal de la sesión. Tienen que cumplirse todos los casos nuevos y no romperse ninguno de los «App:».
6. **Entrega** con el formato de abajo. Aitor copia el cambio a `firestore.rules`, actualiza el README y despliega.

## Ficha de acceso

```
Ruta:            live_sessions/{id}/proofs/{uid}
Qué guarda:      foto de prueba de un participante
Dueño:           el uid del id del documento
Leer uno (get):  participantes de la sesión
Listar (list):   participantes · consulta del repositorio: <fichero:línea>
Crear:           el dueño, si es participante
Editar:          igual que crear · campos que cambian: image, createdAt
Borrar:          el dueño
Campos:          image      string, 1..307199   obligatorio
                 createdAt  timestamp == hora del servidor   obligatorio
Inmutables:      —
Del servidor:    —
Lecturas extra:  1 get (sesión padre) por evaluación
```

## Formato de la entrega

En este orden, breve:
1. **Ficha de acceso.**
2. **Bloque de reglas**, con comentarios en español, y dónde va (`firestore.rules:línea`). Solo lo que cambia.
3. **Explicación condición a condición:** qué impide cada una y qué ataque concreto corta. Aitor tiene que poder defenderla sin IA; viene de Java y Python, así que usa esas analogías.
4. **Alternativa descartada** y motivo.
5. **Cambios que exige en el cliente** (`fichero:línea`): consultas que necesitan un `where` o un `limit`, constantes que deben coincidir.
6. **Fila para la tabla del README** (`README.md`, «Reglas de Firestore»).
7. **Resultado de las pruebas:** casos nuevos y total.
8. **Mensaje de commit propuesto**, p. ej. `fix(rules): lectura de sesiones solo públicas, propias o en las que participas`.

## Nunca

- Ejecutar `firebase deploy` ni hacer commit (lo hace Aitor; además está denegado en `settings.json`).
- Editar `firestore.rules` sin que Aitor lo pida: se propone el cambio mínimo y lo aplica él.
- Relajar una regla para que pase una prueba, un sembrado o una pantalla. Si la app necesita más permiso, se justifica en la ficha.
- Abrir «temporalmente» las reglas del proyecto real. Los datos de ejemplo se cargan en el emulador o desde la consola.
- Dar por buena una regla sin haber pasado las pruebas, o inventar su resultado.
- Guardar un rol en un campo que el usuario pueda escribir (`users/{uid}.role`). Los roles van en *custom claims*, que solo pone el servidor.

## Ficheros de la skill

| Fichero | Para qué |
|---|---|
| `referencia/firestore.md` | Forma canónica, *helpers*, recetas por tipo de campo, patrones de propiedad, trampas y límites |
| `referencia/firestore.objetivo.rules` | Reglas completas a las que debe converger `firestore.rules`. Probadas (63/63). No es lo desplegado |
| `referencia/supabase.md` | Convenciones de RLS para las tablas de la fase 3 |
| `pruebas/rules_test.py` | Casos ejecutables contra un emulador aparte. Con `firestore.rules` actual fallan los hallazgos abiertos de la auditoría |
