import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/checkin/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/parsing.dart';

const _checkInPageUrl = '$baseUrl/plugin.php?id=dsu_paulsign:sign';
const _checkInRequestUrl = '$baseUrl/plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&inajax=1';

final _re = RegExp(r'formhash" value="(?<FormHash>\w+)"');

/// Do a checkin work for a specified user with given [feeling] and [message].
///
/// User info and credential MUST be wrapped in [netClient].
///
/// This function acts like a common function used by both AutoCheckinRepository
/// and CheckinRepository, but not becomes a static function of those' base
/// class, because they don't have it.
Task<CheckinResult> doCheckin(NetClientProvider netClient, CheckinFeeling feeling, String message) {
  return Task(() async {
    final respEither = await netClient.get(_checkInPageUrl).run();
    if (respEither.isLeft()) {
      talker.handle(respEither.unwrapErr());
      return const CheckinResultWebRequestFailed(null);
    }

    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      talker.error(
        'failed to check in: web request failed with status code '
        '${resp.statusCode}',
      );
      return CheckinResultWebRequestFailed(resp.statusCode);
    }

    final document = parseHtmlDocument(resp.data as String);
    final formHashMatch = _re.firstMatch(document.body?.innerHtml ?? '');
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      return const CheckinResultFormHashNotFound();
    }

    final body = {'formhash': formHash, 'qdxq': feeling.toString(), 'qdmode': 1, 'todaysay': message, 'fastreply': 1};

    final checkInRespEither = await netClient.postForm(_checkInRequestUrl, data: body).run();
    if (checkInRespEither.isLeft()) {
      return const CheckinResultWebRequestFailed(null);
    }

    final checkInResp = checkInRespEither.unwrap();
    final checkInRespData = (checkInResp.data as String).split('\n');

    final checkInResult = checkInRespData
        .firstWhereOrNull((e) => e.contains('</div>'))
        ?.replaceFirst('</div>', '')
        .trim();

    // Return results.
    if (checkInResult == null) {
      talker.error('check in result in null: $checkInResult');
      return CheckinResultOtherError(resp.data as String);
    }

    if (checkInResult.contains('签到成功')) {
      talker.info('check in success: $checkInResult');
      return CheckinResultSuccess(checkInResult);
    }

    if (checkInResult.contains('已经签到')) {
      talker.error('check in failed: already checked in today');
      return const CheckinResultAlreadyChecked();
    }

    if (checkInResult.contains('已经过了签到时间')) {
      talker.error('check in failed: late in time');
      return const CheckinResultLateInTime();
    }

    if (checkInResult.contains('签到时间还没有到')) {
      talker.error('check in failed: early in time');
      return const CheckinResultEarlyInTime();
    }

    talker.error('check in with other error: $checkInResult');
    return CheckinResultOtherError(resp.data as String);
  });
}
