import 'package:codo/app/app_routes.dart';

/// Decide a qué pantalla va la app al arrancar.
String startupRoute({required bool signedIn, required bool onboardingSeen}) {
  // Quien ya tiene sesión no necesita ver el onboarding otra vez.
  if (signedIn) return AppRoutes.home;
  if (!onboardingSeen) return AppRoutes.onboarding;
  return AppRoutes.login;
}