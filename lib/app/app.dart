
import 'package:flutter/material.dart';

class App extends StatelessWidget{

  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Codo",
      // RUTAS CON NOMBRE: un mapa "nombre de ruta -> función que crea la pantalla".
      routes: {

      },
      // Primera pantalla que se muestra al arrancar la app.
      initialRoute: "/Onboardingview",
    );
  }

}

