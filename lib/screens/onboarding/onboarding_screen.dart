import 'package:codo/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:codo/admins/preferences_admin.dart';

//Son las tres paginas que aparecen en el onboarding
// las del tutorial de como funciona la app
const _pageCount = 3;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // _conroller: controlador de la página.
  final _controller = PageController();
  // traemos las preferencias del usuario
  final _prefs = PreferencesAdmin();
  // indica la pagina en la que se encuantra ahora la pantalla
  int _current = 0;

  // cambia la pagina que el usuario ve, lo llamamos cuando queramos para que la cambie
  void _onPageChanged(int index) {
    setState(() => _current = index);
  }
  //el finish cambia de pagina a la siguiente (login)
  //y cambia el valor de onboarding_seen a true para que
  // al entrar a la aplicacion no se vuelva a mostrar
  Future<void> _finish() async {
    await _prefs.markAsOnboardingSeen();
    if (!mounted) return;
    Navigator.popAndPushNamed(context, AppRoutes.login);
  }
  //funcion que controla en 300 milisegundos el cambio de pagina, si el usuario
  // ejecuta la funcion finish si ha termionado el onboarding
  void _next() {
    if (_current == _pageCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  // Flutter lo llama una vez, cuando la pantalla sale del árbol para siempre.
  // Aquí se libera lo creado en el State; si no, el controlador se queda en
  // memoria (fuga) aunque la pantalla ya no exista.
  @override
  void dispose() {
    _controller.dispose();
    // Siempre al final: primero se libera lo propio y luego lo de Flutter.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Scaffold con botón Saltar, PageView (3 páginas), puntos y botón.
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: _next, child: Text('Saltar'))
      ),
    );
  }
}
