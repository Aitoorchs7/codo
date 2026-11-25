import 'dart:convert';

import 'package:codo/admins/weather_admin.dart';
import 'package:codo/repositories/weather_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Responde siempre lo mismo y tarda 20 ms, como una red rápida
http.Client fakeServer() => MockClient((request) async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return http.Response(
    jsonEncode({'current': {'temperature_2m': 15.0}}),
    200,
  );
});

void main() {
  test('two screens asking at once make no duplicate calls (100 runs)', () async {
    var duplicates = 0;

    for (var run = 1; run <= 100; run++) {
      // UN solo repositorio, nuevo en cada vuelta (caché vacía), como en la app
      final repo = WeatherRepository(admin: WeatherAdmin(client: fakeServer()));

      // Hoy y Ahora piden lo mismo A LA VEZ, sobre el MISMO repositorio
      await Future.wait([
        repo.currentTemp(40.42, -3.70), // pantalla Hoy
        repo.currentTemp(40.42, -3.70), // pantalla Ahora
      ]);

      // Bastaba 1 llamada: lo que pase de 1 es duplicado
      duplicates += repo.realCalls - 1;
    }

    debugPrint('Llamadas duplicadas en 100 ejecuciones: $duplicates');
    expect(duplicates, 0);
  });
}