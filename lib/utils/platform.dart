import 'dart:io';

import 'package:flutter/foundation.dart';

const isWeb = kIsWeb;
final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
final isMobile = Platform.isAndroid || Platform.isIOS;
final isWindows = Platform.isWindows;
final isLinux = Platform.isLinux;
final isMacOS = Platform.isMacOS;
final isAndroid = Platform.isAndroid;
final isIOS = Platform.isIOS;
