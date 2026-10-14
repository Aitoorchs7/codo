import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';

class Medal {
  const Medal({
    required this.id,
    required this.name,
    required this.description,
    required this.xpReward,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final int xpReward;
  final String imageUrl;

  factory Medal.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Medal(
      id: snapshot.id,
      name: readString(data['name']),
      description: readString(data['description']),
      xpReward: readInt(data['xpReward']),
      imageUrl: readString(data['imageUrl']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'xpReward': xpReward,
      'imageUrl': imageUrl,
    };
  }
}