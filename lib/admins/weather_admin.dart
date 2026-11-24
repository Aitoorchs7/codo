// lib/admins/weather_admin.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import 'weather_failure.dart';

class WeatherAdmin {
  // Se inyecta como los demás admins: en las pruebas se pasa un cliente falso
  WeatherAdmin({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  // La URL llega por --dart-define; si no se pasa, la pública de Open-Meteo
  static const _archiveUrl = String.fromEnvironment(
    'WEATHER_ARCHIVE_URL',
    defaultValue: 'https://archive-api.open-meteo.com/v1/archive',
  );
  static const _forecastUrl = String.fromEnvironment(
    'WEATHER_FORECAST_URL',
    defaultValue: 'https://api.open-meteo.com/v1/forecast',
  );

  // Devuelve el JSON como TEXTO: así la red y el jsonDecode se miden por separado
  Future<String> fetchArchiveBody({
    required double lat,
    required double lon,
    int years = 3,
  }) {
    // El archivo va con unos días de retraso: terminamos hace una semana
    final end = DateTime.now().subtract(const Duration(days: 7));
    final start = DateTime(end.year - years, end.month, end.day);

    final uri = Uri.parse(_archiveUrl).replace(queryParameters: {
      'latitude': lat.toStringAsFixed(2), // aproximada, como en el resto de la app
      'longitude': lon.toStringAsFixed(2),
      'start_date': _day(start),
      'end_date': _day(end),
      'hourly':
          'temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m',
    });

    return _get(uri, const Duration(seconds: 20));
  }

  // Petición pequeña (unos cientos de bytes): la temperatura de ahora en un punto.
  // Es la que se lanza muchas veces en el pool del bloque 2.
  Future<String> fetchCurrentBody({required double lat, required double lon}) {
    final uri = Uri.parse(_forecastUrl).replace(queryParameters: {
      'latitude': lat.toStringAsFixed(2),
      'longitude': lon.toStringAsFixed(2),
      'current': 'temperature_2m',
    });
    return _get(uri, const Duration(seconds: 10));
  }

  // GET común: traduce los errores de red y de servidor a WeatherFailure
  Future<String> _get(Uri uri, Duration timeout) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw const WeatherFailure(WeatherError.server);
      }
      return response.body;
    } on TimeoutException {
      throw const WeatherFailure(WeatherError.timeout);
    } on http.ClientException {
      // http envuelve aquí los errores de socket (sin red, DNS…), también en web
      throw const WeatherFailure(WeatherError.noConnection);
    }
  }

  // Cierra las conexiones abiertas cuando ya no se va a usar más
  void dispose() => _client.close();

  // yyyy-MM-dd, el formato que pide Open-Meteo
  String _day(DateTime d) => d.toIso8601String().substring(0, 10);
}
