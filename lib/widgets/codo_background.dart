
import 'package:codo/app/codo_colors.dart';
import 'package:flutter/material.dart';

class CodoBackground extends StatelessWidget{
  const CodoBackground({super.key, required this.child});

  // Lo que se pinta encima del fondo (la pantalla).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // con c traemos los colores del tema
    final c = Theme.of(context).extension<CodoColors>()!;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.bgTop, c.bgBottom],
        ),
      ),
      child: child,
    );
  }

}