# Google Maps Integration

**Blink** uses `google_maps_flutter` to display a live interactive map with friends' positions, custom markers, and smooth camera control.

---

## 📦 Setup

### Add dependency
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  google_maps_cluster_manager: ^3.0.0  # for marker clustering
```

### Android — `AndroidManifest.xml`
```xml
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="${MAPS_API_KEY}"/>
  </application>
</manifest>
```

### iOS — `AppDelegate.swift`
```swift
import GoogleMaps

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_MAPS_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 🗺️ Basic Map Widget

```dart
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(41.2995, 69.2401), // Tashkent default
    zoom: 13.0,
  ),
  markers: _markers,
  mapType: MapType.normal,
  myLocationEnabled: false,      // using custom marker instead
  myLocationButtonEnabled: false,
  zoomControlsEnabled: false,
  compassEnabled: false,
  onMapCreated: (controller) {
    _mapController = controller;
    _applyCustomMapStyle();  // dark/light style
  },
  onCameraMove: (position) {
    _currentZoom = position.zoom;
  },
)
```

---

## 🎨 Custom Map Style

Apply a custom JSON style to match the app's dark/light theme:

```dart
Future<void> _applyCustomMapStyle() async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final stylePath = isDark
      ? 'assets/map_styles/dark_map.json'
      : 'assets/map_styles/light_map.json';

  final style = await rootBundle.loadString(stylePath);
  _mapController?.setMapStyle(style);
}
```

---

## 👤 Custom Avatar Markers

Each friend appears as a circular avatar marker on the map:

```dart
Future<BitmapDescriptor> createAvatarMarker(String imageUrl) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  const double size = 100;

  // Draw circle background
  final paint = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

  // Load and draw network image
  final response = await http.get(Uri.parse(imageUrl));
  final codec = await ui.instantiateImageCodec(response.bodyBytes,
      targetWidth: size.toInt(), targetHeight: size.toInt());
  final frame = await codec.getNextFrame();
  final image = frame.image;

  // Clip to circle
  canvas.clipPath(Path()
    ..addOval(Rect.fromCircle(center: Offset(size / 2, size / 2), radius: size / 2 - 4)));
  canvas.drawImage(image, Offset.zero, Paint());

  // Draw border
  final borderPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}
```

---

## 📍 Building Markers Set

```dart
Set<Marker> _buildMarkers(List<LocationEntity> friendLocations) {
  final markers = <Marker>{};

  // My own marker
  if (_myLocation != null) {
    markers.add(Marker(
      markerId: const MarkerId('me'),
      position: _myLocation!,
      icon: _myAvatarMarker ?? BitmapDescriptor.defaultMarker,
      zIndex: 1.0,
      onTap: _onMyMarkerTap,
    ));
  }

  // Friends' markers
  for (final loc in friendLocations) {
    markers.add(Marker(
      markerId: MarkerId(loc.uid),
      position: LatLng(loc.latitude, loc.longitude),
      icon: _friendMarkers[loc.uid] ?? BitmapDescriptor.defaultMarker,
      onTap: () => _onFriendMarkerTap(loc.uid),
      infoWindow: InfoWindow(title: loc.displayName),
    ));
  }

  return markers;
}
```

---

## 🚀 Camera Control

### Animate to a friend's location
```dart
void moveCameraToFriend(LatLng target) {
  _mapController?.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 15.5),
    ),
  );
}
```

### Fit all friends in view
```dart
void fitAllFriends(List<LatLng> positions) {
  if (positions.isEmpty) return;

  final bounds = positions.fold<LatLngBounds>(
    LatLngBounds(southwest: positions.first, northeast: positions.first),
    (bounds, pos) => LatLngBounds(
      southwest: LatLng(
        min(bounds.southwest.latitude, pos.latitude),
        min(bounds.southwest.longitude, pos.longitude),
      ),
      northeast: LatLng(
        max(bounds.northeast.latitude, pos.latitude),
        max(bounds.northeast.longitude, pos.longitude),
      ),
    ),
  );

  _mapController?.animateCamera(
    CameraUpdate.newLatLngBounds(bounds, 80), // 80px padding
  );
}
```

---

## 🔵 Marker Clustering

When many friends are close together, cluster them:

```dart
late ClusterManager _clusterManager;

void _initClustering(List<FriendMarkerItem> items) {
  _clusterManager = ClusterManager<FriendMarkerItem>(
    items,
    _updateMarkers,
    markerBuilder: _buildClusterMarker,
  );
}

Future<Marker> _buildClusterMarker(Cluster<FriendMarkerItem> cluster) async {
  if (cluster.isMultiple) {
    // Show count badge
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      icon: await _createCountBadgeMarker(cluster.count),
    );
  }
  // Single friend marker
  return _buildSingleMarker(cluster.items.first);
}
```

---

## 🌙 Map Styles

Store custom map style JSONs in `assets/map_styles/`:

```
assets/
└── map_styles/
    ├── dark_map.json    # Dark theme (charcoal, muted colors)
    └── light_map.json   # Light theme (clean, minimal labels)
```

Get free custom styles from: [https://mapstyle.withgoogle.com](https://mapstyle.withgoogle.com)
