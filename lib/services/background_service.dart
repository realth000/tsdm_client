// services/background_service.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point') // 这是一个关键的注解，防止代码被优化掉
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // 这里是后台任务实际执行的地方
    print("BackgroundTask: TSDM Client is running in background!");
    // 例如：你可以在这里检查新消息、更新数据等
    // 注意：这里的代码运行在独立的Isolate中，不能直接操作UI
    
    // 返回 Future.value(true) 表示任务成功
    // 返回 Future.value(false) 表示任务失败
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher, // 上面的回调函数
      isInDebugMode: false, // 开发时设为true可看更多日志
    );
  }

  static Future<void> startBackgroundTask() async {
    // 注册一个周期性任务
    // 注意事项：
    // - 在Android上，最小间隔是15分钟
    // - iOS上的行为可能不同，更受系统限制
    await Workmanager().registerPeriodicTask(
      "tsdmBackgroundTask",
      "tsdmBackgroundTask",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.connected, // 指定网络条件
      ),
    );
  }

  static Future<void> stopBackgroundTask() async {
    await Workmanager().cancelByUniqueName("tsdmBackgroundTask");
  }
}
