// lib/admins/location_admin.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'location_failure.dart';

class LocationAdmin {
  // Se inyecta como los demás admins: en las pruebas se pasa uno falso
  LocationAdmin({GeolocatorPlatform? geo})
      : _geo = geo ?? GeolocatorPlatform.instance;
  final GeolocatorPlatform _geo;
  Future<bool> openSettings() => _geo.openAppSettings();

  Future<Position> currentPosition() async {
    // 1. ¿GPS apagado? -> throw LocationFailure(LocationError.serviceDisabled)
    if (!await _geo.isLocationServiceEnabled()) {
      throw const LocationFailure(LocationError.serviceDisabled);
    }
    // 2. var permission = await _geo.checkPermission();
    //    Si es denied -> pedirlo con _geo.requestPermission() y volver a mirar
    //    Si sigue en denied -> throw ...denied
    //    Si es deniedForever -> throw ...deniedForever
    var permission = await _geo.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geo.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationError.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationError.deniedForever);
    }
    // 3. Camino bueno: getCurrentPosition con un tiempo límite de 10 s.
    //    Precisión baja (LocationAccuracy.low), que es más rápida y gasta menos;
    //    nos basta porque la redondeamos a 2 decimales.
    //    Va dentro de un try: si salta TimeoutException -> throw ...timeout
    try {
      return await _geo.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on TimeoutException {
      throw const LocationFailure(LocationError.timeout);
    } on LocationServiceDisabledException {
      throw const LocationFailure(LocationError.serviceDisabled);
    } on PositionUpdateException {
      throw const LocationFailure(LocationError.unavailable);
    }
  }
}