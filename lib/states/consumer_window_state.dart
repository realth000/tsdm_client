import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/settings_provider.dart';
import '../utils/platform.dart';

/// [ConsumerState] together with [WindowListener].
abstract class ConsumerWindowState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> with WindowListener {
  final _settings = ProviderContainer();

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Future<void> onWindowResize() async {
    await _settings
        .read(settingsProvider.notifier)
        .setWindowSize(await windowManager.getSize());
  }

  @override
  Future<void> onWindowMove() async {
    await _settings
        .read(settingsProvider.notifier)
        .setWindowPosition(await windowManager.getPosition());
  }
}
