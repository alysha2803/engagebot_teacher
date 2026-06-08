// Firebase project configuration for EngageBot.
//
// IMPORTANT — before running on a real device you must complete two steps:
//   1. Register the Android and iOS apps in the Firebase Console
//      (Project Settings → Your apps → Add app).
//   2. Replace every REPLACE_WITH_* placeholder below with the real App IDs
//      from the downloaded google-services.json / GoogleService-Info.plist.
//
// The fastest way is to run `flutterfire configure` from the project root,
// which auto-generates this file and places the config files for you.
//
// The shared values (API key, project ID, sender ID) are already filled in
// from the project the admin team set up.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => web,
    };
  }

  // ── Shared values (same for all platforms) ──────────────────────────────
  static const _apiKey = 'AIzaSyB8U5lFFPnkTptF5_yzhzHyD99eY-0DNdA';
  static const _androidApiKey = 'AIzaSyDUGFQxv_X3Rdf-TBZkz6jQi0v9cXfWcGs';
  static const _projectId = 'engagebot-498717';
  static const _storageBucket = 'engagebot-498717.firebasestorage.app';
  static const _senderId = '638539840267';

  // ── Web ─────────────────────────────────────────────────────────────────
  // App ID: find in Firebase Console → Project Settings → Web apps.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: 'engagebot-498717.firebaseapp.com',
    storageBucket: _storageBucket,
    measurementId: 'G-9H100MJCXC',
  );

  // ── Android ─────────────────────────────────────────────────────────────
  // 1. Register Android app in Firebase Console (use your app's package name).
  // 2. Download google-services.json → place in android/app/.
  // 3. Replace the appId below with the one from google-services.json
  //    (looks like  1:638539840267:android:XXXXXXXXXXXX).
  // 4. Add SHA-1 of your debug key to Firebase for Google Sign-In.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    appId: '1:638539840267:android:8bf90ec4919682097f400e',
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  // ── iOS ──────────────────────────────────────────────────────────────────
  // 1. Register iOS app in Firebase Console (use your app's bundle ID).
  // 2. Download GoogleService-Info.plist → place in ios/Runner/.
  // 3. Replace the appId + iosClientId below from that plist file.
  // 4. Add CFBundleURLSchemes to ios/Runner/Info.plist using the
  //    REVERSED_CLIENT_ID value from GoogleService-Info.plist.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: _senderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'com.engagebot.teacher',
  );
}
