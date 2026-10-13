import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/badge.dart';
import 'package:codo/models/pact.dart';

final samplePacts = [
  Pact(id: 'pact_1', title: 'Estudiar 1 h al día', partnerName: 'Lucía', daysDone: 12, daysTotal: 30, createdAt: DateTime(2026, 9, 20)),
  Pact(id: 'pact_2', title: 'Correr 5 km, 3 días por semana', partnerName: 'Marcos', daysDone: 5, daysTotal: 21, createdAt: DateTime(2026, 9, 28)),
  Pact(id: 'pact_3', title: 'Leer 20 páginas cada noche', partnerName: 'Sofía', daysDone: 18, daysTotal: 30, createdAt: DateTime(2026, 9, 15)),
  Pact(id: 'pact_4', title: 'Sin móvil después de las 23:00', partnerName: 'Pablo', daysDone: 3, daysTotal: 14, createdAt: DateTime(2026, 10, 5)),
  Pact(id: 'pact_5', title: 'Gimnasio por la mañana', partnerName: 'Aitana', daysDone: 9, daysTotal: 20, createdAt: DateTime(2026, 9, 25)),
  Pact(id: 'pact_6', title: 'Practicar guitarra 30 min', partnerName: 'Dani', daysDone: 21, daysTotal: 21, createdAt: DateTime(2026, 9, 10)),
];

const sampleMedals = [
  Medal(id: 'medal_1', name: 'Primer paso', description: 'Completa tu primer check-in.', xpReward: 10, imageUrl: 'https://picsum.photos/seed/codo-medal-1/200'),
  Medal(id: 'medal_2', name: 'Constante', description: 'Siete días seguidos cumpliendo.', xpReward: 50, imageUrl: 'https://picsum.photos/seed/codo-medal-2/200'),
  Medal(id: 'medal_3', name: 'Buen compañero', description: 'Valida 10 check-ins de tu compañero.', xpReward: 40, imageUrl: 'https://picsum.photos/seed/codo-medal-3/200'),
  Medal(id: 'medal_4', name: 'Madrugador', description: 'Haz un check-in antes de las 8:00.', xpReward: 30, imageUrl: 'https://picsum.photos/seed/codo-medal-4/200'),
  Medal(id: 'medal_5', name: 'Pacto cumplido', description: 'Termina un pacto completo.', xpReward: 100, imageUrl: 'https://picsum.photos/seed/codo-medal-5/200'),
  Medal(id: 'medal_6', name: 'Acompañado', description: 'Únete a 3 tareas de tus amigos en Ahora.', xpReward: 60, imageUrl: 'https://picsum.photos/seed/codo-medal-6/200'),
];

// Herramienta de desarrollo: sube los datos de ejemplo a Firestore.
Future<void> seedSampleData({FirestoreAdmin? admin}) async {
  final firestore = admin ?? FirestoreAdmin();
  for (final pact in samplePacts) {
    await firestore.pacts.doc(pact.id).set(pact);
  }
  for (final medal in sampleMedals) {
    await firestore.medals.doc(medal.id).set(medal);
  }
}