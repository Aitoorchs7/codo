import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';

class Profile {

  final String uid;
  final String displayName;
  final String? photoUrl;
  final String? bio;

  final DateTime createdAt;

  final int xp;
  final List<String> medals;


  const Profile({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.xp,
    required this.medals,
    required this.createdAt,
  });

  factory Profile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options){
    final data = snapshot.data();
    return Profile(
      uid: snapshot.id,
      displayName: readString(data?['displayName']),
      photoUrl: readOptionalString(data?['photoUrl']),
      bio: readOptionalString(data?['bio']),
      xp: readInt(data?['xp']),
      medals: readStringList(data?['badges']),
      createdAt: readDate(data?['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore(){
    return{
      'displayName': displayName,
      'xp': xp,
      'badges': medals,
      'createdAt': Timestamp.fromDate(createdAt),// con esto evitamos el datetimenow()
      if(photoUrl != null) 'photoUrl': photoUrl,
      if(bio != null) 'bio': bio,
    };

  }
}

