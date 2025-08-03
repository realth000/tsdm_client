import 'package:flutter/services.dart';

const _mainChannel = MethodChannel('kzs.th000.tsdm_client/mainChannel');

const _methodExitApp = 'exitApp';

/// Exit app on Android platform.
///
/// Currently it only moves to background instead of closing the app.
Future<bool?> androidExitApp() async => _mainChannel.invokeMethod<bool>(_methodExitApp);
