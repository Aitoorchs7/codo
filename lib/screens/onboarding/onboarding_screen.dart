import 'package:codo/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:codo/admins/preferences_admin.dart';
import 'package:codo/widgets/codo_background.dart';
import 'package:codo/app/codo_colors.dart';
import 'package:codo/widgets/glass_button.dart';
import 'package:google_fonts/google_fonts.dart';

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
  //funcion que controla en 300 milisegundos el cambio de pagina, lo rapido que cambia la pagina
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
  Widget build(BuildContext context){
      return Scaffold(
        body: CodoBackground(
          child: SafeArea(
            child: Column(
              children: [
                // 1. Saltar, arriba a la derecha
                // 1. Saltar, arriba a la derecha. En la última página se oculta
                // pero conserva su hueco para que nada se mueva.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Visibility(
                      visible: _current < _pageCount - 1,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: GlassButton(
                        onPressed: _finish,
                        child: const Text('Saltar'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: _onPageChanged,
                    // con un bucle recorremos las paginas que quiere mos mostrar
                    // según el indice en el que este y si el usuario pulsa el
                    //botón de siguiente, el indice aumenta +1 y asi sucesivamente
                    children: [
                      for (final p in _pages) _OnboardingPage(data: p),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      _PageDots(count: _pageCount, current: _current),
                      const SizedBox(height: 24),
                      GlassButton(
                        primary: true,
                        onPressed: _next,
                        child: Text(
                          _current == _pageCount - 1 ? 'Empezar' : 'Siguiente',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
// los datos de las paginas que llevan de
// la clase app_theme en el tema claro y oscuro
class _PageData {
  const _PageData({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;
}

// como se ve una pagina sin texto porque todas tienen la misma estructura
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        // Todo el texto pegado a la izquierda.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Icon(data.icon, size: 96, color: CodoColors.accent),
            ),
          ),
          Text(
            data.title,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            data.text,
            style: textTheme.bodyLarge?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
// Los textos que aparecen en las paginas según su posición en la tabla
const _pages = [
  _PageData(
    icon: Icons.groups,
    title: 'Ponerse cuesta menos '
        'acompañado',
    text: 'Publica lo que estés haciendo y tus'
        'amigos se suman a la vez. Estudiar,'
        'entrenar o leer, a tu codo.',
  ),
  _PageData(
    icon: Icons.handshake,
    title: 'Un pacto, dos '
        'personas',
    text: 'Elegis un reto y haceis check-in cada dia.'
        'Si uno se descuelga, perdeís los dos. Por'
        'eso nadie se descuelga',
  ),
  _PageData(
    icon: Icons.emoji_events,
    title: 'Cada objetivo cuenta',
    text: 'Gana XP, sube de nivel y llena tu perfil de '
        'medallas por lo que de verdad has'
        'cumplido.',
  ),
];
// Puntos de página: el activo es un punto azul más ancho.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  // para esta clase solo necesitamos el numero de paginas y la actual
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    // traemos los colores del tema
    final c = Theme.of(context).extension<CodoColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
        // AnimatedContainer anima solo el cambio de ancho y de color.
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? CodoColors.accent : c.track,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
