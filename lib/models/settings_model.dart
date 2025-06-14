import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  bool eyeCareEnabled = true;
  bool postureEnabled = true;
  bool waterReminderEnabled = true;
  bool workoutReminderEnabled = true;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    eyeCareEnabled = prefs.getBool('eyeCare') ?? true;
    postureEnabled = prefs.getBool('posture') ?? true;
    waterReminderEnabled = prefs.getBool('water') ?? true;
    workoutReminderEnabled = prefs.getBool('workout') ?? true;
    notifyListeners();
  }

  void updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'eyeCare':
        eyeCareEnabled = value;
        break;
      case 'posture':
        postureEnabled = value;
        break;
      case 'water':
        waterReminderEnabled = value;
        break;
      case 'workout':
        workoutReminderEnabled = value;
        break;
    }
    await prefs.setBool(key, value);
    notifyListeners();
  }
}
