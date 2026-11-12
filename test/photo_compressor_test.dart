import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:codo/utils/photo_compressor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// Degradado con algo de ruido, parecido a una foto real.
// Con noise: 128 es ruido puro, el peor caso para JPEG.
// Semilla fija para que salga la misma imagen en cada ejecución.
Uint8List _fakePhoto(int width, int height, {int noise = 20}) {
  final random = Random(42);
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    int channel(int base) =>
        (base + random.nextInt(2 * noise + 1) - noise).clamp(0, 255);
    pixel.setRgb(
      channel(pixel.x * 255 ~/ width),
      channel(pixel.y * 255 ~/ height),
      channel(128),
    );
  }
  return img.encodeJpg(image, quality: 95);
}

void main() {
  test('compressSync shrinks a big landscape photo to 800 px wide and under 300 KB', () {
    final result = compressSync(_fakePhoto(2000, 1500), (_) {});
    final decoded = img.decodeJpg(result)!;

    expect(decoded.width, 800);
    expect(decoded.height, 600); // mantiene la proporción 4:3
    expect(base64Encode(result).length, lessThan(maxBase64Length));
  });

  test('compressSync limits the height of a portrait photo', () {
    final decoded = img.decodeJpg(compressSync(_fakePhoto(1500, 2000), (_) {}))!;

    expect(decoded.height, 800);
    expect(decoded.width, 600);
  });

  test('compressSync does not enlarge a small photo', () {
    final decoded = img.decodeJpg(compressSync(_fakePhoto(400, 300), (_) {}))!;

    expect(decoded.width, 400);
  });

  test('compressSync reports progress that only goes up', () {
    final values = <double>[];
    compressSync(_fakePhoto(1000, 750), values.add);

    expect(values.first, 0.3);
    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThan(values[i - 1]));
    }
    expect(values.last, lessThanOrEqualTo(1));
  });

  test('compressSync throws FormatException when the bytes are not an image', () {
    expect(
          () => compressSync(Uint8List.fromList([1, 2, 3]), (_) {}),
      throwsFormatException,
    );
  });
  test('compressSync gets even pure noise under 300 KB by making it smaller', () {
    final result = compressSync(_fakePhoto(2000, 1500, noise: 128), (_) {});
    final decoded = img.decodeJpg(result)!;

    expect(base64Encode(result).length, lessThan(maxBase64Length));
    expect(decoded.width, lessThan(800)); // con 800 px no cabía
  });
  test('removes the GPS position stored in the photo metadata', () {
    final original = img.Image(width: 100, height: 100);
    original.exif.gpsIfd.gpsLatitude = 40.416775;
    original.exif.gpsIfd.gpsLongitude = -3.703790;
    final bytes = img.encodeJpg(original);
    // Comprobación previa: la foto de partida sí lleva el GPS
    expect(img.decodeJpg(bytes)!.exif.gpsIfd.hasGPSLatitude, isTrue);

    final result = compressSync(bytes, (_) {});

    expect(img.decodeJpg(result)!.exif.gpsIfd.hasGPSLatitude, isFalse);
  });
}