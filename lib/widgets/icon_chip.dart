import 'package:flutter/material.dart';

/// Display some info text with an icon.
final class IconChip extends StatelessWidget {
  /// Constructor.
  const IconChip({required this.iconData, required this.text, this.iconSize, super.key});

  /// Icon widget.
  final IconData iconData;

  /// Size of [iconData].
  final double? iconSize;

  /// Text widget.
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: EdgeInsets.zero,
      avatar: Icon(iconData, color: Theme.of(context).textTheme.labelMedium?.color, size: iconSize),
      label: text,
      side: BorderSide.none,
      // FIXME: Fix background color in bright and dark mode.
      backgroundColor: Theme.of(context).colorScheme.surface,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
    );
  }
}
