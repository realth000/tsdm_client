import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

/// Update window title according to current using locale.
///
/// Only available on desktop platforms.
Future<void> desktopUpdateWindowTitle() async {
  if (isDesktop && !cmdArgs.noWindowConfigs) {
    await windowManager
        .setTitle(LocaleSettings.currentLocale.translations.appName);
    talker.debug('set window title with current locale');
  }
}
