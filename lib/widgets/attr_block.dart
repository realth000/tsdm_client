import 'package:flutter/material.dart';

/// A small block widget to display a value with its name.
class AttrBlock extends StatelessWidget {
  /// Constructor.
  const AttrBlock({
    required this.name,
    required this.value,
    this.maxWidth = 100,
    this.maxHeight = 50,
    this.nameStyle,
    this.valueStyle,
    super.key,
  });

  /// Attribute name.
  final String name;

  /// Attribute value.
  final String value;

  /// Maximum widget.
  final double maxWidth;

  /// Maximum height.
  final double maxHeight;

  /// Optional style of [name].
  final TextStyle? nameStyle;

  /// Optional style of [value].
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      child: Column(
        children: [
          Text(value, style: valueStyle ?? Theme.of(context).textTheme.titleMedium),
          Text(
            name,
            style:
                nameStyle ??
                Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
