
import 'package:codo/screens/login/login_screen.dart';
import 'package:codo/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes{
  static const login = '/login';
  static const onboarding = '/onboarding';

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    onboarding: (context) => const OnboardingScreen(),
  };
}
