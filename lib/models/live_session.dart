import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';

enum SessionCategory { study, train, read, work, other }
enum SessionVisibility { friends, public }
enum SessionStatus { active, finished }

class LiveSession {
  const LiveSession({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.category,
    required this.description,
    required this.visibility,
    required this.startedAt,
    required this.durationMinutes,
    required this.status,
    required this.participantIds,
    required this.latitude,
    required this.longitude,
    required this.locationAt,
    required this.endedAt,

});
  final String id;
  final String creatorId;
  final String creatorName;
  final SessionCategory category;
  final String description;
  final SessionVisibility visibility;
  final DateTime startedAt;
  final int durationMinutes;
  final SessionStatus status;
  final List<String> participantIds;
  final double? latitude;
  final double? longitude;
  final DateTime? locationAt;
  final DateTime? endedAt;

  factory LiveSession.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final location = data['location'];   // puede no venir
    return LiveSession(
      id: snapshot.id,
      creatorId: readString(data['creatorId']),
      creatorName: readString(data['creatorName']),
      description: readString(data['description']),
      startedAt: readDate(data['startedAt']),
      durationMinutes: readInt(data['durationMinutes']),
      category: readEnum(data['category'], SessionCategory.values, SessionCategory.other),
      visibility: readEnum(data['visibility'], SessionVisibility.values, SessionVisibility.friends),
      status: readEnum(data['status'], SessionStatus.values, SessionStatus.active),
      participantIds: readStringList(data['participantIds']),
      endedAt: readOptionalDate(data['endedAt']),
      latitude: location is GeoPoint ? location.latitude : null,
      longitude: location is GeoPoint ? location.longitude : null,
      locationAt: readOptionalDate(data['locationAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'description': description,
      'startedAt': Timestamp.fromDate(startedAt),
      'durationMinutes': durationMinutes,
      'category': category.name,
      'visibility': visibility.name,
      'status': status.name,
      'participantIds': participantIds,
      'endedAt': endedAt == null ? null : Timestamp.fromDate(endedAt!),
// La ubicación solo se escribe si existe
      if (latitude != null && longitude != null) ...{
        'location': GeoPoint(latitude!, longitude!),
        'locationAt': locationAt == null ? null : Timestamp.fromDate(locationAt!),
      },
    };
  }
}
