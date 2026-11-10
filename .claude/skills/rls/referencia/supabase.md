# RLS de Supabase en Codo (fase 3)

Todavía no hay tablas. Esto fija las convenciones para cuando lleguen `purchases`, `entitlements`, `xp_events` y `pact_templates` (`docs/decisiones_producto.md` §8). Supabase cambia rápido: antes de aplicar nada, contrasta con su documentación actual, sobre todo la parte de Firebase Auth.

## 1. Decisión previa: ¿la app habla con Supabase o solo el servidor?

Pregúntasela a Aitor con estas dos opciones antes de escribir una política.

| | A · Solo el servidor (recomendada) | B · La app también lee |
|---|---|---|
| Cómo | La app llama a la API propia (Dart shelf); solo el servidor tiene la clave `service_role` | La app usa el SDK de Supabase con el token de Firebase (*third-party auth*) |
| RLS | Activado en todas las tablas y **sin ninguna política**: `anon` y `authenticated` no ven nada | Activado, con políticas de lectura por tabla |
| Coste | Un punto de entrada que proteger; el ranking sale de un *endpoint* | Hay que poner el *claim* `role: 'authenticated'` a cada usuario de Firebase (función o *script*) y mantener políticas |
| Riesgo | Bajo | Medio: un fallo en una política expone compras |

En las dos, **escribir** en `purchases`, `entitlements` y `xp_events` es siempre cosa del servidor: son campos del servidor (contrato, punto 5).

## 2. Lo que se hace siempre, en cada tabla

```sql
-- 1. RLS activado desde la misma migración que crea la tabla
alter table public.entitlements enable row level security;

-- 2. Sin permisos por defecto para los roles de la app
revoke all on public.entitlements from anon, authenticated;
```

- Una tabla del esquema `public` sin RLS es legible y escribible por cualquiera que tenga la clave pública. Ninguna migración crea una tabla sin las dos líneas de arriba.
- `service_role` se salta RLS: solo vive en el servidor (secreto de Cloud Run), nunca en la app, en el repo ni en un `--dart-define`.
- El uid es el de Firebase, que es **texto**, no UUID: columna `user_id text not null`.

## 3. Políticas (solo si se eligió la opción B)

```sql
grant select on public.entitlements to authenticated;

create policy entitlements_select_own
  on public.entitlements
  for select
  to authenticated
  using ((select auth.jwt() ->> 'sub') = user_id);
```

Reglas de estilo:
- **Nombre:** `<tabla>_<operación>_<quién>` (`entitlements_select_own`, `pact_templates_select_all`).
- **Una política por operación** (`select`, `insert`, `update`, `delete`); nunca `for all`.
- **Siempre `to authenticated`.** Nunca `to public` ni `anon` con datos de usuarios.
- **`using`** filtra las filas que se ven o se tocan; **`with check`** valida la fila que queda. `insert` lleva `with check`; `update` lleva las dos.
- **`auth.jwt() ->> 'sub'`, no `auth.uid()`:** `auth.uid()` convierte a UUID y el uid de Firebase no lo es.
- **Envuelto en `(select …)`** para que se evalúe una vez por consulta y no por fila, y con índice en la columna de la política (`create index on public.entitlements (user_id);`).
- **Vistas** con `security_invoker = true`; si no, se ejecutan con los permisos de quien las creó y se saltan RLS.
- **Funciones `security definer`** solo si hacen falta, con `set search_path = ''` y sin devolver más columnas de las necesarias.

**Tokens de otros proyectos de Firebase.** Firebase firma los tokens de todos sus proyectos con las mismas claves. La plataforma alojada de Supabase rechaza los de proyectos no registrados; aun así, como defensa extra, añade a cada tabla una política **restrictiva** que compruebe emisor y audiencia. Copia el SQL exacto de la guía «Firebase Auth» de Supabase (*third-party auth*); la idea es:

```sql
create policy entitlements_only_codo_project
  on public.entitlements
  as restrictive
  to authenticated
  using (
    (select auth.jwt() ->> 'iss') = 'https://securetoken.google.com/<id-del-proyecto-firebase>'
    and (select auth.jwt() ->> 'aud') = '<id-del-proyecto-firebase>'
  );
```

## 4. Ficha por tabla (punto de partida)

| Tabla | Leer | Escribir | Notas |
|---|---|---|---|
| `purchases` | nadie desde la app | servidor, en la misma transacción que concede lo comprado | Clave única por compra (*purchase token*) para no conceder dos veces |
| `entitlements` | A: vía API · B: su dueño | servidor | Comodines y Plus |
| `xp_events` | vía API o vista de ranking | servidor | El ranking entre amigos no debe exponer eventos sueltos de otros |
| `pact_templates` | cualquier usuario con sesión | servidor o consola | Catálogo; sin datos personales |

## 5. Pruebas

Cada política se prueba con SQL dentro de una transacción que se deshace, simulando el token:

```sql
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub": "uid-de-ana", "role": "authenticated"}';
  select count(*) from public.entitlements;                           -- solo las de Ana
  select count(*) from public.entitlements where user_id = 'uid-de-leo'; -- 0
rollback;
```

Casos mínimos por tabla, igual que en Firestore: el dueño ve lo suyo; otro usuario no; sin sesión (`set local role anon`) no ve nada; nadie inserta, edita ni borra desde un rol de la app. Los resultados van a `docs/pruebas.md`, sin inventar ninguno.

## 6. Entrega

El mismo formato que en `SKILL.md`: ficha, SQL de la migración, explicación de cada cláusula (`using` frente a `with check`), alternativa descartada, cambios en el cliente o en el servidor, resultado de las pruebas y mensaje de commit. Las migraciones las aplica Aitor.
