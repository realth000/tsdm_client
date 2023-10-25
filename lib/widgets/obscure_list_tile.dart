import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ListTile support "obscure" state works like [TextField]
///
/// Set obscure content in subtitle.
/// When set visible to false, show the given [obscureWidget] or default obscure
/// placeholder text.
/// When set visible to true, show the given [subtitle] widget.
class ObscureListTile extends ConsumerStatefulWidget {
  const ObscureListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.obscureWidget,
    this.initialVisibility = false,
    super.key,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? obscureWidget;

  /// Whether content is visible when first build this widget.
  final bool initialVisibility;

  @override
  ConsumerState<ObscureListTile> createState() => _ObscureListTile();
}

/// When [_visible] is false, show obscureWidget, otherwise show the given
/// subtitle widget.
class _ObscureListTile extends ConsumerState<ObscureListTile> {
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
