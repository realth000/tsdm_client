import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/providers/auth_provider.dart';
import 'package:tsdm_client/providers/net_client_provider.dart';

part '../generated/providers/rate_provider.g.dart';

///////////////////////////////////////////////////////////////////////////////

/// Result of rate action.
sealed class RateResult {
  const RateResult._();
}

/// Failed to post the rate action.
final class RateWaiting extends RateResult {
  const RateWaiting() : super._();
}

/// Failed to post the rate action.
final class RateFailed extends RateResult {
  const RateFailed(this.message) : super._();

  final String message;
}

final class RateSucceed extends RateResult {
  const RateSucceed() : super._();
}

@Riverpod(dependencies: [Auth, NetClient])
class Rate extends _$Rate {
  static const _rateTarget =
      '$baseUrl/forum.php?mod=misc&action=rate&ratesubmit=yes&infloat=yes&inajax=1';

  static final _errorTextRe = RegExp(r'alert_error">(?<error>[^<]+)<');

  @override
  Future<RateResult> build() async {
    return const RateWaiting();
  }

  /// Post a rate request with [queryParameters].
  ///
  /// [queryParameters] should have:
  /// * tid
  /// * pid
  /// * formHash
  /// * referer
  /// * handleKey
  /// * sendreasonpm: on / off
  /// * reason
  Future<RateResult> rate(Map<String, String> queryParameters) async {
    state = const AsyncLoading();
    final ret = await _rate(queryParameters);
    state = const AsyncData(RateWaiting());
    return ret;
  }

  Future<RateResult> _rate(Map<String, String> queryParameters) async {
    final resp = await ref.read(netClientProvider()).post(
          _rateTarget,
          data: queryParameters,
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );
    if (resp.statusCode != HttpStatus.ok) {
      return RateFailed('http status: ${resp.statusCode}');
    }

    final data = resp.data as String;

    if (data.contains('succeedhandle_rate')) {
      return const RateSucceed();
    }

    final errorText = _errorTextRe.firstMatch(data)?.namedGroup('error');
    if (errorText != null) {
      return RateFailed(errorText);
    }

    return RateFailed(data);
  }
}
