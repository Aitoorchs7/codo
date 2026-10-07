import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controla el PageView desde código: avanzar de página con el botón,
  // saltar a una concreta o saber en cuál está. Sin él solo se puede deslizar.
  final _controller = PageController();

  // TODO: página actual (int) para los puntos y el texto del botón.
  // TODO: _finish(): guardar seenKey en shared_preferences y ir a /login.
  // TODO: _next(): avanzar de página o terminar en la última.
  void pagina_actual(int pagina) {
    setState(() {
      _controller.jumpToPage(pagina);
    });
  }
  void _finish() {
    // TODO: Ir a /login.
  }
  void _next() {
    if (_controller.page == 2) {
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
