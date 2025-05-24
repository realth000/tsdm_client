import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/shared/models/medal.dart';
import 'package:tsdm_client/widgets/cached_image/cached_image.dart';

/// Widget to show a group of medals.
class MedalGroupView extends StatelessWidget {
  /// Constructor.
  const MedalGroupView(this.medals, {this.expand = false, super.key});

  /// Medals to show.
  final List<Medal> medals;

  /// Use the expanded layout.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameStyle = textTheme.bodyMedium?.copyWith();
    final descriptionStyle = textTheme.labelSmall;

    if (expand) {
      return Column(
        spacing: 8,
        children:
            medals
                .mapIndexed(
                  (idx, e) => Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${idx + 1}'.padLeft(2),
                          style: nameStyle?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      sizedBoxW8H8,
                      CachedImage(e.image, width: medalImageSize.width, height: medalImageSize.height),
                      sizedBoxW8H8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(e.name, style: nameStyle), Text(e.description, style: descriptionStyle)],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      );
    }

    return Wrap(
      runSpacing: 4,
      spacing: 4,
      children:
          medals
              .map(
                (e) => Tooltip(
                  richMessage: WidgetSpan(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(e.name, style: nameStyle), Text(e.description, style: descriptionStyle)],
                    ),
                  ),
                  child: CachedImage(e.image, width: medalImageSize.width, height: medalImageSize.height),
                ),
              )
              .toList(),
    );
  }
}
