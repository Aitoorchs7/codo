import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/pact.dart';

class PactRepository {
  PactRepository({FirestoreAdmin? admin}) : _admin = admin ?? FirestoreAdmin();

  final FirestoreAdmin _admin;

  Stream<List<Pact>> watchPacts() => _admin.pacts
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());
}