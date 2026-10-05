# Codo · Paleta de colores (estilo Grafito)

Referencia de color de toda la interfaz de Codo, para modo oscuro y modo claro.
Úsala como fuente única: ningún color se escribe a mano en una pantalla; todo sale de estos tokens.

## Idea del estilo

- **Base en grises (grafito)** sacada del logo: un icono en blanco y negro con volumen suave.
- **Un único color de acento: azul cobalto.** Se reserva para lo importante (acción principal, progreso, "en directo"). Si aparece en todas partes deja de destacar.
- **Botones de cristal** al estilo Liquid Glass de iOS: translúcidos, con desenfoque y un brillo fino en el borde superior.
- **Fondo de puntitos** que suben muy despacio: cada punto es "alguien haciendo cosas a tu codo".

---

## 1. Acento (igual en los dos modos)

| Token | Valor | Uso |
|---|---|---|
| `accent` | `#2F5BFF` | Botón principal, barra de progreso, icono "en directo", puntos destacados del fondo |
| `accentPressed` | `#2449D9` | Botón principal pulsado |
| `onAccent` | `#FFFFFF` | Texto e iconos sobre el acento (contraste 5,2:1) |
| `accentGlow` | `#2F5BFF` al 42 % (`rgba(47,91,255,0.42)`) | Sombra de color del botón principal |
| `accentProgressGlow` | `#2F5BFF` al 70 % | Brillo de la barra de progreso |

> ⚠️ `#2F5BFF` **no se usa para texto pequeño** sobre los fondos grises (no llega a 4,5:1). Para enlaces o texto en azul usa `accentText` de cada modo.

---

## 2. Modo oscuro

### Fondos y superficies

| Token | Valor | Uso |
|---|---|---|
| `bgTop` | `#2B2C2F` | Parte superior del degradado de fondo |
| `bgBottom` | `#161719` | Parte inferior del degradado de fondo (vertical, de arriba abajo) |
| `surfaceCard` | `rgba(58,59,63,0.55)` + desenfoque 22 | Tarjetas (p. ej. "Tu objetivo") |
| `surfaceCardBorder` | `rgba(255,255,255,0.10)` | Borde de tarjetas |
| `surfaceSolid` | `#2E2F33` | Tarjetas y botones cuando el cristal está desactivado (rendimiento o "reducir transparencia") |
| `track` | `rgba(255,255,255,0.08)` | Fondo de la barra de progreso, interruptores apagados |
| `divider` | `rgba(255,255,255,0.10)` | Separadores |

### Texto

| Token | Valor | Contraste | Uso |
|---|---|---|---|
| `textPrimary` | `#F5F4F3` | 12,7:1 | Títulos, temporizador, texto principal |
| `textSecondary` | `#A9AAAE` | 6,0:1 | Subtítulos, horas, etiquetas |
| `textDisabled` | `rgba(255,255,255,0.32)` | — | Texto desactivado |
| `accentText` | `#7D9BFF` | 5,3:1 | Enlaces y texto en azul |

### Cristal (botones secundarios, chips, botón atrás)

| Token | Valor |
|---|---|
| `glassFill` | `rgba(255,255,255,0.09)` |
| `glassBorder` | `rgba(255,255,255,0.18)` |
| `glassHighlightTop` | `rgba(255,255,255,0.35)` (línea interior de 1,5 px arriba) |
| `glassHighlightBottom` | `rgba(255,255,255,0.06)` (línea interior de 1 px abajo) |
| `glassShadow` | `rgba(0,0,0,0.50)`, desplazamiento y 8, desenfoque 24 |

### Avatares

| Token | Valor | Uso |
|---|---|---|
| `avatarFill` | degradado `#FFFFFF` → `#CFCDCD` (165°) | Persona concentrada ("porcelana") |
| `avatarText` | `#000000` | Inicial dentro del avatar |
| `avatarPausedBorder` | `#5E5F63` | Persona en pausa (solo borde) |

### Puntos del fondo

| Token | Valor |
|---|---|
| `dotColor` | `#E6E4E4` con opacidad aleatoria entre 0,12 y 0,46 |
| `dotAccent` | `#2F5BFF` con opacidad 0,5–0,9 (≈ 6 % de los puntos) |

---

## 3. Modo claro

### Fondos y superficies

| Token | Valor | Uso |
|---|---|---|
| `bgTop` | `#DEDFE1` | Parte superior del degradado de fondo |
| `bgBottom` | `#C8C9CC` | Parte inferior del degradado de fondo |
| `surfaceCard` | `rgba(255,255,255,0.72)` + desenfoque 22 | Tarjetas |
| `surfaceCardBorder` | `rgba(255,255,255,0.95)` | Borde de tarjetas |
| `surfaceCardShadow` | `rgba(0,0,0,0.06)`, desplazamiento y 10, desenfoque 28 | Sombra de tarjetas |
| `surfaceSolid` | `#F4F4F5` | Tarjetas y botones cuando el cristal está desactivado |
| `track` | `rgba(0,0,0,0.10)` | Fondo de la barra de progreso |
| `divider` | `rgba(0,0,0,0.08)` | Separadores |

### Texto

| Token | Valor | Contraste | Uso |
|---|---|---|---|
| `textPrimary` | `#000000` | 15,8:1 | Títulos, temporizador, texto principal |
| `textSecondary` | `#45464A` | 5,7:1 | Subtítulos, horas, etiquetas |
| `textDisabled` | `rgba(0,0,0,0.38)` | — | Texto desactivado |
| `accentText` | `#1A3BBF` | 5,2:1 | Enlaces y texto en azul |

### Cristal

| Token | Valor |
|---|---|
| `glassFill` | `rgba(255,255,255,0.60)` |
| `glassBorder` | `rgba(255,255,255,0.95)` |
| `glassHighlightTop` | `rgba(255,255,255,1.0)` (línea interior de 1,5 px arriba) |
| `glassHighlightBottom` | `rgba(0,0,0,0.04)` (línea interior de 1 px abajo) |
| `glassShadow` | `rgba(0,0,0,0.10)`, desplazamiento y 8, desenfoque 24 |

### Avatares

| Token | Valor | Uso |
|---|---|---|
| `avatarFill` | degradado `#2E2E2E` → `#000000` (165°) | Persona concentrada |
| `avatarText` | `#FFFFFF` | Inicial dentro del avatar |
| `avatarPausedBorder` | `#8F9094` | Persona en pausa (solo borde) |

### Puntos del fondo

| Token | Valor |
|---|---|
| `dotColor` | `#000000` con opacidad aleatoria entre 0,07 y 0,27 |
| `dotAccent` | `#2F5BFF` con opacidad 0,5–0,9 (≈ 6 % de los puntos) |

---

## 4. Colores de estado (propuestos)

Los pide el proyecto para los estados de carga, vacío y error. Todavía no aparecen en el lienzo; están ajustados para que el texto se lea bien sobre los fondos de cada modo.

| Token | Oscuro | Claro | Uso |
|---|---|---|---|
| `error` | `#FF6B6B` (5,0:1) | `#A01C23` (4,7:1) | Mensajes de error, borrar cuenta |
| `success` | `#4CD38A` (7,3:1) | `#155E35` (4,7:1) | Sesión completada, compra correcta |
| `warning` | `#FFC145` (8,6:1) | `#6E3D00` (5,4:1) | Avisos, sin conexión |

El verde y el rojo nunca van solos: siempre con icono o texto, para quien no distingue esos colores.

---

## 5. Recetas de componentes

**Botón principal (cristal teñido de acento)**
- Fondo: degradado vertical de `accent` al 92 % → `accent` al 78 %.
- Borde: 1 px `rgba(255,255,255,0.35)`.
- Brillo: línea interior arriba `rgba(255,255,255,0.65)` y reflejo radial blanco al 45 % en la mitad superior.
- Sombra: `accentGlow`, y 10, desenfoque 28.
- Texto: `onAccent`, Onest 17 semibold. Altura 58, radio 29 (cápsula).

**Botón secundario / chip / botón atrás (cristal neutro)**
- `glassFill` + desenfoque 18 + `glassBorder` + `glassHighlightTop` + `glassShadow`.
- Texto: `textPrimary`.

**Tarjeta**
- `surfaceCard` + desenfoque 22, borde `surfaceCardBorder`, radio 28.

**Barra de progreso**
- Pista `track` de alto 14, radio 7, relleno interior de 3.
- Relleno `accent` de alto 8 con brillo `accentProgressGlow`.

---

## 6. Tipografía (Google Fonts)

| Fuente | Uso |
|---|---|
| **Unbounded** 500–600 | Temporizador, nombre "Codo", iniciales de avatares |
| **Onest** 400–600 | Todo lo demás: textos, botones, etiquetas |

---

## 7. Reglas

1. **Un solo acento.** No añadir otros colores salvo los de estado.
2. **El cristal solo en botones, chips y tarjetas,** nunca en listas largas. `BackdropFilter` es caro: si una pantalla va lenta, usa `surfaceSolid`.
3. **Accesibilidad:** con "reducir animaciones" activado, los puntos del fondo se quedan quietos. Con "reducir transparencia" o alto contraste, el cristal pasa a `surfaceSolid`.
4. **Contraste mínimo 4,5:1** para cualquier texto nuevo. Si un color no está en esta tabla, se añade aquí antes de usarlo.

---

## 8. Flutter: `ThemeExtension` de partida

```dart
import 'package:flutter/material.dart';

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

  // Comunes a los dos modos
  static const accent = Color(0xFF2F5BFF);
  static const accentPressed = Color(0xFF2449D9);
  static const onAccent = Color(0xFFFFFFFF);

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

  @override
  CodoColors copyWith() => this;

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

// Uso: final c = Theme.of(context).extension<CodoColors>()!;
```
