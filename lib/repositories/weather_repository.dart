import 'dart:convert';

import 'package:codo/admins/weather_admin.dart';
import 'package:codo/admins/weather_failure.dart';
import 'package:codo/models/weather_summary.dart';
import 'package:codo/utils/net_log.dart';
import 'package:codo/utils/priority_scheduler.dart';
import 'package:codo/utils/request_pool.dart';
import 'package:codo/utils/weather_isolate.dart';
import 'package:flutter/foundation.dart';

// Dónde se hace el trabajo pesado (bloque 1 de AI2)
enum DecodeMode { mainThread, isolateRun, cancellable }

// Lo que mide una carga: la red y la decodificación, por separado
class DecodeReport {
  final DecodeMode mode;
  final int bytes;
  final int netMs; // esperando a la red (el hilo principal está libre)
  final int decodeMs; // solo jsonDecode (en el hilo principal)
  final int workMs; // decodificar + resumir, esté donde esté
  final WeatherSummary summary;

  const DecodeReport({
    required this.mode,
    required this.bytes,
    required this.netMs,
    required this.decodeMs,
    required this.workMs,
    required this.summary,
  });
}

// Resultado de una pasada del pool (una fila de la tabla K / tiempo)
class PoolReport {
  final int k;
  final int totalMs;
  final int done;
  final int failed;
  const PoolReport({
    required this.k,
    required this.totalMs,
    required this.done,
    required this.failed,
  });
}

class WeatherRepository {
  WeatherRepository({WeatherAdmin? admin}) : _admin = admin ?? WeatherAdmin();
  final WeatherAdmin _admin;
  CancellableSummaryJob? _job;

  Future<DecodeReport> measureArchive({
    required double lat,
    required double lon,
    required int years,
    required DecodeMode mode,
  }) async {
    final id = NetLog.newId('arch');
    final watch = Stopwatch()..start();

    // 1 · Red: await suelta el hilo mientras llegan los bytes
    NetLog.log(id, 'GET archivo de $years años (${mode.name})');
    final body = await _admin.fetchArchiveBody(lat: lat, lon: lon, years: years);
    final netMs = watch.elapsedMilliseconds;
    NetLog.log(id, 'red: $netMs ms, ${body.length} bytes');

    // 2 · Solo jsonDecode, en el hilo principal: la medida que justifica el isolate.
    //     En el modo isolate no se hace, porque congelaría justo lo que queremos evitar.
    var decodeMs = -1;
    if (mode == DecodeMode.mainThread) {
      watch..reset()..start();
      jsonDecode(body);
      decodeMs = watch.elapsedMilliseconds;
      NetLog.log(id, 'jsonDecode en hilo principal: $decodeMs ms');
    }

    // 3 · Decodificar + resumir donde diga el modo
    watch..reset()..start();
    final WeatherSummary summary;
    try {
      summary = switch (mode) {
        DecodeMode.mainThread => summarizeArchive(body),
        DecodeMode.isolateRun => await summarizeWithIsolateRun(body),
        DecodeMode.cancellable when kIsWeb => summarizeArchive(body),
        DecodeMode.cancellable => await (_job = CancellableSummaryJob(id)).run(body),
      };
    } on FormatException {
      throw const WeatherFailure(WeatherError.badData);
    }
    final workMs = watch.elapsedMilliseconds;
    NetLog.log(id, 'resumen listo (${mode.name}): $workMs ms, ${summary.hours} horas');

    return DecodeReport(
      mode: mode,
      bytes: body.length,
      netMs: netMs,
      decodeMs: decodeMs,
      workMs: workMs,
      summary: summary,
    );
  }

  // ── Bloque 2 · Varias peticiones a la vez ──

  // Rejilla de puntos sobre la península: [count] peticiones distintas
  // (URL distinta para que el servidor no devuelva lo mismo de caché)
  static List<(double, double)> grid(int count) => [
        for (var i = 0; i < count; i++)
          (36.5 + (i ~/ 8) * 0.9, -8.5 + (i % 8) * 1.4),
      ];

  // Pide la temperatura actual de [count] puntos con K a la vez.
  // [failEvery]: si no es null, la 1.ª vez de cada N-ésima petición falla a propósito
  Future<PoolReport> loadGrid({
    required int k,
    int count = 32,
    int? failEvery,
    void Function(List<PoolTask<double>> tasks)? onChange,
  }) async {
    final points = grid(count);
    final tasks = <PoolTask<double>>[];
    for (var i = 0; i < points.length; i++) {
      final (lat, lon) = points[i];
      final inject = failEvery != null && (i + 1) % failEvery == 0;
      var firstTry = true;
      tasks.add(PoolTask(NetLog.newId('k$k-p'), () async {
        if (inject && firstTry) {
          firstTry = false;
          // Fallo provocado: simula un 500 del servidor en el primer intento
          await Future<void>.delayed(const Duration(milliseconds: 50));
          throw const WeatherFailure(WeatherError.server);
        }
        final body = await _admin.fetchCurrentBody(lat: lat, lon: lon);
        // JSON de ~300 bytes: decodificarlo en el hilo principal no se nota
        final json = jsonDecode(body) as Map<String, dynamic>;
        return ((json['current'] as Map)['temperature_2m'] as num).toDouble();
      }));
    }

    final pool = RequestPool(
      k: k,
      // Solo se reintenta lo que puede arreglarse solo; un JSON roto seguirá roto
      shouldRetry: (e) => e is WeatherFailure && e.error != WeatherError.badData,
      onChange: onChange == null ? null : () => onChange(tasks),
    );
    final watch = Stopwatch()..start();
    NetLog.log('pool', 'K=$k · $count peticiones · empieza');
    await pool.runAll(tasks);
    final ms = watch.elapsedMilliseconds;
    final done = tasks.where((t) => t.state == RequestState.done).length;
    NetLog.log('pool', 'K=$k · $ms ms · $done/$count terminadas');
    return PoolReport(k: k, totalMs: ms, done: done, failed: count - done);
  }

  // ── Bloque 3 · No pedir dos veces lo mismo ──

  // Cuántas veces se sale DE VERDAD a internet (lo leerá la prueba)
  int realCalls = 0;
  // Temperaturas ya pedidas, por punto
  final Map<String, double> _cache = {};
  // Peticiones EN CURSO por punto: la segunda pantalla se engancha a la misma
  final Map<String, Future<double>> _inFlight = {};

  Future<double> currentTemp(double lat, double lon) async {
    final key = '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';
    final cached = _cache[key];
    if (cached != null) return cached;
    final inFlight = _inFlight[key];
    if (inFlight != null) return inFlight;
    final future = _fetchTemp(key, lat, lon);
    _inFlight[key] = future;
    return future.whenComplete(() => _inFlight.remove(key));
  }

  // Sale a la red de verdad. Solo lo llama currentTemp
  Future<double> _fetchTemp(String key, double lat, double lon) async {
    realCalls++;
    final body = await _admin.fetchCurrentBody(lat: lat, lon: lon);
    final json = jsonDecode(body) as Map<String, dynamic>;
    final temp = ((json['current'] as Map)['temperature_2m'] as num).toDouble();
    _cache[key] = temp;
    return temp;
  }

  // ── Bloque 4 · Lo del usuario primero ──

  // Una petición real a Open-Meteo para el punto i de la rejilla (red de verdad)
  Future<String> _point(int i) {
    final (lat, lon) = grid(64)[i % 64];
    return _admin.fetchCurrentBody(lat: lat, lon: lon);
  }

  // Espera a todas sin cortar en la primera que falle (el fallo ya sale en la traza)
  Future<void> _all(List<Future<String>> futures) => Future.wait(
        futures.map((f) => f.then<void>((_) {}, onError: (Object e) {})),
      );

  // Traza A: arranca una sincronización de fondo de 6 peticiones; a los 150 ms el
  // usuario pide 2 cosas. Se espera que las del usuario adelanten a las de fondo
  // que aún estaban en la cola.
  Future<void> demoUserOvertakes({int slots = 1, int? fairEvery = 3}) async {
    final s = PriorityScheduler(slots: slots, fairEvery: fairEvery);
    NetLog.log('prio', 'TRAZA A · slots=$slots · regla=${fairEvery ?? 'sin regla'}');
    final futures = <Future<String>>[
      for (var i = 0; i < 6; i++)
        s.submit(NetLog.newId('bg'), Priority.background, () => _point(i)),
    ];
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (var i = 0; i < 2; i++) {
      futures.add(s.submit(NetLog.newId('user'), Priority.user, () => _point(10 + i)));
    }
    await _all(futures);
    NetLog.log('prio', 'TRAZA A · fin');
  }

  // Traza B: 3 de fondo esperando y el usuario NO PARA: una petición nueva cada 20 ms
  // durante [userRequests] peticiones (más rápido de lo que se atienden).
  // Con regla, el fondo pasa cada [fairEvery]; sin regla, espera a que el usuario pare.
  Future<void> demoUserFlood({
    int slots = 1,
    int? fairEvery = 3,
    int userRequests = 15,
  }) async {
    final s = PriorityScheduler(slots: slots, fairEvery: fairEvery);
    NetLog.log('prio', 'TRAZA B · slots=$slots · regla=${fairEvery ?? 'sin regla'}');
    final futures = <Future<String>>[
      for (var i = 0; i < 3; i++)
        s.submit(NetLog.newId('bg'), Priority.background, () => _point(20 + i)),
    ];
    for (var i = 0; i < userRequests; i++) {
      futures.add(s.submit(NetLog.newId('user'), Priority.user, () => _point(30 + i)));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    await _all(futures);
    NetLog.log('prio', 'TRAZA B · fin');
  }

  // La pantalla lo llama al cerrarse: mata el isolate si sigue vivo y cierra el cliente HTTP
  void dispose() {
    _job?.cancel();
    _admin.dispose();
  }
}
