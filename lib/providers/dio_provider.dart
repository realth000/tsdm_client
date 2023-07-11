import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tsdm_client/providers/settings_provider.dart';

/// Provider of dio.
///
/// Now only plan to use directly, no state needed.
final dioProvider = Provider<Dio>((ref) => _initDio());

Dio _initDio() {
  final settings = ProviderContainer().read(settingsProvider);

  return Dio()
    ..options = BaseOptions(
      headers: <String, String>{
        'Accept': settings.dioAccept,
        'Accept-Encoding': settings.dioAcceptEncoding,
        'Accept-Language': settings.dioAcceptLanguage,
        'User-Agent': settings.dioUserAgent,
      },
    );
}
