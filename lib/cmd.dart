import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:args/args.dart';
import 'package:tsdm_client/instance.dart';

const _linuxTilingWindowManagers = ['bspwm', 'dwm', 'hyprland', 'i3wm', 'niri', 'sway'];

/// All flags in cmdline.
abstract class Flags {
  /// Disable window related configs, including window size, window title and
  /// window position.
  ///
  /// Set to false if needed, as in recovery mode.
  static const noWindowConfigs = 'no-window-configs';

  /// Disable recoding window status changes, including:
  ///
  /// * Window size changes.
  /// * Window position changes.
  static const noWindowChangeRecords = 'no-window-change-records';
}

/// Cmdline arguments parsed result.
class CmdArgs {
  /// Constructor.
  const CmdArgs({required this.noWindowConfigs, required this.noWindowChangeRecords});

  /// Disable window related configs.
  ///
  /// Set to `true` will disable window_manager related features.
  /// Also the **ONLY** way to disable it.
  final bool noWindowConfigs;

  /// Disable recording window state changes.
  ///
  /// Set to `true` will stop recoding window state change features, window size
  /// and window position in config storage no longer updates.
  final bool noWindowChangeRecords;
}

/// Parse cmdline [args] into global variable [cmdArgs].
void parseCmdArgs(List<String> args) {
  final parser =
      ArgParser()
        ..addFlag(Flags.noWindowConfigs, negatable: false)
        ..addFlag(Flags.noWindowChangeRecords, negatable: false);
  final argsResult = parser.parse(args);

  var noWindowConfig = argsResult.flag(Flags.noWindowConfigs);
  var noWindowChangeRecords = argsResult.flag(Flags.noWindowChangeRecords);

  final envInTilingWindowManager = _linuxTilingWindowManagers.contains(Platform.environment['XDG_CURRENT_DESKTOP']);

  if (Platform.isLinux && !noWindowConfig && envInTilingWindowManager) {
    talker.debug(
      'set no-window-configs to true due to ENV '
      'detected as tiling window manager',
    );
    noWindowConfig = true;
  }

  if (Platform.isLinux && !noWindowChangeRecords && envInTilingWindowManager) {
    talker.debug(
      'set no-window-change-records to true due to ENV '
      'detected as tiling window manager',
    );
    noWindowChangeRecords = true;
  }

  cmdArgs = CmdArgs(noWindowConfigs: noWindowConfig, noWindowChangeRecords: noWindowChangeRecords);
}
