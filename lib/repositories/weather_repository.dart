import 'dart:convert';

import 'package:codo/admins/weather_admin.dart';
import 'package:codo/admins/weather_failure.dart';
import 'package:codo/models/weather_summary.dart';
import 'package:codo/utils/net_log.dart';
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

  // La pantalla lo llama al cerrarse: mata el isolate si sigue vivo y cierra el cliente HTTP
  void dispose() {
    _job?.cancel();
    _admin.dispose();
  }
}
