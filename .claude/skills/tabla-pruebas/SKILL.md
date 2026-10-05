---
name: tabla-pruebas
description: Prepara la tabla de pruebas (qué se probó, qué se esperaba, qué pasó, diferencias entre emulador Android y navegador) para el PDF de entrega, partiendo del checklist de la fase. Úsala cuando Aitor vaya a probar la app o a montar el PDF.
---
# Tabla de pruebas Android / navegador

La rúbrica pide probar en emulador Android y en navegador, con una tabla de **qué se probó, qué se esperaba, qué pasó y diferencias entre plataformas**.

## Pasos
1. Lee `docs/ESTADO.md` y, si existe, `docs/fase1.md` (o el de la fase actual) para sacar las funciones que hay que probar.
2. Genera la tabla en Markdown con estas columnas:
   `# | Qué se prueba | Cómo provocarlo | Resultado esperado | Android: qué pasó | Navegador: qué pasó | Diferencias / notas | Captura`
3. Rellena SOLO las columnas "Qué se prueba", "Cómo provocarlo" y "Resultado esperado". Las columnas de "qué pasó", "diferencias" y "captura" las deja **vacías para Aitor**.
   - **Nunca inventes resultados.** Una prueba que Aitor no ha hecho no tiene resultado.
4. Incluye como mínimo estas filas (ajústalas a lo que exista en el código):
   - Splash con imagen cargada · con URL rota (modo avión o URL falsa).
   - Onboarding: aparece la primera vez · no aparece la segunda · "Saltar".
   - Registro: correo ya usado · contraseña débil · éxito.
   - Acceso: credenciales incorrectas · éxito · cerrar sesión.
   - Listas y cuadrículas: carga · vacío · error (sin red) · con datos.
   - Rutas con parámetros: abrir el detalle correcto.
   - Modo claro y oscuro · letra grande.
5. En "Cómo provocarlo", indica el truco concreto (modo avión del emulador, borrar la colección de prueba, cambiar la URL, `flutter run -d chrome`).
6. Al final añade una sección "Diferencias entre plataformas a vigilar": anchos de pantalla en web, `shared_preferences` en navegador, permisos, teclado, tipografías.

## Salida
Pega la tabla en el chat y ofrece guardarla en `docs/pruebas.md` (Aitor decide). Recuérdale que las capturas deben hacerse en ambos sitios.
