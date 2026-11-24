import 'package:flutter/foundation.dart';

// Traza de red legible: "t+  1234 ms  #arch3  mensaje".
// Un solo reloj para toda la app, así las líneas de distintas peticiones se pueden comparar.
class NetLog {
  NetLog._();

  static final _clock = Stopwatch()..start();
  static final List<String> lines = []; // se copian a docs/ai2/trazas/
  static int _seq = 0;

  // Identificador corto y único por petición: arch1, arch2…
  static String newId(String prefix) => '$prefix${++_seq}';

  static void log(String id, String message) {
    final ms = _clock.elapsedMilliseconds.toString().padLeft(7);
    final line = 't+$ms ms  #$id  $message';
    lines.add(line);
    debugPrint(line);
  }

  static void clear() => lines.clear();
}
