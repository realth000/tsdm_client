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
class Tips extends StatelessWidget {
  /// Constructor.
  const Tips(this.text, {super.key});

  /// Main text to display in tip.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsetsL16R16,
      child: Column(
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
                  fontWeight: FontWeight.w100,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
