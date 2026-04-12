# Performance

Optimization strategies to keep **Blink** fast, battery-efficient, and cost-effective.

---

## 📍 Location Updates — Battery Efficiency

The single biggest battery drain is continuous GPS. Use adaptive strategies:

### Distance Filter
Only write to Firestore if the user has moved more than a threshold:
```dart
Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.balanced,  // not "high" unless needed
    distanceFilter: 10,  // only trigger if moved 10+ meters
  ),
).listen((position) {
  _onNewPosition(position);
});
```

### Debouncing Writes
Prevent flooding Firestore with writes every second:
```dart
Timer? _debounceTimer;

void _onNewPosition(Position pos) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(seconds: 10), () {
    _writeLocationToFirestore(pos);
  });
}
```

### Background Mode Battery Strategy

| App State | Location Accuracy | Update Interval |
|-----------|------------------|-----------------|
| Foreground | High (GPS) | 10 seconds |
| Background | Balanced | 30 seconds |
| Screen off 5+ min | Low power | 60 seconds |
| Ghost mode | None | Paused |

---

## 🔥 Firestore Read Optimization

### Use Field-Level Updates
```dart
// ❌ Don't: overwrites the entire document (expensive)
await docRef.set(fullUserData);

// ✅ Do: only updates changed fields
await docRef.update({'batteryPercent': 72, 'isCharging': false});
```

### Enable Offline Persistence
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```
This caches Firestore data locally — app loads instantly even with no internet.

### Limit Query Results
```dart
// Always paginate or limit notification/history queries
.collection('notifications').doc(uid).collection('items')
.orderBy('createdAt', descending: true)
.limit(30)  // don't load 1000 notifications
```

### Avoid N+1 Reads
```dart
// ❌ Don't: fetch each friend's profile one by one
for (final uid in friendUids) {
  final doc = await firestore.collection('users').doc(uid).get();
}

// ✅ Do: batch fetch with whereIn (max 10 per query)
await firestore.collection('users')
  .where(FieldPath.documentId, whereIn: friendUids.take(10).toList())
  .get();
```

---

## 🗺️ Map Performance

### Custom Marker Caching
Avoid re-rendering custom markers on every rebuild. Cache `BitmapDescriptor`:
```dart
final Map<String, BitmapDescriptor> _markerCache = {};

Future<BitmapDescriptor> _getMarker(String uid, String avatarUrl) async {
  if (_markerCache.containsKey(uid)) return _markerCache[uid]!;
  final marker = await _createCustomMarker(avatarUrl);
  _markerCache[uid] = marker;
  return marker;
}
```

### Marker Clustering
Use `google_maps_cluster_manager` for dense friend groups:
```dart
ClusterManager(
  items: friendMarkers,
  updateMarkers: (markers) => setState(() => _markers = markers),
  markerBuilder: _buildClusterMarker,
);
```

### Minimize setState Calls
Use `Riverpod` to rebuild only the marker layer, not the whole map:
```dart
// Only markers widget rebuilds, not the entire GoogleMap
Consumer(
  builder: (context, ref, _) {
    final locations = ref.watch(friendsLocationsProvider).value ?? [];
    return _buildMarkerSet(locations);
  },
)
```

---

## 📱 Flutter UI Performance

### Use `const` Constructors
```dart
// ✅ Prevents unnecessary rebuilds
const AppButton(label: 'Send Wave')
```

### ListView.builder for Long Lists
```dart
// ✅ Lazy rendering — only builds visible items
ListView.builder(
  itemCount: friends.length,
  itemBuilder: (context, index) => FriendListTile(friend: friends[index]),
)
```

### Image Caching
```dart
// Use cached_network_image to avoid re-downloading profile photos
CachedNetworkImage(
  imageUrl: user.photoUrl,
  placeholder: (_, __) => const CircleAvatar(child: Icon(Icons.person)),
  errorWidget: (_, __, ___) => const CircleAvatar(child: Icon(Icons.error)),
)
```

### Avoid Rebuilding Static Widgets
```dart
// Extract static widgets into const or separate classes
class _StaticMapOverlay extends StatelessWidget {
  const _StaticMapOverlay();
  @override Widget build(context) => ... // never rebuilds
}
```

---

## 🧹 Stream Management

Always cancel stream subscriptions to prevent memory leaks:
```dart
StreamSubscription? _locationSub;

@override
void initState() {
  super.initState();
  _locationSub = locationStream.listen(_handleLocation);
}

@override
void dispose() {
  _locationSub?.cancel(); // ✅ critical
  super.dispose();
}
```

With Riverpod `StreamProvider`, this is handled automatically when the provider is disposed.

---

## 📊 Performance Targets

| Metric | Target |
|--------|--------|
| Cold start time | < 2 seconds |
| Map marker update latency | < 500ms |
| Firestore read (cached) | < 50ms |
| Firestore write (location) | < 300ms |
| Battery drain per hour | < 3% |
| App memory usage | < 150MB |
