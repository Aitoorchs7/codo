// Resumen de un archivo de Open-Meteo: pocos números en vez de un Map de varios MB.
// Es lo que vuelve del isolate, así que tiene que ser pequeño y solo con tipos simples.
class WeatherSummary {
  final int hours;
  final double avgTemp;
  final double maxTemp;
  final double totalRain;

  const WeatherSummary({
    required this.hours,
    required this.avgTemp,
    required this.maxTemp,
    required this.totalRain,
  });

  // json = resultado de jsonDecode. Open-Meteo trae listas paralelas dentro de "hourly"
  factory WeatherSummary.fromArchiveJson(Map<String, dynamic> json) {
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) {
      throw const FormatException('Falta "hourly" en la respuesta');
    }
    // Puede haber horas sin dato (null): se descartan con whereType
    final temps = (hourly['temperature_2m'] as List? ?? []).whereType<num>();
    final rain = (hourly['precipitation'] as List? ?? []).whereType<num>();
    if (temps.isEmpty) throw const FormatException('Sin temperaturas');

    return WeatherSummary(
      hours: temps.length,
      avgTemp: temps.fold<double>(0, (sum, t) => sum + t) / temps.length,
      maxTemp: temps.fold<double>(-999, (max, t) => t > max ? t.toDouble() : max),
      totalRain: rain.fold<double>(0, (sum, r) => sum + r),
    );
  }
}
