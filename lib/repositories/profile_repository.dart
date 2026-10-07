
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile.dart';

class ProfileRepository {
  final _col = FirebaseFirestore.instance.collection('users').withConverter<Profile>(
    fromFirestore: Profile.fromFirestore,
    toFirestore: (profile, _) => profile.toFirestore(),
  );
}