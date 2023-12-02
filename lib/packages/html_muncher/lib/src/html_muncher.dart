import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/types.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/web_colors.dart';
import 'package:tsdm_client/widgets/network_indicator_image.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:url_launcher/url_launcher.dart';

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
  String? tapUrl;

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
    if (spanList.isEmpty) {
      // Not intend to happen.
      return const TextSpan();
    }
    // Do not wrap in another layout when there is only one span.
    if (spanList.length == 1) {
      return spanList.first;
    }
    return TextSpan(children: spanList);
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
          // Base text style.
          var style = Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: state.colorStack.lastOrNull,
                fontWeight: state.bold ? FontWeight.w600 : null,
                fontSize: state.fontSizeStack.lastOrNull,
                decoration: TextDecoration.combine([
                  if (state.underline) TextDecoration.underline,
                  if (state.lineThrough) TextDecoration.lineThrough,
                ]),
                decorationThickness: 1.5,
              );

          // Attach url to open when `onTap`.
          GestureRecognizer? recognizer;
          if (state.tapUrl != null) {
            final u = state.tapUrl!;
            recognizer = TapGestureRecognizer()
              ..onTap = () async {
                await launchUrl(
                  Uri.parse(u),
                  mode: LaunchMode.externalApplication,
                );
              };
            style = style?.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
            );
          }

          // TODO: Support text-shadow.
          return TextSpan(
            text: node.text?.trim(),
            recognizer: recognizer,
            style: style,
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
            'strike' => _buildLineThrough(node),
            'p' => _buildP(node),
            'table' when node.classes.contains('cgtl') => _buildTable(node),
            'span' => _buildSpan(node),
            'blockquote' => _buildBlockQuote(node),
            'div'
                when node.attributes['class']?.contains('blockcode') ?? false =>
              _buildBlockCode(node),
            'a' => _buildA(node),
            'div' ||
            'ignore_js_op' ||
            'table' ||
            'tbody' ||
            'tr' ||
            'td' =>
              _munch(node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  InlineSpan _buildFont(uh.Element element) {
    // Setup color
    final hasColor = _tryPushColor(element);
    // Setup font size.
    final hasFontSize = _tryPushFontSize(element);
    // Munch!
    final ret = _munch(element);

    // Restore color
    if (hasColor) {
      state.colorStack.removeLast();
    }
    if (hasFontSize) {
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

  InlineSpan _buildLineThrough(uh.Element element) {
    state.lineThrough = true;
    final ret = _munch(element);
    state.lineThrough = false;
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

  InlineSpan _buildTable(uh.Element element) {
    String? title;
    final rows = <TableRow>[];
    for (final (index, node) in element.nodes.indexed) {
      if (node.nodeType != uh.Node.ELEMENT_NODE) {
        continue;
      }
      final e = node as uh.Element;

      // Parse table title.
      if (index == 0 && e.localName == 'caption') {
        title = e.text;
        continue;
      }
      if (e.localName != 'tbody') {
        continue;
      }

      for (final n in e.nodes) {
        if (n.nodeType != uh.Node.ELEMENT_NODE) {
          continue;
        }
        final ne = n as uh.Element;
        if (ne.localName != 'tr') {
          continue;
        }

        final (t, d) = ne.parseTableRow();
        rows.add(TableRow(
          children: [
            Text(t ?? ''),
            ...d.map((e) => Text(e)),
          ],
        ));
      }
    }
    return WidgetSpan(child: Table(children: rows));
  }

  InlineSpan _buildSpan(uh.Element element) {
    final styleEntries = element.attributes['style']
        ?.split(';')
        .map((e) {
          final x = e.trim().split(':');
          return (x.firstOrNull?.trim(), x.lastOrNull?.trim());
        })
        .whereType<(String, String)>()
        .map((e) => MapEntry(e.$1, e.$2))
        .toList();
    if (styleEntries == null) {
      final ret = _munch(element);
      return TextSpan(children: [ret, const TextSpan(text: '\n')]);
    }

    final styleMap = Map.fromEntries(styleEntries);
    final color = styleMap['color'];
    final hasColor = _tryPushColor(element, colorString: color);
    final fontSize = styleMap['font-size'];
    final hasFontSize = _tryPushFontSize(element, fontSizeString: fontSize);

    final ret = _munch(element);

    if (hasColor) {
      state.colorStack.removeLast();
    }
    if (hasFontSize) {
      state.fontSizeStack.removeLast();
    }

    return TextSpan(children: [ret, const TextSpan(text: '\n')]);
  }

  InlineSpan _buildBlockQuote(uh.Element element) {
    final ret = _munch(element);
    return WidgetSpan(
        child: Card(
            child: Padding(
      padding: edgeInsetsL15T15R15B15,
      child: RichText(text: ret),
    )));
  }

  InlineSpan _buildBlockCode(uh.Element element) {
    final text = element.querySelector('div')?.innerText.trim() ?? '';
    return TextSpan(
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          await Clipboard.setData(
            ClipboardData(text: text),
          );
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              context.t.aboutPage.copiedToClipboard,
            ),
          ));
        },
      style: const TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dashed,
      ),
      text: text,
    );
    // FIXME: Remove duplicate white space when using `WidgetSpan` here.
    return WidgetSpan(
        child: Card(
            child: Padding(
      padding: const EdgeInsets.all(15),
      child: Text(text),
    )));
  }

  InlineSpan _buildA(uh.Element element) {
    if (element.attributes.containsKey('href')) {
      state.tapUrl = element.attributes['href']!;
      final ret = _munch(element);
      state.tapUrl = null;
      return ret;
    }
    return _munch(element);
  }

  /*                Setup Functions                      */

  /// Try parse color from [element].
  /// When provide [colorString], use that in advance.
  ///
  /// If has valid color, push to stack and return true.
  bool _tryPushColor(uh.Element element, {String? colorString}) {
    // Trim and add alpha value for "#ffafc7".
    // Set to an invalid color value if "color" attribute not found.
    final attr = colorString ?? element.attributes['color'];
    int? colorValue;
    if (attr != null && attr.startsWith('#')) {
      colorValue = int.tryParse(
          element.attributes['color']?.substring(1).padLeft(8, 'ff') ?? 'g',
          radix: 16);
    }
    Color? color;
    if (colorValue != null) {
      color = Color(colorValue);
      state.colorStack.add(color);
    } else {
      // If color not in format #aabcc, try parse as color name.
      final webColor = WebColors.fromString(attr);
      if (webColor.isValid) {
        color = webColor.color;
        state.colorStack.add(color);
      }
    }
    return color != null;
  }

  /// Try parse font size from [element].
  /// When provide [fontSizeString], use that in advance.
  ///
  /// If has valid color, push to stack and return true.
  bool _tryPushFontSize(uh.Element element, {String? fontSizeString}) {
    final fontSize =
        FontSize.fromString(fontSizeString ?? element.attributes['size']);
    if (fontSize.isValid) {
      state.fontSizeStack.add(fontSize.value());
    }
    return fontSize.isValid;
  }
}
