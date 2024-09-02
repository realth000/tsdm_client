import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Small widget to show color scheme seeded from [color].
class ColorPalette extends StatelessWidget {
  /// Constructor.
  const ColorPalette({
    required this.color,
    this.width = 40,
    this.height = 40,
    this.borderRadius = 15,
    this.selected = false,
    this.padding = 8,
    super.key,
  }) : assert(width > 0 && height > 0, 'width and height MUST greater than 0');

  /// Color to seed colorscheme.
  final Color color;

  /// Widget width.
  final double width;

  /// Widget height.
  final double height;

  /// Radius on widget.
  final double borderRadius;

  /// Selected or not.
  final bool selected;

  /// Padding between border and colored circle.
  final double padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    );
    final palette = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width - padding * 2,
            height: height / 2 - padding,
            color: colorScheme.primary,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width / 2 - padding,
                height: height / 2 - padding,
                color: colorScheme.secondary,
              ),
              Container(
                width: width / 2 - padding,
                height: height / 2 - padding,
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        shape: StarBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.surfaceBright),
          points: 12,
          pointRounding: 1,
          innerRadiusRatio: 0.7,
        ),
      ),
      child: Center(
        child: Stack(
          children: [
            Align(child: palette),
            Align(
              child: selected
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(padding * 1.5),
                      child: Container(
                        width: padding * 1.5,
                        height: padding * 1.5,
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.check,
                          size: padding,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : sizedBoxEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
