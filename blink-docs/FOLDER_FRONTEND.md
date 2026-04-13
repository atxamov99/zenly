# 📁 Frontend Papka Tuzilmasi

**Blink** ilovasining faqat frontend (presentation) qismiga tegishli papka tuzilmasi.

---

## 🗂 To'liq Tuzilma

```
lib/
│
├── main.dart                         # Ilova kirish nuqtasi
│
├── core/                             # Umumiy yordamchilar
│   ├── constants/
│   │   ├── app_colors.dart           # Barcha ranglar
│   │   ├── app_strings.dart          # UI matnlar
│   │   └── app_sizes.dart            # Padding, radius, o'lchamlar
│   │
│   ├── router/
│   │   └── app_router.dart           # GoRouter navigatsiya
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData bosh fayl
│   │   ├── light_theme.dart          # Light mavzu
│   │   └── dark_theme.dart           # Dark mavzu
│   │
│   └── utils/
│       ├── date_utils.dart           # "2 daqiqa oldin" formatlash
│       ├── location_utils.dart       # Koordinat yordamchilari
│       └── validators.dart           # Form validatsiya
│
├── presentation/
│   │
│   ├── providers/                    # Riverpod ViewModellar
│   │   ├── auth_provider.dart
│   │   ├── location_provider.dart
│   │   ├── friends_provider.dart
│   │   ├── map_provider.dart
│   │   └── ghost_mode_provider.dart
│   │
│   ├── screens/
│   │   │
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   │
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── otp_screen.dart
│   │   │   └── register_screen.dart
│   │   │
│   │   ├── profile_setup/
│   │   │   └── profile_setup_screen.dart
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart      # Bottom nav wrapper
│   │   │
│   │   ├── map/
│   │   │   ├── map_screen.dart
│   │   │   └── widgets/
│   │   │       ├── friend_marker.dart
│   │   │       └── friend_bottom_sheet.dart
│   │   │
│   │   ├── friends/
│   │   │   ├── friends_screen.dart
│   │   │   └── widgets/
│   │   │       └── friend_list_tile.dart
│   │   │
│   │   ├── notifications/
│   │   │   └── notifications_screen.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   │
│   │   └── settings/
│   │       └── settings_screen.dart
│   │
│   └── widgets/                      # Umumiy qayta ishlatiladigan widgetlar
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── avatar_widget.dart
│       ├── battery_indicator.dart
│       └── loading_overlay.dart
│
├── services/                         # Qurilma servislari
│   ├── location_service.dart         # Background GPS logic
│   ├── notification_service.dart     # FCM xabarlari
│   ├── battery_service.dart          # Batareya so'rovi
│   └── geocoding_service.dart        # Manzil aniqlash
│
└── assets/
    ├── images/                       # Rasm va illustratsiyalar
    ├── icons/                        # Custom iconlar
    ├── fonts/
    │   └── Inter/                    # Inter shrift fayllari
    └── map_styles/
        ├── dark_map.json
        └── light_map.json
```

---

## 📦 pubspec.yaml — Frontend Paketlari

```yaml
dependencies:
  # State management
  flutter_riverpod: ^2.4.0

  # Navigatsiya
  go_router: ^12.0.0

  # Xarita
  google_maps_flutter: ^2.5.0
  google_maps_cluster_manager: ^3.0.0

  # Joylashuv
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  background_locator_2: latest
  permission_handler: ^11.1.0

  # Rasmlar
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4

  # Batareya
  battery_plus: ^4.0.0

  # Lokal kesh
  hive_flutter: ^1.1.0

  # Bildirishnomalar
  firebase_messaging: ^14.7.0
  flutter_local_notifications: latest

  # Scheduled ghost uchun
  workmanager: latest
```

---

## 📋 Har Bir Faylning Vazifasi

### `core/` papkasi

| Fayl | Vazifa |
|------|--------|
| `app_colors.dart` | Barcha HEX ranglarni bir joyda saqlash |
| `app_strings.dart` | UI matnlar (lokalizatsiya tayyorligi uchun) |
| `app_sizes.dart` | Padding, radius, o'lchamlar konstantalari |
| `app_router.dart` | Barcha sahifalar va yo'naltirishlar |
| `app_theme.dart` | Light va Dark ThemeData'larni birlashtiradi |
| `date_utils.dart` | Timestamp → "2 daqiqa oldin" formatiga o'girish |
| `location_utils.dart` | Koordinat hisoblash, masofa |
| `validators.dart` | Telefon, email, username validatsiyasi |

### `presentation/providers/` papkasi

| Fayl | Boshqaradigan holat |
|------|---------------------|
| `auth_provider.dart` | Kirish/chiqish holati |
| `location_provider.dart` | Mening joylashuvim |
| `friends_provider.dart` | Do'stlar ro'yxati, so'rovlar |
| `map_provider.dart` | Xarita markerlari, kamera |
| `ghost_mode_provider.dart` | Ghost mode holati |

### `presentation/screens/` papkasi

| Papka | Ekranlar |
|-------|----------|
| `splash/` | Boshlang'ich ekran |
| `onboarding/` | Tanishuv ekrani |
| `auth/` | Login, OTP, Register |
| `profile_setup/` | Profil to'ldirish |
| `home/` | Bottom nav wrapper |
| `map/` | Asosiy xarita ekrani |
| `friends/` | Do'stlar ro'yxati |
| `notifications/` | Bildirishnomalar |
| `profile/` | Profil va tahrirlash |
| `settings/` | Sozlamalar |

### `services/` papkasi

| Fayl | Vazifa |
|------|--------|
| `location_service.dart` | GPS oqimini boshqarish, Firestore'ga yuklash |
| `notification_service.dart` | FCM xabarlarini qabul qilish va ko'rsatish |
| `battery_service.dart` | Batareya darajasini olish va yuklash |
| `geocoding_service.dart` | Koordinat → Manzil aylantirish |
