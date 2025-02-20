import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/features/rate/models/models.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/logger.dart';
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
}
