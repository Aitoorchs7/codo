import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/badge.dart';

class MedalRepository {
  MedalRepository({FirestoreAdmin? admin}) : _admin = admin ?? FirestoreAdmin();

  final FirestoreAdmin _admin;

  Stream<List<Medal>> watchMedals() => _admin.medals
      .orderBy('xpReward')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());
}