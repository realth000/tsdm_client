import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tsdm_client/cmd.dart';
import 'package:tsdm_client/constants/constants.dart';
import 'package:tsdm_client/utils/logger.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Global logger instance.
late final Talker talker;

/// Global cmdline args.
///
/// Only used in desktop platforms.
///
/// Init in [parseCmdArgs]
late final CmdArgs cmdArgs;

/// Global instance.
late final FlutterLocalNotificationsPlugin flnp;

/// Get the initialized placeholder image data.
///
/// A singleton with only initializing once insurance actually does not work.
/// Still there are some steps when building ui codec from image data, so call
/// it again and again shall be considered as cheap.
Future<ui.ImmutableBuffer> getPlaceholderImageData() async {
  return ui.ImmutableBuffer.fromAsset(assetPlaceholderImagePath);
}

/// The global snackbar key.
///
/// Because we have global BlocListeners outside of `MaterialApp` that calls `showSnackBar`, use this global key to
/// access a context with `Scaffold` to show the snack bar.
///
/// Do NOT use this global key directly, call `showSnackBar` function instead.
final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

class _TalkerObserver implements TalkerObserver {
  _TalkerObserver(this.logFile, this.sink);

  final File logFile;
  final IOSink sink;

  /// Init the file to save log, this function MUST be called as early as possible.
  Future<void> initLogFile() async {}

  @override
  void onError(TalkerError err) {
    sink.write('${err.generateTextMessage()}\n');
  }

  @override
  void onException(TalkerException err) {
    sink.write('${err.generateTextMessage()}\n');
  }

  @override
  void onLog(TalkerData log) {
    sink.write('${log.generateTextMessage()}\n');
  }
}

/// Init talker logger.
///
/// This function MUST be called as early as possible.
Future<void> initLogger() async {
  final nowTime = DateTime.now();
  final sep = Platform.pathSeparator;
  final logDir = await getLogDir();

  // Delete logs from 7 days ago.
  if (logDir.existsSync()) {
    for (final logFileCache in logDir.listSync(followLinks: false)) {
      if (logFileCache.existsSync() && nowTime.difference(logFileCache.statSync().modified).inDays.abs() > 7) {
        await logFileCache.delete();
      }
    }
  } else {
    await logDir.create();
  }

  final logFileTime = '${nowTime.year}${"${nowTime.month}".padLeft(2, "0")}${"${nowTime.day}".padLeft(2, "0")}';
  final logFile = File('${logDir.path}${sep}tsdm_client_$logFileTime.log');
  final sink = logFile.openWrite(mode: FileMode.append);

  talker = TalkerFlutter.init(
    settings: TalkerSettings(colors: {TalkerLogType.debug.key: AnsiPen()..xterm(60)}),
    observer: _TalkerObserver(logFile, sink),
  );
}
