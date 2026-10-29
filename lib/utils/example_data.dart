import 'package:codo/admins/auth_failure.dart';
import 'package:codo/admins/auth_service.dart';
import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/models/medal.dart';
import 'package:codo/models/pact.dart';
import 'package:codo/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

// En example_data.dart
const seedUsers = [
  (email: 'ana@codo.test', name: 'Ana'),
  (email: 'leo@codo.test', name: 'Leo'),
  (email: 'marta@codo.test', name: 'Marta'),
  (email: 'iker@codo.test', name: 'Iker'),
];
const seedPassword = 'codo1234';   // solo existe en el emulador

// Frases de ejemplo; se van repitiendo entre las 24 sesiones
const _seedDescriptions = [
  'Repaso de Acceso a Datos', 'Piernas y core', 'Novela antes de dormir',
  'Informe del trabajo', 'Practicar guitarra', 'Temario de la oposición',
];

// Herramienta de desarrollo: crea 4 usuarios y 24 sesiones en el EMULADOR.
Future<void> seedLiveSessions({
  AuthService? auth,
  ProfileRepository? profiles,
  FirestoreAdmin? admin,
}) async {
  final authService = auth ?? AuthService();
  final profileRepo = profiles ?? ProfileRepository();
  final firestore = admin ?? FirestoreAdmin();
  final now = DateTime.now();

  for (var u = 0; u < seedUsers.length; u++) {
    final seedUser = seedUsers[u];

    // 1. Entrar como este usuario: la primera vez se registra; si ya existe, inicia sesión
    User user;
    try {
      user = await authService.register(seedUser.email, seedPassword);
    } on AuthFailure catch (e) {
      if (e.error != AuthError.emailInUse) rethrow;
      user = await authService.signIn(seedUser.email, seedPassword);
    }

    // 2. Su perfil en users/{uid}
    await profileRepo.getOrCreateProfile(uid: user.uid, displayName: seedUser.name);

    // 3. Sus 6 sesiones
    for (var i = 0; i < 6; i++) {
      final n = u * 6 + i;                 // número de sesión: del 0 al 23
      final isActive = i == 0;             // la primera de cada uno sigue en curso
      final startedAt = isActive
          ? now.subtract(const Duration(minutes: 20))
          : now.subtract(Duration(days: n + 1, hours: n % 5));
      final duration = 30 + (n % 4) * 30;  // 30, 60, 90 o 120 min
      final hasLocation = n % 4 != 3;      // 18 con ubicación y 6 sin ella

      final session = LiveSession(
        id: 'session_${u}_$i',
        creatorId: user.uid,
        creatorName: seedUser.name,
        category: SessionCategory.values[n % SessionCategory.values.length],
        description: _seedDescriptions[n % _seedDescriptions.length],
        visibility: n % 3 == 0 ? SessionVisibility.friends : SessionVisibility.public,
        startedAt: startedAt,
        durationMinutes: duration,
        status: isActive ? SessionStatus.active : SessionStatus.finished,
        endedAt: isActive ? null : startedAt.add(Duration(minutes: duration)),
        participantIds: [user.uid],
        // Posición aproximada (2 decimales, unos 1 km) alrededor del centro de Madrid
        latitude: hasLocation ? (4042 + n % 7 - 3) / 100 : null,
        longitude: hasLocation ? (-370 + n % 5 - 2) / 100 : null,
        locationAt: hasLocation ? startedAt : null,
      );
      await firestore.liveSessions.doc(session.id).set(session);
    }

    // 4. Salir, para que el siguiente usuario entre limpio
    await authService.signOut();
  }
}

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