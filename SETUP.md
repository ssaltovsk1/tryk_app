# 🚀 Quick Start Guide - Running Cyber Shield on Mobile

## Prerequisites

1. **Install Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install
   - Follow installation instructions for your OS

2. **Verify Flutter installation:**
   ```bash
   flutter doctor
   ```
   Fix any issues shown (Android Studio, Xcode, etc.)

## 📱 Running on Android Phone (Easiest Method)

### Step 1: Prepare Your Phone

1. **Enable Developer Mode:**
   - Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options

2. **Enable USB Debugging:**
   - In Developer Options, turn on:
     - USB Debugging
     - Install via USB

### Step 2: Connect & Run

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd tryk_app

# 2. Get dependencies
flutter pub get

# 3. Connect your phone via USB cable

# 4. Verify phone is detected
flutter devices

# 5. Run the app
flutter run
```

That's it! The app will install and launch on your phone.

## 🔄 Development Tips

**While the app is running:**
- Press `r` - Hot reload (instant UI updates)
- Press `R` - Hot restart (full app restart)
- Press `q` - Quit

**Make changes:**
1. Edit any `.dart` file
2. Save the file
3. Press `r` in terminal
4. See changes instantly on phone!

## 📦 Build APK for Distribution

```bash
# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

**Install APK manually:**
1. Copy `app-release.apk` to phone
2. Settings → Security → Enable "Unknown Sources"
3. Tap APK file → Install

## 🍎 Running on iPhone (Mac Required)

```bash
# 1. Connect iPhone via USB

# 2. Open Xcode project
open ios/Runner.xcworkspace

# 3. In Xcode: Select your Team (Apple ID)

# 4. Run
flutter run
```

## 🖥️ Running on Emulator

### Android Emulator:
```bash
# Start Android Studio → AVD Manager → Run emulator
# Then:
flutter run
```

### iOS Simulator (Mac only):
```bash
open -a Simulator
flutter run
```

## ❗ Troubleshooting

### "No devices found"
```bash
# Android:
adb devices
adb kill-server
adb start-server

# Then try again:
flutter devices
```

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### App crashes on startup
```bash
# Check logs:
flutter run --verbose

# Or Android logs:
adb logcat
```

### Permission denied
```bash
# Android: Check USB debugging is enabled
# iOS: Trust the computer on iPhone
```

## 📊 App Structure

Once running, you'll see:

1. **Home Screen** - 5 module cards
2. **Tap any module** - See lessons
3. **Tap a lesson** - Start quiz
4. **Complete tasks** - Get score and feedback

## 🎯 Testing the App

**Try these demo lessons:**

1. **Детективный Квест** (Detective Quest)
   - Module #4 (Orange)
   - Chat-based detective scenario
   - Make choices and see consequences

2. **Образование** (Education)
   - Module #5 (Blue)
   - "Незнакомец в сети" lesson
   - Single-choice questions about online safety

## 🔧 Configuration

**Change app name:**
- Edit `android/app/src/main/AndroidManifest.xml`
- Change `android:label="Cyber Shield"`

**Change app icon:**
- Use https://icon.kitchen
- Replace files in `android/app/src/main/res/`

**Change package name:**
- Edit `android/app/build.gradle`
- Change `applicationId "com.cybershield.app"`

## 📱 Minimum Requirements

- **Android:** 5.0 (API 21) or higher
- **iOS:** 11.0 or higher
- **Flutter:** 3.0.0 or higher

## 🆘 Need Help?

```bash
# Check Flutter health
flutter doctor -v

# Check connected devices
flutter devices

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## ✅ Success Checklist

- [ ] Flutter installed (`flutter doctor` shows ✓)
- [ ] Phone connected (`flutter devices` shows device)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs (`flutter run` success)
- [ ] Hot reload works (press `r`)

---

**Happy coding! 🎉**

If you encounter issues, run `flutter doctor` and fix any ❌ shown.
