import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/medal.dart';
import 'package:codo/models/pact.dart';
import 'package:codo/models/profile.dart';

class FirestoreAdmin {
  FirestoreAdmin({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Profile> get profiles =>
      _db.collection('users').withConverter<Profile>(
        fromFirestore: Profile.fromFirestore,
        toFirestore: (profile, _) => profile.toFirestore(),
      );

  CollectionReference<Pact> get pacts =>
      _db.collection('pacts').withConverter<Pact>(
        fromFirestore: Pact.fromFirestore,
        toFirestore: (pact, _) => pact.toFirestore(),
      );

  CollectionReference<Medal> get medals =>
      _db.collection('badges').withConverter<Medal>(
        fromFirestore: Medal.fromFirestore,
        toFirestore: (medal, _) => medal.toFirestore(),
      );
}