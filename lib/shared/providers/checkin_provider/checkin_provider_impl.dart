import 'dart:io';

import 'package:collection/collection.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/check_in_feeling.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/models/checkin_result.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/shared/providers/server_time_provider/sevrer_time_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/parsing.dart';

class CheckInProviderImpl implements CheckinProvider {
  static const _checkInPageUrl = '$baseUrl/plugin.php?id=dsu_paulsign:sign';
  static const _checkInRequestUrl =
      '$baseUrl/plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&inajax=1';

  @override
  Future<CheckinResult> checkin(
    CheckinFeeling feeling,
    String message,
  ) async {
    final netClient = getIt.get<NetClientProvider>();

    final resp = await netClient.get(_checkInPageUrl);
    if (resp.statusCode != HttpStatus.ok) {
      debug(
        'failed to check in: web request failed with status code ${resp.statusCode}',
      );
      return CheckinWebRequestFailed(resp.statusCode!);
    }

    final document = parseHtmlDocument(resp.data as String);
    getIt.get<ServerTimeProvider>().updateServerTimeWithDocument(document);
    final re = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re.firstMatch(document.body?.innerHtml ?? '');
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      return const CheckinFormHashNotFound();
    }

    final body = {
      'formhash': formHash,
      'qdxq': feeling.toString(),
      'qdmode': 1,
      'todaysay': message,
      'fastreply': 1,
    };

    final checkInResp = await getIt
        .get<NetClientProvider>()
        .postForm(_checkInRequestUrl, data: body);

    final checkInRespData = (checkInResp.data as String).split('\n');

    final checkInResult = checkInRespData
        .firstWhereOrNull((e) => e.contains('</div>'))
        ?.replaceFirst('</div>', '')
        .trim();

    // Return results.
    if (checkInResult == null) {
      debug('check in result in null: $checkInResult');
      return CheckinOtherError(resp.data as String);
    }

    if (checkInResult.contains('签到成功')) {
      debug('check in success: $checkInResult');
      return CheckinSuccess(checkInResult);
    }

    if (checkInResult.contains('已经签到')) {
      debug('check in failed: already checked in today');
      return const CheckinAlreadyChecked();
    }

    if (checkInResult.contains('已经过了签到时间')) {
      debug('check in failed: late in time');
      return const CheckinLateInTime();
    }

    if (checkInResult.contains('签到时间还没有到')) {
      debug('check in failed: early in time');
      return const CheckinEarlyInTime();
    }

    debug('check in with other error: $checkInResult');
    return CheckinOtherError(resp.data as String);
  }
}
