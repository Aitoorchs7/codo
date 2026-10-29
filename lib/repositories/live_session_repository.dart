import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/live_session.dart';

class LiveSessionRepository {
  LiveSessionRepository({FirestoreAdmin? admin}) : _admin = admin ?? FirestoreAdmin();

  final FirestoreAdmin _admin;

  // Pequeña a propósito: cada usuario de prueba tiene 6 sesiones → 2 páginas (4 + 2)
  static const historyPageSize = 4;

  // Último documento de la página anterior; la pantalla nunca lo ve
  DocumentSnapshot<LiveSession>? _lastHistoryDoc;

  // Consulta 1 · where con dos condiciones: sesiones públicas de una categoría.
  // snapshots: en «Ahora» la gente entra y sale, la lista tiene que moverse sola.
  Stream<List<LiveSession>> watchPublicByCategory(SessionCategory category) =>
      _admin.liveSessions
          .where('category', isEqualTo: category.name)
          .where('visibility', isEqualTo: SessionVisibility.public.name)
          .orderBy('startedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  // Consulta 2 · orderBy + limit: las últimas sesiones públicas.
  // snapshots, por el mismo motivo.
  Stream<List<LiveSession>> watchRecentPublic({int limit = 10}) =>
      _admin.liveSessions
          .where('visibility', isEqualTo: SessionVisibility.public.name)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  // Consulta 3 · rango sobre una fecha: mi historial entre dos días.
  // get: son sesiones pasadas, no cambian; escucharlas gastaría lecturas para nada.
  Future<List<LiveSession>> getHistoryBetween(
      String uid, DateTime from, DateTime to) async {
    final snap = await _admin.liveSessions
        .where('creatorId', isEqualTo: uid)
        .where('startedAt', isGreaterThanOrEqualTo: from)
        .where('startedAt', isLessThan: to)
        .orderBy('startedAt', descending: true)
        .get();
    return snap.docs.map((doc) => doc.data()).toList();
  }

  // Consulta 4 · paginación con startAfterDocument: mi historial de 4 en 4.
  // get: cada página se pide una vez al pulsar «Cargar más».
  Future<List<LiveSession>> getHistoryPage(String uid, {bool reset = false}) async {
    if (reset) _lastHistoryDoc = null;   // volver a la primera página
    var query = _admin.liveSessions
        .where('creatorId', isEqualTo: uid)
        .orderBy('startedAt', descending: true)
        .limit(historyPageSize);
    final last = _lastHistoryDoc;
    if (last != null) query = query.startAfterDocument(last);
    final snap = await query.get();
    if (snap.docs.isNotEmpty) _lastHistoryDoc = snap.docs.last;
    return snap.docs.map((doc) => doc.data()).toList();
  }
}