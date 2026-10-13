import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';

class Pact {
  const Pact({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.daysDone,
    required this.daysTotal,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String partnerName;
  final int daysDone;
  final int daysTotal;
  final DateTime createdAt;

  // Progreso entre 0 y 1 para la barra. Con 0 días totales no se divide.
  double get progress =>
      daysTotal <= 0 ? 0 : (daysDone / daysTotal).clamp(0.0, 1.0).toDouble();

  factory Pact.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Pact(
      id: snapshot.id,
      title: readString(data['title']),
      partnerName: readString(data['partnerName']),
      daysDone: readInt(data['daysDone']),
      daysTotal: readInt(data['daysTotal']),
      createdAt: readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'partnerName': partnerName,
      'daysDone': daysDone,
      'daysTotal': daysTotal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}