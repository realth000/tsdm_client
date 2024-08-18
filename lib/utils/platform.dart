import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs

const isWeb = kIsWeb;
final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;
final isWindows = Platform.isWindows;
final isLinux = Platform.isLinux;
final isMacOS = Platform.isMacOS;
final isAndroid = Platform.isAndroid;
final isIOS = Platform.isIOS;
