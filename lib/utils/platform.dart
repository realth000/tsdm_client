import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:flutter/foundation.dart';

// Simple api.
// ignore_for_file: public_member_api_docs

const bool isWeb = kIsWeb;
final bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final bool isMobile = Platform.isAndroid || Platform.isIOS;
final bool isWindows = Platform.isWindows;
final bool isLinux = Platform.isLinux;
final bool isMacOS = Platform.isMacOS;
final bool isAndroid = Platform.isAndroid;
final bool isIOS = Platform.isIOS;
