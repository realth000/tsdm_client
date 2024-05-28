import 'package:flutter/material.dart';

/// Display some info text with an icon.
final class IconChip extends StatelessWidget {
  /// Constructor.
  const IconChip({
    required this.icon,
    required this.text,
    super.key,
  });

  /// Icon widget.
  final Widget icon;

  /// Text widget.
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: EdgeInsets.zero,
      avatar: icon,
      label: text,
      side: BorderSide.none,
      // FIXME: Fix background color in bright and dark mode.
      backgroundColor: Theme.of(context).colorScheme.surface,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
    );
  }
}
