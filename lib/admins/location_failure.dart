//Fallos al elegir en la localizacion; la pantalla decide el texto
enum LocationError {
  denied, deniedForever, serviceDisabled, timeout, unavailable
}

class LocationFailure implements Exception {
  final LocationError error;
  const LocationFailure(this.error);
}
