import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
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
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await trayManager.setIcon('assets/icon.png');
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

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimers());
  }

  void _startTimers() {
    final settings = Provider.of<SettingsModel>(context, listen: false);

    _eyeTimer = Timer.periodic(Duration(minutes: 1), (_) {
      if (settings.eyeCareEnabled) {
        _showBreakOverlay("Eye Care", "Look 20 feet away for 20 seconds.");
      }
    });

    _postureTimer = Timer.periodic(Duration(minutes: 2), (_) {
      if (settings.postureEnabled) {
        _showBreakOverlay("Posture Break", "Stand and stretch your body.");
      }
    });

    _waterTimer = Timer.periodic(Duration(minutes: 3), (_) {
      if (settings.waterReminderEnabled) {
        NotificationService.showNotification("ZenBreak - Stay Hydrated", "💧 Drink some water!");
      }
    });

    _workoutTimer = Timer.periodic(Duration(minutes: 4), (_) {
      if (settings.workoutReminderEnabled) {
        NotificationService.showNotification("ZenBreak - Workout Time", "🏋️ Do a short workout or stretch!");
      }
    });
  }

  Future<void> _showBreakOverlay(String title, String message) async {
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
                Text(title, style: TextStyle(color: Colors.white, fontSize: 32)),
                SizedBox(height: 20),
                Text(message, style: TextStyle(color: Colors.white70, fontSize: 20)),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("I've done it!"),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
  void dispose() {
    _eyeTimer?.cancel();
    _postureTimer?.cancel();
    _waterTimer?.cancel();
    _workoutTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenBreak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: HomeScreen(),
    );
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
