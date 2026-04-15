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
| — | — |

### Qolgan fayllar
| Fayl | Holat |
|------|-------|
| Design doc yozish | ⏳ |
| Implementation plan yozish | ⏳ |
| Backend: `POST /api/auth/google` endpoint | ⏳ |
| Flutter: datasources, repositories, providers yangilash | ⏳ |
| Flutter: pubspec.yaml (firebase o'chirish, http/socket qo'shish) | ⏳ |

---

## Phase 2: Location + Map
_Hali boshlanmadi_

## Phase 3: Friends + Notifications
_Hali boshlanmadi_

## Phase 4: Ghost Mode + Battery + Settings
_Hali boshlanmadi_
