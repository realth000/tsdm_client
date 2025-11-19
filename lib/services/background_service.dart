import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("BackgroundTask: TSDM Client is running in background!");
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      print("BackgroundService: Initialized successfully");
    } catch (e) {
      print("BackgroundService: Initialization failed - $e");
      rethrow;
    }
  }

  static Future<void> startBackgroundTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        "tsdmBackgroundTask",
        "tsdmBackgroundTask",
        frequency: Duration(minutes: 15),
        initialDelay: Duration(seconds: 10),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      print("BackgroundService: Background task started successfully");
    } catch (e) {
      print("BackgroundService: Failed to start background task - $e");
      rethrow;
    }
  }

  static Future<void> stopBackgroundTask() async {
    try {
      await Workmanager().cancelByUniqueName("tsdmBackgroundTask");
      print("BackgroundService: Background task stopped successfully");
    } catch (e) {
      print("BackgroundService: Failed to stop background task - $e");
      rethrow;
    }
  }
}
