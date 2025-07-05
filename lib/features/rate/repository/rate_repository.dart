import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/extensions/universal_html.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Extension on [String] that provides filling rate url methods.
extension _FillRateTarget on String {
  /// Some query parameters not exists in incoming rateTarget.
  String _fillRateTarget() {
    return '$this&infloat=yes&handlekey=rate&t='
        '${DateTime.now().millisecondsSinceEpoch}&'
        'inajax=1&ajaxtarget=fwin_content_rate';
  }
}

/// Repository of rate.
final class RateRepository with LoggerMixin {
  static const _rateTarget = '$baseUrl/forum.php?mod=misc&action=rate&ratesubmit=yes&infloat=yes&inajax=1';

  /// Regexp to grep the error text from response html body.
  static final _errorTextRe = RegExp('alert_error">(?<error>[^<]+)<');

  /// Rate limit handler function text.
  ///
  /// User will trigger this error when too many points rated in 24 hour.
  static final _errorHandleRateRe = RegExp(r"{errorhandle_rate\('(?<error>[^']+)',");

  String _buildRateLogTarget({required String tid, required String pid}) =>
      '$baseUrl/forum.php?mod=misc&action=viewratings&tid=$tid&pid=$pid'
      '&infloat=yes&handlekey=viewratings&inajax=1&ajaxtarget=fwin_content_viewratings';

  List<RateLogItem> _buildRateLogItemListFromDocument(uh.Document doc) => doc
      .querySelectorAll('table.list > tbody > tr')
      .map((tr) {
        final tds = tr.querySelectorAll('td');
        if (tds.length != 4) {
          return null;
        }

        final attrRaw = tds.first.innerText.trim().split(' ');
        if (attrRaw.length != 2) {
          return null;
        }
        final attrName = attrRaw.first;
        final attrValue = int.tryParse(attrRaw.last);
        final userNode = tds[1].querySelector('a');
        final username = userNode?.innerText.trim();
        final uid = userNode?.attributes['href']?.tryParseAsUri()?.queryParameters['uid'];
        final time = tds[2].dateTime();
        final reason = tds[3].innerText.trim();

        if (attrValue == null || username == null || uid == null || time == null) {
          warning('incomplete rate log item: attrValue=$attrValue, username=$username, uid=$uid, time=$time');
          return null;
        }

        return RateLogItem(
          attrName: attrName,
          attrValue: attrValue,
          username: username,
          uid: uid,
          time: time,
          reason: reason,
        );
      })
      .whereType<RateLogItem>()
      .toList();

  /// Fetch rate info for given [pid].
  AsyncEither<RateWindowInfo> fetchInfo({required String pid, required String rateTarget}) => AsyncEither(() async {
    switch (await getIt.get<NetClientProvider>().get(rateTarget._fillRateTarget()).run()) {
      case Left(:final value):
        return left(value);
      case Right(:final value) when value.statusCode != HttpStatus.ok:
        return left(HttpRequestFailedException(value.statusCode));
      case Right(:final value):
        final xmlDoc = parseXmlDocument(value.data as String);
        final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
        if (htmlBodyData == null) {
          return left(RateInfoHtmlBodyNotFound());
        }
        final divCNode = parseHtmlDocument(htmlBodyData).body;
        if (divCNode == null) {
          return left(RateInfoDivCNodeNotFound());
        }
        final rateWindowInfo = RateWindowInfo.fromDivCNode(divCNode);
        if (rateWindowInfo == null) {
          final errorText = divCNode.querySelector('div.alert_error')?.childNodes[0].text;
          if (errorText != null) {
            return left(RateInfoWithErrorException(errorText));
          }
          return left(RateInfoInvalidDivCNode());
        }
        debug('get rate formHash: ${rateWindowInfo.formHash}');
        return right(rateWindowInfo);
    }
  });

  /// Rate with given info [formData].
  AsyncVoidEither rate(Map<String, String> formData) => AsyncVoidEither(() async {
    final respEither = await getIt.get<NetClientProvider>().postForm(_rateTarget, data: formData).run();
    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }
    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(resp.statusCode));
    }

    final data = resp.data as String;
    final errorText = _errorTextRe.firstMatch(data)?.namedGroup('error');
    if (errorText != null) {
      return left(RateFailedException(errorText));
    }
    final errorHandleRateText = _errorHandleRateRe.firstMatch(data)?.namedGroup('error');
    if (errorHandleRateText != null) {
      return left(RateFailedException(errorHandleRateText));
    }
    return rightVoid();
  });

  /// Fetch all rate log for post specified by [pid] and [tid].
  AsyncEither<List<RateLogItem>> fetchRateLog({required String tid, required String pid}) => getIt
      .get<NetClientProvider>()
      .get(_buildRateLogTarget(tid: tid, pid: pid))
      .mapHttp((v) => v.data as String)
      .map((e) => parseXmlDocument(e).documentElement?.nodes.first.text ?? '')
      .map(parseHtmlDocument)
      .map(_buildRateLogItemListFromDocument);
}
