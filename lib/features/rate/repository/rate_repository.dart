import 'dart:io';

import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/features/rate/models/rate_window_info.dart';
import 'package:tsdm_client/features/rate/repository/exceptions/exceptions.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/parsing.dart';

extension _FillRateTarget on String {
  /// Some query parameters not exists in incoming rateTarget.
  String _fillRateTarget() {
    return '$this&infloat=yes&handlekey=rate&t=${DateTime.now().millisecondsSinceEpoch}&inajax=1&ajaxtarget=fwin_content_rate';
  }
}

final class RateRepository {
  static const _rateTarget =
      '$baseUrl/forum.php?mod=misc&action=rate&ratesubmit=yes&infloat=yes&inajax=1';

  static final _errorTextRe = RegExp(r'alert_error">(?<error>[^<]+)<');

  /// Fetch rate info for given [pid].
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  ///
  /// # Sealed Exception
  ///
  /// * **RateInfoException** when failed to fetch rate info.
  Future<RateWindowInfo> fetchInfo({
    required String pid,
    required String rateTarget,
  }) async {
    final resp = await getIt.get<NetClientProvider>().get(
          rateTarget._fillRateTarget(),
        );
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }
    final xmlDoc = parseXmlDocument(resp.data as String);
    final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
    if (htmlBodyData == null) {
      throw const RateInfoHtmlBodyNotFound();
    }
    final divCNode = parseHtmlDocument(htmlBodyData).body;
    if (divCNode == null) {
      throw const RateInfoDivCNodeNotFound();
    }
    final rateWindowInfo = RateWindowInfo.fromDivCNode(divCNode);
    if (rateWindowInfo == null) {
      final errorText =
          divCNode.querySelector('div.alert_error')?.childNodes[0].text;
      if (errorText != null) {
        throw RateInfoWithErrorException(errorText);
      }
      throw const RateInfoInvalidDivCNode();
    }
    debug('get rate formHash: ${rateWindowInfo.formHash}');
    return rateWindowInfo;
  }

  /// Rate with given info [formData].
  ///
  /// # Exception
  ///
  /// * **HttpRequestFailedException** when http request failed.
  /// * **RateFailedException** when rate failed.
  Future<void> rate(Map<String, String> formData) async {
    final resp = await getIt
        .get<NetClientProvider>()
        .postForm(_rateTarget, data: formData);
    if (resp.statusCode != HttpStatus.ok) {
      throw HttpRequestFailedException(resp.statusCode!);
    }

    final data = resp.data as String;
    final errorText = _errorTextRe.firstMatch(data)?.namedGroup('error');
    if (errorText != null) {
      throw RateFailedException(errorText);
    }
  }
}
