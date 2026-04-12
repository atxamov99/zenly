# Real-time System

**Blink** relies heavily on Firestore's real-time capabilities to keep all friends' locations, statuses, and battery levels in sync instantly.

---

## ⚡ How It Works

Firestore provides real-time listeners via `.snapshots()` which return a `Stream<DocumentSnapshot>` or `Stream<QuerySnapshot>`. These streams are consumed by Riverpod `StreamProvider`s and automatically rebuild the UI whenever data changes.

```
Firebase Firestore
      │
      │ (WebSocket / gRPC)
      ▼
Firestore SDK (cloud_firestore)
      │
      │ .snapshots() → Stream<DocumentSnapshot>
      ▼
Riverpod StreamProvider
      │
      │ ref.watch(...).when(...)
      ▼
Flutter Widget rebuilds
```

---

## 🗺️ Friends' Live Locations

### Stream: Watch all friends' location documents

```dart
Stream<List<LocationEntity>> watchFriendsLocations(String currentUid) async* {
  // Step 1: Get friend UIDs from friendships collection
  final friendsSnapshot = await FirebaseFirestore.instance
      .collection('friendships')
      .where('users', arrayContains: currentUid)
      .get();

  final friendUids = friendsSnapshot.docs
      .map((doc) => (doc['users'] as List).firstWhere((u) => u != currentUid))
      .cast<String>()
      .toList();

  if (friendUids.isEmpty) {
    yield [];
    return;
  }

  // Step 2: Stream each friend's location document
  // Merge multiple streams into one
  final locationStreams = friendUids.map((uid) =>
    FirebaseFirestore.instance.collection('locations').doc(uid).snapshots()
  );

  yield* Rx.combineLatestList(locationStreams).map((snapshots) =>
    snapshots
      .where((snap) => snap.exists)
      .map((snap) => LocationModel.fromFirestore(snap).toEntity())
      .toList()
  );
}
```

---

## 👤 Friend Online Status Stream

```dart
Stream<UserEntity> watchFriendStatus(String friendUid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(friendUid)
      .snapshots()
      .map((snap) => UserModel.fromFirestore(snap).toEntity());
}
```

---

## 📬 Friend Requests Stream

```dart
Stream<List<FriendRequestEntity>> watchIncomingRequests(String currentUid) {
  return FirebaseFirestore.instance
      .collection('friend_requests')
      .where('toUid', isEqualTo: currentUid)
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => FriendRequestModel.fromFirestore(doc).toEntity())
          .toList());
}
```

---

## 🔔 Notifications Stream

```dart
Stream<List<NotificationEntity>> watchNotifications(String uid) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .doc(uid)
      .collection('items')
      .where('isRead', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
          .toList());
}
```

---

## 🔋 Battery Status Update (Write)

Battery is updated on a timer (every 60 seconds):

```dart
Timer.periodic(const Duration(seconds: 60), (_) async {
  final level = await Battery().batteryLevel;
  final isCharging = await Battery().batteryState == BatteryState.charging;

  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'batteryPercent': level,
    'isCharging': isCharging,
  });
});
```

---

## 🌐 Online Presence System

### Mark user as online on app start

```dart
Future<void> setOnlineStatus(String uid, bool isOnline) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'isOnline': isOnline,
    'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
  });
}
```

### Auto-mark offline when app is closed

```dart
// In main.dart or app lifecycle observer:
AppLifecycleListener(
  onHide: () => setOnlineStatus(uid, false),
  onShow: () => setOnlineStatus(uid, true),
  onDetach: () => setOnlineStatus(uid, false),
);
```

---

## ⚡ Performance Considerations

| Strategy | Description |
|----------|-------------|
| **Field-level updates** | Use `update()` instead of `set()` — sends only changed fields |
| **Distance filter** | Only push GPS update to Firestore if moved > 10 meters |
| **Debounce writes** | Debounce location writes (max 1 write per 10 seconds) |
| **Stream cancellation** | Cancel Firestore listeners when screen is disposed |
| **Limit queries** | Always use `.limit(n)` on notification/history queries |
| **Cache** | Enable Firestore offline persistence for faster loads |

```dart
// Enable offline persistence (do this once at app startup)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 🔁 Riverpod Integration

```dart
// In providers/location_provider.dart

final friendsLocationsProvider = StreamProvider<List<LocationEntity>>((ref) {
  final uid = ref.watch(currentUidProvider)!;
  return ref.watch(locationRepositoryProvider).watchFriendsLocations(uid);
});

// In map_screen.dart
final locationsAsync = ref.watch(friendsLocationsProvider);

locationsAsync.when(
  data: (locations) => _buildMarkers(locations),
  loading: () => const CircularProgressIndicator(),
  error: (err, _) => Text('Error: $err'),
);
```
