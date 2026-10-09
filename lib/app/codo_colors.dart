import 'package:flutter/material.dart';

/// Colores propios de Codo (docs/CODO_PALETA_COLORES.md es la fuente de verdad).
/// Se registran en el tema como extensión para leerlos desde cualquier pantalla:
/// `Theme.of(context).extension<CodoColors>()!`. Los de ColorScheme (acento,
/// texto principal...) se leen con `Theme.of(context).colorScheme`.
@immutable
class CodoColors extends ThemeExtension<CodoColors> {
  const CodoColors({
    required this.bgTop,
    required this.bgBottom,
    required this.surfaceCard,
    required this.surfaceCardBorder,
    required this.surfaceSolid,
    required this.track,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.accentText,
    required this.glassFill,
    required this.glassBorder,
    required this.glassHighlightTop,
    required this.glassShadow,
    required this.avatarText,
    required this.avatarPausedBorder,
    required this.dotColor,
    required this.error,
    required this.success,
    required this.warning,
  });

  // Iguales en claro y oscuro: son static, no dependen del modo.
  static const accent = Color(0xFF2F5BFF);
  static const accentPressed = Color(0xFF2449D9);
  static const onAccent = Color(0xFFFFFFFF);

  // Dependen del modo: cada instancia (dark / light) trae sus valores.
  final Color bgTop, bgBottom, surfaceCard, surfaceCardBorder, surfaceSolid;
  final Color track, divider;
  final Color textPrimary, textSecondary, textDisabled, accentText;
  final Color glassFill, glassBorder, glassHighlightTop, glassShadow;
  final Color avatarText, avatarPausedBorder, dotColor;
  final Color error, success, warning;

  static const dark = CodoColors(
    bgTop: Color(0xFF2B2C2F),
    bgBottom: Color(0xFF161719),
    surfaceCard: Color(0x8C3A3B3F), // rgba(58,59,63,0.55)
    surfaceCardBorder: Color(0x1AFFFFFF),
    surfaceSolid: Color(0xFF2E2F33),
    track: Color(0x14FFFFFF),
    divider: Color(0x1AFFFFFF),
    textPrimary: Color(0xFFF5F4F3),
    textSecondary: Color(0xFFA9AAAE),
    textDisabled: Color(0x52FFFFFF),
    accentText: Color(0xFF7D9BFF),
    glassFill: Color(0x17FFFFFF),
    glassBorder: Color(0x2EFFFFFF),
    glassHighlightTop: Color(0x59FFFFFF),
    glassShadow: Color(0x80000000),
    avatarText: Color(0xFF000000),
    avatarPausedBorder: Color(0xFF5E5F63),
    dotColor: Color(0xFFE6E4E4),
    error: Color(0xFFFF6B6B),
    success: Color(0xFF4CD38A),
    warning: Color(0xFFFFC145),
  );

  static const light = CodoColors(
    bgTop: Color(0xFFDEDFE1),
    bgBottom: Color(0xFFC8C9CC),
    surfaceCard: Color(0xB8FFFFFF), // rgba(255,255,255,0.72)
    surfaceCardBorder: Color(0xF2FFFFFF),
    surfaceSolid: Color(0xFFF4F4F5),
    track: Color(0x1A000000),
    divider: Color(0x14000000),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF45464A),
    textDisabled: Color(0x61000000),
    accentText: Color(0xFF1A3BBF),
    glassFill: Color(0x99FFFFFF),
    glassBorder: Color(0xF2FFFFFF),
    glassHighlightTop: Color(0xFFFFFFFF),
    glassShadow: Color(0x1A000000),
    avatarText: Color(0xFFFFFFFF),
    avatarPausedBorder: Color(0xFF8F9094),
    dotColor: Color(0xFF000000),
    error: Color(0xFFA01C23),
    success: Color(0xFF155E35),
    warning: Color(0xFF6E3D00),
  );

  // La extensión es inmutable y solo hay dos instancias fijas, así que no
  // hace falta copiarla con cambios: devuelve la misma.
  @override
  CodoColors copyWith() => this;

  // Flutter la usa para animar el cambio entre modo claro y oscuro:
  // mezcla cada color de los dos modos según t (0 = este, 1 = el otro).
  @override
  CodoColors lerp(ThemeExtension<CodoColors>? other, double t) {
    if (other is! CodoColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return CodoColors(
      bgTop: l(bgTop, other.bgTop),
      bgBottom: l(bgBottom, other.bgBottom),
      surfaceCard: l(surfaceCard, other.surfaceCard),
      surfaceCardBorder: l(surfaceCardBorder, other.surfaceCardBorder),
      surfaceSolid: l(surfaceSolid, other.surfaceSolid),
      track: l(track, other.track),
      divider: l(divider, other.divider),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textDisabled: l(textDisabled, other.textDisabled),
      accentText: l(accentText, other.accentText),
      glassFill: l(glassFill, other.glassFill),
      glassBorder: l(glassBorder, other.glassBorder),
      glassHighlightTop: l(glassHighlightTop, other.glassHighlightTop),
      glassShadow: l(glassShadow, other.glassShadow),
      avatarText: l(avatarText, other.avatarText),
      avatarPausedBorder: l(avatarPausedBorder, other.avatarPausedBorder),
      dotColor: l(dotColor, other.dotColor),
      error: l(error, other.error),
      success: l(success, other.success),
      warning: l(warning, other.warning),
    );
  }
}
