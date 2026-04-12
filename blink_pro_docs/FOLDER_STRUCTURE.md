# Folder Structure

Complete project folder tree for **Blink** following Clean Architecture principles.

---

## 📁 Full Structure

```
blink/
├── android/                    # Android native configs
│   ├── app/
│   │   ├── google-services.json
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
│
├── ios/                        # iOS native configs
│   ├── Runner/
│   │   ├── GoogleService-Info.plist
│   │   └── Info.plist
│   └── Podfile
│
├── assets/
│   ├── images/                 # App images & illustrations
│   ├── icons/                  # Custom icons
│   └── fonts/                  # Custom fonts (e.g. Inter)
│
├── lib/
│   ├── main.dart               # App entry point
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_sizes.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── router/
│   │   │   └── app_router.dart       # GoRouter or AutoRoute
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       ├── location_utils.dart
│   │       └── validators.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user_entity.dart
│   │   │   ├── location_entity.dart
│   │   │   └── friendship_entity.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart        # Abstract
│   │   │   ├── user_repository.dart        # Abstract
│   │   │   ├── location_repository.dart    # Abstract
│   │   │   └── friend_repository.dart      # Abstract
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── sign_in_usecase.dart
│   │       │   ├── sign_out_usecase.dart
│   │       │   └── get_current_user_usecase.dart
│   │       ├── location/
│   │       │   ├── update_location_usecase.dart
│   │       │   ├── get_friends_locations_usecase.dart
│   │       │   └── toggle_ghost_mode_usecase.dart
│   │       └── friends/
│   │           ├── send_friend_request_usecase.dart
│   │           ├── accept_friend_request_usecase.dart
│   │           └── get_friends_usecase.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── location_model.dart
│   │   │   └── friendship_model.dart
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── firebase_auth_datasource.dart
│   │   │   │   ├── firestore_user_datasource.dart
│   │   │   │   ├── firestore_location_datasource.dart
│   │   │   │   └── firestore_friend_datasource.dart
│   │   │   └── local/
│   │   │       └── hive_cache_datasource.dart
│   │   └── repositories/
│   │       ├── auth_repository_impl.dart
│   │       ├── user_repository_impl.dart
│   │       ├── location_repository_impl.dart
│   │       └── friend_repository_impl.dart
│   │
│   ├── presentation/
│   │   ├── providers/              # Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── location_provider.dart
│   │   │   ├── friends_provider.dart
│   │   │   └── map_provider.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── otp_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── profile_setup/
│   │   │   │   └── profile_setup_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart       # Bottom nav wrapper
│   │   │   ├── map/
│   │   │   │   ├── map_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── friend_marker.dart
│   │   │   │       └── friend_bottom_sheet.dart
│   │   │   ├── friends/
│   │   │   │   ├── friends_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── friend_list_tile.dart
│   │   │   ├── notifications/
│   │   │   │   └── notifications_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── edit_profile_screen.dart
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── widgets/                # Shared reusable widgets
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── avatar_widget.dart
│   │       ├── battery_indicator.dart
│   │       └── loading_overlay.dart
│   │
│   └── services/
│       ├── location_service.dart       # Background GPS logic
│       ├── notification_service.dart   # FCM handler
│       ├── battery_service.dart        # Battery % polling
│       └── geocoding_service.dart      # Address lookup
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

---

## 📦 Key Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_messaging: ^14.7.0
  firebase_storage: ^11.5.0
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  battery_plus: ^4.0.0
  go_router: ^12.0.0
  hive_flutter: ^1.1.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  permission_handler: ^11.1.0
```
