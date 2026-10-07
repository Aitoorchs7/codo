
import 'package:flutter/material.dart';

import '../screens/onboarding/onboarding_screen.dart';

class App extends StatelessWidget{

  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Codo',
      initialRoute: "/onboarding",

      routes: {
        "/onboarding": (context) => OnboardingScreen(),

      },
    );
  }

}