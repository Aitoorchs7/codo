import 'package:codo/admins/firestore_admin.dart';
import 'package:codo/models/profile.dart';

class ProfileRepository {
  ProfileRepository({FirestoreAdmin? admin}) : _admin = admin ?? FirestoreAdmin();

  final FirestoreAdmin _admin;

  Future<void> saveProfile(Profile profile) =>
      _admin.profiles.doc(profile.uid).set(profile);

  Future<Profile?> getProfile(String uid) async {
    final doc = await _admin.profiles.doc(uid).get();
    return doc.data();
  }
}