# Location Tracking

**Blink** uses device GPS to track user location in both foreground and background, then broadcasts updates to Firestore in real-time.

---

## 📦 Packages Used

| Package | Purpose |
|---------|---------|
| `geolocator` | Foreground location + stream |
| `background_locator_2` | Background tracking when app is closed |
| `geocoding` | Reverse geocoding (coordinates → address) |
| `permission_handler` | Request location permissions |

---

## 🔑 Permissions

### Android — `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

### iOS — `Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Blink needs your location to show your position to friends.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Blink needs background location to update friends even when the app is closed.</string>
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>
```

---

## 🔐 Permission Request Flow

```dart
Future<bool> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    // Show dialog → open app settings
    await Geolocator.openAppSettings();
    return false;
  }

  // For background location (Android 10+)
  final bgStatus = await Permission.locationAlways.request();
  return bgStatus.isGranted;
}
```

---

## 📍 Foreground Location Stream

```dart
class LocationService {
  StreamSubscription<Position>? _subscription;

  void startTracking(String uid) {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,  // update only if moved 10+ meters
    );

    _subscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position position) {
      _uploadLocation(uid, position);
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _uploadLocation(String uid, Position pos) async {
    // Reverse geocode
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final address = placemarks.isNotEmpty
        ? '${placemarks[0].street}, ${placemarks[0].locality}'
        : '';

    await FirebaseFirestore.instance.collection('locations').doc(uid).set({
      'uid': uid,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'accuracy': pos.accuracy,
      'altitude': pos.altitude,
      'speed': pos.speed,
      'heading': pos.heading,
      'address': address,
      'city': placemarks.isNotEmpty ? placemarks[0].locality : '',
      'country': placemarks.isNotEmpty ? placemarks[0].country : '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
```

---

## 🌙 Background Location Tracking

Using `background_locator_2` to track location even when app is in background or closed.

### Setup

```dart
// In main.dart — initialize background locator
await BackgroundLocator.initialize();

// Check if already running
bool isRunning = await BackgroundLocator.isServiceRunning();
```

### Start background tracking

```dart
BackgroundLocator.registerLocationUpdate(
  LocationCallbackHandler.callback,
  initCallback: LocationCallbackHandler.initCallback,
  disposeCallback: LocationCallbackHandler.disposeCallback,
  iosSettings: IOSSettings(
    accuracy: LocationAccuracy.Navigation,
    distanceFilter: 15,
    stopWithTerminate: false,
  ),
  autoStop: false,
  androidSettings: AndroidSettings(
    accuracy: LocationAccuracy.Navigation,
    interval: 5,             // seconds
    distanceFilter: 15,      // meters
    androidNotificationSettings: AndroidNotificationSettings(
      notificationChannelName: 'Location tracking',
      notificationTitle: 'Blink is running',
      notificationMsg: 'Sharing your location with friends',
      notificationBigMsg: 'Blink is tracking your location in the background',
      notificationIcon: '',
      notificationIconColor: Colors.blue,
      notificationTapCallback: LocationCallbackHandler.notificationCallback,
    ),
  ),
);
```

### Callback handler (top-level function)

```dart
class LocationCallbackHandler {
  static void initCallback(Map<dynamic, dynamic> params) {
    // Called when background service starts
  }

  static void disposeCallback() {
    // Called when background service stops
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    // This runs in an isolate — cannot access app state
    // Use shared_preferences or direct Firebase call
    final uid = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('uid') ?? '');

    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('locations').doc(uid).update({
        'latitude': locationDto.latitude,
        'longitude': locationDto.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static void notificationCallback() {
    // Tap on background notification → open app
  }
}
```

---

## 📏 Location Accuracy Modes

| Mode | Accuracy | Battery Use | When to Use |
|------|----------|-------------|-------------|
| `LocationAccuracy.high` | ~3–5m | High | Foreground |
| `LocationAccuracy.balanced` | ~30m | Medium | Background |
| `LocationAccuracy.low` | ~1km | Low | Ghost mode off, long idle |
| `LocationAccuracy.lowest` | ~3km | Minimal | Approximate sharing mode |

---

## 🔄 Location Sharing Modes

Users can choose from three modes in settings:

| Mode | What friends see |
|------|-----------------|
| `precise` | Exact coordinates |
| `approximate` | Coordinates rounded to ~1km |
| `off` | Location hidden (same as ghost mode) |

```dart
LatLng approximateLocation(double lat, double lng) {
  // Round to 2 decimal places ≈ ~1.1km accuracy
  return LatLng(
    (lat * 100).round() / 100,
    (lng * 100).round() / 100,
  );
}
```
