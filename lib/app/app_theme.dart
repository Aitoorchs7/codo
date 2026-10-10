import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'codo_colors.dart';

/// Temas claro y oscuro de Codo. Las pantallas no escriben colores:
/// los leen de aquí con Theme.of(context).
class AppTheme {
  AppTheme._();

  static final light = _build(Brightness.light, CodoColors.light);
  static final dark = _build(Brightness.dark, CodoColors.dark);

  // Construye un tema a partir de la paleta de su modo. Es el mismo código
  // para los dos modos: solo cambian los colores que recibe.
  static ThemeData _build(Brightness brightness, CodoColors c) {
    // ColorScheme es el reparto de colores estándar de Flutter. Los widgets
    // de Material (botones, campos...) lo leen solos. Un único acento.
    final scheme = ColorScheme(
      brightness: brightness,
      primary: CodoColors.accent,
      onPrimary: CodoColors.onAccent,
      secondary: CodoColors.accent,
      onSecondary: CodoColors.onAccent,
      error: c.error,
      // Texto sobre el color de error: oscuro en modo oscuro, blanco en claro.
      onError: brightness == Brightness.dark ? c.bgBottom : CodoColors.onAccent,
      surface: c.surfaceSolid,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outlineVariant: c.divider,
    );

    // Partimos del TextTheme normal de ese modo y le cambiamos la fuente a
    // Onest y el color al del tema. Los títulos van en semibold.
    final base = ThemeData(brightness: brightness).textTheme;
    final textTheme = GoogleFonts.onestTextTheme(base)
        .apply(bodyColor: c.textPrimary, displayColor: c.textPrimary)
        .copyWith(
          headlineMedium: GoogleFonts.onest(
            fontSize: 28,
            height: 34 / 28,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
      // El de Material 3 trae letterSpacing 0.5; el diseño no lo tiene.
        bodyLarge: GoogleFonts.onest(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: c.textPrimary,
        ),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      // Fondo liso por ahora; el degradado de la paleta irá en un widget.
      scaffoldBackgroundColor: c.bgBottom,
      // Registra CodoColors para leerlo con Theme.of(context).extension.
      extensions: [c],
      // Botón principal: acento, forma de cápsula.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CodoColors.accent,
          foregroundColor: CodoColors.onAccent,
          disabledBackgroundColor: c.track,
          disabledForegroundColor: c.textDisabled,
          minimumSize: const Size.fromHeight(58),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Botones de texto (p. ej. "Saltar"): azul legible, no el acento puro.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.accentText),
      ),
      // Botón secundario de cristal (p. ej. "Saltar").
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.glassFill,
          foregroundColor: c.textPrimary,
          disabledForegroundColor: c.textDisabled,
          side: BorderSide(color: c.glassBorder),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
