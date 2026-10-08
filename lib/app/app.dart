
import 'package:flutter/material.dart';

import 'app_theme.dart';

class App extends StatelessWidget{

  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Codo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Sigue el modo claro/oscuro del móvil.
      themeMode: ThemeMode.system,
      home:Scaffold(

      )
    );
  }

}