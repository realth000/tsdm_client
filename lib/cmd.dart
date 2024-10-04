import 'package:args/args.dart';
import 'package:tsdm_client/instance.dart';

/// All flags in cmdline.
abstract class Flags {
  /// Disable window related configs, including window size, window title and
  /// window position.
  ///
  /// Set to false if needed, as in recovery mode.
  static const noWindowConfigs = 'no-window-configs';
}

/// Cmdline arguments parsed result.
class CmdArgs {
  /// Constructor.
  const CmdArgs({
    required this.noWindowConfigs,
  });

  /// Disable window related configs.
  ///
  /// Set to `true` will disable window_manager related features.
  /// Also the **ONLY** way to disable it.
  final bool noWindowConfigs;
}

/// Parse cmdline [args] into global variable [cmdArgs].
void parseCmdArgs(List<String> args) {
  final parser = ArgParser()..addFlag(Flags.noWindowConfigs, negatable: false);

  final argsResult = parser.parse(args);
  cmdArgs = CmdArgs(
    noWindowConfigs: argsResult.flag(Flags.noWindowConfigs),
  );
}
