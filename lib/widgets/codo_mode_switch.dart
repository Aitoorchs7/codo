import 'package:codo/app/codo_colors.dart';
import 'package:flutter/material.dart';

//Selector de dos o más opciones una barra que se desliza hasta la
// opción elegida.
class CodoModeSwitch extends StatelessWidget {
  const CodoModeSwitch({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final count = labels.length;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.track,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          // La píldora: se desliza a la posición de la opción elegida.
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              count == 1 ? 0 : -1 + 2 * selected / (count - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: c.textPrimary,
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        // El color del texto también se anima con la píldora.
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 280),
                          style: (labelStyle ?? const TextStyle()).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: i == selected ? c.bgBottom : c.textSecondary,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}