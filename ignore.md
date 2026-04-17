# Blink — Progress Tracker

Har bir fayl yakunlangandan so'ng shu yerga yoziladi.

---

## Phase 1: Foundation + Auth

### Yakunlangan fayllar

| Fayl | Holat |
|------|-------|
| `docs/superpowers/plans/2026-04-12-blink-phase1-auth.md` | ✅ Plan yozildi |
| `blink/pubspec.yaml` | ✅ Task 1 — barcha dependencies |
| `blink/lib/main.dart` | ✅ Task 13 — Firebase + Riverpod + GoRouter |
| `blink/assets/images/`, `icons/`, `map_styles/` | ✅ Task 1 — asset papkalar |
| `blink/lib/core/constants/app_colors.dart` | ✅ Task 3 |
| `blink/lib/core/constants/app_sizes.dart` | ✅ Task 3 |
| `blink/lib/core/constants/app_strings.dart` | ✅ Task 3 |
| `blink/lib/core/errors/exceptions.dart` | ✅ Task 3 |
| `blink/lib/core/errors/failures.dart` | ✅ Task 3 |
| `blink/lib/core/theme/app_theme.dart` | ✅ Task 3 |
| `blink/lib/domain/entities/user_entity.dart` | ✅ Task 4 |
| `blink/lib/domain/repositories/auth_repository.dart` | ✅ Task 4 |
| `blink/lib/domain/repositories/user_repository.dart` | ✅ Task 4 |
| `blink/test/unit/domain/user_entity_test.dart` | ✅ Task 4 |
| `blink/lib/domain/usecases/auth/verify_phone_usecase.dart` | ✅ Task 5 |
| `blink/lib/domain/usecases/auth/verify_otp_usecase.dart` | ✅ Task 5 |
| `blink/lib/domain/usecases/auth/sign_in_email_usecase.dart` | ✅ Task 5 |
| `blink/lib/domain/usecases/auth/sign_in_google_usecase.dart` | ✅ Task 5 |
| `blink/lib/domain/usecases/auth/sign_out_usecase.dart` | ✅ Task 5 |
| `blink/lib/domain/usecases/user/create_user_profile_usecase.dart` | ✅ Task 5 |
| `blink/test/unit/domain/usecases/verify_otp_usecase_test.dart` | ✅ Task 5 |
| `blink/lib/data/models/user_model.dart` | ✅ Task 6 |
| `blink/lib/data/datasources/remote/firebase_auth_datasource.dart` | ✅ Task 6 |
| `blink/lib/data/datasources/remote/firestore_user_datasource.dart` | ✅ Task 6 |
| `blink/test/unit/data/models/user_model_test.dart` | ✅ Task 6 |
| `blink/lib/data/repositories/auth_repository_impl.dart` | ✅ Task 7 |
| `blink/lib/data/repositories/user_repository_impl.dart` | ✅ Task 7 |
| `blink/lib/presentation/providers/auth_provider.dart` | ✅ Task 7 |
| `blink/lib/presentation/providers/user_provider.dart` | ✅ Task 7 |
| `blink/lib/core/router/app_router.dart` | ✅ Task 8 |
| `blink/lib/presentation/widgets/app_button.dart` | ✅ Task 9 |
| `blink/lib/presentation/widgets/app_text_field.dart` | ✅ Task 9 |
| `blink/lib/presentation/screens/splash/splash_screen.dart` | ✅ Task 10 |
| `blink/lib/presentation/screens/onboarding/onboarding_screen.dart` | ✅ Task 10 |
| `blink/lib/presentation/screens/auth/login_screen.dart` | ✅ Task 11 |
| `blink/lib/presentation/screens/auth/otp_screen.dart` | ✅ Task 11 |
| `blink/lib/presentation/screens/auth/register_screen.dart` | ✅ Task 11 |
| `blink/lib/presentation/screens/profile_setup/profile_setup_screen.dart` | ✅ Task 12 |
| `blink/lib/presentation/screens/home/home_screen.dart` | ✅ Task 13 |

### Qolgan (manual) qadamlar
| Qadam | Holat |
|-------|-------|
| `flutterfire configure` ishlatib `firebase_options.dart` yaratish | ✅ Tugallandi |

---

## Phase 1.5: Backend Integration (Firebase → Custom Backend)

**Maqsad:** Firebase Auth + Firestore ni Node.js/Express/MongoDB backend bilan almashtirish.

**Backend:** `backend/` papkada, Node.js + Express + MongoDB + Socket.IO, port 4000.

**Nima o'zgaradi:**
- Firebase Auth o'chirilib, JWT (email+parol, Google Sign-In) ishlatiladi
- Firestore o'chirilib, REST API ishlatiladi
- Socket.IO real-time location uchun qo'shiladi
- `flutter_secure_storage` JWT tokenlarni saqlash uchun
- `google_sign_in` → backend `/api/auth/google` endpoint bilan ulash

### Yakunlangan fayllar
| Fayl | Holat |
|------|-------|
| `docs/superpowers/specs/2026-04-15-backend-integration-design.md` | ✅ Design doc |
| `docs/superpowers/plans/2026-04-15-blink-phase1.5-backend-integration.md` | ✅ Plan |
| `backend/src/routes/auth.routes.js` | ✅ Task 1 — `POST /api/auth/google` qo'shildi |
| `backend/package.json` | ✅ Task 1 — `google-auth-library` qo'shildi |
| `blink/pubspec.yaml` | ✅ Task 2 — Firebase o'chirildi, dio/secure_storage/socket qo'shildi |
| `blink/lib/core/constants/api_constants.dart` | ✅ Task 3 — backend URL'lar |
| `blink/lib/data/datasources/local/token_storage.dart` | ✅ Task 4 — JWT secure storage |
| `blink/lib/data/datasources/remote/api_client.dart` | ✅ Task 5 — Dio + refresh interceptor |
| `blink/lib/data/models/user_model.dart` | ✅ Task 6 — `fromApi` factory, Firestore o'chdi |
| `blink/lib/domain/repositories/auth_repository.dart` | ✅ Task 7 — phone OTP olib tashlandi |
| `blink/lib/domain/usecases/auth/sign_in_email_usecase.dart` | ✅ Task 8 — RegisterUseCase yangilandi |
| `blink/lib/data/datasources/remote/api_auth_datasource.dart` | ✅ Task 9 — yangi datasource |
| `blink/lib/data/datasources/remote/api_user_datasource.dart` | ✅ Task 10 — profile/avatar |
| `blink/lib/data/repositories/auth_repository_impl.dart` | ✅ Task 11 — API datasource |
| `blink/lib/data/repositories/user_repository_impl.dart` | ✅ Task 12 — API datasource |
| `blink/lib/presentation/providers/auth_provider.dart` | ✅ Task 13 — AsyncNotifier + API providers |
| `blink/lib/presentation/providers/user_provider.dart` | ✅ Task 14 — FutureProvider |
| `blink/lib/core/router/app_router.dart` | ✅ Task 15 — `/otp` o'chdi |
| `blink/lib/presentation/screens/auth/login_screen.dart` | ✅ Task 16 — email + Google |
| `blink/lib/presentation/screens/auth/register_screen.dart` | ✅ Task 17 — username + displayName |
| `blink/lib/presentation/screens/profile_setup/profile_setup_screen.dart` | ✅ Task 18 — ApiUserDatasource |
| `blink/lib/main.dart` | ✅ Task 19 — Firebase init o'chdi |
| **O'chirilgan fayllar** | ✅ Task 20 |
| `firebase_options.dart`, `firebase_auth_datasource.dart`, `firestore_user_datasource.dart` | 🗑️ |
| `otp_screen.dart`, `verify_phone_usecase.dart`, `verify_otp_usecase.dart` | 🗑️ |
| `verify_otp_usecase_test.dart`, `widget_test.dart` | 🗑️ |
| **`flutter analyze`** | ✅ Task 21 — No issues found |

---

## Phase 2A: Location + Map

**Maqsad:** GPS background ga ham ishlaydigan foreground service orqali har 10s da backendga yuboradi, OpenStreetMap xaritasida o'z + do'stlar joylashuvini real-time ko'rsatadi.

**Texnologiyalar:** `flutter_map` (OpenStreetMap, bepul), `flutter_foreground_task` 8.x, `geolocator`, `socket_io_client`.

### Yakunlangan fayllar
| Fayl | Holat |
|------|-------|
| `docs/superpowers/specs/2026-04-16-phase2a-location-map-design.md` | ✅ Spec |
| `docs/superpowers/plans/2026-04-16-phase2a-location-map.md` | ✅ Plan |
| `blink/pubspec.yaml` | ✅ Task 1 — flutter_map, latlong2, foreground_task |
| `blink/lib/core/constants/api_constants.dart` | ✅ Task 2 — location endpointlar |
| `blink/lib/domain/entities/friend_location_entity.dart` | ✅ Task 3 |
| `blink/lib/data/datasources/local/token_storage.dart` | ✅ Task 4 — SharedPrefs mirror |
| `blink/lib/data/datasources/remote/api_location_datasource.dart` | ✅ Task 5 |
| `blink/lib/services/location_task_handler.dart` | ✅ Task 6 — background isolate |
| `blink/lib/services/location_service.dart` | ✅ Task 7 — foreground service control |
| `blink/lib/services/socket_service.dart` | ✅ Task 8 |
| `blink/lib/presentation/providers/socket_provider.dart` | ✅ Task 9 |
| `blink/lib/presentation/providers/location_provider.dart` | ✅ Task 9 |
| `blink/android/app/src/main/AndroidManifest.xml` | ✅ Task 10 — permissions + service |
| `blink/lib/main.dart` | ✅ Task 11 — WithForegroundTask |
| `blink/lib/presentation/screens/map/widgets/friend_location_sheet.dart` | ✅ Task 12 |
| `blink/lib/presentation/screens/map/map_screen.dart` | ✅ Task 13 |
| `blink/lib/core/router/app_router.dart` | ✅ Task 14 — `/map` route |
| **`flutter analyze`** | ✅ Task 15 — No issues found |

### Manual test (foydalanuvchi bajaradi)
- [ ] `flutter run` — build muvaffaqiyatli
- [ ] Login → `/map` ekran ochiladi
- [ ] Permissions so'raladi (FINE + BACKGROUND + Notifications)
- [ ] OpenStreetMap tiles yuklanadi
- [ ] O'z marker (ko'k aylana) ko'rinadi
- [ ] Foreground notifikatsiya paydo bo'ladi
- [ ] Backend logida har 10s da `POST /location/update 200`
- [ ] App background da ham backend log davom etadi

## Phase 2B: Friends

**Maqsad:** 3 tab MainShell (Map/Friends/Profile), do'stlar qidirish/qabul/blok, QR ulashish, Profile + Ghost Mode, real-time `notification:new` socket banner.

**Texnologiyalar:** `qr_flutter` (display), `mobile_scanner` (scan), Riverpod AsyncNotifier'lar.

### Yakunlangan fayllar
| Fayl | Holat |
|------|-------|
| `docs/superpowers/specs/2026-04-17-phase2b-friends-design.md` | ✅ Spec |
| `docs/superpowers/plans/2026-04-17-phase2b-friends.md` | ✅ Plan |
| `blink/pubspec.yaml` | ✅ Task 1 — qr_flutter, mobile_scanner |
| `blink/lib/core/constants/api_constants.dart` | ✅ Task 2 — friends/blocks/profile-privacy |
| `blink/lib/domain/entities/friend_entity.dart` | ✅ Task 3 |
| `blink/lib/domain/entities/friend_request_entity.dart` | ✅ Task 4 |
| `blink/lib/data/datasources/remote/api_friends_datasource.dart` | ✅ Task 5 |
| `blink/lib/data/datasources/remote/api_block_datasource.dart` | ✅ Task 6 |
| `blink/lib/data/datasources/remote/api_profile_datasource.dart` | ✅ Task 7 |
| `blink/lib/data/datasources/local/token_storage.dart` | ✅ Task 8 — ghost mode flag |
| `blink/lib/services/location_task_handler.dart` | ✅ Task 9 — ghost mode skip |
| `blink/lib/services/socket_service.dart` | ✅ Task 10 — notification:new |
| `blink/lib/presentation/providers/friends_provider.dart` | ✅ Task 11 |
| `blink/lib/presentation/providers/profile_provider.dart` | ✅ Task 12 |
| `blink/lib/presentation/screens/friends/widgets/friend_tile.dart` | ✅ Task 13 |
| `blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart` | ✅ Task 14 |
| `blink/lib/presentation/screens/friends/widgets/requests_tab.dart` | ✅ Task 15 |
| `blink/lib/presentation/screens/friends/widgets/qr_show_dialog.dart` | ✅ Task 16 |
| `blink/lib/presentation/screens/friends/widgets/qr_scan_screen.dart` | ✅ Task 17 |
| `blink/lib/presentation/screens/friends/widgets/add_friend_tab.dart` | ✅ Task 18 |
| `blink/lib/presentation/screens/friends/friends_screen.dart` | ✅ Task 19 |
| `blink/lib/presentation/screens/profile/profile_screen.dart` | ✅ Task 20 |
| `blink/lib/presentation/widgets/in_app_banner.dart` | ✅ Task 21 |
| `blink/lib/presentation/screens/main/main_shell.dart` | ✅ Task 22 |
| `blink/lib/core/router/app_router.dart` | ✅ Task 23 — `/main` route |
| `blink/android/app/src/main/AndroidManifest.xml` | ✅ Task 24 — CAMERA permission |
| **`flutter analyze`** | ✅ Task 25 — No issues found |

### Manual test (foydalanuvchi bajaradi)
- [ ] Login → `/main` ekran (3 tab) ochiladi
- [ ] Friends tab → "Qo'shish" → username yozish → search natijalari
- [ ] "+" bosish → so'rov yuboriladi
- [ ] Boshqa user → kelgan so'rovni qabul qilish → do'st bo'ladi
- [ ] Long-press do'st → menu (Joylashuv / Unfriend / Block)
- [ ] QR ko'rsatish → boshqa user skanerlasa → so'rov keladi
- [ ] Profile tab → Ghost Mode ON → 10s da yana location yubormaydi
- [ ] Real-time: friend so'rov yuborsa → in-app banner + Friends tab badge

## Phase 2C: Battery + Privacy

**Phase 2B'da bajarilgan:** Profile ekran, Ghost Mode toggle.

**Qoldi:**
- 🔋 Batareya ulashish toggle (`battery_plus` paket bilan, do'stlarga foizni ko'rsatish/yashirish)
- 🔒 Maxfiylik (location visibility: `precise` / `approximate` / `friends` / `none`)
- Per-friend ghost list (`ghostFromList` — ma'lum do'stga ko'rinmaslik)

_Hali boshlanmadi_

## Phase 3: Notifications + Geozones
_Hali boshlanmadi_
