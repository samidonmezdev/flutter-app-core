# app_core

A comprehensive Flutter SDK that consolidates all essential app services — Ads, In-App Purchases, Analytics, Push Notifications, Version Management, Rate Dialog, and Support — into a single, unified package.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Initial Setup](#initial-setup)
  - [Firebase Setup](#firebase-setup)
  - [Android Setup](#android-setup)
  - [iOS Setup](#ios-setup)
- [Bootstrap](#bootstrap)
- [Services](#services)
  - [Ads — AdMob](#ads--admob)
  - [IAP — Adapty](#iap--adapty)
  - [Analytics — Firebase](#analytics--firebase)
  - [Push — FCM](#push--fcm)
  - [Version Check](#version-check)
  - [Rate Dialog](#rate-dialog)
  - [Support & Privacy](#support--privacy)
- [Event Bus](#event-bus)
- [Custom Implementations](#custom-implementations)
- [Full Example](#full-example)
- [Roadmap](#roadmap)

---

## Features

| Service | Provider | Capabilities |
|---|---|---|
| Ads | Google AdMob | Interstitial, Rewarded, Banner |
| IAP | Adapty | Purchase, Restore, Premium stream |
| Analytics | Firebase Analytics | Events, User ID, User properties |
| Push | Firebase Cloud Messaging | Token, Topics, Foreground messages |
| Version | package_info_plus | Force update, Store redirect |
| Rate | in_app_review | Native review dialog, launch tracking |
| Support | url_launcher | Email, Privacy Policy, Terms of Service |
| Event Bus | Dart Streams | Cross-service communication |

---

## Architecture

```
lib/
├── app_core.dart                  ← single import entry point
│
├── core/
│   ├── app_core.dart              ← AppCore static facade
│   ├── app_config.dart            ← configuration model
│   └── event_bus.dart             ← stream-based event bus
│
├── services/                      ← abstract interfaces
│   ├── ads/ads_service.dart
│   ├── iap/iap_service.dart
│   ├── analytics/analytics_service.dart
│   ├── push/push_service.dart
│   ├── version/version_service.dart
│   ├── rate/rate_service.dart
│   └── support/support_service.dart
│
└── implementations/               ← concrete implementations
    ├── admob/admob_ads_service.dart
    ├── adapty/adapty_iap_service.dart
    ├── firebase/firebase_analytics_service.dart
    ├── fcm/fcm_push_service.dart
    ├── version/default_version_service.dart
    ├── rate/default_rate_service.dart
    └── support/default_support_service.dart
```

Every service is behind an abstract interface. You can swap out any implementation without touching the rest of your app.

---

## Installation

Add `app_core` to your project's `pubspec.yaml`:

```yaml
dependencies:
  app_core:
    git:
      url: https://github.com/cytechnoware/app_core.git
      ref: v0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Initial Setup

### Firebase Setup

`app_core` uses Firebase Analytics and Firebase Cloud Messaging. You must configure Firebase in your app before calling `AppCore.bootstrap()`.

1. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

2. Initialize Firebase in `main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     // then call AppCore.bootstrap(...)
   }
   ```

### Android Setup

**AdMob** — Add your App ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
  </application>
</manifest>
```

**FCM** — Add the `google-services.json` file (downloaded from Firebase Console) to `android/app/`.

**url_launcher** — Add intent queries to `AndroidManifest.xml`:

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
  </intent>
</queries>
```

### iOS Setup

**AdMob** — Add your App ID to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

**FCM** — Add `GoogleService-Info.plist` (downloaded from Firebase Console) to `ios/Runner/`.

**Push Notifications** — Enable capabilities in Xcode:
- `Push Notifications`
- `Background Modes → Remote notifications`

**url_launcher** — Add to `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>mailto</string>
</array>
```

---

## Bootstrap

Call `AppCore.bootstrap()` once, as early as possible in your app — before `runApp()`.

All services are **optional**. Only provide the ones you actually use.

```dart
import 'package:app_core/app_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler before bootstrap
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await AppCore.bootstrap(AppConfig(
    privacyUrl: 'https://example.com/privacy',
    termsUrl: 'https://example.com/terms',
    supportEmail: 'support@example.com',

    ads: AdMobAdsService(
      interstitialAdUnitId: 'ca-app-pub-xxx/interstitial_id',
      rewardedAdUnitId: 'ca-app-pub-xxx/rewarded_id',
      bannerAdUnitId: 'ca-app-pub-xxx/banner_id',
    ),

    iap: AdaptyIAPService(
      adaptyApiKey: 'YOUR_ADAPTY_PUBLIC_KEY',
    ),

    analytics: FirebaseAnalyticsService(),

    push: FCMPushService(),

    version: DefaultVersionService(
      androidPackageId: 'com.example.app',
      iosAppId: '123456789',
      minimumVersion: '1.2.0', // users below this will see force update
    ),

    rate: DefaultRateService(
      minLaunchCount: 5,
      minDaysSinceInstall: 7,
    ),

    support: DefaultSupportService(
      supportEmail: 'support@example.com',
      privacyUrl: 'https://example.com/privacy',
      termsUrl: 'https://example.com/terms',
    ),
  ));

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Handle background FCM messages here
}
```

---

## Services

### Ads — AdMob

```dart
// Show an interstitial ad
await AppCore.ads.showInterstitial();

// Show a rewarded ad with a completion callback
await AppCore.ads.showRewarded(
  onRewarded: () {
    // Grant the user their reward
    grantExtraLives();
  },
);

// Load a banner ad (use AdMobAdsService.bannerAd to attach it to a widget)
await AppCore.ads.showBanner();
final bannerAd = (AppCore.ads as AdMobAdsService).bannerAd;

// Clean up when done
AppCore.ads.dispose();
```

> **Tip:** Ads are loaded automatically during `init()`. After each show, the next ad is pre-fetched in the background so it's ready for the next call.

**Test Ad Unit IDs (use during development):**

| Format | Android | iOS |
|---|---|---|
| Banner | `ca-app-pub-3940256099942544/6300978111` | `ca-app-pub-3940256099942544/2934735716` |
| Interstitial | `ca-app-pub-3940256099942544/1033173712` | `ca-app-pub-3940256099942544/4411468910` |
| Rewarded | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-3940256099942544/1712485313` |

---

### IAP — Adapty

```dart
// Trigger a purchase (use the Adapty Placement ID)
await AppCore.iap.purchase('premium_monthly');

// Restore previous purchases
await AppCore.iap.restore();

// Check premium status synchronously
if (AppCore.iap.isPremium()) {
  unlockPremiumFeatures();
}

// React to premium status changes in real time
AppCore.iap.premiumStream.listen((isPremium) {
  setState(() => _isPremium = isPremium);
});
```

> **Setup:** Create a placement in your [Adapty dashboard](https://app.adapty.io), then pass its ID to `purchase()`.

---

### Analytics — Firebase

```dart
// Log a custom event
AppCore.analytics.logEvent('level_complete', params: {
  'level': 5,
  'score': 1200,
});

// Set a persistent user ID (call after login)
AppCore.analytics.setUserId('user_abc123');

// Set a custom user property
AppCore.analytics.setUserProperty('plan', 'premium');
```

**Using the Analytics Navigator Observer:**

```dart
final analyticsService = AppCore.analytics as FirebaseAnalyticsService;

MaterialApp(
  navigatorObservers: [analyticsService.observer],
  // ...
);
```

---

### Push — FCM

```dart
// Get the device FCM token (send this to your backend)
final token = await AppCore.push.getToken();
print('FCM Token: $token');

// Subscribe to a topic
await AppCore.push.subscribe('breaking_news');

// Unsubscribe from a topic
await AppCore.push.unsubscribe('breaking_news');

// Listen to foreground messages
AppCore.push.onMessage.listen((message) {
  final title = message['title'];
  final body = message['body'];
  final data = message['data'];
  showLocalNotification(title: title, body: body);
});
```

> **Note:** Background and terminated-state messages require a top-level `@pragma('vm:entry-point')` handler registered before `bootstrap()`. See the [Bootstrap](#bootstrap) section above.

---

### Version Check

```dart
// Check if the current version is below the configured minimumVersion
if (await AppCore.version.isUpdateRequired()) {
  // Show a force-update dialog, then redirect to store
  showForceUpdateDialog(
    onConfirm: () => AppCore.version.openStore(),
  );
}

// Check if any update is available (optional, non-blocking)
if (await AppCore.version.isUpdateAvailable()) {
  showSoftUpdateBanner();
}

// Get the store URL manually
final url = AppCore.version.getStoreUrl();
```

---

### Rate Dialog

```dart
// In main() or your app init — increment every launch
AppCore.rate.incrementLaunchCount();

// After a positive user action (e.g., completing a level, finishing a task)
if (await AppCore.rate.shouldShowRateDialog()) {
  await AppCore.rate.showRateDialog();
}
```

`shouldShowRateDialog()` returns `true` only when:
- The user has launched the app at least `minLaunchCount` times
- At least `minDaysSinceInstall` days have passed since first launch
- The user has not already rated

---

### Support & Privacy

```dart
// Open the support email client
await AppCore.support.openSupport();

// Send a pre-filled email
await AppCore.support.sendEmail(
  subject: 'Bug Report — v1.2.0',
  body: 'Describe your issue here...',
);

// Open privacy policy in the browser
await AppCore.support.openPrivacyPolicy();

// Open terms of service in the browser
await AppCore.support.openTermsOfService();
```

---

## Event Bus

The built-in event bus lets services and UI components communicate without direct coupling.

```dart
// Emit an event from anywhere
AppCore.events.emit('purchase_success', data: {'productId': 'premium_monthly'});

// Listen to an event
final subscription = AppCore.events.on('purchase_success', (data) {
  final productId = data['productId'];
  // Disable ads, unlock content, log analytics
  AppCore.analytics.logEvent('purchase', params: {'product': productId});
});

// Cancel the subscription when no longer needed
subscription.cancel();
```

**Recommended event names:**

| Event | When to emit |
|---|---|
| `purchase_success` | After a successful IAP |
| `purchase_restored` | After restore completes |
| `ad_rewarded` | After rewarded ad completes |
| `ad_closed` | After any ad is dismissed |
| `push_received` | On foreground push message |
| `rate_dialog_shown` | When the rate dialog appears |

---

## Custom Implementations

Every service is an abstract class. You can provide your own implementation by extending the interface and passing it to `AppConfig`.

**Example — Custom Analytics (Mixpanel):**

```dart
class MixpanelAnalyticsService implements AnalyticsService {
  @override
  Future<void> init() async {
    await Mixpanel.init('YOUR_TOKEN', trackAutomaticEvents: true);
  }

  @override
  void logEvent(String name, {Map<String, dynamic>? params}) {
    Mixpanel.getInstance('YOUR_TOKEN').track(name, properties: params);
  }

  @override
  void setUserId(String userId) {
    Mixpanel.getInstance('YOUR_TOKEN').identify(userId);
  }

  @override
  void setUserProperty(String name, String value) {
    Mixpanel.getInstance('YOUR_TOKEN').getPeople().set(name, value);
  }
}
```

Pass it in `AppConfig`:

```dart
await AppCore.bootstrap(AppConfig(
  analytics: MixpanelAnalyticsService(),
  // ...
));
```

---

## Full Example

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  await AppCore.bootstrap(AppConfig(
    privacyUrl: 'https://example.com/privacy',
    supportEmail: 'hello@example.com',
    ads: AdMobAdsService(
      interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
      rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',
      bannerAdUnitId: 'ca-app-pub-3940256099942544/6300978111',
    ),
    iap: AdaptyIAPService(adaptyApiKey: 'YOUR_ADAPTY_KEY'),
    analytics: FirebaseAnalyticsService(),
    push: FCMPushService(),
    version: DefaultVersionService(
      androidPackageId: 'com.example.app',
      iosAppId: '123456789',
      minimumVersion: '1.0.0',
    ),
    rate: DefaultRateService(minLaunchCount: 3, minDaysSinceInstall: 3),
    support: DefaultSupportService(
      supportEmail: 'hello@example.com',
      privacyUrl: 'https://example.com/privacy',
    ),
  ));

  // Cross-service logic: disable ads when user goes premium
  AppCore.events.on('purchase_success', (_) {
    AppCore.analytics.logEvent('premium_activated');
  });

  // Increment launch count for rate dialog tracking
  AppCore.rate.incrementLaunchCount();

  // Force update check
  if (await AppCore.version.isUpdateRequired()) {
    // Handle force update in your UI
  }

  runApp(const MyApp());
}
```

---

## Roadmap

- [ ] Remote Config (Firebase) integration
- [ ] Deep link / routing helper for push notification taps
- [ ] Secure storage helper (flutter_secure_storage)
- [ ] Offline-first analytics queue
- [ ] GrowthManager: cross-service orchestration (premium → disable ads → log analytics)
- [ ] pub.dev public release (interface-only layer)

---

## License

MIT © cytechnoware
