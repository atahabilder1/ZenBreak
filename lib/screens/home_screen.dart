import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ZenBreak Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSwitchTile(
            context,
            '👀 Eye Care Reminder (Every 20 mins)',
            settings.eyeCareEnabled,
            (val) => settings.updateSetting('eyeCare', val),
          ),
          _buildSwitchTile(
            context,
            '🧍 Posture & Walk Reminder (Every 40 mins)',
            settings.postureEnabled,
            (val) => settings.updateSetting('posture', val),
          ),
          _buildSwitchTile(
            context,
            '💧 Drink Water Reminder (Every 1 hour)',
            settings.waterReminderEnabled,
            (val) => settings.updateSetting('water', val),
          ),
          _buildSwitchTile(
            context,
            '🏋️ Workout Reminder (Every 2 hours)',
            settings.workoutReminderEnabled,
            (val) => settings.updateSetting('workout', val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
