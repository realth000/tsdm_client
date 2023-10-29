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

  // Alignment in this page requires a fixed max width that equals to website
  // page width.
  // Currently is 712.
  return ConstrainedBox(
    constraints: const BoxConstraints(
      maxWidth: 712,
    ),
    child: RichText(text: muncher._munch(context, rootElement)),
  );
}

/// Font size.
/// Only works for tsdm.
///
/// In the text editor, only 1 - 7 sizes are used.
/// Font height can be known by hovering on html element in the devtool viewer.
/// Normal text size is 18px.
enum FontSize {
  /// "1": 11px
  size1,

  /// "2": 14px
  size2,

  /// "3": 17px
  size3,

  /// "4": 19px
  size4,

  /// "5": 25px
  size5,

  /// "6": 33px
  size6,

  /// "7": 49px
  size7,

  // Not support size.
  notSupport;

  factory FontSize.fromString(String? size) {
    if (size == null) {
      return FontSize.notSupport;
    }

    return switch (size) {
      '1' => FontSize.size1,
      '2' => FontSize.size2,
      '3' => FontSize.size3,
      '4' => FontSize.size4,
      '5' => FontSize.size5,
      '6' => FontSize.size6,
      '7' => FontSize.size7,
      String() => FontSize.notSupport,
    };
  }

  double value() {
    return switch (this) {
      FontSize.size1 => 11.0,
      FontSize.size2 => 14.0,
      FontSize.size3 => 17.0,
      FontSize.size4 => 19.0,
      FontSize.size5 => 25.0,
      FontSize.size6 => 33.0,
      FontSize.size7 => 49.0,
      FontSize.notSupport => 18.0, // Default is 18
    };
  }

  bool get isValid => this != FontSize.notSupport;

  bool get isNotValid => !isValid;
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
            'font' => _buildFont(context, node),
            'strong' => _buildStrong(context, node),
            'u' => _buildUnderline(context, node),
            'p' => _buildP(context, node),
            'a' || 'ignore_js_op' => _munch(context, node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  InlineSpan _buildFont(BuildContext context, uh.Element element) {
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
    final ret = _munch(context, element);

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

  InlineSpan _buildP(BuildContext context, uh.Element element) {
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

    final ret = _munch(context, element);

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
