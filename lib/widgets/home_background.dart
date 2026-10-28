import 'package:codo/app/codo_colors.dart';
import 'package:flutter/material.dart';

// Fondo de las secciones principales: la red de puntos, con un velo del
// color del tema para que las tarjetas y los textos se lean bien.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          isDark
              ? 'assets/images/imagenes_app/fondo_codo_oscuro.webp'
              : 'assets/images/imagenes_app/fondo_codo_claro.webp',
          fit: BoxFit.cover,
        ),
        ColoredBox(color: c.bgBottom.withValues(alpha: 0.6)),
      ],
    );
  }
}