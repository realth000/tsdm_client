import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';

part '../generated/providers/checkin_provider.g.dart';

enum CheckInResult {
  success,
  notAuthorized,
  webRequestFailed,
  formHashNotFound,
  alreadyCheckedIn,
  earlyInTime,
  lateInTime,
  otherError,
}

@Riverpod(dependencies: [Auth, NetClient])
class CheckIn extends _$CheckIn {
  static const _checkInPageUrl =
      'https://www.tsdm39.com/plugin.php?id=dsu_paulsign:sign';
  static const _checkInRequestUrl =
      'https://www.tsdm39.com/plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&inajax=1';

  @override
  Future<(CheckInResult result, String? message)> build() async {
    final uid = ref.read(authProvider);
    if (uid == null) {
      debug('failed to check in: not authorized');
      return (CheckInResult.notAuthorized, null);
    }

    final resp = await ref.read(netClientProvider()).get(_checkInPageUrl);
    if (resp.statusCode != HttpStatus.ok) {
      debug(
        'failed to check in: web request failed with status code ${resp.statusCode}',
      );
      return (CheckInResult.webRequestFailed, '${resp.statusCode}');
    }

    final document = html_parser.parse(resp.data);
    final re = RegExp(r'formhash" value="(?<FormHash>\w+)"');
    final formHashMatch = re.firstMatch(document.body?.innerHtml ?? '');
    final formHash = formHashMatch?.namedGroup('FormHash');
    if (formHash == null) {
      return (CheckInResult.formHashNotFound, null);
    }

    final body = {
      'formhash': formHash,
      'qdxq': 'ng',
      'qdmode': 1,
      'todaysay': Uri.encodeComponent('签到'),
      'fastreply': 1,
    };

    final checkInResp = await ref.read(netClientProvider()).post(
          _checkInRequestUrl,
          data: body,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

    final checkInRespData = (checkInResp.data as String).split('\n');

    final checkInResult = checkInRespData
        .firstWhereOrNull((e) => e.contains('</div>'))
        ?.replaceFirst('</div>', '')
        .trim();

    if (checkInResult == null) {
      debug('check in result in null: $checkInResult');
      return (CheckInResult.otherError, checkInResp.data as String);
    }

    if (checkInResult.contains('签到成功')) {
      debug('check in success: $checkInResult');
      return (CheckInResult.success, checkInResult);
    }

    if (checkInResult.contains('已经签到')) {
      debug('check in failed: already checked in today');
      return (CheckInResult.alreadyCheckedIn, null);
    }

    if (checkInResult.contains('已经过了签到时间')) {
      debug('check in failed: late in time');
      return (CheckInResult.lateInTime, null);
    }

    if (checkInResult.contains('签到时间还没有到')) {
      debug('check in failed: early in time');
      return (CheckInResult.earlyInTime, null);
    }

    debug('check in with other error: $checkInResult');
    return (CheckInResult.otherError, checkInResult);
  }
}
