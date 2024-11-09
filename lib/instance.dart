import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tsdm_client/cmd.dart';

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
