import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsModel extends ChangeNotifier {
  bool eyeCareEnabled = true;
  bool postureEnabled = true;
  bool waterReminderEnabled = true;
  bool workoutReminderEnabled = true;
  int eyeCareInterval = 20; // in minutes
  int postureInterval = 40;
  int waterInterval = 60;
  int workoutInterval = 120;

  List<Map<String, dynamic>> customReminders = [];

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      eyeCareEnabled = prefs.getBool('eyeCare') ?? true;
      postureEnabled = prefs.getBool('posture') ?? true;
      waterReminderEnabled = prefs.getBool('water') ?? true;
      workoutReminderEnabled = prefs.getBool('workout') ?? true;
      eyeCareInterval = prefs.getInt('eyeCareInterval') ?? 20;
      postureInterval = prefs.getInt('postureInterval') ?? 40;
      waterInterval = prefs.getInt('waterInterval') ?? 60;
      workoutInterval = prefs.getInt('workoutInterval') ?? 120;
      final reminders = prefs.getStringList('customReminders') ?? [];
      customReminders = reminders.map((json) => Map<String, dynamic>.from(jsonDecode(json))).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'eyeCare': eyeCareEnabled = value; break;
      case 'posture': postureEnabled = value; break;
      case 'water': waterReminderEnabled = value; break;
      case 'workout': workoutReminderEnabled = value; break;
    }
    await prefs.setBool(key, value);
    notifyListeners();
  }

  void updateInterval(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (key) {
      case 'eyeCareInterval': eyeCareInterval = value; break;
      case 'postureInterval': postureInterval = value; break;
      case 'waterInterval': waterInterval = value; break;
      case 'workoutInterval': workoutInterval = value; break;
    }
    await prefs.setInt(key, value);
    notifyListeners();
  }

  Future<void> addCustomReminder(String title, String message, int interval, bool isRepeating) async {
    final prefs = await SharedPreferences.getInstance();
    final reminder = {'title': title, 'message': message, 'interval': interval, 'isRepeating': isRepeating};
    customReminders.add(reminder);
    final remindersJson = customReminders.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('customReminders', remindersJson);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    eyeCareEnabled = true;
    postureEnabled = true;
    waterReminderEnabled = true;
    workoutReminderEnabled = true;
    eyeCareInterval = 20;
    postureInterval = 40;
    waterInterval = 60;
    workoutInterval = 120;
    customReminders.clear();
    await prefs.setBool('eyeCare', true);
    await prefs.setBool('posture', true);
    await prefs.setBool('water', true);
    await prefs.setBool('workout', true);
    await prefs.setInt('eyeCareInterval', 20);
    await prefs.setInt('postureInterval', 40);
    await prefs.setInt('waterInterval', 60);
    await prefs.setInt('workoutInterval', 120);
    await prefs.setStringList('customReminders', []);
    notifyListeners();
  }
}