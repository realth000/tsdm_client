// lib/features/settings/provider/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/background_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _backgroundKeepAlive = false;
  
  bool get backgroundKeepAlive => _backgroundKeepAlive;
  
  Future<void> setBackgroundKeepAlive(bool value) async {
    _backgroundKeepAlive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_keep_alive', value);
    notifyListeners();
    
    // 根据开关状态启动或停止后台任务
    if (value) {
      await BackgroundService.startBackgroundTask();
    } else {
      await BackgroundService.stopBackgroundTask();
    }
  }
  
  Future<void> loadBackgroundKeepAlive() async {
    final prefs = await SharedPreferences.getInstance();
    _backgroundKeepAlive = prefs.getBool('background_keep_alive') ?? false;
    notifyListeners();
  }
}
