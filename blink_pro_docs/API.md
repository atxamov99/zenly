# APIs

All external APIs and Firebase services used in **Blink**.

---

## 🔥 Firebase Services

### Firebase Authentication
- **Purpose:** User sign-in and identity management
- **Methods used:** Phone (OTP), Email/Password, Google Sign-In
- **SDK:** `firebase_auth`
- **Key methods:**
  ```dart
  FirebaseAuth.instance.verifyPhoneNumber(...)
  FirebaseAuth.instance.signInWithCredential(...)
  FirebaseAuth.instance.authStateChanges()
  ```

---

### Cloud Firestore
- **Purpose:** Primary database — user profiles, locations, friendships
- **SDK:** `cloud_firestore`
- **Mode:** Real-time streams via `.snapshots()`
- **Key operations:**
  ```dart
  // Write location
  firestore.collection('locations').doc(uid).set(data)

  // Watch friends' locations
  firestore.collection('locations').doc(friendUid).snapshots()

  // Query friend requests
  firestore.collection('friend_requests')
    .where('toUid', isEqualTo: uid)
    .where('status', isEqualTo: 'pending')
    .snapshots()
  ```

---

### Firebase Cloud Messaging (FCM)
- **Purpose:** Push notifications (friend requests, waves, alerts)
- **SDK:** `firebase_messaging`
- **Key setup:**
  ```dart
  FirebaseMessaging.onMessage.listen(...)           // foreground
  FirebaseMessaging.onMessageOpenedApp.listen(...)  // background tap
  FirebaseMessaging.instance.getToken()             // get FCM token
  ```
- **Token storage:** Saved to Firestore `users/{uid}.fcmToken`

---

### Firebase Storage
- **Purpose:** Profile photo uploads
- **SDK:** `firebase_storage`
- **Path convention:** `avatars/{uid}/profile.jpg`
- **Usage:**
  ```dart
  FirebaseStorage.instance.ref('avatars/$uid/profile.jpg').putFile(imageFile)
  ```

---

## 🗺️ Google Maps

### Google Maps Flutter Plugin
- **Package:** `google_maps_flutter`
- **Purpose:** Interactive map with friend markers, camera control
- **Required keys:**
  - Android: `AndroidManifest.xml` → `MAPS_API_KEY`
  - iOS: `AppDelegate.swift` → `GMSServices.provideAPIKey(...)`

- **Key features used:**
  ```dart
  GoogleMap(
    initialCameraPosition: CameraPosition(target: myLatLng, zoom: 14),
    markers: _markers,
    onCameraMove: _onCameraMove,
    myLocationEnabled: true,
    myLocationButtonEnabled: false,
  )
  ```

### Geocoding API (Reverse Geocoding)
- **Package:** `geocoding`
- **Purpose:** Convert GPS coordinates to readable address
- **Usage:**
  ```dart
  List<Placemark> places = await placemarkFromCoordinates(lat, lng);
  String address = '${places[0].street}, ${places[0].locality}';
  ```

---

## 📍 Geolocator (Device GPS)

- **Package:** `geolocator`
- **Purpose:** Get current device location
- **Usage:**
  ```dart
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Stream of location updates
  Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update only if moved 10m
    ),
  ).listen((Position pos) { ... });
  ```

---

## 🔋 Battery Plus

- **Package:** `battery_plus`
- **Purpose:** Get device battery level and charging status
- **Usage:**
  ```dart
  final battery = Battery();
  int level = await battery.batteryLevel;  // 0–100
  BatteryState state = await battery.batteryState; // charging / discharging
  ```

---

## 🔑 API Keys Setup

| Service | Location |
|---------|----------|
| Google Maps (Android) | `android/app/src/main/AndroidManifest.xml` |
| Google Maps (iOS) | `ios/Runner/AppDelegate.swift` |
| Firebase (Android) | `android/app/google-services.json` |
| Firebase (iOS) | `ios/Runner/GoogleService-Info.plist` |

> ⚠️ **Never commit API keys to Git.** Use `.gitignore` and environment files or CI/CD secrets.

---

## 🌐 API Rate Limits & Costs

| API | Free Tier | Cost beyond |
|-----|-----------|-------------|
| Google Maps (loads) | $200/month credit | $7/1000 loads |
| Geocoding | $200/month credit | $5/1000 requests |
| Firestore reads | 50K/day | $0.06/100K |
| Firestore writes | 20K/day | $0.18/100K |
| FCM | Free (unlimited) | Free |
