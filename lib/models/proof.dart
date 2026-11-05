import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';

// Foto de prueba de un participante; el id del documento es su uid
class Proof {
  const Proof({required this.uid, required this.imageBase64, this.createdAt});

  final String uid;
  final String imageBase64;
  final DateTime? createdAt; // null hasta que el servidor pone la hora

  Uint8List get bytes => base64Decode(imageBase64);

  factory Proof.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? _,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Proof(
      uid: snapshot.id,
      imageBase64: readString(data['image']),
      createdAt: readOptionalDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'image': imageBase64,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
