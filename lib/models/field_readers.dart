import 'package:cloud_firestore/cloud_firestore.dart';

String readString(Object? value, {String fallback = ''}) =>
    value is String ? value : fallback;

String? readOptionalString(Object? value) => value is String ? value : null;

int readInt(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : fallback;

DateTime readDate(Object? value) => value is Timestamp
    ? value.toDate()
    : DateTime.fromMillisecondsSinceEpoch(0);

List<String> readStringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];