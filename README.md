
# 🌿 ZenBreak – Your Desktop Wellness Companion

**ZenBreak** is a lightweight, cross-platform wellness assistant that helps you take mindful breaks, maintain good posture, stay hydrated, and move your body — all while working at your computer. Built with Flutter, ZenBreak runs in the system tray and gently reminds you to care for your eyes, back, and health without disrupting your workflow.

---

## 🧠 Features

- 👀 **Eye Care Reminders** — every 20 minutes (20-20-20 rule)
- 🧍‍♂️ **Posture & Stretch Reminders** — every 40 minutes
- 💧 **Hydration Prompts** — every 1 hour
- 🏋️ **Light Workout Prompts** — every 2 hours
- 🛑 **Distraction Blocking (Coming Soon)** — enforce breaks by blocking screen
- 🧩 **Settings Panel** — toggle each type of reminder
- 📥 **Installer Support** — build `.exe` installer via Inno Setup
- 🌙 **System Tray Mode** — quietly runs in the background
- 🧘‍♂️ **Custom Zen App Icon**

---

## 🛠 Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [tray_manager](https://pub.dev/packages/tray_manager)
- [window_manager](https://pub.dev/packages/window_manager)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [provider](https://pub.dev/packages/provider)

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/zenbreak.git
cd zenbreak
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run -d windows
```

### 4. Build the `.exe` (Windows)

```bash
flutter build windows
```

### 5. Create Installer (Optional)

Use [Inno Setup](https://jrsoftware.org/isinfo.php) and point it to `build/windows/x64/runner/Release/` to package ZenBreak as an installer.

---

## 📂 Folder Structure

```
lib/
├── main.dart
├── models/
│   └── settings_model.dart
├── services/
│   └── notification_service.dart
├── screens/
│   └── home_screen.dart
assets/
└── icon.png
```

---

## 📃 License

MIT License. See [LICENSE](LICENSE) file for details.

---

## 💬 Credits

ZenBreak is built with love and mindfulness by [Anik Tahabilder](https://github.com/anik-tahabilder).  
Inspired by healthy work-life balance, deep focus, and the 20-20-20 rule.
