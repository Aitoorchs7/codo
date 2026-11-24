import 'dart:convert';

import 'package:codo/admins/weather_failure.dart';
import 'package:codo/utils/weather_isolate.dart';
import 'package:flutter_test/flutter_test.dart';

// JSON con la forma de Open-Meteo; [hours] controla el tamaño
String _archive(int hours) => jsonEncode({
      'hourly': {
        'temperature_2m': [for (var i = 0; i < hours; i++) i % 30],
        'precipitation': [for (var i = 0; i < hours; i++) i.isEven ? 1 : null],
      },
    });

void main() {
  test('summarizeArchive summarizes and skips hours without data', () {
    final s = summarizeArchive(_archive(4)); // temps 0,1,2,3 · lluvia 1,null,1,null
    expect(s.hours, 4);
    expect(s.avgTemp, 1.5);
    expect(s.maxTemp, 3);
    expect(s.totalRain, 2);
  });

  test('summarizeArchive throws FormatException when "hourly" is missing', () {
    expect(() => summarizeArchive('{"daily": {}}'), throwsFormatException);
  });

  test('Isolate.run gives the same result as the main thread', () async {
    final body = _archive(1000);
    final s = await summarizeWithIsolateRun(body);
    expect(s.hours, summarizeArchive(body).hours);
  });

  test('cancellable job finishes and leaves 0 open ports', () async {
    final s = await CancellableSummaryJob('t1').run(_archive(1000));
    expect(s.hours, 1000);
    await _untilPortsClosed();
  });

  test('cancellable job with corrupt JSON fails with badData and closes ports', () async {
    await expectLater(
      CancellableSummaryJob('t3').run('no es json'),
      throwsA(isA<WeatherFailure>()
          .having((f) => f.error, 'error', WeatherError.badData)),
    );
    await _untilPortsClosed();
  });

  test('cancel kills the isolate and leaves 0 open ports', () async {
    final job = CancellableSummaryJob('t2');
    final future = job.run(_archive(500000)); // grande, para cancelarlo a mitad
    job.cancel();
    await expectLater(
      future,
      throwsA(isA<WeatherFailure>()
          .having((f) => f.error, 'error', WeatherError.cancelled)),
    );
    await _untilPortsClosed();
  });
}

// onExit llega un poco después de kill: se espera hasta 2 s a que los puertos bajen a 0
Future<void> _untilPortsClosed() async {
  for (var i = 0; i < 40 && CancellableSummaryJob.openPorts != 0; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(CancellableSummaryJob.openPorts, 0);
}
