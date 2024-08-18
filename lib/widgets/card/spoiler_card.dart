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
    return Card(
      elevation: widget.elevation,
      child: Padding(
        padding: edgeInsetsL16T16R16B16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(text: widget.title),
            SizedBox(
              width: sizeButtonInCardMinWidth,
              child: FilledButton.icon(
                icon: _visible
                    ? const Icon(Icons.expand_less_outlined)
                    : const Icon(Icons.expand_more_outlined),
                label: Text(
                  _visible
                      ? context.t.spoilerCard.expandLess
                      : context.t.spoilerCard.expandMore,
                ),
                onPressed: () {
                  setState(() {
                    _visible = !_visible;
                  });
                },
              ),
            ),
            if (_visible) RichText(text: widget.content),
          ].insertBetween(sizedBoxW4H4),
        ),
      ),
    );
  }
}
