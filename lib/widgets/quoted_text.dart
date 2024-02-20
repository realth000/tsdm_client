import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';

/// Widget to show some quoted text.
class QuotedText extends StatelessWidget {
  /// Construct from [String] [text].
  const QuotedText(this.text, {super.key}) : span = null;

  /// Construct from an [InlineSpan] span.
  const QuotedText.rich(this.span, {super.key}) : text = null;

  /// Text to show in quoted style.
  final String? text;

  /// Span to show in quoted style.
  final InlineSpan? span;

  @override
  Widget build(BuildContext context) {
    final quotedColor = Theme.of(context).colorScheme.tertiary;
    final quotedStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: quotedColor);

    final iconHead = Transform.rotate(
      angle: 180 * pi / 180,
      child: Icon(Icons.format_quote_rounded, size: 28, color: quotedColor),
    );

    final spanHead = TextSpan(children: [WidgetSpan(child: iconHead)]);

    final iconTail =
        Icon(Icons.format_quote_rounded, size: 28, color: quotedColor);

    final spanTail = TextSpan(children: [WidgetSpan(child: iconTail)]);

    if (text != null) {
      return Text.rich(
        TextSpan(children: [spanHead, TextSpan(text: ' $text '), spanTail]),
      );
    }

    if (span != null) {
      // Because we want to let the start quoted icon lay on the left of
      // the content span, but rich text widgets and span widgets do not
      // provide such api, we have to wrap the head and the rest of contents
      // in two rich text and put in a row.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            WidgetSpan(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconHead,
                ],
              ),
            ),
          ),
          sizedBoxW5H5,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  // Add a line feed to ensure the child content is lower than
                  // start quote icon in vertical direction.
                  TextSpan(text: '\n', style: quotedStyle, children: [span!]),
                  WidgetSpan(
                    child: Row(
                      children: [
                        const Spacer(),
                        iconTail,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Impossible.
    return Container();
  }
}
