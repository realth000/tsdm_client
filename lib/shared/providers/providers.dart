import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider.dart';
import 'package:tsdm_client/shared/providers/checkin_provider/checkin_provider_impl.dart';
import 'package:tsdm_client/shared/providers/cookie_provider/cookie_provider.dart';
import 'package:tsdm_client/shared/providers/image_cache_provider/image_cache_provider.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';

/// 3. All providers **MUST NOT** be directly used by blocs or elsewhere.
///
/// This rule is to ensure clear and lightweight dependencies.
Future<void> initProviders() async {
  await initCache();

  getIt
    ..registerFactory(CookieProvider.new)
    ..registerFactory(NetClientProvider.new)
    ..registerFactory<CheckinProvider>(CheckInProviderImpl.new)
    ..registerFactory(ImageCacheProvider.new);
  await getIt.allReady();
}
