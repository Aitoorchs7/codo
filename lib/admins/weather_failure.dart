// Fallos al pedir el tiempo; la pantalla decide el texto
enum WeatherError { timeout, noConnection, server, badData, cancelled }

class WeatherFailure implements Exception {
  final WeatherError error;
  const WeatherFailure(this.error);

  // Para que en las trazas salga "server" y no "Instance of WeatherFailure"
  @override
  String toString() => error.name;
}
