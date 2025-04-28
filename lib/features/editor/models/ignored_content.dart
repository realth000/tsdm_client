import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/utils/html/netease_card.dart';
import 'package:tsdm_client/utils/html/newcomer_report_card.dart';
import 'package:tsdm_client/widgets/card/bounty_answer_card.dart';
import 'package:tsdm_client/widgets/card/bounty_card.dart';
import 'package:tsdm_client/widgets/card/code_card.dart';
import 'package:tsdm_client/widgets/card/lock_card/locked_card.dart';
import 'package:tsdm_client/widgets/card/review_card.dart';
import 'package:universal_html/parsing.dart';

part 'ignored_content.mapper.dart';

/// The format definition of all types of ignored contents used in editor.
///
/// Ignored content, or ignored widget is a type of data that only visible in quill_delta and ignored
/// when generating bbcode. Purpose is to support rendering different kinds of data that come from html
/// content, these contents are only visible when editor is readonly.
///
/// Theses contents let us render html page contents in thread page, constrained in the types we recognize
/// and intend to render, so that using the rich editor to take place of the custom html parser used in past.
@MappableClass()
final class EditorIgnoredContent with EditorIgnoredContentMappable {
  /// Constructor.
  const EditorIgnoredContent({required this.kind, required this.data});

  /// Kind of the content.
  ///
  /// This field is the recognizer to dispatch rendering works on [data].
  final String kind;

  /// Content data.
  final String data;
}

// /// Render [NeteaseCard].
// Widget _renderNeteaseCard(String data) {
//   return NeteaseCard(data);
// }
//
// /// Render [NewcomerReportCard].
// Widget _renderNewcomerReport(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   // <table cellspacing="0" cellpadding="0" class="cgtl mbm">
//   // <caption>报到详细信息</caption>
//   // <tbody>
//   //   <tr>
//   //     <th valign="top">昵称:</th>
//   //     <td> USER_NICKNAME</td>
//   //   </tr>
//   //
//   //   ...
//   //
//   // </tbody>
//   // </table>
//   final content =
//       element
//           .querySelectorRootAll('tbody > tr')
//           .map((e) => (e.querySelector('th')?.innerText.trim(), e.querySelector('td')?.innerText.trim()))
//           .whereType<(String, String)>()
//           .map((e) => NewcomerReportInfo(title: e.$1, data: e.$2))
//           .toList();
//
//   return NewcomerReportCard(content);
// }
//
// /// Render [BountyAnswerCard].
// Widget _renderBountyAnswerCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   final userAvatarUrl = element.querySelector('div.pstl > div.psta > img')?.imageUrl();
//   final userInfoNode = element.querySelector('div.pstl > div.psti > p.xi2 > a');
//   final username = userInfoNode?.innerText.trim();
//   final userSpaceUrl = userInfoNode?.attributes['href'];
//   final answer = element.querySelector('div.pstl > div.psti > div.mtn')?.innerText.trim();
//   if (userAvatarUrl == null || username == null || userSpaceUrl == null || answer == null) {
//     talker.error(
//       'failed to parse bounty answer: '
//       'avatar=$userAvatarUrl, username=$username, '
//       'userSpaceUrl=$userSpaceUrl, answer=$answer',
//     );
//     return sizedBoxEmpty;
//   }
//
//   return BountyAnswerCard(userAvatarUrl: userAvatarUrl, username: username, userSpaceUrl: userSpaceUrl, answer: answer);
// }
//
// /// Render [BountyCard].
// Widget _renderBountyCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   final price = element.querySelector('cite')?.innerText ?? '';
//   return BountyCard(price: price, resolved: false);
// }
//
// // TODO: Restore elevation.
// /// Render [CodeCard].
// Widget _renderCodeCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   // Usually each line in the block code is ended with `<br>` tag, but rarely it does not.
//   // To ensure each line is wrapped correctly, extract each line (contents in each `<div>`) and manually place them.
//   //
//   // Some code blocks do not have line number prefix, use the raw content inside if so.
//   final liNodes = element.querySelectorAll('div ol li');
//   final text = liNodes.isNotEmpty ? liNodes.map((e) => e.innerText.trim()).join('\n') : element.innerText.trim();
//   // state
//   //   ..headingBrNodePassed = true
//   //   ..elevation += _elevationStep;
//   // final ret = WidgetSpan(child: CodeCard(code: text, elevation: 1));
//   // state.elevation -= _elevationStep;
//   return CodeCard(code: text, elevation: 1);
// }
//
//
// // TODO: Restore elevation.
// // TODO: Restore allowWithPurchase.
// /// Render [LockedCard].
// Widget _renderLockedCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   final lockedArea = Locked.fromLockDivNode(element, allowWithPurchase: true);
//   if (lockedArea.isNotValid()) {
//     return sizedBoxEmpty;
//   }
//
//   // state
//   //   ..headingBrNodePassed = true
//   //   ..elevation += _elevationStep;
//   // final ret = [WidgetSpan(child: LockedCard(lockedArea, elevation: state.elevation)), emptySpan];
//   // state.elevation -= _elevationStep;
//   return LockedCard(lockedArea, elevation: 1);
// }
//
// /// Render [ReviewCard].
// Widget _renderReviewCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   if (element.children.length <= 1) {
//     return sizedBoxEmpty;
//   }
//   final avatarUrl = element.querySelector('div.psta > a > img')?.imageUrl();
//   final name = element.querySelector('div.psti > a')?.firstEndDeepText();
//   final content = element.querySelector('div.psti')?.nodes.elementAtOrNull(2)?.text?.trim();
//   // final time = element
//   //     .querySelector('div.psti > span > span')
//   //     ?.attributes['title']
//   //     ?.parseToDateTimeUtc8();
//
//   return ReviewCard(name: name ?? '', content: content ?? '', avatarUrl: avatarUrl);
// }
//
// Widget _renderSpoilerCard(String data) {
//   final element = parseHtmlDocument(data).body!;
//
//   final title = element.querySelector('div.spoiler_control > input.spoiler_btn')?.attributes['value'];
//   final contentNode = element.querySelector('div.spoiler_content');
//   if (title == null || contentNode == null) {
//     // Impossible.
//     return sizedBoxEmpty;
//   }
//   state.elevation += _elevationStep;
//   final elevation = state.elevation;
//   final content = _munch(contentNode);
//   state.elevation -= _elevationStep;
//   if (content == null) {
//     return null;
//   }
//   while (content.lastOrNull == emptySpan) {
//     content.removeLast();
//   }
//   state.headingBrNodePassed = true;
//   final ret = WidgetSpan(
//     child: SpoilerCard(title: TextSpan(text: title), content: TextSpan(children: content), elevation: elevation),
//   );
//   return [ret, emptySpan];
// }
