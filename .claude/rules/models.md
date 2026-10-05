---
paths:
  - "lib/models/**/*.dart"
---
# Modelos

- Inmutables: campos `final` y constructor `const` cuando se pueda.
- Cada modelo que vive en Firestore trae su conversor para `withConverter`: `factory X.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options)` y `Map<String, dynamic> toFirestore()`. Es el único sitio donde se tocan `Timestamp` y `Map`; hacia fuera salen `DateTime` y tipos propios.
- Datos corruptos: decide por campo si hay valor por defecto o si falla con un error claro; nunca dejes que un `null` reviente lejos del conversor.
- Sin lógica de interfaz ni imports de Flutter.
