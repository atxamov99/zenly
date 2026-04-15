# Design: Backend Integration (Firebase → Custom Backend)

**Date:** 2026-04-15  
**Phase:** 1.5  
**Approach:** B — Data layer replacement only

---

## Overview

Replace Firebase Auth + Firestore with a custom Node.js/Express/MongoDB backend.  
Domain layer (entities, use cases, repository interfaces) stays unchanged.  
Only the data layer and providers are updated.

**Backend base URL:** `http://localhost:4000/api`  
**Real-time:** Socket.IO at `http://localhost:4000`

---

## 1. Package Changes (`pubspec.yaml`)

### Remove
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`

### Add
- `dio: ^5.4.0` — HTTP client with interceptor support
- `flutter_secure_storage: ^9.0.0` — secure JWT token storage
- `socket_io_client: ^2.0.3` — real-time location

### Keep
- `firebase_core` — required by `firebase_messaging`
- `firebase_messaging` — push notifications (FCM)
- `google_sign_in` — get Google ID token for backend auth

---

## 2. New Files (Data Layer)

### `blink/lib/data/datasources/remote/api_client.dart`
- Dio instance configured with base URL
- `Authorization: Bearer <accessToken>` header on every request
- Interceptor: on 401, call `POST /api/auth/refresh`, retry original request
- On refresh failure: clear tokens, redirect to login

### `blink/lib/data/datasources/remote/api_auth_datasource.dart`
Replaces `firebase_auth_datasource.dart`.

| Method | Endpoint | Notes |
|--------|----------|-------|
| `login(email, password)` | `POST /api/auth/login` | Returns accessToken + refreshToken |
| `register(email, password, username, displayName)` | `POST /api/auth/register` | Returns accessToken + refreshToken |
| `loginWithGoogle(idToken)` | `POST /api/auth/google` | Google ID token → JWT |
| `refreshToken(refreshToken)` | `POST /api/auth/refresh` | Returns new tokens |
| `logout()` | `POST /api/auth/logout` | Clears server session |
| `getMe()` | `GET /api/auth/me` | Returns current user |

Tokens stored in `flutter_secure_storage`:
- Key `access_token` → accessToken
- Key `refresh_token` → refreshToken

### `blink/lib/data/datasources/remote/api_user_datasource.dart`
Replaces `firestore_user_datasource.dart`.

| Method | Endpoint | Notes |
|--------|----------|-------|
| `getUserById(id)` | `GET /api/auth/me` | Current user only for now |
| `updateProfile(fields)` | `PATCH /api/profile` | displayName, username, etc. |
| `uploadAvatar(file)` | `POST /api/profile/avatar` | multipart/form-data |
| `watchUser(id)` | `GET /api/auth/me` | Single fetch only; real-time sync added in Phase 2 |

---

## 3. Modified Files (Data Layer)

### `blink/lib/data/repositories/auth_repository_impl.dart`
- Replace `FirebaseAuthDatasource` with `ApiAuthDatasource`
- Auth state stream replaced with manual check (read token from secure storage)

### `blink/lib/data/repositories/user_repository_impl.dart`
- Replace `FirestoreUserDatasource` with `ApiUserDatasource`

---

## 4. Modified Files (Presentation Layer)

### `blink/lib/presentation/providers/auth_provider.dart`
- Remove Firebase stream providers
- Add `ApiClient` provider
- Add `ApiAuthDatasource` provider
- `authStateProvider`: checks secure storage for token on app start → returns uid or null
- `AuthNotifier`: AsyncNotifier managing login/register/logout actions

### `blink/lib/presentation/providers/user_provider.dart`
- `currentUserProvider`: fetches from `GET /api/auth/me`
- Remove Firestore stream

### `blink/lib/main.dart`
- Remove `Firebase.initializeApp` and `DefaultFirebaseOptions` import
- Firebase is fully removed in this phase (FCM push notifications added in Phase 3)

---

## 5. Screen Changes

### `login_screen.dart`
- Remove phone OTP button and flow
- Keep: email + password login, Google Sign-In button

### Deleted files
- `blink/lib/presentation/screens/auth/otp_screen.dart`
- `blink/lib/domain/usecases/auth/verify_phone_usecase.dart`
- `blink/lib/domain/usecases/auth/verify_otp_usecase.dart`
- `blink/lib/data/datasources/remote/firebase_auth_datasource.dart`
- `blink/lib/data/datasources/remote/firestore_user_datasource.dart`

---

## 6. Router Changes (`app_router.dart`)
- Remove `/otp` route
- Auth redirect logic stays the same (check `authStateProvider`)

---

## 7. Backend Addition

### `backend/src/routes/auth.routes.js`
New endpoint: `POST /api/auth/google`

**Flow:**
1. Receive `{ idToken }` from Flutter
2. Verify with Google using `google-auth-library` npm package
3. Find or create user in MongoDB by email
4. Return `accessToken` + `refreshToken` + `user`

**New npm package:** `google-auth-library`

---

## 8. Auth Flow Summary

```
App start
  └─ secure_storage has token? → authenticated → home
  └─ no token → splash → onboarding → login

Email login
  └─ POST /api/auth/login → store tokens → home

Register
  └─ POST /api/auth/register → store tokens → profile-setup → home

Google Sign-In
  └─ google_sign_in → idToken → POST /api/auth/google → store tokens → home

Token expired (401)
  └─ Dio interceptor → POST /api/auth/refresh → retry → continue
  └─ Refresh also expired → clear tokens → login

Logout
  └─ POST /api/auth/logout → clear secure_storage → login
```

---

## 9. What Does NOT Change

- `blink/lib/domain/` — all entities, use cases, repository interfaces
- `blink/lib/core/` — constants, theme, errors, router structure
- `blink/lib/presentation/screens/` — except login_screen and otp_screen removal
- `blink/lib/presentation/widgets/` — unchanged
- All test files for domain layer

---

## 10. Error Handling

| HTTP Status | Meaning | Flutter action |
|-------------|---------|----------------|
| 400 | Validation error | Show field error |
| 401 | Unauthorized | Refresh token or redirect to login |
| 409 | Duplicate email/username | Show error message |
| 500 | Server error | Show generic error |

---

## Sequence

1. Backend: add `POST /api/auth/google` endpoint
2. Flutter pubspec: remove firebase_auth/firestore/storage, add dio/secure_storage/socket_io_client
3. Flutter: create `api_client.dart`
4. Flutter: create `api_auth_datasource.dart`
5. Flutter: create `api_user_datasource.dart`
6. Flutter: update `auth_repository_impl.dart`
7. Flutter: update `user_repository_impl.dart`
8. Flutter: update `auth_provider.dart`
9. Flutter: update `user_provider.dart`
10. Flutter: update `login_screen.dart` (remove OTP)
11. Flutter: delete unused files (otp_screen, firebase datasources, phone usecases)
12. Flutter: update `main.dart`
13. Test end-to-end: register → login → home
