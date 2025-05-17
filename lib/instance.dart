import 'dart:ui' as ui;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tsdm_client/cmd.dart';
import 'package:tsdm_client/constants/constants.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Global logger instance.
final talker = TalkerFlutter.init();

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
