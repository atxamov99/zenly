# Phase 2A: Joylashuv + Xarita — Dizayn Spetsifikatsiyasi

## Maqsad

Foydalanuvchi real-time joylashuvini backendga yuboradi va do'stlarining joylashuvini xaritada ko'radi. Ilova background da ham ishlaydi.

## Arxitektura

```
Telefon (GPS)
    ↓ har 10 soniya
LocationService (Foreground Service)
    ↓ HTTP POST /api/location/update
Backend (Node.js)
    ↓ Socket.IO emit → friend:location_changed
Do'stlar telefonlari
    ↓ SocketService tinglaydi
Flutter UI (MapScreen) yangilanadi
```

## Texnologiyalar

| Komponent | Paket |
|-----------|-------|
| Xarita | `flutter_map` + `latlong2` |
| GPS | `geolocator` (allaqachon bor) |
| Background service | `flutter_foreground_task` |
| Real-time | `socket_io_client` (allaqachon bor) |
| Xarita tiles | OpenStreetMap (bepul, API key shart emas) |

## Yangi fayllar

| Fayl | Vazifa |
|------|--------|
| `lib/services/location_service.dart` | GPS stream + har 10s backendga yuborish |
| `lib/services/socket_service.dart` | Socket.IO ulanish, event tinglash, qayta ulanish |
| `lib/data/datasources/remote/api_location_datasource.dart` | location API so'rovlari |
| `lib/domain/entities/friend_location_entity.dart` | Do'st joylashuv modeli |
| `lib/presentation/screens/map/map_screen.dart` | flutter_map + markerlar |
| `lib/presentation/providers/location_provider.dart` | O'z joylashuv + do'stlar joylashuvi state |
| `lib/presentation/providers/socket_provider.dart` | Socket ulanish state |

## Xarita ekrani

### Ko'rinish
- To'liq ekran `flutter_map` (OpenStreetMap tiles)
- O'z marker: avatar + pulse animatsiya
- Do'st markerlari: avatar + ism

### Do'st kartochkasi (markerga bosganda)
Pastdan chiquvchi bottom sheet:
```
┌─────────────────────────────┐
│  [Avatar]  Abdulaziz        │
│           🏠 Uyda           │
│           🔋 83%            │
│           2 daqiqa oldin    │
└─────────────────────────────┘
```

### Tugmalar
- 📍 "Menga qayt" — o'z joylashuvga zoom
- 👁 Ghost mode holati ko'rsatuvchi icon (bosganda Settings ga yo'naltiradi)

### Navigatsiya (BottomNavigationBar)
- 🗺️ Xarita (joriy)
- 👥 Do'stlar (Phase 2B)
- 👤 Profil (Phase 2B)

## LocationService

- `geolocator` paketi GPS stream'dan koordinat oladi
- Interval: **10 soniya**
- `flutter_foreground_task` bilan Android Foreground Service
- Bildirishnoma: "Blink joylashuvingizni foydalanmoqda"
- Ilova yopilganda ham ishlaydi

## SocketService

- Ilova ochilganda JWT token bilan `socket_io_client` ulanadi
- Tinglash: `friend:location_changed`, `friend:presence_changed`, `friend:smart_status_changed`
- Internet uzilsa avtomatik qayta ulanadi (`reconnection: true`)
- `socket:ready` eventida ulanish tasdiqlangan deb hisoblanadi

## Backend API (allaqachon tayyor)

| Endpoint | Vazifa |
|----------|--------|
| `POST /api/location/update` | GPS koordinat yuborish |
| `GET /api/location/visible-friends` | Do'stlar joylashuvini olish |
| `POST /api/location/share/:friendId` | Do'st bilan ulashishni yoqish |
| `DELETE /api/location/share/:friendId` | Ulashishni o'chirish |

## Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Do'st joylashuv entity

```dart
class FriendLocationEntity {
  final String friendId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final double lat;
  final double lng;
  final bool isOnline;
  final String smartStatus; // idle, home, traveling, offline
  final int? batteryPercent;
  final DateTime? lastSeenAt;
}
```

## Xatolarni boshqarish

- GPS ruxsat berilmasa → `PermissionDeniedException` — foydalanuvchiga so'rov
- GPS o'chirilgan bo'lsa → bildirishnoma ko'rsatish
- Backend ulanmasa → xarita bo'sh, do'stlar ko'rinmaydi (silent fail)
- Socket uzilsa → avtomatik qayta ulanish (exponential backoff)

## Keyingi bosqichlar (Phase 2B, 2C)

- Do'stlar tizimi (friend.routes.js allaqachon bor)
- Ghost mode toggle xaritada
- Geozone (joy belgisi)
- Battery holati yuborish
