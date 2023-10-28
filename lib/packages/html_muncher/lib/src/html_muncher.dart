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

  bool bold = false;
  bool underline = false;
  bool lineThrough = false;
  bool center = false;
  List<Color> colorStack = [];

  @override
  String toString() {
    return 'MunchState {bold=$bold, underline=$underline, lineThrough=$lineThrough, color=$colorStack}';
  }
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: state.colorStack.lastOrNull,
                  fontWeight: state.bold ? FontWeight.w600 : null,
                  decoration: TextDecoration.combine([
                    if (state.underline) TextDecoration.underline,
                    if (state.lineThrough) TextDecoration.lineThrough,
                  ]),
                ),
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
              ),
            'br' => const TextSpan(text: '\n'),
            'font' => _buildFont(context, node),
            'strong' => _buildStrong(context, node),
            'u' => _buildUnderline(context, node),
            'a' || 'p' || 'ignore_js_op' => _munch(context, node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  InlineSpan _buildFont(BuildContext context, uh.Element element) {
    // Trim and add alpha value for "#ffafc7".
    final colorValue = int.tryParse(
        element.attributes['color']?.substring(1).padLeft(8, 'ff') ?? 'a',
        radix: 16);
    Color? color;
    if (colorValue != null) {
      color = Color(colorValue);
      state.colorStack.add(color);
    }
    final ret = _munch(context, element);
    if (color != null) {
      state.colorStack.removeLast();
    }
    return ret;
  }

  InlineSpan _buildStrong(BuildContext context, uh.Element element) {
    state.bold = true;
    final ret = _munch(context, element);
    state.bold = false;
    return ret;
  }

  InlineSpan _buildUnderline(BuildContext context, uh.Element element) {
    state.underline = true;
    final ret = _munch(context, element);
    state.underline = false;
    return ret;
  }
}
