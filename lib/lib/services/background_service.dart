// 创建新文件: lib/services/background_service.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("BackgroundTask: TSDM Client is running in background!");
    // 这里可以添加实际的后台任务逻辑
    // 例如：检查更新、同步数据等
    
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> startBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      "tsdmBackgroundTask",
      "tsdmBackgroundTask",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> stopBackgroundTask() async {
    await Workmanager().cancelByUniqueName("tsdmBackgroundTask");
  }
}
