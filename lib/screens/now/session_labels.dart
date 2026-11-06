import 'package:codo/models/live_session.dart';

// Texto de cada categoría; lo usan Ahora y Nueva sesión
String categoryLabel(SessionCategory category) => switch (category) {
  SessionCategory.study => 'Estudiar',
  SessionCategory.train => 'Entrenar',
  SessionCategory.read => 'Leer',
  SessionCategory.work => 'Trabajar',
  SessionCategory.other => 'Otros',
};