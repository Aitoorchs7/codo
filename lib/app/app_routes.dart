
import 'package:codo/screens/auth/auth_screen.dart';
import 'package:codo/screens/home/home_screen.dart';
import 'package:codo/screens/onboarding/onboarding_screen.dart';
import 'package:codo/screens/pacts/pact_detail_screen.dart';
import 'package:codo/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes{
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const splash = '/splash';
  static const home = '/home';
  static const pactDetail = '/pact-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(settings, const SplashScreen());
      case onboarding:
        return _page(settings, const OnboardingScreen());
      case login:
        return _page(settings, const AuthScreen());
      case home:
        return _page(settings, const HomeScreen());
      case pactDetail:
        final args = settings.arguments;
        if (args is! PactDetailArgs) return _errorPage(settings);
        return _page(settings, PactDetailScreen(args: args));
      default:
        return _errorPage(settings);
    }
  }

  static MaterialPageRoute<void> _page(RouteSettings settings, Widget screen) =>
      MaterialPageRoute(settings: settings, builder: (_) => screen);

  static MaterialPageRoute<void> _errorPage(RouteSettings settings) =>
      _page(settings, const Scaffold(body: Center(child: Text('Ruta no válida'))));
}
