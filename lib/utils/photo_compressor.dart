import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:codo/admins/photo_failure.dart';

// Límite de la regla de producto: la miniatura en base64 por debajo de 300 KB
const maxBase64Length = 300 * 1024;
const _maxSide = 800;

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
  progress(0.3);
  final resized = image.width >= image.height
      ? (image.width > _maxSide
            ? img.copyResize(image, width: _maxSide)
            : image)
      : (image.height > _maxSide
            ? img.copyResize(image, height: _maxSide)
            : image);
  progress(0.5);
  const qualities = [85, 70, 55, 40];
  for (var i = 0; i < qualities.length; i++) {
    final jpg = img.encodeJpg(resized, quality: qualities[i]);
    progress(0.5 + 0.5 * (i + 1) / qualities.length);
    if (base64Encode(jpg).length < maxBase64Length) return jpg;
  }
  throw const FormatException('No baja de 300 KB');
}
