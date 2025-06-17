// lib/utils/app_launch_checker.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppLaunchChecker {
  static const _key = 'is_first_launch';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool(_key) ?? true;

    if (hasLaunched) {
      await prefs.setBool(_key, false); // Đánh dấu đã mở
    }

    return hasLaunched;
  }
}
