import 'package:flutter/material.dart';

/// Display some info text with an icon.
final class IconChip extends StatelessWidget {
  /// Constructor.
  const IconChip({required this.iconData, required this.text, this.iconSize, this.backgroundColor, super.key});

  /// Icon widget.
  final IconData iconData;

  /// Size of [iconData].
  final double? iconSize;

  /// Text widget.
  final Widget text;

  /// Background color of chip.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: EdgeInsets.zero,
      avatar: Icon(iconData, color: Theme.of(context).textTheme.labelMedium?.color, size: iconSize),
      label: text,
      side: BorderSide.none,
      // FIXME: Fix background color in bright and dark mode.
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
    );
  }
}
