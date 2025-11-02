# Firebase Setup Guide

This guide will help you set up Firebase Realtime Database for multiplayer game sessions.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `road-trip-game` (or any name you like)
4. Disable Google Analytics (optional, not needed for this app)
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the Android icon to add an Android app
2. **Android package name**: `com.example.roadtripgame`
   - This MUST match the package name in your app
   - Find it in: `android/app/build.gradle` under `applicationId`
3. **App nickname**: Road Trip Game (Android)
4. Leave SHA-1 blank for now (not needed for Realtime Database)
5. Click "Register app"
6. **Download `google-services.json`**
   - This file is critical!
   - Save it to: `android/app/google-services.json`
7. Skip the SDK setup steps (we already added dependencies)
8. Click "Continue to console"

## Step 3: Add iOS App to Firebase (If using iOS)

1. In Firebase Console, click the iOS icon to add an iOS app
2. **iOS bundle ID**: `com.example.roadtripgame`
   - Must match the bundle identifier in your iOS app
   - Find it in Xcode or `ios/Runner.xcodeproj/project.pbxproj`
3. **App nickname**: Road Trip Game (iOS)
4. Leave App Store ID blank
5. Click "Register app"
6. **Download `GoogleService-Info.plist`**
   - Save it to: `ios/Runner/GoogleService-Info.plist`
7. Skip the SDK setup steps
8. Click "Continue to console"

## Step 4: Enable Realtime Database

1. In Firebase Console, click "Realtime Database" in the left menu (under "Build")
2. Click "Create Database"
3. **Location**: Choose closest to your region (e.g., us-central1, europe-west1)
4. **Security rules**: Start in **test mode** (we'll secure it later)
   - Click "Enable"

### Important: Update Security Rules

After enabling the database, update the security rules:

1. Click on the "Rules" tab in Realtime Database
2. Replace the rules with:

```json
{
  "rules": {
    "sessions": {
      "$sessionId": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

3. Click "Publish"

**Note**: These rules allow anyone to read/write sessions. For production, you should add authentication and more restrictive rules.

## Step 5: Get Your Database URL

1. In the Realtime Database page, find your database URL
2. It looks like: `https://road-trip-game-xxxxx-default-rtdb.firebaseio.com/`
3. Copy this URL - you'll need it later

## Step 6: Configure the App

### For Android:

1. Make sure `google-services.json` is in `android/app/`
2. That's it! The app will automatically use it.

### For iOS:

1. Make sure `GoogleService-Info.plist` is in `ios/Runner/`
2. Open the iOS project in Xcode
3. Drag `GoogleService-Info.plist` into the project (Runner folder)
4. Make sure "Copy items if needed" is checked
5. Make sure it's added to the Runner target

## Step 7: Test the Setup

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app on your device/emulator
4. Try creating a game session
5. Check Firebase Console → Realtime Database → Data tab
6. You should see a "sessions" node with your test data!

## Troubleshooting

### "FirebaseException: No Firebase App has been created"
- Make sure `Firebase.initializeApp()` is called in `main.dart` before running the app
- Make sure you ran `flutter pub get` after adding firebase dependencies

### Android: "google-services.json not found"
- Verify the file is at `android/app/google-services.json`
- Run `flutter clean` and rebuild

### iOS: "GoogleService-Info.plist not found"
- Verify the file is in `ios/Runner/GoogleService-Info.plist`
- Make sure it's added to the Xcode project
- Clean build folder in Xcode (Product → Clean Build Folder)

### "Permission denied" errors
- Check that your Realtime Database security rules allow read/write
- Make sure you're in test mode or have proper authentication

## Cost & Limits

### Free Tier (Spark Plan):
- ✅ 1 GB stored data
- ✅ 10 GB/month downloaded
- ✅ 100 simultaneous connections
- ✅ **FREE FOREVER**

For a family of 4-5 people, you'll never hit these limits!

### Upgrading to Paid (If Needed):
- Only charged for what you use beyond free tier
- $5/GB stored per month
- $1/GB downloaded
- No minimum fees

---

**You're all set!** 🎉

The app will now sync game scores in real-time across all connected devices.
