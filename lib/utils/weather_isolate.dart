import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:codo/admins/weather_failure.dart';
import 'package:codo/models/weather_summary.dart';
import 'package:codo/utils/net_log.dart';
import 'package:flutter/foundation.dart';

// Trabajo pesado y síncrono: decodificar el JSON y resumirlo.
// Pública para poder llamarla en el hilo principal (para medir) y probarla sin isolate.
WeatherSummary summarizeArchive(String body) =>
    WeatherSummary.fromArchiveJson(jsonDecode(body) as Map<String, dynamic>);

// Opción 1 · Isolate.run: crea el isolate, ejecuta, devuelve el resultado y el isolate
// muere solo. Es de primer nivel a propósito: así la closure solo captura `body`
// y no arrastra el repositorio ni la pantalla al otro isolate.
Future<WeatherSummary> summarizeWithIsolateRun(String body) {
  if (kIsWeb) return Future.value(summarizeArchive(body)); // en web no hay isolates
  return Isolate.run(() => summarizeArchive(body));
}

// Opción 2 · Isolate.spawn a mano: lo mismo, pero se puede matar a mitad.
// Isolate.run no se puede cancelar: si se cierra la pantalla, sigue hasta acabar.
class CancellableSummaryJob {
  CancellableSummaryJob(this.id);
  final String id;

  // Puertos abiertos por todos los trabajos. Tiene que volver a 0: es la prueba del bloque 1
  static int openPorts = 0;

  Isolate? _isolate;
  final _result = ReceivePort(); // buzón del resultado (o del error)
  final _exit = ReceivePort(); // buzón que avisa cuando el isolate muere
  final _done = Completer<WeatherSummary>();
  bool _closed = false;
  bool _cancelled = false;

  // No es async a propósito: devuelve el futuro YA, para que quien llama lo esté
  // escuchando aunque se cancele mientras el isolate todavía arranca
  Future<WeatherSummary> run(String body) {
    openPorts += 2;
    _result.listen(_onResult);
    _exit.listen((_) {
      NetLog.log(id, 'isolate terminado (onExit)');
      _closePorts(); // los dos buzones se cierran solo cuando el isolate ya no existe
    });
    _spawn(body);
    return _done.future;
  }

  Future<void> _spawn(String body) async {
    try {
      _isolate = await Isolate.spawn(
        _worker,
        [_result.sendPort, body],
        onExit: _exit.sendPort,
        onError: _result.sendPort, // un error llega como [mensaje, traza]
      );
    } catch (_) {
      // No llegó a nacer: no habrá onExit, así que los puertos se cierran aquí
      _closePorts();
      if (!_done.isCompleted) _done.completeError(const WeatherFailure(WeatherError.badData));
      return;
    }
    NetLog.log(id, 'isolate creado');
    if (_cancelled) _isolate!.kill(priority: Isolate.immediate); // cancelado mientras arrancaba
  }

  void _onResult(dynamic message) {
    if (_done.isCompleted) return;
    if (message is WeatherSummary) {
      _done.complete(message);
    } else {
      _done.completeError(const WeatherFailure(WeatherError.badData));
    }
  }

  // Se llama desde dispose de la pantalla
  void cancel() {
    if (_done.isCompleted || _cancelled) return;
    _cancelled = true;
    NetLog.log(id, 'pantalla cerrada: kill al isolate');
    _isolate?.kill(priority: Isolate.immediate); // onExit llegará después y cerrará los puertos
    _done.completeError(const WeatherFailure(WeatherError.cancelled));
  }

  void _closePorts() {
    if (_closed) return;
    _closed = true;
    _result.close();
    _exit.close();
    openPorts -= 2;
    NetLog.log(id, 'puertos cerrados; abiertos ahora: $openPorts');
  }
}

// Tiene que ser de primer nivel: el isolate no ve objetos de la pantalla
void _worker(List<Object> args) {
  final send = args[0] as SendPort;
  final body = args[1] as String;
  try {
    send.send(summarizeArchive(body));
  } catch (_) {
    send.send('error');
  }
}
