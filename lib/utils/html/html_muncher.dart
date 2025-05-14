import 'package:collection/collection.dart';
import 'package:dart_bbcode_web_colors/dart_bbcode_web_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/build_context.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/adaptive_color.dart';
import 'package:tsdm_client/utils/html/css_parser.dart';
import 'package:tsdm_client/utils/html/munch_options.dart';

// Netease card
import 'package:tsdm_client/utils/html/netease_card.dart';

// Newcomer card
import 'package:tsdm_client/utils/html/newcomer_report_card.dart';

// Table
import 'package:tsdm_client/utils/html/table_width.dart';
import 'package:tsdm_client/utils/html/types.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/show_bottom_sheet.dart';

// Bounty answer card
import 'package:tsdm_client/widgets/card/bounty_answer_card.dart';

// Bounty card
import 'package:tsdm_client/widgets/card/bounty_card.dart';

// Code card
import 'package:tsdm_client/widgets/card/code_card.dart';

// Locked card
import 'package:tsdm_client/widgets/card/lock_card/locked_card.dart';

// Review card
import 'package:tsdm_client/widgets/card/review_card.dart';

// Spoiler card
import 'package:tsdm_client/widgets/card/spoiler_card.dart';

// Loading
import 'package:tsdm_client/widgets/network_indicator_image.dart';

// THIS CAN BE REMOVED
import 'package:tsdm_client/widgets/quoted_text.dart';
import 'package:universal_html/html.dart' as uh;

/// Use the same span to append line break.
const emptySpan = TextSpan(text: '\n');

/// Step when elevation changes.
const _elevationStep = 0.2;

/// List type composes `<ol>` and `<ul>`
sealed class _ListType {}

/// `<ul>` ordered list tag.
final class _ListUnordered extends _ListType {}

/// `<ol>` ordered list tag.
final class _ListOrdered extends _ListType {
  /// Constructor.
  _ListOrdered(this.number);

  /// Number in order.
  final int number;
}

/// Use an empty span.
// final null = WidgetSpan(child: Container());

/// Munch the html node [rootElement] and its children nodes into a flutter
/// widget.
///
/// Main entry of this package.
Widget munchElement(
  BuildContext context,
  uh.Element rootElement, {
  bool parseLockedWithPurchase = false,
  MunchOptions options = const MunchOptions(),
}) {
  final muncher = _Muncher(context, parseLockedWithPurchase: parseLockedWithPurchase, options: options);

  final ret = muncher._munch(rootElement);
  if (ret == null) {
    return const SizedBox.shrink();
  }
  // Remove trailing empty spaces.
  while (ret.lastOrNull == emptySpan) {
    ret.removeLast();
  }

  // Alignment in this page requires a fixed max width that equals to website
  // page width.
  // Currently is 712.
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: htmlContentMaxWidth),
    child: Text.rich(TextSpan(children: ret)),
  );
}

/// State of [_Muncher].
class _MunchState {
  /// State of munching html document.
  _MunchState();

  /// Use bold font.
  bool bold = false;

  /// Use italic font.
  bool italic = false;

  /// User underline.
  bool underline = false;

  /// Add line strike.
  bool lineThrough = false;

  /// Align span in center.
  bool center = false;

  /// Flag indicating current node's is inside a `<pre>` node or not.
  /// When in a `<pre>`, all text should be treated as raw text.
  bool inPre = false;

  /// Flag indicate current node inside a div or not.
  ///
  /// Make sure one line break when (nested or not) div ended.
  bool inDiv = false;

  /// If true, use [String.trim], if false, use [String.trimLeft].
  bool trimAll = false;

  /// Flag to indicate whether in state of repeated line wrapping.
  bool inRepeatWrapLine = false;

  /// Flag indicating has already munched all heading br nodes.
  ///
  /// Use this flag to filter all br node ahead of the real content to avoid
  /// large white space ahead of post text data.
  bool headingBrNodePassed = false;

  /// Text alignment.
  TextAlign? textAlign;

  /// Record the elevation.
  ///
  /// In some nested cards, elevation can be more than 1.
  ///
  /// Default is 0, increase when building in cards.
  double elevation = -_elevationStep;

  /// Flag indicating whether we should wrap line in word.
  ///
  /// Default, flutter only wrap line on word boundaries but when we using
  /// in some special case (e.g. url) we want to wrap the line inside words.
  ///
  /// Turn on this flag in such situation.
  ///
  /// THIS OPTION IS NOT IGNORED, prepare for copy content feature.
  bool wrapInWord = false;

  /// Url link to tap.
  ///
  /// [TapGestureRecognizer] not works in nested [TextSpan].
  ///
  /// As a workaround.
  String? tapUrl;

  /// All colors currently used.
  ///
  /// Use as a stack because only the latest font works on font.
  final colorStack = <Color>[];

  /// All background colors currently used.
  ///
  /// Use as a stack because only the latest font works on font.
  final backgroundColorStack = <Color>[];

  /// All font sizes currently used.
  ///
  /// Use as a stack because only the latest size works on font.
  final fontSizeStack = <double>[];

  // TODO: Handle indent level when list type nested.
  /// All munching state of list types.
  ///
  /// Can be nested.
  final listStack = <_ListType>[];

  /// An internal field to save field current values.
  _MunchState? _reservedState;

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
    elevation = _reservedState!.elevation;

    _reservedState = null;
  }

  @override
  String toString() {
    return 'MunchState {bold=$bold, underline=$underline, '
        'lineThrough=$lineThrough, color=$colorStack}';
  }
}

/// Munch html nodes into flutter widgets.
final class _Muncher with LoggerMixin {
  /// Constructor.
  _Muncher(this.context, {required this.parseLockedWithPurchase, required this.options});

  /// Context to build widget when munching.
  final BuildContext context;

  //////// Configs ////////
  bool parseLockedWithPurchase;

  /// Munch state to use when munching.
  final _MunchState state = _MunchState();

  /// Additional options control injected by caller.
  final MunchOptions options;

  /// Map to store div classes and corresponding munch functions.
  Map<String, List<InlineSpan>? Function(uh.Element)>? _divMap;

  /// Regex to match netease player iframe.
  final _neteasePlayerRe = RegExp(r'//music\.163\.com/outchain/player\?.*id=(?<id>\d+).*');

  List<InlineSpan>? _munch(uh.Element rootElement) {
    final spanList = <InlineSpan>[];

    for (final node in rootElement.nodes) {
      final subSpanList = munchNode(node);
      if (subSpanList != null) {
        spanList.addAll(subSpanList);
      }
    }
    if (spanList.isEmpty) {
      // Not intend to happen.
      return null;
    }
    return spanList;
  }

  /// Munch a [node] and its children.
  List<InlineSpan>? munchNode(uh.Node? node) {
    if (node == null) {
      // Reach end.
      return null;
    }
    switch (node.nodeType) {
      // Text node does not have children.
      case uh.Node.TEXT_NODE:
        {
          // Mark already munched text, all heading br nodes were passed.

          String? text;
          // When inPre is true, current node is inside a `<pre>` node.
          // Should reserve the original style.
          if (state.inPre) {
            text = node.text;
          } else if (state.trimAll) {
            text = node.text?.trim();
          } else {
            text = node.text?.trimLeft();
          }
          // If text is trimmed to empty, maybe it is an '\n' before trimming.
          if (text?.isEmpty ?? true) {
            if (state.trimAll) {
              return null;
            }
            if (state.inRepeatWrapLine) {
              return null;
            }
            state.inRepeatWrapLine = true;
            return null;
          }

          // Attach url to open when `onTap`.
          TapGestureRecognizer? recognizer;
          if (state.tapUrl != null) {
            // Copy to save the url.
            final url = state.tapUrl;
            recognizer =
                TapGestureRecognizer()
                  ..onTap = () {
                    context.dispatchAsUrl(url!);
                    options.onUrlLaunched?.call();
                  };
          }
          state
            ..headingBrNodePassed = true
            ..inRepeatWrapLine = false;

          final wrapText = text;
          // Ignore wrap text;
          // state.wrapInWord ? text?.split('').join('\u200B') : text;

          // TODO: Support text-shadow.
          return [TextSpan(text: wrapText, recognizer: recognizer, style: _buildTextStyle())];
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
            'img' => _buildImg(node),
            'br' => state.headingBrNodePassed ? [emptySpan] : null,
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
            // Ordered list in web page uses ul tag and has class "litype_1".
            'ul' when !node.classes.contains('litype_1') => _buildUl(node),
            'ol' || 'ul' when node.classes.contains('litype_1') => _buildOl(node),
            'li' => _buildLi(node),
            'code' => _buildCode(node),
            'dl' => _buildDl(node),
            'b' => _buildB(node),
            'i' => _buildI(node),
            'hr' => _buildHr(node),
            'pre' => _buildPre(node),
            'details' => _buildDetails(node),
            'iframe' => _buildIframe(node),
            'table' when node.classes.contains('cgtl') => _buildNewcomerReport(node),
            'table' => _buildTable(node),
            'sup' => _buildSup(node),
            'ignore_js_op' ||
            'table' ||
            'tbody' ||
            'dd' ||
            'marquee' ||
            'center' ||
            'nav' ||
            'section' ||
            'pre' => _munch(node),
            String() => null,
          };
          return span;
        }
    }
    return null;
  }

  List<InlineSpan>? _buildImg(uh.Element element) {
    final url = element.imageUrl();
    if (url == null) {
      return null;
    }
    state.headingBrNodePassed = true;
    final hrefUrl = state.tapUrl;
    final imgWidth = element.attributes['width']?.parseToInt()?.toDouble();
    final imgHeight = element.attributes['height']?.parseToInt()?.toDouble();
    return [
      WidgetSpan(
        child: GestureDetector(
          onTap: () async => showImageActionBottomSheet(context: context, imageUrl: url, hrefUrl: hrefUrl),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: imgWidth ?? double.infinity, maxHeight: imgHeight ?? double.infinity),
            child: NetworkIndicatorImage(url),
          ),
        ),
      ),
    ];
  }

  List<InlineSpan>? _buildFont(uh.Element element) {
    // Setup color
    final hasColor = _tryPushColor(element);
    // Setup font size.
    final hasFontSize = _tryPushFontSize(element);
    // Setup background color.
    final hasBackgroundColor = _tryPushBackgroundColor(element);
    // Munch!
    final ret = _munch(element);

    // Restore color
    if (hasColor) {
      state.colorStack.removeLast();
    }
    if (hasFontSize) {
      state.fontSizeStack.removeLast();
    }
    if (hasBackgroundColor) {
      state.backgroundColorStack.removeLast();
    }

    // Restore color.
    return ret;
  }

  List<InlineSpan>? _buildStrong(uh.Element element) {
    final origBold = state.bold;
    state.bold = true;
    final ret = _munch(element);
    state.bold = origBold;
    return ret;
  }

  List<InlineSpan>? _buildUnderline(uh.Element element) {
    final origUnderline = state.underline;
    state.underline = true;
    final ret = _munch(element);
    state.underline = origUnderline;
    return ret;
  }

  List<InlineSpan>? _buildLineThrough(uh.Element element) {
    final origThrough = state.lineThrough;
    state.lineThrough = true;
    final ret = _munch(element);
    state.lineThrough = origThrough;
    return ret;
  }

  List<InlineSpan>? _buildP(uh.Element element) {
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

    if (ret == null) {
      return null;
    }

    late final List<InlineSpan> ret2;

    if (align != null) {
      ret2 = [
        WidgetSpan(child: Row(children: [Expanded(child: Text.rich(TextSpan(children: ret), textAlign: align))])),
      ];

      // Restore text align.
      state.textAlign = null;
    } else {
      ret2 = ret;
    }

    return ret2;
  }

  List<InlineSpan>? _buildSpan(uh.Element element) {
    final styleEntries =
        element.attributes['style']
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
      if (ret == null) {
        return null;
      }
      return [...ret, emptySpan];
    }

    final styleMap = Map.fromEntries(styleEntries);
    final color = styleMap['color'];
    final hasColor = _tryPushColor(element, colorString: color);
    final fontSize = styleMap['font-size'];
    final hasFontSize = _tryPushFontSize(element, fontSizeString: fontSize);
    final hasBackgroundColor = _tryPushBackgroundColor(element);

    final ret = _munch(element);

    if (hasColor) {
      state.colorStack.removeLast();
    }
    if (hasFontSize) {
      state.fontSizeStack.removeLast();
    }
    if (hasBackgroundColor) {
      state.backgroundColorStack.removeLast();
    }
    if (ret == null) {
      return null;
    }

    return [...ret, emptySpan];
  }

  List<InlineSpan> _buildBlockQuote(uh.Element element) {
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
    final span = element.innerText.isEmpty ? null : TextSpan(children: _munch(element));
    state.restore();
    return [WidgetSpan(child: QuotedText.rich(span)), emptySpan];
  }

  List<InlineSpan>? _munchDiv(uh.Element element) {
    final origInDiv = state.inDiv;
    _divMap ??= {
      'blockcode': _buildBlockCode,
      'locked': _buildLockedArea,
      'cm': _buildReview,
      'spoiler': _buildSpoiler,
      'rusld': _buildUnresolvedBounty,
      'rsld': _buildResolvedBounty,
      'rwdbst': _buildBountyBestAnswer,
    };

    state.inDiv = true;
    // Find the first munch executor, use `_munch` if none found.
    final executor = _divMap!.entries.firstWhereOrNull((e) => element.classes.contains(e.key))?.value ?? _munch;
    final ret = executor(element);
    state.inDiv = origInDiv;

    if (ret != null && ret.isNotEmpty && ret.last != emptySpan) {
      ret.add(emptySpan);
    }
    return ret;
  }

  List<InlineSpan>? _buildBlockCode(uh.Element element) {
    // Usually each line in the block code is ended with `<br>` tag, but rarely it does not.
    // To ensure each line is wrapped correctly, extract each line (contents in each `<div>`) and manually place them.
    //
    // Some code blocks do not have line number prefix, use the raw content inside if so.
    final liNodes = element.querySelectorAll('div ol li');
    final text = liNodes.isNotEmpty ? liNodes.map((e) => e.innerText.trim()).join('\n') : element.innerText.trim();
    state
      ..headingBrNodePassed = true
      ..elevation += _elevationStep;
    final ret = WidgetSpan(child: CodeCard(code: text, elevation: state.elevation));
    state.elevation -= _elevationStep;
    return [ret];
  }

  List<InlineSpan>? _buildLockedArea(uh.Element element) {
    final lockedArea = Locked.fromLockDivNode(element, allowWithPurchase: parseLockedWithPurchase);
    if (lockedArea.isNotValid()) {
      return null;
    }

    state
      ..headingBrNodePassed = true
      ..elevation += _elevationStep;
    final ret = [WidgetSpan(child: LockedCard(lockedArea, elevation: state.elevation)), emptySpan];
    state.elevation -= _elevationStep;
    return ret;
  }

  List<InlineSpan>? _buildReview(uh.Element element) {
    if (element.children.length <= 1) {
      return null;
    }
    final avatarUrl = element.querySelector('div.psta > a > img')?.imageUrl();
    final name = element.querySelector('div.psti > a')?.firstEndDeepText();
    final content = element.querySelector('div.psti')?.nodes.elementAtOrNull(2)?.text?.trim();
    // final time = element
    //     .querySelector('div.psti > span > span')
    //     ?.attributes['title']
    //     ?.parseToDateTimeUtc8();

    return [WidgetSpan(child: ReviewCard(name: name ?? '', content: content ?? '', avatarUrl: avatarUrl))];
  }

  /// Spoiler is a button with an area of contents.
  /// Button is used to control the visibility of contents.
  List<InlineSpan>? _buildSpoiler(uh.Element element) {
    final title = element.querySelector('div.spoiler_control > input.spoiler_btn')?.attributes['value'];
    final contentNode = element.querySelector('div.spoiler_content');
    if (title == null || contentNode == null) {
      // Impossible.
      return null;
    }
    state.elevation += _elevationStep;
    final elevation = state.elevation;
    final content = _munch(contentNode);
    state.elevation -= _elevationStep;
    if (content == null) {
      return null;
    }
    while (content.lastOrNull == emptySpan) {
      content.removeLast();
    }
    state.headingBrNodePassed = true;
    final ret = WidgetSpan(
      child: SpoilerCard(title: TextSpan(text: title), content: TextSpan(children: content), elevation: elevation),
    );
    return [ret, emptySpan];
  }

  /// Build for the thread bounty info area.
  ///
  /// The bounty is processing, not resolved.
  ///
  /// ```html
  /// <div class="rusld z">
  ///   <cite>${price}<cite>
  /// </div>
  List<InlineSpan>? _buildUnresolvedBounty(uh.Element element) {
    final price = element.querySelector('cite')?.innerText ?? '';
    return [
      WidgetSpan(child: BountyCard(price: price, resolved: false)),
      // Ensure an empty line space between post content.
      const TextSpan(text: '\n\n'),
    ];
  }

  /// Build for the thread bounty info area.
  ///
  /// The bounty is resolved.
  ///
  /// ```html
  /// <div class="rsld z">
  ///   <cite>${price}<cite>
  /// </div>
  /// ```
  List<InlineSpan>? _buildResolvedBounty(uh.Element element) {
    final price = element.querySelector('cite')?.innerText ?? '';
    return [
      WidgetSpan(child: BountyCard(price: price, resolved: true)),
      // Ensure an empty line space between post content.
      const TextSpan(text: '\n\n'),
    ];
  }

  /// Build for the best answer of bounty area.
  ///
  /// This answer only occurs with already resolved bounty.
  ///
  /// * `USER_AVATAR_URL`: Avatar url of the answered user.
  /// * `USER_SPACE_URL`: Profile url of the answered user.
  /// * `USERNAME`: Username of the answered user.
  /// * `PTID`: Thread id of the answer.
  /// * `PID`: Post id of the answer.
  /// * `USER_ANSWER`: Answer content.
  ///
  /// ```html
  /// <div class="rwdbst">
  ///    <h3 class="psth">最佳答案</h3>
  ///    <div class="pstl">
  ///      <div class="psta">
  ///        <img src="${USER_AVATAR_URL">
  ///      </div>
  ///      <div class="psti">
  ///        <p class="xi2">
  ///          <a href="${USER_SPACE_URL}" class="xw1">${USERNAME}</a>
  ///          <a href="javascript:;" onclick="window.open('forum.php?mod=redirect&amp;goto=findpost&amp;ptid=${PTID}&amp;pid=${PID}')">查看完整内容</a></p>
  ///        <div class="mtn">${USER_ANSWER}</div>
  ///      </div>
  ///    </div>
  ///  </div>
  /// ```
  List<InlineSpan>? _buildBountyBestAnswer(uh.Element element) {
    final userAvatarUrl = element.querySelector('div.pstl > div.psta > img')?.imageUrl();
    final userInfoNode = element.querySelector('div.pstl > div.psti > p.xi2 > a');
    final username = userInfoNode?.innerText.trim();
    final userSpaceUrl = userInfoNode?.attributes['href'];
    final answer = element.querySelector('div.pstl > div.psti > div.mtn')?.innerText.trim();
    if (userAvatarUrl == null || username == null || userSpaceUrl == null || answer == null) {
      error(
        'failed to parse bounty answer: '
        'avatar=$userAvatarUrl, username=$username, '
        'userSpaceUrl=$userSpaceUrl, answer=$answer',
      );
      return null;
    }

    return [
      WidgetSpan(
        child: BountyAnswerCard(
          userAvatarUrl: userAvatarUrl,
          username: username,
          userSpaceUrl: userSpaceUrl,
          answer: answer,
        ),
      ),
    ];
  }

  List<InlineSpan>? _buildA(uh.Element element) {
    if (!element.attributes.containsKey('href') || !options.renderUrl) {
      return _munch(element);
    }

    final url = element.attributes['href']!;
    // Flag indicating only has <img> inside the <a> node.
    // <a href="xxx"><img src="xxx"></a>
    //
    // If true, do not show outside.
    final hasOnlyImg =
        element.childNodes.length == 1 &&
        element.childNodes[0].nodeType == uh.Node.ELEMENT_NODE &&
        (element.childNodes[0] as uh.Element).tagName == 'IMG';
    state
      ..tapUrl = url.prependHost()
      ..wrapInWord = true;
    final ret = _munch(element);
    state.wrapInWord = false;
    if (ret == null) {
      return null;
    }
    state.tapUrl = null;
    if (hasOnlyImg) {
      // Only a <img> node inside the current <a> node.
      // Do NOT show url prefix.
      return ret;
    }
    final Widget? content;
    if (url.isUserSpaceUrl) {
      if (element.innerText.contains('@')) {
        // Text already has the label, do not add duplicate one.
        content = null;
      } else {
        content = Text('@', style: TextStyle(color: Theme.of(context).colorScheme.primary));
      }
    } else {
      final IconData prefixIcon;
      if (url.startsWith('mailto:')) {
        prefixIcon = Icons.email_outlined;
      } else {
        prefixIcon = Icons.link;
      }

      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(prefixIcon, size: state.fontSizeStack.lastOrNull ?? 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 2),
        ],
      );
    }

    return [
      TextSpan(
        children: [
          if (content != null)
            WidgetSpan(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(onTap: () async => context.dispatchAsUrl(url), child: content),
              ),
            ),
          ...ret,
        ],
      ),
    ];
  }

  List<InlineSpan>? _buildTr(uh.Element element) {
    state.trimAll = true;
    final ret = _munch(element);
    state.trimAll = false;
    if (ret == null) {
      return null;
    }
    return ret;
  }

  List<InlineSpan>? _buildTd(uh.Element element) {
    state.trimAll = true;
    final ret = _munch(element);
    state.trimAll = false;
    if (ret == null) {
      return null;
    }

    // Removed trailing '\n' here to fix white space found in tables.
    // Add it back or think in another way if caused other issues.
    return ret;
  }

  List<InlineSpan>? _buildH1(uh.Element element) {
    state.fontSizeStack.add(FontSize.size6.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    if (ret == null) {
      return null;
    }
    return [emptySpan, ...ret, emptySpan];
  }

  List<InlineSpan>? _buildH2(uh.Element element) {
    state.fontSizeStack.add(FontSize.size5.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    if (ret == null) {
      return null;
    }
    return [emptySpan, ...ret, emptySpan];
  }

  List<InlineSpan>? _buildH3(uh.Element element) {
    state.fontSizeStack.add(FontSize.size4.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    if (ret == null) {
      return null;
    }
    return [emptySpan, ...ret, emptySpan];
  }

  List<InlineSpan>? _buildH4(uh.Element element) {
    state.fontSizeStack.add(FontSize.size3.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    if (ret == null) {
      return null;
    }
    return [emptySpan, ...ret, emptySpan];
  }

  /// Build `<ul>` tag.
  List<InlineSpan>? _buildUl(uh.Element element) {
    state.listStack.add(_ListUnordered());
    final ret = _munch(element);
    state.listStack.removeLast();
    return ret;
  }

  /// Build `<ol>` tag.
  List<InlineSpan>? _buildOl(uh.Element element) {
    state.listStack.add(_ListOrdered(1));
    final ret = _munch(element);
    state.listStack.removeLast();
    return ret;
  }

  /// Build `<li>` tag.
  List<InlineSpan>? _buildLi(uh.Element element) {
    final ret = _munch(element);
    if (ret == null) {
      return null;
    }

    // final String leading
    final leading = switch (state.listStack.lastOrNull) {
      _ListUnordered() => '•  ',
      _ListOrdered(:final number) => () {
        // Pop and push a larger number.
        state.listStack.removeLast();
        state.listStack.add(_ListOrdered(number + 1));
        return '$number. ';
      }(),
      null => () {
        error('failed to detect html list leading type: empty list stack');
        return '•  ';
      }(), // Unreachable but handle it.
    };

    if (!(ret.lastOrNull?.toPlainText().endsWith('\n') ?? false)) {
      // Append a trailing <br> if not have it.
      // This is a render issue on the server side, same bbcode may produce different result, with or without trailing
      // line break.
      return [TextSpan(text: leading), ...ret, emptySpan];
    } else {
      return [TextSpan(text: leading), ...ret];
    }
  }

  /// <code>xxx</code> tags. Mainly for github.com
  List<InlineSpan>? _buildCode(uh.Element element) {
    state.fontSizeStack.add(FontSize.size2.value());
    final ret = _munch(element);
    state.fontSizeStack.removeLast();
    if (ret == null) {
      return null;
    }
    state
      ..headingBrNodePassed = true
      ..elevation += _elevationStep;
    final ret2 = WidgetSpan(
      child: Card(
        elevation: state.elevation,
        color: Theme.of(context).colorScheme.onSecondary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        margin: EdgeInsets.zero,
        child: Text.rich(TextSpan(children: ret)),
      ),
    );
    state.elevation -= _elevationStep;
    return [ret2];
  }

  List<InlineSpan>? _buildDl(uh.Element element) {
    // Skip rate log area.
    if (element.id.startsWith('ratelog_')) {
      return null;
    }
    return _munch(element);
  }

  List<InlineSpan>? _buildB(uh.Element element) {
    final origBold = state.bold;
    state.bold = true;
    final ret = _munch(element);
    state.bold = origBold;
    if (ret == null) {
      return null;
    }
    return ret;
  }

  List<InlineSpan>? _buildI(uh.Element element) {
    // Ignore thread last modified info element.
    // This kind of node is specially handled.
    if (element.classes.contains('pstatus')) {
      return null;
    }
    final origItalic = state.italic;
    state.italic = true;
    final ret = _munch(element);
    state.italic = origItalic;
    if (ret == null) {
      return null;
    }
    return ret;
  }

  List<InlineSpan> _buildHr(uh.Element element) {
    return [const WidgetSpan(child: Divider())];
  }

  List<InlineSpan>? _buildPre(uh.Element element) {
    // Avoid reset parent's inPre state.
    final alreadyInPre = state.inPre;
    if (!alreadyInPre) {
      state.inPre = true;
    }
    final ret = _munch(element);
    if (!alreadyInPre) {
      state.inPre = false;
    }
    return ret;
  }

  /// Build a detail card here.
  List<InlineSpan>? _buildDetails(uh.Element element) {
    final summary = element.children.elementAtOrNull(0);
    state.elevation += _elevationStep;
    final dataSpanList = element.children.skip(1).map(_munch).whereType<List<InlineSpan>>().toList();
    state.elevation -= _elevationStep;
    if (summary == null || dataSpanList.isEmpty) {
      return null;
    }

    final summarySpan = _munch(summary);
    if (summarySpan == null) {
      return null;
    }

    // Trim all trailing whitespace in card.
    final ch = dataSpanList.lastOrNull;
    if (ch != null) {
      while (ch.lastOrNull == emptySpan ||
          ((ch.lastOrNull is TextSpan) && ((ch.last as TextSpan).text?.trim().isEmpty ?? false))) {
        ch.removeLast();
      }
      dataSpanList.last = ch;
    }
    state.elevation += _elevationStep;
    final ret = WidgetSpan(
      child: SpoilerCard(
        title: TextSpan(children: summarySpan),
        content: TextSpan(children: dataSpanList.flattened.toList()),
        elevation: state.elevation,
      ),
    );
    state.elevation -= _elevationStep;

    return [ret, emptySpan];
  }

  List<InlineSpan>? _buildIframe(uh.Element element) {
    final neteasePlayerId = _neteasePlayerRe.firstMatch(element.attributes['src'] ?? '')?.namedGroup('id');
    if (neteasePlayerId != null) {
      // Recognized netease player iframe.
      return [WidgetSpan(child: NeteaseCard(neteasePlayerId))];
    }
    return null;
  }

  List<InlineSpan>? _buildNewcomerReport(uh.Element element) {
    // <table cellspacing="0" cellpadding="0" class="cgtl mbm">
    // <caption>报到详细信息</caption>
    // <tbody>
    //   <tr>
    //     <th valign="top">昵称:</th>
    //     <td> USER_NICKNAME</td>
    //   </tr>
    //
    //   ...
    //
    // </tbody>
    // </table>
    final data =
        element
            .querySelectorRootAll('tbody > tr')
            .map((e) => (e.querySelector('th')?.innerText.trim(), e.querySelector('td')?.innerText.trim()))
            .whereType<(String, String)>()
            .map((e) => NewcomerReportInfo(title: e.$1, data: e.$2))
            .toList();

    return [WidgetSpan(child: NewcomerReportCard(data))];
  }

  List<InlineSpan>? _buildTable(uh.Element element) {
    final allTr = element.querySelectorRootAll('tbody > tr');
    if (allTr.isEmpty) {
      // Impossible
      return null;
    }
    if (allTr.length == 1) {
      // Not a regular table, only something wrapped.
      return _munch(element.querySelectorRootAll('tbody').first);
    }
    final tableRows = <TableRow>[];
    final allTableRowContent = <List<Widget>>[];
    var columnMaxCount = 0;
    for (final tr in allTr) {
      final tableRowContent = <Widget>[];
      final tds = tr.querySelectorRootAll('td');
      for (final td in tds) {
        tableRowContent.add(Text.rich(TextSpan(children: _buildTd(td))));
      }
      if (tds.length > columnMaxCount) {
        columnMaxCount = tds.length;
      }
      allTableRowContent.add(tableRowContent);
    }

    for (final row in allTableRowContent) {
      if (row.length < columnMaxCount) {
        row.addAll(List<Widget>.generate(columnMaxCount - row.length, (_) => sizedBoxEmpty));
      }
    }

    // Some tables do not have the same column width on each row.
    // Fill them.
    //
    // Only a workaround on unbalanced tables.
    //
    // FIXME: Support rowspan and colspan attr.
    tableRows.addAll(allTableRowContent.map((e) => TableRow(children: e)).toList());

    return [
      WidgetSpan(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const MaxIntrinsicColumnWidth(maxWidth: htmlContentMaxWidth),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: tableRows,
            border: TableBorder.all(color: Theme.of(context).colorScheme.surfaceContainer),
          ),
        ),
      ),
    ];
  }

  List<InlineSpan> _buildSup(uh.Element element) {
    return [
      TextSpan(
        text: element.innerText,
        style: _buildTextStyle()?.copyWith(fontFeatures: [const FontFeature.superscripts()]),
      ),
    ];
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
    final color = attr.toColor();
    if (color != null) {
      if (Theme.of(context).brightness == Brightness.dark) {
        state.colorStack.add(Color(color).adaptiveDark());
      } else {
        state.colorStack.add(Color(color));
      }
      return true;
    }
    return false;
  }

  bool _tryPushBackgroundColor(uh.Element element) {
    final attr = element.attributes['style'];
    if (attr == null) {
      return false;
    }
    final color = parseCssString(attr)?.backgroundColor;
    if (color != null) {
      if (Theme.of(context).brightness == Brightness.dark) {
        state.backgroundColorStack.add(color.adaptiveDark());
      } else {
        state.backgroundColorStack.add(color);
      }
      return true;
    }
    return false;
  }

  /// Try parse font size from [element].
  /// When provide [fontSizeString], use that in advance.
  ///
  /// If has valid color, push to stack and return true.
  bool _tryPushFontSize(uh.Element element, {String? fontSizeString}) {
    final fontSize = FontSize.fromString(fontSizeString ?? element.attributes['size']);
    if (fontSize.isValid) {
      state.fontSizeStack.add(fontSize.value());
    }
    return fontSize.isValid;
  }

  /// Function to build text style, where you could run it everywhere and don't have to carry all style member logic.
  TextStyle? _buildTextStyle() {
    final color = state.colorStack.lastOrNull ?? (state.tapUrl != null ? Theme.of(context).colorScheme.primary : null);
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color,
      fontWeight: state.bold ? FontWeight.w600 : null,
      fontSize: state.fontSizeStack.lastOrNull,
      backgroundColor: state.backgroundColorStack.lastOrNull,
      decorationColor: color,
      decoration: TextDecoration.combine([
        if (state.underline) TextDecoration.underline,
        if (state.lineThrough) TextDecoration.lineThrough,
      ]),
      fontStyle: state.italic ? FontStyle.italic : null,
      decorationThickness: 1.5,
    );

    return style;
  }
}
