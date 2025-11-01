# Android Auto Debugging Guide

This guide will help you debug and test the Android Auto integration for the Road Trip Game.

## Overview

The Android Auto implementation consists of:
- **Flutter/Dart side**: `AndroidAutoManager` pushes scoreboard updates via MethodChannel
- **Android/Kotlin side**: `MainActivity` receives updates and stores them in `ScoreboardRepository`
- **Android Auto Screen**: `RoadTripCarScreen` displays the scoreboard in Android Auto UI

## Testing Android Auto

### Option 1: Android Auto Desktop Head Unit (DHU)

The DHU is a simulator that runs on your computer and connects to your Android device.

#### Setup:

1. **Install Android Auto DHU**:
   ```bash
   # Make sure you have Android SDK installed
   # DHU comes with the Android SDK
   cd %ANDROID_SDK_ROOT%\extras\google\auto
   desktop-head-unit.exe
   ```

2. **Enable Developer Mode on your Android phone**:
   - Open Android Auto app on phone
   - Tap version number 10 times to enable developer mode
   - Go to Settings > Developer settings
   - Enable "Unknown sources"

3. **Connect phone via USB** with USB debugging enabled

4. **Run the DHU**:
   ```bash
   desktop-head-unit.exe
   ```

5. **Run your app**:
   ```bash
   flutter run -d <your-device-id>
   ```

6. The Road Trip Game should appear in the DHU launcher

### Option 2: Real Car Head Unit

If you have access to a car with Android Auto:

1. Connect your phone via USB
2. Enable developer mode (see above)
3. Run your app on the phone
4. The app should appear in the car's Android Auto interface

### Option 3: Android Automotive OS Emulator

For testing on Android Automotive OS (built-in car systems):

1. Create an Automotive emulator in Android Studio
2. Run your app directly on the emulator
3. The Android Auto screen should load automatically

## Viewing Debug Logs

### Flutter/Dart Logs

All car-related components now use `dart:developer` logging. View them with:

```bash
flutter run -d windows  # or your device
# Look for logs tagged with:
# - AndroidAutoManager
# - CarPlayManager
# - CarScoreboardController
```

**Key log messages to look for:**

1. **Initialization**:
   ```
   [AndroidAutoManager] AndroidAutoManager initialized, adding listener
   [CarScoreboardController] CarScoreboardController initialized
   ```

2. **Scoreboard updates**:
   ```
   [CarScoreboardController] Rebuilding snapshot: session=ABC123, entries=2
   [AndroidAutoManager] Pushing snapshot: session=ABC123, entries=2
   [AndroidAutoManager] Successfully pushed snapshot (1 total)
   ```

3. **Errors to watch for**:
   ```
   [AndroidAutoManager] MethodChannel not available - Android Auto not connected
   [AndroidAutoManager] Platform error pushing to Android Auto: ...
   ```

### Android/Kotlin Logs

Use `adb logcat` to view Android logs:

```bash
adb logcat | findstr "MainActivity RoadTripCarScreen ScoreboardRepository"
```

**Key log messages to look for:**

1. **MethodChannel setup**:
   ```
   I/MainActivity: Configuring Flutter engine - setting up Android Auto MethodChannel
   I/MainActivity: MethodChannel setup complete
   ```

2. **Receiving updates**:
   ```
   I/MainActivity: MethodChannel received call: updateScoreboard
   I/MainActivity: updateScoreboard: session=ABC123, updatedAt=..., entriesCount=2
   I/MainActivity: Updating ScoreboardRepository with ...
   ```

3. **Android Auto screen**:
   ```
   I/RoadTripCarScreen: Screen created with initial snapshot=...
   I/RoadTripCarScreen: Received snapshot update: ...
   I/RoadTripCarScreen: Building scoreboard template
   ```

## Common Issues and Solutions

### Issue 1: "MethodChannel not available"

**Symptom**: Logs show `MissingPluginException` or "MethodChannel not available"

**Cause**: This is **normal** when Android Auto is not connected. The MethodChannel only exists when the Android app is running.

**Solution**: This is expected behavior. The logs will show success once you:
1. Connect to DHU or real Android Auto
2. Launch the app on Android Auto

### Issue 2: Android Auto screen shows "Waiting for game"

**Symptom**: Screen loads but shows "Waiting for game" even when a game is active

**Possible causes**:
1. **No active session**: Make sure you've created or joined a game session
2. **Scores not being updated**: Check `GameScoreBoard` widget logs
3. **Link session not active**: Verify LinkController has an active session

**Debug steps**:
```
1. Check CarScoreboardController logs:
   [CarScoreboardController] Rebuilding snapshot: session=null

2. If session is null, check LinkController
3. If session exists, check if scores are being updated:
   [CarScoreboardController] CarScoreboardController updating scores: 2 entries
```

### Issue 3: Screen not appearing in DHU

**Symptom**: App runs but doesn't appear in Android Auto DHU

**Possible causes**:
1. **Developer mode not enabled** on phone
2. **App not registered** for Android Auto
3. **Service not declared** in manifest

**Debug steps**:
```bash
# Check if service is running
adb shell dumpsys activity services | findstr RoadTripCarAppService

# Check Android Auto apps list
adb shell dumpsys car_service | findstr road_trip
```

**Solution**: Verify these are in `AndroidManifest.xml`:
- ✅ `<uses-feature android:name="android.software.car.mode"` (line 6-7)
- ✅ `<service android:name=".car.RoadTripCarAppService"` (line 49-62)
- ✅ Proper intent filters and metadata

### Issue 4: Updates not appearing in Android Auto

**Symptom**: Flutter app shows updates but Android Auto screen doesn't refresh

**Debug steps**:
1. Check if Flutter is pushing updates:
   ```
   [AndroidAutoManager] Successfully pushed snapshot (X total)
   ```

2. Check if Android is receiving updates:
   ```
   I/MainActivity: updateScoreboard: session=ABC123, entriesCount=2
   I/ScoreboardRepository: update called with ...
   ```

3. Check if screen is listening for updates:
   ```
   I/RoadTripCarScreen: Received snapshot update: ...
   ```

If step 1 succeeds but step 2 fails:
- **MethodChannel issue**: Check channel name matches exactly: `road_trip_car/android_auto`

If step 2 succeeds but step 3 fails:
- **Repository flow issue**: Check `ScoreboardRepository.kt` and `RoadTripCarScreen.kt`

### Issue 5: Build errors

**Symptom**: Gradle build fails or Kotlin compilation errors

**Solutions**:
1. Check Gradle dependencies in `android/app/build.gradle`:
   ```gradle
   implementation "androidx.car.app:app:1.4.0"
   implementation "androidx.car.app:app-projected:1.4.0"
   ```

2. Sync Gradle:
   ```bash
   cd android
   gradlew clean
   gradlew build
   ```

3. Check Kotlin version compatibility in `build.gradle`

## Testing Checklist

Use this checklist to verify your Android Auto implementation:

### Pre-Testing
- [ ] Developer mode enabled on Android device
- [ ] USB debugging enabled
- [ ] DHU installed and running (or real car connected)
- [ ] App builds without errors

### Initial Connection
- [ ] App appears in Android Auto launcher
- [ ] Tapping app opens RoadTripCarScreen
- [ ] Screen shows "Waiting for game"
- [ ] Logs show: `[AndroidAutoManager] AndroidAutoManager initialized`

### During Game
- [ ] Create/join a game session on phone
- [ ] Android Auto screen updates to show session code
- [ ] Player names appear in the list
- [ ] Logs show: `[AndroidAutoManager] Successfully pushed snapshot`
- [ ] Logs show: `I/MainActivity: updateScoreboard: session=...`

### Score Updates
- [ ] Increment a score in the game
- [ ] Android Auto screen reflects the new score
- [ ] Multiple updates work correctly
- [ ] Logs show continuous successful pushes

### Disconnection
- [ ] Disconnect from Android Auto
- [ ] App continues to work on phone
- [ ] Logs show: `[AndroidAutoManager] MethodChannel not available` (expected)
- [ ] Reconnect to Android Auto
- [ ] Screen updates with current state

## Advanced Debugging

### Enable Verbose Logging

To see even more detailed logs:

1. **Flutter**:
   ```bash
   flutter run --verbose
   ```

2. **Android**:
   ```bash
   adb logcat *:V  # Verbose mode
   ```

### Filter Specific Components

```bash
# Only car-related logs
adb logcat | findstr /C:"MainActivity" /C:"RoadTripCar" /C:"Scoreboard"

# Only errors
adb logcat *:E

# Specific tag
adb logcat -s RoadTripCarScreen
```

### Inspect MethodChannel Communication

Add a breakpoint in `MainActivity.kt` at line 22 to inspect incoming MethodChannel calls.

### Check Android Auto Service State

```bash
# Check if CarAppService is bound
adb shell dumpsys activity services com.example.road_trip_game

# Check Android Auto host state
adb shell dumpsys car_service
```

## Performance Monitoring

Monitor the number of pushes to ensure efficiency:

```
[AndroidAutoManager] AndroidAutoManager disposing (pushes: 15 success, 0 failed)
```

**Expected behavior**:
- 1 push on initialization
- 1 push per score update
- 1 push per session change
- 0 or very few failures (failures are normal if not connected to Android Auto)

**Red flags**:
- Hundreds of pushes in a short time (indicates update loop)
- High failure rate when connected (indicates communication issue)

## Getting Help

If you're still experiencing issues:

1. **Collect logs**:
   ```bash
   flutter run > flutter_output.txt 2>&1
   adb logcat > android_logs.txt
   ```

2. **Document the issue**:
   - What you expected to happen
   - What actually happened
   - Complete logs from both Flutter and Android
   - Steps to reproduce

3. **Check configuration**:
   - Verify all files match the expected structure
   - Ensure dependencies are up to date
   - Test on a different device/emulator

## Configuration Reference

### Required Files

| File | Purpose | Status |
|------|---------|--------|
| `lib/services/car/android_auto_manager.dart` | Flutter MethodChannel client | ✅ |
| `lib/services/car/car_scoreboard.dart` | Scoreboard state management | ✅ |
| `android/app/src/main/kotlin/.../MainActivity.kt` | MethodChannel handler | ✅ |
| `android/app/src/main/kotlin/.../car/RoadTripCarAppService.kt` | Android Auto service | ✅ |
| `android/app/src/main/kotlin/.../car/RoadTripCarScreen.kt` | Android Auto UI | ✅ |
| `android/app/src/main/kotlin/.../car/ScoreboardRepository.kt` | State repository | ✅ |
| `android/app/src/main/res/xml/automotive_app_desc.xml` | Auto app descriptor | ✅ |
| `AndroidManifest.xml` | Service declaration | ✅ |

### Key Configuration Values

| Setting | Value | Location |
|---------|-------|----------|
| MethodChannel name | `road_trip_car/android_auto` | MainActivity.kt, AndroidAutoManager.dart |
| Min Car API Level | `1` | car_app_config.xml |
| Service category | `androidx.car.app.category.GENERAL` | AndroidManifest.xml |
| Car app dependency | `androidx.car.app:app:1.4.0` | build.gradle |

---

**Last Updated**: 2025
**Version**: 1.0
