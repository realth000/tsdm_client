import 'package:flutter/material.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/types.dart';
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

  // Alignment in this page requires a fixed max width that equals to website
  // page width.
  // Currently is 712.
  return ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 712,
    ),
    child: RichText(text: muncher._munch(rootElement)),
  );
}

/// State of [Muncher].
class MunchState {
  MunchState();

  bool bold = false;
  bool underline = false;
  bool lineThrough = false;
  bool center = false;
  TextAlign? textAlign;
  final colorStack = <Color>[];
  final fontSizeStack = <double>[];

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

  InlineSpan _munch(uh.Element rootElement) {
    final widgetList = <Widget>[];
    final spanList = <InlineSpan>[];

    for (final node in rootElement.nodes) {
      final span = munchNode(node);
      if (span != null) {
        spanList.add(span);
      }
    }
    if (spanList.isNotEmpty) {
      widgetList.add(RichText(
        text: TextSpan(children: spanList),
        textAlign: state.textAlign ?? TextAlign.justify,
      ));
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

  InlineSpan? munchNode(uh.Node? node) {
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
                  fontSize: state.fontSizeStack.lastOrNull,
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
            'font' => _buildFont(node),
            'strong' => _buildStrong(node),
            'u' => _buildUnderline(node),
            'p' => _buildP(node),
            'a' || 'div' || 'ignore_js_op' => _munch(node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  InlineSpan _buildFont(uh.Element element) {
    // Setup color
    // Trim and add alpha value for "#ffafc7".
    // Set to an invalid color value if "color" attribute not found.
    final colorValue = int.tryParse(
        element.attributes['color']?.substring(1).padLeft(8, 'ff') ?? 'g',
        radix: 16);
    Color? color;
    if (colorValue != null) {
      color = Color(colorValue);
      state.colorStack.add(color);
    }

    // Setup font size.
    final fontSize = FontSize.fromString(element.attributes['size']);
    if (fontSize.isValid) {
      state.fontSizeStack.add(fontSize.value());
    }
    // Munch!
    final ret = _munch(element);

    // Restore color
    if (color != null) {
      state.colorStack.removeLast();
    }

    if (fontSize.isValid) {
      state.fontSizeStack.removeLast();
    }

    // Restore color.
    return ret;
  }

  InlineSpan _buildStrong(uh.Element element) {
    state.bold = true;
    final ret = _munch(element);
    state.bold = false;
    return ret;
  }

  InlineSpan _buildUnderline(uh.Element element) {
    state.underline = true;
    final ret = _munch(element);
    state.underline = false;
    return ret;
  }

  InlineSpan _buildP(uh.Element element) {
    // Alignment requires the whole rendered page to a fixed max width that
    // equals to website page, otherwise if is different if we have a "center"
    // or "right" alignment.
    final alignValue = element.attributes['align'];
    final align = switch (alignValue) {
      'left' => TextAlign.left,
      'center' => TextAlign.center,
      'right' => TextAlign.right,
      String() => null,
      null => null,
    };

    // Setup text align.
    //
    // Text align only have effect on the [RichText]'s children, not its children's
    // children. Remember every time we build a [RichText] with "children" we
    // need to apply the current text alignment.
    if (align != null) {
      state.textAlign = align;
    }

    final ret = _munch(element);

    late final InlineSpan ret2;

    if (align != null) {
      ret2 = WidgetSpan(
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: ret,
                textAlign: align,
              ),
            ),
          ],
        ),
      );

      // Restore text align.
      state.textAlign = null;
    } else {
      ret2 = ret;
    }

    return ret2;
  }
}
