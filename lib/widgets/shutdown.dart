import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/storage_provider/storage_provider.dart';
import 'package:tsdm_client/utils/platform.dart';

/// Graceful shutdown.
Future<void> exitApp() async {
  await getIt.get<StorageProvider>().dispose();
  // Close the app.
  if (isAndroid || isIOS) {
    await SystemNavigator.pop(animated: true);
  } else {
    // CAUTION: unsafe operation.
    exit(0);
  }
}
