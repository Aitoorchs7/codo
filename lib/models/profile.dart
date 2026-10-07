import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {

  final String uid;
  final String displayName;
  String? photoUrl;
  String? bio;

  final DateTime createdAt;

  final int xp;
  final List<String> badges;


  Profile({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.xp,
    required this.badges,
    required this.createdAt,
  });

  factory Profile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options){
    final data = snapshot.data();
    return Profile(
      uid: snapshot.id,
      displayName: data?['displayName'] ?? '',
      photoUrl: data?['photoUrl'],
      bio: data?['bio'],
      xp: data?['xp'] ?? 0,
      badges: List<String>.from(data?['badges'] ?? []),
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore(){
    return{
      'displayName': displayName,
      'xp': xp,
      'badges': badges,
      'createdAt': createdAt,
      if(photoUrl != null) 'photoUrl': photoUrl,
      if(bio != null) 'bio': bio,
    };

  }
}

