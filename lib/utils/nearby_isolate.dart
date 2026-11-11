import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

// Resultado: (posición en la lista original, metros hasta el usuario)
typedef Nearby = (int, double);

class NearbySorter {
  Future<List<Nearby>> sort(
      LatLng me,
      List<LatLng> points, {
        void Function(double)? onProgress,
      }) async {
    // En web no hay isolates reales: igual que con las fotos
    if (kIsWeb) return sortSync(me, points, onProgress ?? (_) {});
    final port = ReceivePort();
    await Isolate.spawn(_worker, [port.sendPort, me, points]);
    await for (final message in port) {
      if (message is double) {
        onProgress?.call(message);
      } else {
        port.close();
        if (message is List<Nearby>) return message;
        break;
      }
    }
    throw StateError('No se pudo calcular la distancia');
  }
}

void _worker(List<Object> args) {
  final send = args[0] as SendPort;
  try {
    send.send(sortSync(args[1] as LatLng, args[2] as List<LatLng>, send.send));
  } catch (_) {
    send.send('error'); // sin esto, la pantalla esperaría para siempre
  }
}

// Pública para poder probarla sin isolate
List<Nearby> sortSync(LatLng me, List<LatLng> points, void Function(double) progress) {
  const distance = Distance();
  final result = <Nearby>[];
  for (var i = 0; i < points.length; i++) {
    result.add((i, distance.as(LengthUnit.Meter, me, points[i])));
    progress((i + 1) / points.length);
  }
  result.sort((a, b) => a.$2.compareTo(b.$2)); // de menor a mayor distancia
  return result;
}