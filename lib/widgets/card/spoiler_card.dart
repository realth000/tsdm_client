import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/i18n/strings.g.dart';

/// SpoilerCard is an area munched from html document.
///
/// Contains a [title] and a [content] area.
/// Holding a button to control the visibility of [content], expand more or
/// expand less.
class SpoilerCard extends StatefulWidget {
  /// Constructor.
  const SpoilerCard({
    required this.title,
    required this.content,
    this.elevation,
    super.key,
  });

  /// Title of this expand more/less area.
  final InlineSpan title;

  /// Content to show when expanded.
  final InlineSpan content;

  /// Elevation of this card.
  final double? elevation;

  @override
  State<SpoilerCard> createState() => _SpoilerCardState();
}

class _SpoilerCardState extends State<SpoilerCard> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final tr = context.t.spoilerCard;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: widget.elevation,
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.expand_outlined, color: primaryColor),
                sizedBoxW8H8,
                Text(
                  tr.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: primaryColor,
                      ),
                ),
              ],
            ),
            sizedBoxW8H8,
            OutlinedButton.icon(
              icon: _visible
                  ? const Icon(Icons.expand_less_outlined)
                  : const Icon(Icons.expand_more_outlined),
              label: Text.rich(widget.title),
              onPressed: () {
                setState(() {
                  _visible = !_visible;
                });
              },
            ),
            if (_visible) ...[
              sizedBoxW8H8,
              Text.rich(widget.content),
            ],
          ].insertBetween(sizedBoxW4H4),
        ),
      ),
    );
  }
}
