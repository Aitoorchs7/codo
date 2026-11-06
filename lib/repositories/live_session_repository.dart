import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/models/proof.dart';
import 'package:codo/repositories/session_failure.dart';

class LiveSessionRepository {
  LiveSessionRepository({FirestoreAdmin? admin})
    : _admin = admin ?? FirestoreAdmin();

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
  Stream<List<LiveSession>> watchRecentPublic({int limit = 10}) => _admin
      .liveSessions
      .where('visibility', isEqualTo: SessionVisibility.public.name)
      .orderBy('startedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  // Consulta 3 · rango sobre una fecha: mi historial entre dos días.
  // get: son sesiones pasadas, no cambian; escucharlas gastaría lecturas para nada.
  Future<List<LiveSession>> getHistoryBetween(
    String uid,
    DateTime from,
    DateTime to,
  ) async {
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
  Future<List<LiveSession>> getHistoryPage(
    String uid, {
    bool reset = false,
  }) async {
    if (reset) _lastHistoryDoc = null; // volver a la primera página
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

  // Publicar: Firestore pone el id del documento; el campo id del modelo no se guarda
  Future<void> createSession(LiveSession session) =>
      _guard(() => _admin.liveSessions.add(session));

  // Editar: solo descripción y duración (las reglas rechazan cualquier otro campo)
  Future<void> updateSession(
    String id, {
    required String description,
    required int durationMinutes,
  }) => _guard(
    () => _admin.liveSessions.doc(id).update({
      'description': description,
      'durationMinutes': durationMinutes,
    }),
  );

  // Terminar: deja de estar activa pero no se borra (puede tener participantes)
  Future<void> finishSession(String id) => _guard(
    () => _admin.liveSessions.doc(id).update({
      'status': SessionStatus.finished.name,
      'endedAt': FieldValue.serverTimestamp(),
    }),
  );

  // Borrar: las reglas solo lo permiten si eres el creador y nadie más se ha unido
  Future<void> deleteSession(String id, String uid) => _guard(() async {
    await _admin.proofs(id).doc(uid).delete(); // primero la hija
    await _admin.liveSessions.doc(id).delete();
  });
  // Traduce los errores de Firestore a fallos de dominio
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw SessionFailure(switch (e.code) {
        'permission-denied' => SessionError.permissionDenied,
        'not-found' => SessionError.notFound,
        'unavailable' => SessionError.network,
        _ => SessionError.unknown,
      });
    }
  }

  // Guarda (o reemplaza) mi prueba de esta sesión
  Future<void> saveProof(String sessionId, String uid, Uint8List jpg) => _guard(
    () => _admin
        .proofs(sessionId)
        .doc(uid)
        .set(Proof(uid: uid, imageBase64: base64Encode(jpg))),
  );

  // Lee mi prueba; null si todavía no hay
  Future<Proof?> getProof(String sessionId, String uid) => _guard(
    () async => (await _admin.proofs(sessionId).doc(uid).get()).data(),
  );
}
