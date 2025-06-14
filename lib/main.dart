import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/settings_model.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions options = WindowOptions(
    size: Size(400, 600),
    center: true,
    skipTaskbar: false,
    title: "ZenBreak",
    alwaysOnTop: true,
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setPreventClose(true);
  });

  await trayManager.setIcon('assets/icon.png');
  await trayManager.setToolTip("ZenBreak is running in the background");
  await trayManager.setContextMenu(Menu(items: [
    MenuItem(key: 'show', label: 'Show ZenBreak'),
    MenuItem(key: 'exit', label: 'Exit'),
  ]));
  trayManager.addListener(MyTrayHandler());

  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsModel()..loadSettings(),
      child: ZenBreakApp(),
    ),
  );
}

class ZenBreakApp extends StatefulWidget {
  @override
  State<ZenBreakApp> createState() => _ZenBreakAppState();
}

class _ZenBreakAppState extends State<ZenBreakApp> with WindowListener {
  Timer? _eyeTimer, _postureTimer, _waterTimer, _workoutTimer;
  List<Timer?> _customTimers = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isOnBreak = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadSound();
  }

  Future<void> _loadSound() async {
    await _audioPlayer.setSource(AssetSource('sounds/notification.wav'));
  }

  void _startTimers() {
    final settings = Provider.of<SettingsModel>(context, listen: false);
    _cancelTimers();
    _eyeTimer = Timer.periodic(Duration(minutes: settings.eyeCareInterval), (_) {
      if (settings.eyeCareEnabled && !_isOnBreak) _scheduleBreak("Eye Care", "Look 20 feet away for 20 seconds.");
    });
    _postureTimer = Timer.periodic(Duration(minutes: settings.postureInterval), (_) {
      if (settings.postureEnabled && !_isOnBreak) _scheduleBreak("Posture Break", "Stand and stretch your body.");
    });
    _waterTimer = Timer.periodic(Duration(minutes: settings.waterInterval), (_) {
      if (settings.waterReminderEnabled && !_isOnBreak) _scheduleBreak("Hydration", "💧 Drink some water!");
    });
    _workoutTimer = Timer.periodic(Duration(minutes: settings.workoutInterval), (_) {
      if (settings.workoutReminderEnabled && !_isOnBreak) _scheduleBreak("Workout Time", "🏋️ Do a short workout or stretch!");
    });
    for (var reminder in settings.customReminders) {
      _customTimers.add(Timer.periodic(Duration(minutes: reminder['interval']), (_) {
        if (!_isOnBreak) _scheduleBreak(reminder['title'], reminder['message']);
      }));
    }
  }

  void _cancelTimers() {
    _eyeTimer?.cancel();
    _postureTimer?.cancel();
    _waterTimer?.cancel();
    _workoutTimer?.cancel();
    for (var timer in _customTimers) timer?.cancel();
    _customTimers.clear();
  }

  void _scheduleBreak(String title, String message) {
    final settings = Provider.of<SettingsModel>(context, listen: false);
    List<Map<String, String>> activeBreaks = [];
    if (settings.eyeCareEnabled && title == "Eye Care") activeBreaks.add({'title': title, 'message': message});
    if (settings.postureEnabled && title == "Posture Break") activeBreaks.add({'title': title, 'message': message});
    if (settings.waterReminderEnabled && title == "Hydration") activeBreaks.add({'title': title, 'message': message});
    if (settings.workoutReminderEnabled && title == "Workout Time") activeBreaks.add({'title': title, 'message': message});
    for (var reminder in settings.customReminders) {
      if (reminder['title'] == title) activeBreaks.add({'title': title, 'message': reminder['message']});
    }
    if (activeBreaks.isNotEmpty) _showBreakOverlay(activeBreaks);
  }

  Future<void> _showBreakOverlay(List<Map<String, String>> breaks) async {
    if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(duration: 500);
    await _audioPlayer.resume();
    await windowManager.setAlwaysOnTop(true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...breaks.map((breakItem) => Column(
                  children: [
                    Text(breakItem['title']!, style: TextStyle(color: Colors.white, fontSize: 32)),
                    Text(breakItem['message']!, style: TextStyle(color: Colors.white70, fontSize: 20)),
                    SizedBox(height: 20),
                  ],
                )).toList(),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    _isOnBreak = true;
                    Navigator.of(context).pop();
                    await _turnScreenOff();
                  },
                  child: Text("OK, I'm taking a break"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _turnScreenOff() async {
    await windowManager.hide();
    await Future.delayed(Duration(minutes: 1));
    await _showBackToWorkOverlay();
  }

  Future<void> _showBackToWorkOverlay() async {
    await windowManager.show();
    await windowManager.focus();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome Back!", style: TextStyle(color: Colors.white, fontSize: 32)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _isOnBreak = false;
                    _startTimers();
                    Navigator.of(context).pop();
                  },
                  child: Text("I'm back to work"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsModel>(context, listen: false);
    settings.addListener(_startTimers);
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenBreak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: Text("ZenBreak Settings")),
        body: HomeScreen(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _startTimers();
            await Future.delayed(Duration(milliseconds: 300));
            await windowManager.setPreventClose(true);
            await windowManager.hide();
          },
          child: Icon(Icons.check),
          tooltip: 'Minimize to Tray and Start',
        ),
      ),
    );
  }

  @override
  void dispose() {
    final settings = Provider.of<SettingsModel>(context, listen: false);
    settings.removeListener(_startTimers);
    _cancelTimers();
    _audioPlayer.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }
}

class MyTrayHandler with TrayListener {
  @override
  void onTrayIconMouseDown() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem item) async {
    if (item.key == 'show') {
      await windowManager.show();
      await windowManager.focus();
    } else if (item.key == 'exit') {
      await trayManager.destroy();
      await windowManager.setPreventClose(false);
      await windowManager.close();
    }
  }
}
