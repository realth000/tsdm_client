import 'package:flutter/material.dart';

/// ListTile support "obscure" state works like [TextField]
///
/// Set obscure content in subtitle.
/// When set visible to false, show the given [obscureWidget] or default obscure
/// placeholder text.
/// When set visible to true, show the given [subtitle] widget.
class ObscureListTile extends StatefulWidget {
  /// Constructor.
  const ObscureListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.obscureWidget,
    this.initialVisibility = false,
    super.key,
  });

  /// Leading widget.
  final Widget? leading;

  /// Title widget.
  final Widget? title;

  /// Subtitle widget.
  final Widget? subtitle;

  /// Widget that visibility is under control.
  final Widget? obscureWidget;

  /// Whether content is visible when first build this widget.
  final bool initialVisibility;

  @override
  State<ObscureListTile> createState() => _ObscureListTile();
}

/// When [_visible] is false, show obscureWidget, otherwise show the given
/// subtitle widget.
class _ObscureListTile extends State<ObscureListTile> {
  static const _obscurePlaceholder = '********';

  late bool _visible = widget.initialVisibility;

  @override
  Widget build(BuildContext context) {
    late final Widget? subtitleWidget;
    if (widget.subtitle == null) {
      subtitleWidget = null;
    } else if (_visible) {
      subtitleWidget = widget.subtitle;
    } else {
      subtitleWidget = widget.obscureWidget ?? const Text(_obscurePlaceholder);
    }

    late final Widget? trailingWidget;
    if (widget.subtitle == null) {
      trailingWidget = null;
    } else {
      trailingWidget = IconButton(
        icon: Icon(_visible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _visible = !_visible;
          });
        },
      );
    }

    return ListTile(
      leading: widget.leading,
      title: widget.title,
      subtitle: subtitleWidget,
      trailing: trailingWidget,
    );
  }
}
