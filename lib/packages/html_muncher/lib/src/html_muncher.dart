import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/types.dart';
import 'package:tsdm_client/packages/html_muncher/lib/src/web_colors.dart';
import 'package:tsdm_client/shared/models/locked.dart';
import 'package:tsdm_client/widgets/card/code_card.dart';
import 'package:tsdm_client/widgets/card/lock_card/locked_card.dart';
import 'package:tsdm_client/widgets/card/review_card.dart';
import 'package:tsdm_client/widgets/card/spoiler_card.dart';
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
  /// State of munching html document.
  MunchState();

  /// Use bold font.
  bool bold = false;

  /// User underline.
  bool underline = false;

  /// Add line strikte.
  bool lineThrough = false;

  /// Align span in center.
  bool center = false;

  /// Flag indicating current node's parent is `<div>` or not.
  /// IF in a div, should make sure current item is in a new line.
  bool inDiv = false;

  /// If true, use [String.trim], if false, use [String.trimLeft].
  bool trimAll = false;

  /// Flag to indicate whether in state of repeated line wrapping.
  bool inRepeatWrapLine = false;

  /// Text alignment.
  TextAlign? textAlign;

  /// All colors currently used.
  ///
  /// Use as a stack because only the latest font works on font.
  final colorStack = <Color>[];

  /// All font sizes currently used.
  ///
  /// Use as a stack because only the latest size works on font.
  final fontSizeStack = <double>[];

  /// Url to open when tap on the text.
  String? tapUrl;

  /// An internal field to save field current values.
  MunchState? _reservedState;

  /// Save current state [_reservedState].
  void save() {
    _reservedState = this;
  }

  /// Restore state from [_reservedState].
  void restore() {
    if (_reservedState != null) {
      return;
    }
    bold = _reservedState!.bold;
    underline = _reservedState!.underline;
    lineThrough = _reservedState!.lineThrough;
    center = _reservedState!.center;
    textAlign = _reservedState!.textAlign;
    colorStack
      ..clear()
      ..addAll(_reservedState!.colorStack);
    fontSizeStack
      ..clear()
      ..addAll(_reservedState!.fontSizeStack);
    tapUrl = _reservedState!.tapUrl;

    _reservedState = null;
  }

  @override
  String toString() {
    return 'MunchState {bold=$bold, underline=$underline, '
        'lineThrough=$lineThrough, color=$colorStack}';
  }
}

/// Munch html nodes into flutter widgets.
class Muncher {
  /// Constructor.
  Muncher(this.context);

  /// Context to build widget when munching.
  final BuildContext context;

  /// Munch state to use when munching.
  final MunchState state = MunchState();

  /// Map to store div classes and corresponding munch functions.
  Map<String, InlineSpan Function(uh.Element)>? _divMap;

  InlineSpan _munch(uh.Element rootElement) {
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

  /// Munch a [node] and its children.
  InlineSpan? munchNode(uh.Node? node) {
    if (node == null) {
      // Reach end.
      return null;
    }
    switch (node.nodeType) {
      // Text node does not have children.
      case uh.Node.TEXT_NODE:
        {
          final text =
              state.trimAll ? node.text?.trim() : node.text?.trimLeft();
          // If text is trimmed to empty, maybe it is an '\n' before trimming.
          if (text?.isEmpty ?? true) {
            if (state.trimAll) {
              return null;
            }
            if (state.inRepeatWrapLine) {
              return null;
            }
            state.inRepeatWrapLine = true;
            return const TextSpan(text: '\n');
          }

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
                await context.dispatchAsUrl(u);
              };
            style = style?.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dashed,
            );
          }

          state.inRepeatWrapLine = false;
          // TODO: Support text-shadow.
          return TextSpan(
            text: state.inDiv ? '${text ?? ""}\n' : text,
            recognizer: recognizer,
            style: style,
          );
        }

      case uh.Node.ELEMENT_NODE:
        {
          final element = node as uh.Element;
          final localName = element.localName;

          // Skip invisible nodes.
          if (element.attributes['style']?.contains('display: none') ?? false) {
            return null;
          }

          // TODO: Handle <ul> and <li> marker
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
            'span' => _buildSpan(node),
            'blockquote' => _buildBlockQuote(node),
            'div' => _munchDiv(node),
            'a' => _buildA(node),
            'tr' => _buildTr(node),
            'td' => _buildTd(node),
            'h1' => _buildH1(node),
            'h2' => _buildH2(node),
            'h3' => _buildH3(node),
            'h4' => _buildH4(node),
            'li' => _buildLi(node),
            'code' => _buildCode(node),
            'dl' => _buildDl(node),
            'ignore_js_op' ||
            'table' ||
            'tbody' ||
            'ul' ||
            'dd' ||
            'pre' =>
              _munch(node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  InlineSpan _buildFont(uh.Element element) {
    final oldInDiv = state.inDiv;
    state.inDiv = false;
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

    state.inDiv = oldInDiv;
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
    final oldInDiv = state.inDiv;
    state.inDiv = false;
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
    // Text align only have effect on the [RichText]'s children, not its
    /// children's children. Remember every time we build a [RichText]
    /// with "children" we need to apply the current text alignment.
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

    state.inDiv = oldInDiv;
    return ret2;
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
    // Try isolate the munch state inside quoted message.
    // Bug is that when the original quoted message "truncated" at unclosed
    // tags like "foo[s]bar...", the unclosed tag will affect all
    // following contents in current post, that is, all texts are marked with
    // line through.
    // This is unfixable after rendered into html because we do not know whether
    // a whole decoration tag (e.g. <strike>) contains the all following post
    // messages is user added or caused by the bug above. Here just try to save
    // and restore munch state to avoid potential issued about "styles inside
    // quoted blocks  affects outside main content".
    state.save();
    final ret = _munch(element);
    state.restore();
    return TextSpan(
      children: [
        WidgetSpan(
          child: Card(
            child: Padding(
              padding: edgeInsetsL15T15R15B15,
              child: RichText(text: ret),
            ),
          ),
        ),
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _munchDiv(uh.Element element) {
    _divMap ??= {
      'blockcode': _buildBlockCode,
      'locked': _buildLockedArea,
      'cm': _buildReview,
      'spoiler': _buildSpoiler,
    };

    final alreadyInDiv = state.inDiv;

    if (!alreadyInDiv) {
      state.inDiv = true;
    }
    // Find the first munch executor, use `_munch` if none found.
    final executor = _divMap!.entries
            .firstWhereOrNull((e) => element.classes.contains(e.key))
            ?.value ??
        _munch;
    final ret = executor(element);
    if (!alreadyInDiv) {
      state.inDiv = false;
    }
    return ret;
  }

  InlineSpan _buildBlockCode(uh.Element element) {
    final text = element.querySelector('div')?.innerText.trim() ?? '';
    return WidgetSpan(child: CodeCard(code: text));
  }

  InlineSpan _buildLockedArea(uh.Element element) {
    final lockedArea =
        Locked.fromLockDivNode(element, allowWithPurchase: false);
    if (lockedArea.isNotValid()) {
      return const TextSpan();
    }

    return TextSpan(
      children: [
        WidgetSpan(child: LockedCard(lockedArea)),
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildReview(uh.Element element) {
    if (element.children.length <= 1) {
      return const TextSpan();
    }
    final avatarUrl = element.querySelector('div.psta > a > img')?.imageUrl();
    final name = element.querySelector('div.psti > a')?.firstEndDeepText();
    final content = element
        .querySelector('div.psti')
        ?.nodes
        .elementAtOrNull(2)
        ?.text
        ?.trim();
    // final time = element
    //     .querySelector('div.psti > span > span')
    //     ?.attributes['title']
    //     ?.parseToDateTimeUtc8();

    return WidgetSpan(
      child: ReviewCard(
        name: name ?? '',
        content: content ?? '',
        avatarUrl: avatarUrl,
      ),
    );
  }

  /// Spoiler is a button with an area of contents.
  /// Button is used to control the visibility of contents.
  InlineSpan _buildSpoiler(uh.Element element) {
    final title = element
        .querySelector('div.spoiler_control > input.spoiler_btn')
        ?.attributes['value'];
    final contentNode = element.querySelector('div.spoiler_content');
    if (title == null || contentNode == null) {
      // Impossible.
      return const TextSpan();
    }
    final content = _munch(contentNode);
    return TextSpan(
      children: [
        WidgetSpan(
          child: SpoilerCard(
            title: title,
            content: content,
          ),
        ),
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildA(uh.Element element) {
    if (element.attributes.containsKey('href')) {
      state.tapUrl = element.attributes['href'];
      final ret = _munch(element);
      state.tapUrl = null;
      return ret;
    }
    return _munch(element);
  }

  InlineSpan _buildTr(uh.Element element) {
    state.trimAll = true;
    final ret = _munch(element);
    state.trimAll = false;
    return TextSpan(children: [ret, const TextSpan(text: '\n')]);
  }

  InlineSpan _buildTd(uh.Element element) {
    state.trimAll = true;
    final ret = _munch(element);
    state.trimAll = false;
    return TextSpan(children: [ret, const TextSpan(text: ' ')]);
  }

  InlineSpan _buildH1(uh.Element element) {
    state.fontSizeStack.add(FontSize.size6.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    return TextSpan(
      children: [
        const TextSpan(text: '\n'),
        ret,
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildH2(uh.Element element) {
    state.fontSizeStack.add(FontSize.size5.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    return TextSpan(
      children: [
        const TextSpan(text: '\n'),
        ret,
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildH3(uh.Element element) {
    state.fontSizeStack.add(FontSize.size4.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    return TextSpan(
      children: [
        const TextSpan(text: '\n'),
        ret,
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildH4(uh.Element element) {
    state.fontSizeStack.add(FontSize.size3.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    return TextSpan(
      children: [
        const TextSpan(text: '\n'),
        ret,
        const TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _buildLi(uh.Element element) {
    final ret = _munch(element);
    return TextSpan(
      children: [
        WidgetSpan(
          child: Icon(
            Icons.radio_button_unchecked,
            size: FontSize.size2.value(),
          ),
        ),
        const TextSpan(text: ' '),
        ret,
      ],
    );
  }

  /// <code>xxx</code> tags. Mainly for github.com
  InlineSpan _buildCode(uh.Element element) {
    state.fontSizeStack.add(FontSize.size2.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    return WidgetSpan(
      child: Card(
        color: Theme.of(context).colorScheme.onSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        margin: EdgeInsets.zero,
        child: RichText(text: ret),
      ),
    );
  }

  InlineSpan _buildDl(uh.Element element) {
    // Skip rate log area.
    if (element.id.startsWith('ratelog_')) {
      return const TextSpan();
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
        radix: 16,
      );
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
