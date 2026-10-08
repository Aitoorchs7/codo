
import 'package:codo/app/app_routes.dart';
import 'package:codo/screens/login/login_screen.dart';
import 'package:codo/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class App extends StatelessWidget{

  const App({super.key});

  static final Map<String, Widget Function(BuildContext)> rutasApp= AppRoutes.routes;

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Codo',

      //los temas claro y oscuro de la app
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      routes: AppRoutes.routes,
      initialRoute: AppRoutes.onboarding,
      // Sigue el modo claro/oscuro del móvil.
      themeMode: ThemeMode.system,
    );
  }

}