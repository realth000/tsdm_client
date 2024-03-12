import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/features/editor/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/models/models.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
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
          emojiList: [...emojiGroupMap[groupId]!.emojiList, ...emojiList],
        );
      }
    }
    return emojiGroupMap.values.toList();
  }

  Future<bool> _generateDownloadEmojiTask(
    NetClientProvider netClient,
    ImageCacheProvider cacheProvider,
    EmojiGroup emojiGroup,
    Emoji emoji, {
    bool force = false,
  }) async {
    // Skip if have cache.
    if (!force && cacheProvider.hasEmojiCacheFile(emojiGroup.id, emoji.id)) {
      return true;
    }
    var retryMaxTimes = 3;
    // Retry until success.
    while (true) {
      if (retryMaxTimes <= 0) {
        debug('failed to download emoji ${emojiGroup.id}_${emoji.id}: '
            'exceed max retry times');
        return false;
      }
      try {
        final resp = await netClient.getImage(emoji.url);
        if (resp.statusCode != HttpStatus.ok) {
          await Future.delayed(const Duration(milliseconds: 200), () {});
          retryMaxTimes -= 1;
          continue;
        }
        await cacheProvider.updateEmojiCache(
          emojiGroup.id,
          emoji.id,
          resp.data as List<int>,
        );
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 200), () {});
        retryMaxTimes -= 1;
        continue;
      }
    }
    return true;
  }

  /// Force load all emoji from server through [_emojiInfoUrl].
  ///
  /// No cookie needed in this process.
  ///
  /// Return false when single emoji file exceed max retry times.
  Future<bool> loadEmojiFromServer() async {
    debug('load emoji from server');
    // TODO: Use injected net client.
    final netClient = NetClientProvider(disableCookie: true);
    final resp = await netClient.get(_emojiInfoUrl);
    if (resp.statusCode != HttpStatus.ok) {
      debug('failed to load emoji info: StatusCode=${resp.statusCode}');
      return false;
    }
    emojiGroupList = _parseEmojiInfo(resp.data as String);
    final cacheProvider = getIt.get<ImageCacheProvider>();
    // Save emoji info.
    await cacheProvider.saveEmojiInfo(emojiGroupList!);
    // TODO: Download emoji in parallel.
    // Download emoji data.
    for (final emojiGroup in emojiGroupList!) {
      final downloadList = emojiGroup.emojiList.map(
        (e) =>
            _generateDownloadEmojiTask(netClient, cacheProvider, emojiGroup, e),
      );
      debug('download for emoji group: ${emojiGroup.id}');
      await Future.wait(downloadList);
    }
    return true;
  }

  /// Load all emoji data from
  /// * cache: if have.
  /// * server: when cache is invalid.
  ///
  /// Only load the emoji info, do not load the emoji image data.
  ///
  /// Currently there there is no validation on emoji and emoji groups.
  ///
  /// # Sealed Exceptions
  ///
  /// * **[EmojiRelatedException]** when failed to load emoji.
  Future<void> loadEmojiFromCacheOrServer() async {
    final cacheProvider = getIt.get<ImageCacheProvider>();
    if (await cacheProvider.validateEmojiCache()) {
      // Have valid emoji cache.
      emojiGroupList = await cacheProvider.loadEmojiInfo();
    } else {
      // Do not have valid emoji cache, reload from server.
      final ret = await loadEmojiFromServer();
      if (!ret) {
        throw EmojiLoadFailedException();
      }
    }
  }
}
