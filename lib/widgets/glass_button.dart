import 'package:codo/app/codo_colors.dart';
import 'package:codo/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botón de cristal. Por defecto es el secundario (Saltar, Atrás...);
/// con primary: true es el principal, teñido de azul (Siguiente, Empezar...).
class GlassButton extends StatefulWidget {
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
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  // Solo se encoge si el botón está activo; al soltar siempre se restaura.
  void _setPressed(bool value) {
    if (value && widget.onPressed == null) return;
    if (value) HapticFeedback.lightImpact();
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    final primary = widget.primary;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: GlassSurface(
          radius: primary ? 29 : 24,
          tint: primary ? CodoColors.accent : null,
          // Dentro hay un TextButton para conservar efecto al pulsar, foco y
          // accesibilidad. El cristal lo pone GlassSurface.
          child: TextButton(
            onPressed: widget.onPressed,
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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}