import 'package:codo/app/codo_colors.dart';
import 'package:codo/widgets/glass_surface.dart';
import 'package:flutter/material.dart';

/// Botón de cristal. Por defecto es el secundario (Saltar, Atrás...);
/// con primary: true es el principal, teñido de azul (Siguiente, Empezar...).
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.primary = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;

    return GlassSurface(
      radius: primary ? 29 : 24,
      tint: primary ? CodoColors.accent : null,
      // Dentro hay un TextButton para conservar efecto al pulsar, foco y
      // accesibilidad. El cristal lo pone GlassSurface.
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: primary ? CodoColors.onAccent : c.textPrimary,
          minimumSize: primary ? const Size.fromHeight(58) : const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: primary ? 17 : 15,
            fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        child: child,
      ),
    );
  }
}