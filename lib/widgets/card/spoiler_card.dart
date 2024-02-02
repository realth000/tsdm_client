import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/list.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

/// SpoilerCard is an area munched from html document.
///
/// Contains a [title] and a [content] area.
/// Holding a button to control the visibility of [content], expand more or expand less.
class SpoilerCard extends StatefulWidget {
  const SpoilerCard({required this.title, required this.content, super.key});

  final String title;
  final InlineSpan content;

  @override
  State<SpoilerCard> createState() => _SpoilerCardState();
}

class _SpoilerCardState extends State<SpoilerCard> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: edgeInsetsL15T15R15B15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            SizedBox(
              width: sizeButtonInCardMinWidth,
              child: ElevatedButton(
                child: Text(_visible
                    ? context.t.spoilerCard.expandLess
                    : context.t.spoilerCard.expandMore,),
                onPressed: () {
                  setState(() {
                    _visible = !_visible;
                  });
                },
              ),
            ),
            if (_visible) RichText(text: widget.content),
          ].insertBetween(sizedBoxW5H5),
        ),
      ),
    );
  }
}
