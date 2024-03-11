import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/features/editor/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

/// The repository of bbcode editor features injected into bbcode editor.
///
/// Provide materials including:
/// * Emoji
///
final class EditorRepository {
  /// Url to fetch all available emoji info.
  ///
  /// It's a one-line javascript file expected in the following format:
  ///
  /// ``` javascript
  /// ...
  /// var smilies_type = new Array()
  /// smilies_type = new Array()
  /// smilies_type['_${GROUP_ID}'] = ['${GROUP_NAME}', '${GROUP_ROUTE_NAME}']
  /// (repeat above line ...)
  /// var smilies_array = new Array()
  /// var smilies_fast = new Array()
  /// smilies_array[${GROUP_ID}] = new Array()
  /// smilies_array[${GROUP_ID}][${PAGE_NUMBER}] =
  ///   [['${EMOJI_ID}','${BBCODE}','${FILE_NAME}','20','${WIDTH}','${HEIGHT}']]
  /// ...
  /// ```
  ///
  /// All data we need to save:
  ///
  /// * GROUP_ID: Emoji group id. Also the first part of emoji bbcode like
  ///   "10" in "{:10_200:}".
  /// * GROUP_NAME: Human readable emoji group name.
  /// * GROUP_ROUTE_NAME: A part of the route we fetch the emoji image. For
  ///   example: In https://img.mikudm.net/img02/smilies/TSDM/9.jpg the "TSDM"
  ///   is the group route name.
  /// * PAGE_NUMBER: Page number of the emoji in group when display in browser.
  ///   Optional because we provides a different layout and this parameter is
  ///   not required.
  /// * EMOJI_ID: The emoji id in group. Like the "200" in BBCode "{:10_200:}".
  /// * BBCODE: Used in editor and represent the emoji when send data to server.
  ///   Also formatted like "{:${GROUP_ID}_${EMOJI_ID}:}".
  /// * FILE_NAME: the final file name in url when we fetch the emoji image. We
  ///   don't name cache with this value.
  static const _emojiInfoUrl = '$baseUrl/data/cache/common_smilies_var.js?y1Z';

  /// Head of the image url.
  ///
  /// Full url: [_emojiFileUrlHead]/${ROUTE_NAME}/${FILE_NAME}
  static const _emojiFileUrlHead = 'https://img.mikudm.net/img02/smilies/';

  /// Expected to match data:
  ///
  /// smilies_type['_12'] = ['梦予馨', 'TSDM']
  ///
  /// Matches:
  /// * groupId: 12
  /// * groupName: 梦予馨
  /// * routeName: TSDM
  static final _emojiGroupInfoRe = RegExp(
    r"smilies_type\['_(?<groupId>\d+)'\] = \['(?<groupName>[^']+)', '(?<routeName>[^']+)'\]",
  );

  static final _emojiGroupDataRe =
      RegExp(r'smilies_array\[(?<groupId>\d+)\]\[\d+\] = \[(?<data>.+)\]');

  /// All groups of emoji.
  ///
  /// TODO: Do not use the type in code editor.
  /// Here we should use our own emoji group type.
  List<EmojiGroup>? emojiGroupList;

  /// Parse emoji info fetched from [_emojiInfoUrl] into a list of [EmojiGroup].
  ///
  /// The input [info] is expected in format described above [_emojiInfoUrl]
  /// document.
  List<EmojiGroup> _parseEmojiInfo(String info) {
    // Flag to record the parse state.
    // 1: Parsing group info, group name, group id...
    // 2: Parsing emoji in each group.
    var phase = 0;

    // Key: group id.
    // Value: group.
    final emojiGroupMap = <String, EmojiGroup>{};

    // Split into lines.
    final lines = info.split(';');
    for (final line in lines) {
      // Try parse group info
      if (phase <= 1 && _emojiGroupInfoRe.hasMatch(line)) {
        if (phase < 0) {
          // Proceed into group info parsing.
          phase += 1;
        }
        // smilies_type['_12'] = ['梦予馨', 'TSDM']
        final m = _emojiGroupInfoRe.firstMatch(line)!;
        emojiGroupMap[m.namedGroup('groupId')!] = EmojiGroup(
          name: m.namedGroup('groupName')!,
          id: m.namedGroup('groupId')!,
          routeName: m.namedGroup('routeName')!,
          emojiList: [],
        );
      }
      if (phase == 1) {
        // Proceed into emoji in group parsing.
        phase += 1;
      }
      if (_emojiGroupDataRe.hasMatch(line)) {
        final m = _emojiGroupDataRe.firstMatch(line)!;
        final groupId = m.namedGroup('groupId')!;
        final data = m.namedGroup('data')!;
        final routeName = emojiGroupMap[groupId]!.routeName;
        final emojiList = <Emoji>[];
        for (final d in data.split('],[')) {
          //  ['694', '{:10_694:}','14.jpg','20','20','50'
          final dd = d.split("'");
          if (dd.length != 13) {
            continue;
          }
          final id = dd[1];
          final code = dd[3];
          final fileName = dd[5];
          emojiList.add(
            Emoji(
              id: id,
              code: code,
              url: '$_emojiFileUrlHead/$routeName/$fileName',
            ),
          );
        }
        emojiGroupMap[groupId] = emojiGroupMap[groupId]!.copyWith(
          emojiList: emojiList,
        );
      }
    }
    return emojiGroupMap.values.toList();
  }

  /// Load all emoji from server through [_emojiInfoUrl].
  ///
  /// No cookie needed in this process.
  Future<void> loadEmojiFromServer() async {
    final resp = await getIt.get<NetClientProvider>().get(_emojiInfoUrl);
    if (resp.statusCode != HttpStatus.ok) {
      debug('failed to load emoji info: StatusCode=${resp.statusCode}');
      return;
    }
    emojiGroupList = _parseEmojiInfo(resp.data as String);
  }
}
