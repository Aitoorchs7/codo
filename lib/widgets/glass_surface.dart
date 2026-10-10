import 'dart:ui';

import 'package:codo/app/codo_colors.dart';
import 'package:flutter/material.dart';

/// Superficie de cristal: desenfoque, interior casi transparente y la luz
/// solo en el borde. La usan botones, chips y tarjetas.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 18,
    this.tint,
  });

  final Widget child;
  final double radius;
  final double blur;

  // Color con el que se tiñe el cristal. null = cristal neutro.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    final shape = BorderRadius.circular(radius);
    final tinted = tint != null;
    const white = CodoColors.onAccent;

    // Interior: casi transparente, con un poco más de cuerpo arriba a la
    // izquierda. Sin reflejos ni líneas dentro.
    final fill = tinted
        ? LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        tint!.withValues(alpha: 0.85),
        tint!.withValues(alpha: 0.65),
      ],
    )
        : LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        c.glassFill,
        c.glassFill.withValues(alpha: c.glassFill.a * 0.5),
      ],
    );

    final glass = ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: fill, borderRadius: shape),
          child: child,
        ),
      ),
    );

    // El borde luminoso se pinta POR ENCIMA y fuera del recorte, para que su
    // halo no se corte.
    return CustomPaint(
      foregroundPainter: _RimPainter(
        radius: radius,
        core: white.withValues(alpha: 0.9),
        glow: tinted ? white.withValues(alpha: 0.35) : CodoColors.accent,
      ),
      child: tinted
          ? DecoratedBox(
        // Resplandor exterior del color del cristal.
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            BoxShadow(
              color: tint!.withValues(alpha: 0.42),
              offset: const Offset(0, 10),
              blurRadius: 28,
            ),
          ],
        ),
        child: glass,
      )
          : glass,
    );
  }
}

/// Dibuja el borde del cristal: una línea de 1 px con un degradado (luz blanca
/// en una esquina, casi nada en medio y color en la esquina opuesta) y,
/// debajo, el mismo trazo desenfocado como halo.
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.radius,
    required this.core,
    required this.glow,
  });

  final double radius;
  final Color core;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius),
    );

    // k multiplica la opacidad: 1 para la línea, menos para el halo.
    Shader shader(double k) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        core.withValues(alpha: core.a * k),
        core.withValues(alpha: 0.18 * k),
        core.withValues(alpha: 0.18 * k),
        glow.withValues(alpha: glow.a * k),
      ],
      stops: const [0, 0.35, 0.65, 1],
    ).createShader(rect);

    // 1. Halo: trazo más grueso y desenfocado.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = shader(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // 2. Línea nítida de 1 px.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = shader(1),
    );
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.radius != radius || old.core != core || old.glow != glow;
}