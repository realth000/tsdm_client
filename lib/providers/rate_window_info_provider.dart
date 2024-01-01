import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/models/rate_window_info.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';
import 'package:tsdm_client/utils/debug.dart';
import 'package:universal_html/parsing.dart';

part '../generated/providers/rate_window_info_provider.g.dart';

extension _FillRateTarget on String {
  /// Some query parameters not exists in incoming rateTarget.
  String _fillRateTarget() {
    return '$this&infloat=yes&handlekey=rate&t=${DateTime.now().millisecondsSinceEpoch}&inajax=1&ajaxtarget=fwin_content_rate';
  }
}

/// Result of fetching rate window info.
sealed class RateInfoState {
  const RateInfoState._();
}

final class RateInfoWaiting extends RateInfoState {
  const RateInfoWaiting() : super._();
}

/// Http request error in fetching rate window info.
final class RateInfoBadHttpResp extends RateInfoState {
  const RateInfoBadHttpResp(this.code) : super._();

  final String code;

  @override
  String toString() => 'RateFetchInfoBadHttpResp { code=$code }';
}

/// Html info content not found in response.
/// This is not the "404 NOT FOUND".
final class RateInfoNotFound extends RateInfoState {
  const RateInfoNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoNotFound';
}

final class RateInfoHtmlBodyNotFound extends RateInfoState {
  const RateInfoHtmlBodyNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoHtmlBodyNotFound';
}

final class RateInfoDivCNodeNotFound extends RateInfoState {
  const RateInfoDivCNodeNotFound() : super._();

  @override
  String toString() => 'RateFetchInfoDivCNodeNotFound';
}

final class RateInfoInvalidDivCNode extends RateInfoState {
  const RateInfoInvalidDivCNode() : super._();

  @override
  String toString() => 'RateFetchInfoInvalidCNode';
}

/// Successfully fetched info [info].
final class RateInfoSuccess extends RateInfoState {
  const RateInfoSuccess(this.info) : super._();
  final RateWindowInfo info;
}

@Riverpod(dependencies: [Auth, NetClient])
class RateInfo extends _$RateInfo {
  @override
  Future<RateInfoState> build(String postID, String rateTarget) async {
    final resp = await ref.read(netClientProvider()).get(
          rateTarget._fillRateTarget(),
          options: Options(
            headers: {'Accept': '*/*'},
          ),
        );
    if (resp.statusCode != 200) {
      return Future.error(
          RateInfoBadHttpResp('${resp.statusCode}'), StackTrace.current);
    }
    final xmlDoc = parseXmlDocument(resp.data as String);
    final htmlBodyData = xmlDoc.documentElement?.nodes.firstOrNull?.text;
    if (htmlBodyData == null) {
      return Future.error(const RateInfoHtmlBodyNotFound(), StackTrace.current);
    }
    final divCNode = parseHtmlDocument(htmlBodyData).body;
    if (divCNode == null) {
      return Future.error(const RateInfoDivCNodeNotFound(), StackTrace.current);
    }
    final rateWindowInfo = RateWindowInfo.fromDivCNode(divCNode);
    debug('get rate formHash: ${rateWindowInfo.formHash}');
    if (rateWindowInfo.isNotValid()) {
      return Future.error(const RateInfoInvalidDivCNode(), StackTrace.current);
    }
    return RateInfoSuccess(rateWindowInfo);
  }

  /// Fetch info in rate confirm window.
  Future<void> fetchRateWindowInfo() async {}
}
