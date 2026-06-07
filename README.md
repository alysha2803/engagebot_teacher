# EngageBot Teacher 📊

**EngageBot Smart Classroom — Teacher Analytics Application**

A Flutter app for real-time student engagement analytics, class management, and reporting.

---

## Prerequisites

Before running this project, make sure the following are installed on your machine:

| Tool | Minimum Version | Download |
|------|----------------|----------|
| Flutter SDK | 3.3.0+ | https://docs.flutter.dev/get-started/install |
| Android Studio | Hedgehog+ | https://developer.android.com/studio |
| Android SDK (API 33) | API 33 (Android 13) | via Android Studio SDK Manager |
| Java JDK | 11+ | bundled with Android Studio |

Verify your setup at any time:
```bash
flutter doctor
```

---

## Running in an Android Emulator (Step-by-Step)

### Step 1 — Install Dependencies

In the project root, fetch all Flutter packages:

```bash
flutter pub get
```

---

### Step 2 — Create or Verify an AVD (Android Virtual Device)

1. Open **Android Studio**
2. Go to **Tools → Device Manager** (or **Virtual Device Manager**)
3. Click **Create Device**
4. Select a hardware profile (e.g. **Pixel 4 XL**) → click **Next**
5. Download and select a system image (e.g. **API 33 / Android 13 — x86_64**) → click **Next**
6. Name the AVD (e.g. `Pixel_4_XL_API_33`) → click **Finish**

To list existing AVDs from the command line:
```bash
flutter emulators
```

---

### Step 3 — Launch the Emulator

**Option A — From Android Studio:**
- Open **Device Manager** → click the ▶ play button next to your AVD

**Option B — From the terminal:**
```bash
flutter emulators --launch Pixel_4_XL_API_33
```
> Replace `Pixel_4_XL_API_33` with the exact emulator ID shown by `flutter emulators`.

Wait for the emulator to fully boot (the Android home screen should be visible — this can take 1–3 minutes on first launch).

---

### Step 4 — Confirm the Device is Detected

```bash
flutter devices
```

You should see output similar to:
```
Found 1 connected device:
  sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 13 (API 33)
```

If the emulator doesn't appear, run:
```bash
adb devices
```
and make sure it shows `emulator-5554 device` (not `offline`).

---

### Step 5 — Run the App

```bash
flutter run
```

If multiple devices are connected, specify the emulator explicitly:
```bash
flutter run -d emulator-5554
```

The app will compile, install, and launch automatically on the emulator.

---

## Quick Reference Commands

```bash
# Get packages
flutter pub get

# Analyze for errors (no issues = good to go)
flutter analyze

# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch Pixel_4_XL_API_33

# Check connected devices
flutter devices

# Run on the connected emulator
flutter run

# Run in release mode (faster, no debug tools)
flutter run --release

# Hot reload (while app is running — press 'r' in terminal)
# Hot restart (press 'R' in terminal)
```

---

## Troubleshooting

### Emulator doesn't appear in `flutter devices`
- Make sure the emulator is **fully booted** (home screen visible, not just Android logo)
- Try restarting ADB: `adb kill-server && adb start-server`
- Check the emulator process is running in Task Manager

### `flutter doctor` shows Android SDK issues
- Open Android Studio → **SDK Manager** → install **Android SDK Platform 33** and **Android SDK Build-Tools**

### HAXM / Virtualization errors
- Enable **Intel HAXM** or **AMD Hypervisor** in your BIOS
- In Android Studio → SDK Manager → **SDK Tools** → install **Intel x86 Emulator Accelerator (HAXM)**

### Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## Project Structure

```
engagebot_teacher/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── app/
│   │   ├── router/app_router.dart  # GoRouter navigation
│   │   └── theme/app_theme.dart    # Design system & colours
│   ├── features/
│   │   ├── auth/                   # Login screen
│   │   ├── dashboard/              # Teacher dashboard
│   │   ├── classes/                # Class management
│   │   ├── student_profile/        # Per-student analytics
│   │   ├── reports/                # Engagement reports
│   │   └── settings/               # App settings
│   ├── shared/
│   │   └── widgets/                # Reusable UI components
│   └── data/                       # Models & providers
├── android/                        # Android-specific config
├── pubspec.yaml                    # Dependencies
└── analysis_options.yaml           # Linter rules
```

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation / routing |
| `fl_chart` | Engagement charts |
| `dio` | HTTP networking |
| `shared_preferences` | Local storage |
| `google_fonts` | Typography |
| `cached_network_image` | Image caching |

---

*Flutter SDK ≥ 3.3.0 · Dart SDK ≥ 3.3.0 · Android API 33*
