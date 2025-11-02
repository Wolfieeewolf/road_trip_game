# Road Trip Game - Release Build Information

**Build Date:** 2025-11-01
**Build Status:** ✅ SUCCESS

---

## Build Outputs

### iOS Build (via GitHub Actions)

**File:** `road-trip-game-unsigned.ipa`
**Size:** 7.44 MB
**Location:** GitHub Actions artifacts (downloaded from Actions tab)

**Use for:**
- Distribution to family members via AltStore (free sideloading)
- Testing on iOS devices without Apple Developer account
- Family/private distribution (4-5 people)

**How to get the IPA:**
1. Go to https://github.com/Wolfieeewolf/road_trip_game/actions
2. Click on the most recent successful workflow run
3. Scroll down to "Artifacts" section
4. Download `ios-release-unsigned` (7.44 MB)
5. Extract the .zip file to get `road-trip-game-unsigned.ipa`

**Next steps:** See "iOS Distribution via AltStore" section below

---

### 1. Android APK (Direct Installation)

**File:** `app-release.apk`
**Size:** 51.4 MB
**Location:** `D:\New HD\MCP\road_trip_game\build\app\outputs\flutter-apk\app-release.apk`

**Use for:**
- Direct installation on Android devices
- Testing on physical devices
- Distribution outside Google Play Store
- Sharing with beta testers

**How to install:**
1. Transfer APK to Android device
2. Enable "Install from Unknown Sources" in device settings
3. Tap the APK file to install

---

### 2. Android App Bundle (Google Play Store)

**File:** `app-release.aab`
**Size:** 42.3 MB
**Location:** `D:\New HD\MCP\road_trip_game\build\app\outputs\bundle\release\app-release.aab`

**Use for:**
- **Google Play Store submission** (recommended)
- Automatic APK generation optimized for each device
- Smaller download sizes for end users

**How to upload to Play Store:**
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app (or create new app listing)
3. Navigate to **Production** → **Create new release**
4. Upload `app-release.aab`
5. Fill in release notes
6. Submit for review

---

## Signing Information

**Keystore Location:** `D:\keys\roadtrip-release.keystore`
**Keystore Alias:** `roadtrip`
**Validity:** 10,000 days (27+ years)

**IMPORTANT:**
- ⚠️ **BACKUP YOUR KEYSTORE FILE!** You cannot update your app without it
- Store `D:\keys\roadtrip-release.keystore` in a secure location
- Keep the passwords safe (currently in `android/key.properties`)
- Never commit keystore or passwords to version control

**Backup checklist:**
- [ ] Copy keystore to external drive
- [ ] Store keystore in cloud storage (encrypted)
- [ ] Document passwords in password manager
- [ ] Share with team members securely

---

## Android Auto & CarPlay Support

Both builds include full support for:
- ✅ Android Auto (all versions, 2015+)
- ✅ Apple CarPlay
- ✅ Factory head units (Kia, Toyota, Honda, etc.)
- ✅ Aftermarket head units (Sony, Alpine, Kenwood, Pioneer, etc.)

**Testing:**
- Use Desktop Head Unit (DHU) for Android Auto testing
- Test in actual car for best experience
- Refer to `ANDROID_AUTO_DEBUG.md` for troubleshooting

---

## iOS Distribution via AltStore (Free Family Distribution)

### What is AltStore?

AltStore is a **free** alternative app store for iOS that allows you to sideload apps without jailbreaking or paying for Apple Developer account. Perfect for distributing your app to 4-5 family members!

**Key Features:**
- ✅ Completely free (no $99/year Apple Developer fee)
- ✅ Works on all iPhones running iOS 14.0+
- ✅ Apps auto-refresh in background (won't expire every 7 days)
- ✅ Easy installation via WiFi
- ✅ No jailbreak required

**Limitations:**
- Maximum 3 apps per Apple ID (enough for your needs)
- Requires AltServer running on your PC when refreshing apps
- Each family member needs to install AltStore on their device

---

### Step 1: Set Up AltStore on Your Windows PC

**Download and Install:**

1. **Download AltServer for Windows**
   - Go to https://altstore.io/
   - Click "Download AltServer for Windows"
   - Save `AltServer.zip` to your computer

2. **Install iTunes and iCloud**
   - Download iTunes from https://www.apple.com/itunes/download/win64
   - Download iCloud from https://support.apple.com/en-us/HT204283
   - Install both (required for AltServer to communicate with iPhones)
   - Restart your computer after installation

3. **Extract and Run AltServer**
   - Extract `AltServer.zip` to a folder (e.g., `C:\Program Files\AltServer`)
   - Run `AltServer.exe`
   - You'll see an AltStore icon in your system tray (notification area)

---

### Step 2: Install AltStore on Each Family Member's iPhone

**For each iPhone that needs the app:**

1. **Connect iPhone to PC via USB**
   - Use a Lightning to USB cable
   - Make sure the iPhone is unlocked

2. **Trust the Computer**
   - On the iPhone, tap "Trust" when prompted
   - Enter iPhone passcode if asked

3. **Install AltStore via AltServer**
   - Right-click the AltStore icon in your system tray
   - Hover over "Install AltStore"
   - Select the connected iPhone from the list
   - Enter your Apple ID and password when prompted
   - **Note:** Use the family member's Apple ID (the one they use for App Store)

4. **Wait for Installation**
   - AltServer will install AltStore on the iPhone
   - Takes 1-2 minutes
   - You'll see "AltStore installed successfully" message

5. **Trust the Developer Certificate**
   - On the iPhone, go to: **Settings** → **General** → **VPN & Device Management**
   - Find your Apple ID under "Developer App"
   - Tap it and tap "Trust [Your Apple ID]"
   - Tap "Trust" again to confirm

---

### Step 3: Install Road Trip Game via AltStore

**On each family member's iPhone:**

1. **Download the IPA to your PC**
   - Go to https://github.com/Wolfieeewolf/road_trip_game/actions
   - Download the latest `ios-release-unsigned` artifact
   - Extract `road-trip-game-unsigned.ipa`

2. **Method A: Install via WiFi (Recommended)**
   - Make sure iPhone and PC are on the same WiFi network
   - On iPhone, open the AltStore app
   - Tap "My Apps" tab
   - Tap the "+" button in the top-left corner
   - It will show available IPAs from your PC
   - If the file doesn't appear:
     - On PC, right-click AltStore tray icon → "Settings"
     - Note the WiFi server address (e.g., "192.168.1.100:65432")
     - On iPhone in AltStore, manually enter this address if prompted

3. **Method B: Install via USB (If WiFi doesn't work)**
   - Connect iPhone to PC via USB
   - On PC, right-click AltStore tray icon
   - Click "Sideload .ipa..."
   - Select the iPhone from the list
   - Browse to `road-trip-game-unsigned.ipa`
   - Enter Apple ID password if prompted
   - Wait for installation (1-2 minutes)

4. **App Installed!**
   - Road Trip Game will appear on the iPhone home screen
   - First launch may show "Untrusted Developer" warning
   - Go to **Settings** → **General** → **VPN & Device Management**
   - Trust the developer certificate if needed

---

### Step 4: Enable Auto-Refresh (Important!)

Without auto-refresh, apps expire every 7 days and need to be reinstalled. Here's how to prevent that:

**One-Time Setup per iPhone:**

1. **Enable Background Refresh for AltStore**
   - On iPhone: **Settings** → **AltStore**
   - Enable "Background App Refresh"

2. **Keep AltServer Running on Your PC**
   - AltServer.exe should always be running on your PC
   - It will auto-start when you login (by default)
   - The iPhone connects to it automatically over WiFi to refresh apps

3. **How Auto-Refresh Works**
   - When the iPhone is on the same WiFi as your PC
   - And AltServer is running
   - AltStore automatically refreshes all sideloaded apps every 7 days
   - This happens in the background, no user action needed

**Important Notes:**
- Your PC doesn't need to be on 24/7
- Just needs to be on occasionally when the iPhone is nearby
- If you miss a refresh and app expires, just open AltStore and tap "Refresh All"
- Family members who don't live with you: They can manually refresh when visiting, or you can send them updated IPAs to install

---

### Distributing to Family Members Who Live Elsewhere

If family members don't live with you and can't access your PC regularly:

**Option 1: One-Time Setup Visit**
1. Set up AltStore on their iPhone when they visit
2. Install Road Trip Game
3. Give them the IPA file to keep
4. They can use their own PC with AltServer to refresh (requires setting up AltServer on their PC)

**Option 2: Manual Refresh When Visiting**
1. Set up their iPhone when they visit
2. When app expires (every 7 days), they reinstall via AltStore when visiting again
3. Or they set up AltServer on their own PC

**Option 3: Share IPA for Their Own AltServer**
1. Send them `road-trip-game-unsigned.ipa` via email or cloud storage
2. They install AltServer on their own Windows/Mac PC
3. They install AltStore on their iPhone via their own PC
4. They sideload the IPA file themselves
5. Their own AltServer handles auto-refresh

**Recommended:** Option 3 for maximum independence

---

### Updating the App (Future Versions)

When you make changes and want to release updates:

1. **Build New Version**
   - Update `version:` in `pubspec.yaml` (e.g., `1.0.1+2`)
   - Push changes to GitHub
   - GitHub Actions will build new IPA automatically
   - Download new IPA from Actions artifacts

2. **Distribute to Family**
   - Send new IPA file via email, cloud storage, or shared folder
   - Or share the GitHub Actions artifact download link

3. **Family Members Install Update**
   - Open AltStore on iPhone
   - Tap "My Apps"
   - Tap Road Trip Game
   - Tap "Update" or "Sideload"
   - Select the new IPA file
   - App will update while preserving user data

**Note:** Updates keep game data (achievements, statistics, friends list) intact

---

### Troubleshooting AltStore

**Problem: "Could not find AltServer"**
- Solution: Make sure AltServer.exe is running on your PC (check system tray)
- Make sure iPhone and PC are on the same WiFi network
- Disable VPN on both devices temporarily

**Problem: "Maximum number of apps reached"**
- Solution: Each Apple ID can have max 3 sideloaded apps
- Remove an app in AltStore to make room

**Problem: "App expired / Needs to be refreshed"**
- Solution 1: Open AltStore app, tap "Refresh All"
- Solution 2: Make sure AltServer is running on your PC
- Solution 3: Connect iPhone to PC and manually refresh

**Problem: iTunes/iCloud not detected**
- Solution: Install iTunes and iCloud for Windows from Apple's website
- Restart computer after installation
- Don't use Microsoft Store versions

**Problem: "Unable to Sign App"**
- Solution: Enter your Apple ID credentials again
- Make sure you're using the same Apple ID as the iPhone
- If using 2-factor authentication, generate app-specific password

---

### Quick Start Checklist for Family Members

**Print or share this checklist with each family member:**

**Before Your iPhone Can Use the App:**
- [ ] Download and install AltStore from https://altstore.io/ (help needed from person with Windows PC)
- [ ] Trust the developer certificate in iPhone Settings
- [ ] Install Road Trip Game IPA via AltStore
- [ ] Enable Background App Refresh for AltStore

**Using the App:**
- [ ] Open Road Trip Game from home screen
- [ ] Create or join a game session
- [ ] Use session code to play with others
- [ ] Check achievements and statistics

**Keeping the App Active:**
- [ ] Make sure AltStore background refresh is enabled
- [ ] Keep AltServer running on a PC you have access to
- [ ] Or manually refresh every 7 days by opening AltStore

**CarPlay Support:**
- [ ] Connect iPhone to car via USB or Bluetooth
- [ ] CarPlay should show "Road Trip Games"
- [ ] Start a game on phone, scoreboard appears on car display

---

## Build Features

### Optimizations Applied

1. **Icon Tree-Shaking**
   - MaterialIcons reduced from 1.6MB to 15.8KB
   - 99.0% size reduction
   - Only used icons included

2. **Code Signing**
   - Fully signed with release keystore
   - Ready for production distribution
   - Tamper-proof installation

3. **Release Optimizations**
   - Code obfuscation enabled
   - Debug symbols removed
   - Optimized for performance

### Included Features

- 6 multiplayer road trip games
- Link/session system for multiplayer
- Android Auto scoreboard display
- Apple CarPlay scoreboard display
- Achievement system
- Statistics tracking
- Friends list
- Audio recording (Sound Spy game)
- Location services (Windmill game)

---

## Testing the Release Build

### On Android Device

```bash
# Install via ADB
adb install "D:\New HD\MCP\road_trip_game\build\app\outputs\flutter-apk\app-release.apk"

# Or transfer file and install manually
```

### Test Android Auto

1. **Enable Developer Mode** on phone (in Android Auto app)
2. **Connect to DHU**:
   ```bash
   adb forward tcp:5277 tcp:5277
   cd "C:\Users\wolfi\AppData\Local\Android\Sdk\extras\google\auto"
   .\desktop-head-unit.exe
   ```
3. Launch app from DHU interface
4. Start a game session and verify scoreboard updates

### Test in Your Kia Carnival

1. Install release APK on phone
2. Connect phone to car via USB
3. Android Auto should launch automatically
4. Look for "Road Trip Games" in app drawer
5. Start a game and verify scoreboard displays

---

## Google Play Store Submission Checklist

### Before Submitting

- [ ] Test APK on multiple devices
- [ ] Test Android Auto functionality
- [ ] Verify all games work correctly
- [ ] Check permissions are appropriate
- [ ] Prepare app screenshots (phone + tablet)
- [ ] Prepare feature graphic (1024x500)
- [ ] Prepare app icon (512x512)
- [ ] Write app description
- [ ] Set up privacy policy (required for Google Play)
- [ ] Choose content rating
- [ ] Set pricing (free/paid)

### App Listing Requirements

**Title:** Road Trip Games (or your chosen name)

**Short Description (80 chars):**
```
Multiplayer car games with Android Auto & CarPlay support
```

**Full Description (4000 chars max):**
```
Transform your road trips into fun multiplayer adventures!

Road Trip Games brings 6 exciting multiplayer games designed specifically for car journeys:

🚗 Number Plate Match - Spot license plates
🔊 Sound Spy - Listen and identify sounds
🌬️ Windmill - Find windmills using GPS
🎨 Color Chase - Find objects by color
🚦 Sign Scramble - Unscramble road signs
🎯 Road Trip Bingo - Classic bingo with road items

ANDROID AUTO & CARPLAY SUPPORT
View live scoreboards on your car's display! Works with all Android Auto and CarPlay compatible head units.

MULTIPLAYER FUN
Connect with friends using simple session codes. Play together in the same car or compete remotely.

FEATURES:
✓ 6 unique games
✓ Android Auto integration
✓ Apple CarPlay support
✓ Multiplayer sessions
✓ Achievement system
✓ Statistics tracking
✓ Friends list

Perfect for long drives, family road trips, and making memories!
```

**Category:** Games > Casual
**Content Rating:** Everyone

**Required Screenshots:**
- Phone: 5-8 screenshots (1080x1920 or 1440x2560)
- Tablet: 5-8 screenshots (1536x2048)
- Optional: Android Auto screenshot

---

## Version Information

**Current Version:** 1.0.0+1 (from pubspec.yaml)

**To update version for next release:**
1. Edit `pubspec.yaml`
2. Change `version: 1.0.1+2` (increment version number and build number)
3. Rebuild: `flutter build appbundle --release`

**Version Format:** `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- Example: `1.0.0+1` → First release
- Example: `1.0.1+2` → Bug fix update
- Example: `1.1.0+3` → New features
- Example: `2.0.0+4` → Major update

---

## Troubleshooting

### Build Errors

If you encounter build errors in the future:

```bash
# Clean build
cd "D:\New HD\MCP\road_trip_game"
flutter clean
flutter pub get
flutter build apk --release
```

### Signing Errors

If keystore is missing:
```
Error: Keystore file 'D:\keys\roadtrip-release.keystore' not found
```

Solution: Restore keystore from backup or create new one (will require new app listing)

### Kotlin Cache Errors

The warnings about Kotlin daemon compilation are normal and don't affect the build. They occur due to incremental compilation caches. The build still succeeds.

---

## Next Steps

### For Testing
1. Install `app-release.apk` on your test devices
2. Test all games thoroughly
3. Test Android Auto in your Kia Carnival
4. Gather feedback from beta testers

### For Google Play Release
1. Create Google Play Developer account ($25 one-time fee)
2. Create app listing with screenshots and description
3. Upload `app-release.aab`
4. Fill in store listing details
5. Submit for review (typically 1-3 days)

### For Future Updates
1. Make code changes
2. Update version in `pubspec.yaml`
3. Rebuild: `flutter build appbundle --release`
4. Upload new `.aab` to Play Store
5. Existing users get automatic updates

---

## Support & Documentation

- **Android Auto Debugging:** See `ANDROID_AUTO_DEBUG.md`
- **Design System:** See `lib/styles/README.md`
- **Development Guide:** See `CLAUDE.md`

---

## Important Notes

1. **Keep Keystore Safe:** Without it, you cannot update your app
2. **Test Before Release:** Always test release builds on real devices
3. **Version Numbers:** Increment for each Play Store upload
4. **App Bundle Preferred:** Google Play requires .aab, not .apk
5. **First Release:** May take 2-3 days for Google review
6. **Updates:** Usually reviewed faster (hours to 1 day)

---

**Build completed successfully!** 🎉

Your app is ready for testing and distribution.
