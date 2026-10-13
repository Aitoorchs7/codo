import 'package:codo/admins/auth_failure.dart';

//Texto para el usuario de cada error de acceso. Un switch sobre un enum
//obliga a cubrir todos los casos: si alguien añade un AuthError nuevo y no
//lo trata aquí, el proyecto no compila.
String authErrorMessage(AuthError error) {
  return switch (error) {
    AuthError.invalidCredentials =>
    'Correo o contraseña incorrectos. Revísalos e inténtalo otra vez.',
    AuthError.emailInUse =>
    'Este correo ya tiene una cuenta. ¿Quieres entrar?',
    AuthError.weakPassword =>
    'Contraseña demasiado débil: usa al menos 6 caracteres.',
    AuthError.invalidEmail =>
    'El correo no tiene un formato válido.',
    AuthError.userDisabled =>
    'Esta cuenta está desactivada.',
    AuthError.tooManyRequests =>
    'Demasiados intentos. Espera un momento y vuelve a probar.',
    AuthError.networkRequestFailed =>
    'Sin conexión. Comprueba tu red e inténtalo de nuevo.',
    AuthError.unknown =>
    'Algo ha salido mal. Inténtalo de nuevo.',
  };
}