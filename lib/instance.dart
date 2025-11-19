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
final GetIt getIt = GetIt.instance;

/// Global logger instance.
late final Talker talker;

/// The log file instance.
///
/// This is a global instance because we have to reinit the log sink
/// after deleting logs.
late File _logFile;

/// The sink of log file.
///
/// This is a global instance because we have to release the file first
/// when deleting logs.
late IOSink _logSink;

/// Flag indicating [_logSink] is in closed state or not.
bool _logSinkClosed = false;

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
  _TalkerObserver();

  /// Init the file to save log, this function MUST be called as early as possible.
  Future<void> initLogFile() async {}

  @override
  void onError(TalkerError err) {
    if (_logSinkClosed) {
      return;
    }
    _logSink.write('${err.generateTextMessage()}\n');
  }

  @override
  void onException(TalkerException err) {
    if (_logSinkClosed) {
      return;
    }
    _logSink.write('${err.generateTextMessage()}\n');
  }

  @override
  void onLog(TalkerData log) {
    if (_logSinkClosed) {
      return;
    }
    _logSink.write('${log.generateTextMessage()}\n');
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
  _logFile = File('${logDir.path}${sep}tsdm_client_$logFileTime.log');
  _logSink = _logFile.openWrite(mode: FileMode.append);

  talker = TalkerFlutter.init(
    settings: TalkerSettings(colors: {TalkerKey.debug: AnsiPen()..xterm(60)}),
    observer: _TalkerObserver(),
  );
}

/// Close the log sink.
///
/// Remember to call [openLogSink] otherwise logs are not saved.
Future<void> closeLogSink() async {
  _logSinkClosed = true;
  await _logSink.flush();
  await _logSink.close();
}

/// Close the log sink.
Future<void> openLogSink() async {
  _logSink = _logFile.openWrite(mode: FileMode.append);
  _logSinkClosed = false;
}
