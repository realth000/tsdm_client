import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/themes/widget_themes.dart';

/// A small widget consist of an info icon in the first row and some tips text
/// in the second row.
///
/// This may be a widget included in material guideline I've seen in some apps
/// but I don't know its name.
///
/// Layout Reference: [ReadYou](https://github.com/Ashinch/ReadYou/blob/main/app/src/main/java/me/ash/reader/ui/component/base/Tips.kt)
class Tips extends StatelessWidget implements PreferredSizeWidget {
  /// Constructor.
  const Tips(
    this.text, {
    this.enablePadding = true,
    this.sizePreferred = false,
    super.key,
  });

  /// Main text to display in tip.
  final String text;

  /// Enable horizontal padding or not.
  final bool enablePadding;

  /// Indicating if using as [PreferredSizeWidget].
  ///
  /// Set to true if used as bottom of [AppBar].
  final bool sizePreferred;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: smallIconSize,
        ),
        sizedBoxW8H8,
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        if (sizePreferred) sizedBoxW4H4,
      ],
    );
    final body =
        sizePreferred ? Row(children: [Expanded(child: content)]) : content;

    return enablePadding
        ? Padding(
            padding: edgeInsetsL16R16,
            child: body,
          )
        : body;
  }

  @override
  Size get preferredSize => const Size(40, 40);
}
