import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:codo/admins/photo_failure.dart';

// Límite de la regla de producto: la miniatura en base64 por debajo de 300 KB
const maxBase64Length = 300 * 1024;
const _sides = [800, 600, 400];    // si no cabe con 800 px, se prueba más pequeña
const _qualities = [85, 70, 55, 40];

class PhotoCompressor {
  Future<Uint8List> compress(
    Uint8List bytes, {
    void Function(double)? onProgress,
  }) async {
    // En web no hay isolates reales: se hace en el hilo principal
    if (kIsWeb) {
      try {
        return compressSync(bytes, onProgress ?? (_) {});
      } catch (_) {
        throw const PhotoFailure(PhotoError.compressFailed);
      }
    }
    final port = ReceivePort();
    await Isolate.spawn(_worker, [port.sendPort, bytes]);
    await for (final message in port) {
      if (message is double) {
        onProgress?.call(message); // progreso
      } else {
        port.close(); // resultado o error: se cierra el buzón
        if (message is Uint8List) return message;
        break;
      }
    }
    throw const PhotoFailure(PhotoError.compressFailed);
  }
}

// Tiene que ser una función de primer nivel: el isolate no ve objetos de la pantalla
void _worker(List<Object> args) {
  final send = args[0] as SendPort;
  final bytes = args[1] as Uint8List;
  try {
    send.send(compressSync(bytes, send.send));
  } catch (_) {
    send.send('error');
  }
}


// Pública para poder probarla sin isolate
Uint8List compressSync(Uint8List bytes, void Function(double) progress) {
  final raw = img.decodeImage(bytes);
  if (raw == null) throw const FormatException('Imagen no válida');
  final image = img.bakeOrientation(raw); // endereza las fotos de cámara (EXIF)
  image.exif = img.ExifData();
  progress(0.3);
  final total = _sides.length * _qualities.length; // 12 intentos como mucho
  var step = 0;
  for (final side in _sides) {
    final resized = _fit(image, side);
    for (final quality in _qualities) {
      final jpg = img.encodeJpg(resized, quality: quality);
      step++;
      progress(0.3 + 0.7 * step / total);
      if (base64Encode(jpg).length < maxBase64Length) return jpg;
    }
  }
  throw const FormatException('No baja de 300 KB');
}

// Reduce la imagen para que su lado mayor mida como mucho [side]; nunca la amplía
img.Image _fit(img.Image image, int side) {
  if (image.width >= image.height) {
    return image.width > side ? img.copyResize(image, width: side) : image;
  }
  return image.height > side ? img.copyResize(image, height: side) : image;
}
