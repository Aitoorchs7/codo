
import 'package:codo/screens/auth/auth_screen.dart';
import 'package:codo/screens/home/home_screen.dart';
import 'package:codo/screens/onboarding/onboarding_screen.dart';
import 'package:codo/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes{
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const splash = '/splash';
  static const home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const AuthScreen(),
    onboarding: (context) => const OnboardingScreen(),
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
  };

  String initialRoute() => splash;
}
