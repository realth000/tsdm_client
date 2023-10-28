import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:universal_html/html.dart' as uh;

/// Munch the html node [rootElement] and its children nodes into a flutter
/// widget.
///
/// Main entry of this package.
Widget munchElement(BuildContext context, uh.Element rootElement) {
  final muncher = Muncher(
    context,
  );

  return RichText(text: muncher._munch(context, rootElement));
}

/// State of [Muncher].
class MunchState {
  MunchState();

  bool strong = false;
}

/// Munch html nodes into flutter widgets.
class Muncher {
  Muncher(this.context);

  final BuildContext context;
  final MunchState state = MunchState();

  InlineSpan _munch(BuildContext context, uh.Element rootElement) {
    final widgetList = <Widget>[];
    final spanList = <InlineSpan>[];

    for (final node in rootElement.nodes) {
      final span = munchNode(context, node);
      if (span != null) {
        spanList.add(span);
      }
    }
    if (spanList.isNotEmpty) {
      widgetList.add(RichText(text: TextSpan(children: spanList)));
    }
    if (widgetList.isEmpty) {
      return const TextSpan();
    }
    // widgetList.add(widgetList.first);
    return WidgetSpan(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widgetList,
      ),
    );
  }

  InlineSpan? munchNode(BuildContext context, uh.Node? node) {
    if (node == null) {
      // Reach end.
      return null;
    }
    switch (node.nodeType) {
      // Text node does not have children.
      case uh.Node.TEXT_NODE:
        {
          return TextSpan(
            text: node.text?.trim(),
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }

      case uh.Node.ELEMENT_NODE:
        {
          final element = node as uh.Element;
          final localName = element.localName;

          // Parse according to element types.
          final span = switch (localName) {
            'img' when node.imageUrl() != null => WidgetSpan(
                child: NetworkIndicatorImage(node.imageUrl()!),
                // baseline: TextBaseline.ideographic,
              ),
            'br' => const TextSpan(text: '\n'),
            'font' => TextSpan(
                text: node.text ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            'strong' => TextSpan(
                text: node.text ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            'a' || 'p' || 'ignore_js_op' => _munch(context, node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }
}
