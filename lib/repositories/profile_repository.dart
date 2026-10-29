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
  Future<Profile> getOrCreateProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
  }) async {
    final profile = await getProfile(uid);
    if (profile != null) return profile;
    final newProfile = Profile(
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      xp: 0,
      medals: const [],
      createdAt: DateTime.now(),
    );
    await saveProfile(newProfile);
    return newProfile;
  }
    // 1. ¿Existe ya? → lo devuelvo tal cual (no piso su nombre ni su XP)
    // 2. Si no: creo Profile(uid, displayName, photoUrl, xp: 0, medals: const [], createdAt: DateTime.now())
    // 3. saveProfile(profile) y lo devuelvo
}
