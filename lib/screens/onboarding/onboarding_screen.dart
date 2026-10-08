import 'package:flutter/material.dart';

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
  // indica la pagina en la que se encuantra ahora la pantalla
  int _current = 0;

  // cambia la pagina que el usuario ve, lo llamamos cuando queramos para que la cambie
  void _onPageChanged(int index) {
    setState(() => _current = index);
  }
  void _finish() {
    // TODO: Ir a /login.
  }
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
    return const Scaffold();
  }
}
