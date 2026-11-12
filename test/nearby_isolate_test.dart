import 'package:codo/utils/nearby_isolate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  // Usuario en Villanueva de la Torre
  const me = LatLng(40.58, -3.30);
  const madrid = LatLng(40.42, -3.70);      // ~38 km
  const guadalajara = LatLng(40.63, -3.17); // ~12 km
  const toledo = LatLng(39.86, -4.02);      // ~100 km

  group('sortSync', () {
    test('orders the points from nearest to farthest', () {
      final result = sortSync(me, [madrid, guadalajara, toledo], (_) {});
      // Índices de la lista original: Guadalajara (1), Madrid (0), Toledo (2)
      expect(result.map((r) => r.$1), [1, 0, 2]);
    });

    test('reports progress up to 1.0', () {
      final progress = <double>[];
      sortSync(me, [madrid, guadalajara, toledo], progress.add);
      expect(progress.last, 1.0);
      expect(progress.length, 3); // un aviso por punto
    });

    test('returns an empty list when there are no points', () {
      expect(sortSync(me, [], (_) {}), isEmpty);
    });
  });
}