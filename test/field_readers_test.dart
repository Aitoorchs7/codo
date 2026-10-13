import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/models/field_readers.dart';
import 'package:codo/models/pact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('field readers', () {
    test('readString returns the value when it is a String', () {
      expect(readString('hola'), 'hola');
    });

    test('readString returns the fallback when the value is missing or not a String', () {
      expect(readString(null), '');
      expect(readString(42), '');
    });

    test('readInt accepts ints and doubles and ignores garbage', () {
      expect(readInt(7), 7);
      expect(readInt(7.9), 7);
      expect(readInt('7'), 0);
    });

    test('readDate converts a Timestamp and falls back to 1970 for corrupt data', () {
      final date = DateTime.utc(2026, 10, 12);
      expect(readDate(Timestamp.fromDate(date)).toUtc(), date);
      expect(readDate('ayer'), DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('readStringList drops items that are not Strings', () {
      expect(readStringList(['a', 1, 'b']), ['a', 'b']);
      expect(readStringList('no soy una lista'), isEmpty);
    });
  });

  group('Pact.progress', () {
    final base = DateTime(2026, 10, 12);

    test('is the fraction of days done', () {
      final pact = Pact(id: '1', title: 't', partnerName: 'p', daysDone: 12, daysTotal: 30, createdAt: base);
      expect(pact.progress, closeTo(0.4, 0.0001));
    });

    test('is 0 when the pact has no days instead of dividing by zero', () {
      final pact = Pact(id: '1', title: 't', partnerName: 'p', daysDone: 3, daysTotal: 0, createdAt: base);
      expect(pact.progress, 0);
    });

    test('never goes above 1 even with inconsistent data', () {
      final pact = Pact(id: '1', title: 't', partnerName: 'p', daysDone: 40, daysTotal: 30, createdAt: base);
      expect(pact.progress, 1);
    });
  });
}