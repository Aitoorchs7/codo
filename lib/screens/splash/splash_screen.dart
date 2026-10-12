import 'package:codo/admins/auth_service.dart';
import 'package:codo/admins/preferences_admin.dart';
import 'package:codo/app/app_routes.dart';
import 'package:codo/utils/startup_route.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  //traemos las preferencias del usuario
  //para ver si la pantalla se ha visto y si no, hacer que se haya visto
  final _prefs = PreferencesAdmin();
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    //Cargamos la pantalla y ejecutamos el metodo que decide que hacer
    // En cada caso del estado de sesión del usuario.
    _decideDestination();
  }

  Future<void> _decideDestination() async {
    // 1: ¿Hay una sesión guardada?
    final user = await _auth.currentUser();
    // 2: ¿Se ha visto ya el onboarding?
    final seen = await _prefs.isOnboardingSeen();
    // 3: Dejamos el splash visible un mínimo para que se vea.
    await Future.delayed(const Duration(seconds: 2));

    // Tras los await la pantalla puede haber desaparecido: no navegamos.
    if (!mounted) return;

    final route = startupRoute(signedIn: user != null, onboardingSeen: seen);
    // Replacement: el splash sale de la pila y atrás no vuelve a él.
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 104),
            const Text('Codo'),
            Image.network(
              'https://picsum.photos/nada.jpg',
              width: 280,
              height: 168,
              fit: BoxFit.cover,
              // Mientras descarga: progress es null cuando ya terminó.
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 280,
                  height: 168,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              // Si falla la descarga, no rompemos nada: mostramos un aviso.
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 280,
                  height: 168,
                  child: Center(
                    child: Text('No se pudo cargar la imagen'),
                  ),
                );
              },
            ),
            const Text('Cumple tus objetivos acompañado'),
          ],
        ),
      ),
    );
  }
}


