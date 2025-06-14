import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class HomeScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _intervalController = TextEditingController();

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
          Consumer<SettingsModel>(
            builder: (context, settings, child) => _buildSettingTile(
              context,
              '👀 Eye Care Reminder',
              settings.eyeCareEnabled,
              (val) => settings.updateSetting('eyeCare', val),
              settings.eyeCareInterval,
              (val) => settings.updateInterval('eyeCareInterval', val),
            ),
          ),
          Consumer<SettingsModel>(
            builder: (context, settings, child) => _buildSettingTile(
              context,
              '🧍 Posture & Walk Reminder',
              settings.postureEnabled,
              (val) => settings.updateSetting('posture', val),
              settings.postureInterval,
              (val) => settings.updateInterval('postureInterval', val),
            ),
          ),
          Consumer<SettingsModel>(
            builder: (context, settings, child) => _buildSettingTile(
              context,
              '💧 Drink Water Reminder',
              settings.waterReminderEnabled,
              (val) => settings.updateSetting('water', val),
              settings.waterInterval,
              (val) => settings.updateInterval('waterInterval', val),
            ),
          ),
          Consumer<SettingsModel>(
            builder: (context, settings, child) => _buildSettingTile(
              context,
              '🏋️ Workout Reminder',
              settings.workoutReminderEnabled,
              (val) => settings.updateSetting('workout', val),
              settings.workoutInterval,
              (val) => settings.updateInterval('workoutInterval', val),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAddCustomReminderDialog(context, settings),
            child: Text('Add Custom Reminder'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => settings.resetSettings(),
            child: Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, bool value, Function(bool) onChanged, int interval, Function(int) onIntervalChanged) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title, style: TextStyle(fontSize: 18)),
          value: value,
          onChanged: onChanged,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
        Slider(
          value: interval.toDouble(),
          min: 10,
          max: 240,
          divisions: 23,
          label: '$interval mins',
          onChanged: (val) => onIntervalChanged(val.toInt()),
        ),
      ],
    );
  }

  void _showAddCustomReminderDialog(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Reminder'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter a message' : null,
              ),
              TextFormField(
                controller: _intervalController,
                decoration: InputDecoration(labelText: 'Interval (mins)'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
              ),
              SwitchListTile(
                title: Text('Repeat'),
                value: false,
                onChanged: (val) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                settings.addCustomReminder(
                  _titleController.text,
                  _messageController.text,
                  int.parse(_intervalController.text),
                  false,
                );
                _titleController.clear();
                _messageController.clear();
                _intervalController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}