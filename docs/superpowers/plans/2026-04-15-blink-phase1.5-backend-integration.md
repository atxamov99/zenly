# Phase 1.5 — Backend Integration (Firebase → Custom Backend) Implementation Plan

> **Agentik ishchilar uchun:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development (tavsiya) yoki superpowers:executing-plans dan foydalanib har bir taskni bosqichma-bosqich bajaring. Steplar checkbox (`- [ ]`) sintaksisida.

**Maqsad:** Firebase Auth + Firestore ni custom Node.js/Express/MongoDB backend bilan to'liq almashtirish. Domain layer o'zgarmaydi, faqat data layer va presentation providers yangilanadi.

**Arxitektura:** Clean Architecture saqlanadi. Datasourcelar HTTP API ga o'tkaziladi (Dio + interceptor). JWT tokenlar `flutter_secure_storage` da saqlanadi. Auth state Firebase stream o'rniga `AsyncNotifier` orqali boshqariladi.

**Tech Stack:** Flutter, Riverpod, Dio, flutter_secure_storage, google_sign_in, Node.js, Express, MongoDB, google-auth-library

---

## File Structure

### Yangi fayllar
- `backend/src/routes/auth.routes.js` — `POST /api/auth/google` qo'shiladi
- `blink/lib/data/datasources/remote/api_client.dart` — Dio + interceptor
- `blink/lib/data/datasources/remote/api_auth_datasource.dart` — auth API
- `blink/lib/data/datasources/remote/api_user_datasource.dart` — user API
- `blink/lib/data/datasources/local/token_storage.dart` — JWT secure storage
- `blink/lib/core/constants/api_constants.dart` — base URL va endpointlar

### Yangilanadigan fayllar
- `blink/pubspec.yaml`
- `blink/lib/main.dart`
- `blink/lib/core/router/app_router.dart`
- `blink/lib/domain/repositories/auth_repository.dart`
- `blink/lib/data/models/user_model.dart`
- `blink/lib/data/repositories/auth_repository_impl.dart`
- `blink/lib/data/repositories/user_repository_impl.dart`
- `blink/lib/presentation/providers/auth_provider.dart`
- `blink/lib/presentation/providers/user_provider.dart`
- `blink/lib/presentation/screens/auth/login_screen.dart`
- `blink/lib/presentation/screens/auth/register_screen.dart`
- `blink/lib/presentation/screens/profile_setup/profile_setup_screen.dart`
- `blink/lib/domain/usecases/auth/sign_in_email_usecase.dart`
- `backend/package.json`

### O'chiriladigan fayllar
- `blink/lib/data/datasources/remote/firebase_auth_datasource.dart`
- `blink/lib/data/datasources/remote/firestore_user_datasource.dart`
- `blink/lib/presentation/screens/auth/otp_screen.dart`
- `blink/lib/domain/usecases/auth/verify_phone_usecase.dart`
- `blink/lib/domain/usecases/auth/verify_otp_usecase.dart`
- `blink/test/unit/domain/usecases/verify_otp_usecase_test.dart`

---

## Task 1: Backend — Google Sign-In endpointini qo'shish

**Files:**
- Modify: `backend/package.json`
- Modify: `backend/src/routes/auth.routes.js`

- [ ] **Step 1: Backend papkasiga o'tib `google-auth-library` o'rnatish**

```bash
cd backend
npm install google-auth-library
```

- [ ] **Step 2: `auth.routes.js` faylining yuqorisiga import qo'shish**

`backend/src/routes/auth.routes.js` faylining 13-qatorida (`const router = express.Router();` dan oldin) bu kodni qo'shing:

```javascript
const { OAuth2Client } = require("google-auth-library");

const googleClient = new OAuth2Client();
```

- [ ] **Step 3: `POST /google` endpointni qo'shish**

`auth.routes.js` faylida `router.post("/refresh", ...)` dan keyin (139-qatordan keyin) bu endpointni qo'shing:

```javascript
router.post("/google", authLimiter, async (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (typeof idToken !== "string" || !idToken) {
      return res.status(400).json({ message: "idToken is required" });
    }

    let payload;
    try {
      const ticket = await googleClient.verifyIdToken({ idToken });
      payload = ticket.getPayload();
    } catch (err) {
      return res.status(401).json({ message: "Invalid Google idToken" });
    }

    if (!payload || !payload.email) {
      return res.status(401).json({ message: "Google account has no email" });
    }

    const normalizedEmail = payload.email.toLowerCase();

    let user = await User.findOne({ email: normalizedEmail });

    if (!user) {
      let username = (payload.email.split("@")[0] || "user").replace(/[^a-zA-Z0-9_]/g, "").slice(0, 20);
      if (username.length < 3) username = `user${Date.now()}`;

      let unique = username;
      let counter = 1;
      while (await User.findOne({ username: unique })) {
        unique = `${username}${counter}`;
        counter++;
      }

      user = await User.create({
        username: unique,
        email: normalizedEmail,
        passwordHash: await bcrypt.hash(generateOpaqueToken(), 10),
        displayName: payload.name || unique,
        avatarUrl: payload.picture || null
      });
    }

    const { accessToken, refreshToken, session } = await createSession(user, req);

    res.json({
      accessToken,
      refreshToken,
      sessionId: session._id,
      user: serializeUser(user)
    });
  } catch (error) {
    next(error);
  }
});
```

- [ ] **Step 4: Backend serverni qayta ishga tushirish**

```bash
cd backend
npm run dev
```

Kutiladigan natija: `Server running on port 4000` xabar chiqsin.

- [ ] **Step 5: Endpointni curl bilan tekshirish**

```bash
curl -X POST http://localhost:4000/api/auth/google -H "Content-Type: application/json" -d "{}"
```

Kutiladigan natija: `400` status, `{"message":"idToken is required"}`.

- [ ] **Step 6: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add backend/package.json backend/package-lock.json backend/src/routes/auth.routes.js
git commit -m "feat(backend): add POST /api/auth/google endpoint for Google Sign-In"
```

---

## Task 2: Flutter — `pubspec.yaml` yangilash

**Files:**
- Modify: `blink/pubspec.yaml`

- [ ] **Step 1: Firebase paketlarini olib tashlash va yangi paketlarni qo'shish**

`blink/pubspec.yaml` faylida `dependencies` blokini quyidagi bilan to'liq almashtiring:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Networking
  dio: ^5.4.0

  # Storage
  flutter_secure_storage: ^9.0.0

  # Real-time
  socket_io_client: ^2.0.3+1

  # Auth
  google_sign_in: ^6.2.1

  # State Management
  flutter_riverpod: ^2.4.9

  # Navigation
  go_router: ^13.2.0

  # Maps & Location
  google_maps_flutter: ^2.5.3
  geolocator: ^10.1.0
  geocoding: ^2.1.1

  # Device
  battery_plus: ^5.0.1
  permission_handler: ^11.3.0

  # UI & Utils
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  rxdart: ^0.27.7
  http: ^1.2.0
```

- [ ] **Step 2: `flutter pub get` ishlatish**

```bash
cd blink
flutter pub get
```

Kutiladigan natija: Xatoliksiz tugashi. `firebase_*` paketlari endi yo'q.

- [ ] **Step 3: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/pubspec.yaml blink/pubspec.lock
git commit -m "chore(blink): replace firebase deps with dio + secure_storage + socket_io_client"
```

---

## Task 3: Flutter — `api_constants.dart` yaratish

**Files:**
- Create: `blink/lib/core/constants/api_constants.dart`

- [ ] **Step 1: Constants faylini yaratish**

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:4000/api';
  static const String socketUrl = 'http://10.0.2.2:4000';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Profile
  static const String profile = '/profile';
  static const String avatar = '/profile/avatar';
}
```

> Eslatma: `10.0.2.2` Android emulator uchun host kompyuter manzili. Real qurilmada o'z kompyuteringizning lokal IP manzilini ishlatish kerak (masalan `192.168.1.10:4000`).

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/core/constants/api_constants.dart
git commit -m "feat(blink): add ApiConstants for backend endpoints"
```

---

## Task 4: Flutter — `token_storage.dart` yaratish

**Files:**
- Create: `blink/lib/data/datasources/local/token_storage.dart`

- [ ] **Step 1: Local datasource papkasini yaratish va `token_storage.dart` qo'shish**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<void> updateRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/datasources/local/token_storage.dart
git commit -m "feat(blink): add TokenStorage for secure JWT persistence"
```

---

## Task 5: Flutter — `api_client.dart` yaratish

**Files:**
- Create: `blink/lib/data/datasources/remote/api_client.dart`

- [ ] **Step 1: Dio client + token refresh interceptor yaratish**

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../local/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiClient(this._tokenStorage)
      : dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              await _tokenStorage.clear();
              _isRefreshing = false;
              return handler.next(error);
            }

            final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
            final response = await refreshDio.post(
              ApiConstants.refresh,
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['accessToken'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;
            await _tokenStorage.updateAccessToken(newAccessToken);
            await _tokenStorage.updateRefreshToken(newRefreshToken);

            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryRequest);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          } catch (e) {
            await _tokenStorage.clear();
            _isRefreshing = false;
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ));
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/datasources/remote/api_client.dart
git commit -m "feat(blink): add ApiClient with Dio token refresh interceptor"
```

---

## Task 6: Flutter — `UserModel` ni Firebase dan ozod qilish

**Files:**
- Modify: `blink/lib/data/models/user_model.dart`

- [ ] **Step 1: `user_model.dart` ni to'liq almashtirish**

```dart
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String phone;
  final String photoUrl;
  final String emoji;
  final String statusMessage;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool ghostMode;
  final List<String> ghostFromList;
  final int batteryPercent;
  final bool isCharging;
  final String locationSharingMode;
  final String? fcmToken;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.email,
    required this.phone,
    required this.photoUrl,
    this.emoji = '',
    this.statusMessage = '',
    required this.isOnline,
    this.lastSeen,
    required this.ghostMode,
    this.ghostFromList = const [],
    required this.batteryPercent,
    required this.isCharging,
    required this.locationSharingMode,
    this.fcmToken,
    this.createdAt,
  });

  /// Backend response: `{ id, username, email, displayName, avatarUrl, privacy, presence }`
  factory UserModel.fromApi(Map<String, dynamic> json) {
    final privacy = (json['privacy'] as Map<String, dynamic>?) ?? const {};
    final presence = (json['presence'] as Map<String, dynamic>?) ?? const {};

    return UserModel(
      uid: (json['id'] ?? json['_id'] ?? '').toString(),
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      photoUrl: json['avatarUrl'] as String? ?? '',
      emoji: '',
      statusMessage: '',
      isOnline: presence['isOnline'] as bool? ?? false,
      lastSeen: presence['lastSeenAt'] != null
          ? DateTime.tryParse(presence['lastSeenAt'].toString())
          : null,
      ghostMode: privacy['ghostMode'] as bool? ?? false,
      ghostFromList: const [],
      batteryPercent: 100,
      isCharging: false,
      locationSharingMode: privacy['locationVisibility'] as String? ?? 'friends',
      fcmToken: null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toApi() => {
        'displayName': displayName,
        'username': username,
        'avatarUrl': photoUrl,
      };

  UserEntity toEntity() => UserEntity(
        uid: uid,
        displayName: displayName,
        username: username,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        emoji: emoji,
        statusMessage: statusMessage,
        isOnline: isOnline,
        lastSeen: lastSeen,
        ghostMode: ghostMode,
        ghostFromList: ghostFromList,
        batteryPercent: batteryPercent,
        isCharging: isCharging,
        locationSharingMode: locationSharingMode,
        fcmToken: fcmToken,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        uid: entity.uid,
        displayName: entity.displayName,
        username: entity.username,
        email: entity.email,
        phone: entity.phone,
        photoUrl: entity.photoUrl,
        emoji: entity.emoji,
        statusMessage: entity.statusMessage,
        isOnline: entity.isOnline,
        lastSeen: entity.lastSeen,
        ghostMode: entity.ghostMode,
        ghostFromList: entity.ghostFromList,
        batteryPercent: entity.batteryPercent,
        isCharging: entity.isCharging,
        locationSharingMode: entity.locationSharingMode,
        fcmToken: entity.fcmToken,
      );
}
```

- [ ] **Step 2: Eski `user_model_test.dart` ni o'chirish (Firestore Timestamp ishlatadi)**

```bash
rm blink/test/unit/data/models/user_model_test.dart
```

- [ ] **Step 3: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/models/user_model.dart blink/test/unit/data/models/user_model_test.dart
git commit -m "refactor(blink): UserModel uses backend JSON, drops Firestore types"
```

---

## Task 7: Flutter — `AuthRepository` interfeysini yangilash

**Files:**
- Modify: `blink/lib/domain/repositories/auth_repository.dart`

- [ ] **Step 1: Interfeysni to'liq almashtirish**

```dart
abstract class AuthRepository {
  /// Email + parol bilan tizimga kiradi. Backend uid ni qaytaradi.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Yangi foydalanuvchini ro'yxatdan o'tkazadi. Backend uid ni qaytaradi.
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });

  /// Google Sign-In orqali kiradi. Backend uid ni qaytaradi.
  Future<String> signInWithGoogle();

  /// Tizimdan chiqadi va saqlangan tokenlarni tozalaydi.
  Future<void> signOut();

  /// Saqlangan uid ni qaytaradi (lokal storagedan), aks holda null.
  Future<String?> getStoredUid();

  /// Lokal storage da token bormi.
  Future<bool> hasValidSession();
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/domain/repositories/auth_repository.dart
git commit -m "refactor(blink): AuthRepository drops phone OTP, adds session helpers"
```

---

## Task 8: Flutter — `RegisterEmailUseCase` ni yangilash

**Files:**
- Modify: `blink/lib/domain/usecases/auth/sign_in_email_usecase.dart`

- [ ] **Step 1: `RegisterEmailUseCase` parametrlarini kengaytirish**

`blink/lib/domain/usecases/auth/sign_in_email_usecase.dart` faylini to'liq almashtiring:

```dart
import '../../repositories/auth_repository.dart';

class SignInEmailUseCase {
  final AuthRepository _repo;
  const SignInEmailUseCase(this._repo);

  Future<String> call({
    required String email,
    required String password,
  }) {
    return _repo.signInWithEmail(email: email, password: password);
  }
}

class RegisterEmailUseCase {
  final AuthRepository _repo;
  const RegisterEmailUseCase(this._repo);

  Future<String> call({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) {
    return _repo.registerWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/domain/usecases/auth/sign_in_email_usecase.dart
git commit -m "refactor(blink): RegisterEmailUseCase requires username + displayName"
```

---

## Task 9: Flutter — `ApiAuthDatasource` yaratish

**Files:**
- Create: `blink/lib/data/datasources/remote/api_auth_datasource.dart`

- [ ] **Step 1: Datasource yaratish**

```dart
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../local/token_storage.dart';
import 'api_client.dart';

class ApiAuthDatasource {
  final ApiClient _client;
  final TokenStorage _tokenStorage;
  final GoogleSignIn _googleSignIn;

  ApiAuthDatasource({
    required ApiClient client,
    required TokenStorage tokenStorage,
    GoogleSignIn? googleSignIn,
  })  : _client = client,
        _tokenStorage = tokenStorage,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  Dio get _dio => _client.dio;

  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Login failed'));
    }
  }

  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'username': username,
          'displayName': displayName,
        },
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Registration failed'));
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthException('Google idToken not available');
      }

      final response = await _dio.post(
        ApiConstants.google,
        data: {'idToken': idToken},
      );
      return await _persistAndReturnUid(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Google sign-in failed'));
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Server logout failure is non-fatal — local cleanup still happens.
    }
    await _googleSignIn.signOut();
    await _tokenStorage.clear();
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return response.data['user'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e, 'Failed to fetch user'));
    }
  }

  Future<String?> getStoredUid() => _tokenStorage.getUserId();

  Future<bool> hasValidSession() => _tokenStorage.hasToken();

  Future<String> _persistAndReturnUid(dynamic data) async {
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final userId = (user['id'] ?? user['_id']).toString();

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
    return userId;
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/datasources/remote/api_auth_datasource.dart
git commit -m "feat(blink): add ApiAuthDatasource with email/google auth"
```

---

## Task 10: Flutter — `ApiUserDatasource` yaratish

**Files:**
- Create: `blink/lib/data/datasources/remote/api_user_datasource.dart`

- [ ] **Step 1: Datasource yaratish**

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class ApiUserDatasource {
  final ApiClient _client;

  ApiUserDatasource(this._client);

  Dio get _dio => _client.dio;

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserModel.fromApi(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to fetch user'));
    }
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (username != null) body['username'] = username;
      if (email != null) body['email'] = email;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await _dio.patch(ApiConstants.profile, data: body);
      return UserModel.fromApi(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to update profile'));
    }
  }

  Future<String> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post(ApiConstants.avatar, data: formData);
      return response.data['user']['avatarUrl'] as String;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to upload avatar'));
    }
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/datasources/remote/api_user_datasource.dart
git commit -m "feat(blink): add ApiUserDatasource for profile + avatar"
```

---

## Task 11: Flutter — `auth_repository_impl.dart` ni yangilash

**Files:**
- Modify: `blink/lib/data/repositories/auth_repository_impl.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _datasource.signInWithEmail(email: email, password: password);

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) =>
      _datasource.registerWithEmail(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

  @override
  Future<String> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<String?> getStoredUid() => _datasource.getStoredUid();

  @override
  Future<bool> hasValidSession() => _datasource.hasValidSession();
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/repositories/auth_repository_impl.dart
git commit -m "refactor(blink): AuthRepositoryImpl uses ApiAuthDatasource"
```

---

## Task 12: Flutter — `user_repository_impl.dart` ni yangilash

**Files:**
- Modify: `blink/lib/data/repositories/user_repository_impl.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/api_user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiUserDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<void> createUser(UserEntity user) async {
    await _datasource.updateProfile(
      displayName: user.displayName,
      username: user.username,
      avatarUrl: user.photoUrl.isEmpty ? null : user.photoUrl,
    );
  }

  @override
  Future<UserEntity> getUserById(String uid) async {
    final model = await _datasource.getMe();
    return model.toEntity();
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _datasource.updateProfile(
      displayName: fields['displayName'] as String?,
      username: fields['username'] as String?,
      email: fields['email'] as String?,
      avatarUrl: fields['photoUrl'] as String? ?? fields['avatarUrl'] as String?,
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    // Backend username unique constraint orqali tekshiradi (409 qaytaradi).
    // Bu Phase 1.5 da to'liq tekshirish endpoint yo'q — har doim true qaytaradi.
    return true;
  }

  @override
  Future<void> deleteUser(String uid) async {
    // Backend hozircha account o'chirish endpoint qo'llab-quvvatlamaydi.
    throw UnimplementedError('Account deletion not supported by backend yet');
  }

  @override
  Stream<UserEntity> watchUser(String uid) async* {
    final model = await _datasource.getMe();
    yield model.toEntity();
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/data/repositories/user_repository_impl.dart
git commit -m "refactor(blink): UserRepositoryImpl uses ApiUserDatasource"
```

---

## Task 13: Flutter — `auth_provider.dart` ni yangilash

**Files:**
- Modify: `blink/lib/presentation/providers/auth_provider.dart`

- [ ] **Step 1: Providerlar va `AuthNotifier` yaratish**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/token_storage.dart';
import '../../data/datasources/remote/api_auth_datasource.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/sign_in_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';

// ── Local Storage ───────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>((_) {
  return TokenStorage();
});

// ── HTTP Client ─────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});

// ── Datasource ──────────────────────────────────────────────

final apiAuthDatasourceProvider = Provider<ApiAuthDatasource>((ref) {
  return ApiAuthDatasource(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

// ── Repository ──────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiAuthDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final signInEmailUseCaseProvider = Provider((ref) {
  return SignInEmailUseCase(ref.watch(authRepositoryProvider));
});

final registerEmailUseCaseProvider = Provider((ref) {
  return RegisterEmailUseCase(ref.watch(authRepositoryProvider));
});

final signInGoogleUseCaseProvider = Provider((ref) {
  return SignInGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// ── Auth State ──────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final hasSession = await repo.hasValidSession();
    if (!hasSession) return null;
    return repo.getStoredUid();
  }

  Future<void> setAuthenticated(String uid) async {
    state = AsyncData(uid);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final hasSession = await repo.hasValidSession();
      if (!hasSession) return null;
      return repo.getStoredUid();
    });
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, String?>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

final currentUidProvider = Provider<String>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) throw StateError('No authenticated user');
  return uid;
});
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/presentation/providers/auth_provider.dart
git commit -m "refactor(blink): auth_provider uses AsyncNotifier + ApiClient"
```

---

## Task 14: Flutter — `user_provider.dart` ni yangilash

**Files:**
- Modify: `blink/lib/presentation/providers/user_provider.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_user_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/user/create_user_profile_usecase.dart';
import 'auth_provider.dart';

// ── Datasource ──────────────────────────────────────────────

final apiUserDatasourceProvider = Provider<ApiUserDatasource>((ref) {
  return ApiUserDatasource(ref.watch(apiClientProvider));
});

// ── Repository ──────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(apiUserDatasourceProvider));
});

// ── Use Cases ───────────────────────────────────────────────

final createUserProfileUseCaseProvider = Provider((ref) {
  return CreateUserProfileUseCase(ref.watch(userRepositoryProvider));
});

// ── Current User ────────────────────────────────────────────

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.value;
  if (uid == null) return null;
  try {
    return await ref.watch(userRepositoryProvider).getUserById(uid);
  } catch (_) {
    return null;
  }
});

/// Backend tomondan profil yaratilganligini tekshiradi.
final userProfileExistsProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return false;
  try {
    final user = await ref.watch(userRepositoryProvider).getUserById(uid);
    return user.username.isNotEmpty && user.displayName.isNotEmpty;
  } catch (_) {
    return false;
  }
});
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/presentation/providers/user_provider.dart
git commit -m "refactor(blink): user_provider uses ApiUserDatasource"
```

---

## Task 15: Flutter — `app_router.dart` dan OTP ni olib tashlash

**Files:**
- Modify: `blink/lib/core/router/app_router.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      if (!isAuth && state.matchedLocation == AppRoutes.home) {
        return AppRoutes.login;
      }

      if (isAuth && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );
});
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/core/router/app_router.dart
git commit -m "refactor(blink): remove /otp route from app_router"
```

---

## Task 16: Flutter — `login_screen.dart` ni yangilash

**Files:**
- Modify: `blink/lib/presentation/screens/auth/login_screen.dart`

- [ ] **Step 1: Phone OTP ni o'chirib email + Google qoldirish**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = await ref.read(signInEmailUseCaseProvider).call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uid = await ref.read(signInGoogleUseCaseProvider).call();
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),
                const Text(
                  'Welcome to\nBlink',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Sign in with your email or Google account',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: AppSizes.md),
                AppButton(
                  label: 'Sign In',
                  onPressed: _signInEmail,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSizes.md),
                Row(children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: AppSizes.md),
                AppButton(
                  label: AppStrings.continueWithGoogle,
                  onPressed: _signInGoogle,
                  isOutlined: true,
                  leading: const Icon(Icons.g_mobiledata, size: 22),
                ),
                const SizedBox(height: AppSizes.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Create an account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/presentation/screens/auth/login_screen.dart
git commit -m "feat(blink): login screen uses email + Google (no phone OTP)"
```

---

## Task 17: Flutter — `register_screen.dart` ni yangilash

**Files:**
- Modify: `blink/lib/presentation/screens/auth/register_screen.dart`

- [ ] **Step 1: Username + displayName maydonlarini qo'shish**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = await ref.read(registerEmailUseCaseProvider).call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
            displayName: _displayNameController.text.trim(),
          );
      await ref.read(authStateProvider.notifier).setAuthenticated(uid);
      if (!mounted) return;
      final profileExists = await ref.read(userProfileExistsProvider.future);
      if (!mounted) return;
      context.go(profileExists ? AppRoutes.home : AppRoutes.profileSetup);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSizes.lg),
                AppTextField(
                  hint: 'Username',
                  controller: _usernameController,
                  validator: (v) =>
                      (v == null || v.length < 3) ? 'Minimum 3 characters' : null,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  hint: 'Display name',
                  controller: _displayNameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: AppSizes.md),
                AppButton(
                  label: 'Create Account',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/presentation/screens/auth/register_screen.dart
git commit -m "feat(blink): register screen collects username + displayName"
```

---

## Task 18: Flutter — `profile_setup_screen.dart` ni yangilash

**Files:**
- Modify: `blink/lib/presentation/screens/profile_setup/profile_setup_screen.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _avatar;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  Future<String?> _uploadAvatar() async {
    if (_avatar == null) return null;
    try {
      return await ref.read(apiUserDatasourceProvider).uploadAvatar(_avatar!);
    } catch (e) {
      setState(() => _error = 'Avatar upload failed: $e');
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = ref.read(currentUidProvider);
      final photoUrl = await _uploadAvatar() ?? '';

      await ref.read(createUserProfileUseCaseProvider).call(
            UserEntity(
              uid: uid,
              displayName: _nameController.text.trim(),
              username: _usernameController.text.trim(),
              email: '',
              phone: '',
              photoUrl: photoUrl,
              isOnline: true,
              ghostMode: false,
              batteryPercent: 100,
              isCharging: false,
              locationSharingMode: 'friends',
            ),
          );

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.lg),
                const Text(
                  'Set up your profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSizes.xl),
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                    child: _avatar == null
                        ? const Icon(Icons.camera_alt, color: AppColors.primary, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                const Text('Tap to add photo',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  hint: 'Display name',
                  controller: _nameController,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  hint: 'Username (e.g. abdulaziz)',
                  controller: _usernameController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'At least 3 characters';
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) {
                      return 'Lowercase letters, numbers, underscores only';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: AppSizes.xl),
                AppButton(
                  label: 'Continue',
                  onPressed: _save,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `flutter analyze` orqali tekshirish**

```bash
cd blink
flutter analyze lib/presentation/screens/profile_setup/profile_setup_screen.dart
```

Kutiladigan natija: 0 ta error.

- [ ] **Step 3: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/presentation/screens/profile_setup/profile_setup_screen.dart
git commit -m "refactor(blink): profile_setup uses ApiUserDatasource for avatar"
```

---

## Task 19: Flutter — `main.dart` dan Firebase ni olib tashlash

**Files:**
- Modify: `blink/lib/main.dart`

- [ ] **Step 1: Faylni to'liq almashtirish**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: BlinkApp()));
}

class BlinkApp extends ConsumerWidget {
  const BlinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Blink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add blink/lib/main.dart
git commit -m "refactor(blink): remove Firebase init from main.dart"
```

---

## Task 20: Flutter — Eski fayllarni o'chirish

**Files:**
- Delete: `blink/lib/data/datasources/remote/firebase_auth_datasource.dart`
- Delete: `blink/lib/data/datasources/remote/firestore_user_datasource.dart`
- Delete: `blink/lib/presentation/screens/auth/otp_screen.dart`
- Delete: `blink/lib/domain/usecases/auth/verify_phone_usecase.dart`
- Delete: `blink/lib/domain/usecases/auth/verify_otp_usecase.dart`
- Delete: `blink/test/unit/domain/usecases/verify_otp_usecase_test.dart`
- Delete: `blink/lib/firebase_options.dart`

- [ ] **Step 1: Fayllarni o'chirish**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
rm blink/lib/data/datasources/remote/firebase_auth_datasource.dart
rm blink/lib/data/datasources/remote/firestore_user_datasource.dart
rm blink/lib/presentation/screens/auth/otp_screen.dart
rm blink/lib/domain/usecases/auth/verify_phone_usecase.dart
rm blink/lib/domain/usecases/auth/verify_otp_usecase.dart
rm blink/test/unit/domain/usecases/verify_otp_usecase_test.dart
rm blink/lib/firebase_options.dart
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "chore(blink): delete unused Firebase + phone OTP files"
```

---

## Task 21: Flutter — Loyihani analyze qilish

**Files:** —

- [ ] **Step 1: `flutter analyze` ishlatish**

```bash
cd blink
flutter analyze
```

Kutiladigan natija: 0 ta error. Agar `firebase_*` importlari qolgan fayl chiqsa — uni qo'lda topib o'chiring.

- [ ] **Step 2: Hammasi toza bo'lsa, commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add -A
git commit -m "chore(blink): clean lingering Firebase imports" --allow-empty
```

---

## Task 22: Backend va ilovani end-to-end test qilish

**Files:** —

- [ ] **Step 1: Backendni ishga tushirish (yangi terminal)**

```bash
cd backend
npm run dev
```

Kutiladigan natija: `Server running on port 4000`.

- [ ] **Step 2: Flutter ilovani ishga tushirish**

```bash
cd blink
flutter run
```

Kutiladigan natija: ilova ochilsin. Splash → Login screen ko'rinishi kerak.

- [ ] **Step 3: Register oqimini test qilish**

Login screen da "Create an account" ni bosing. To'ldiring:
- Username: `testuser1`
- Display name: `Test User`
- Email: `test1@example.com`
- Password: `123456`

"Create Account" ni bosing.

Kutiladigan natija: profile setup yoki home screenga o'tishi kerak. Backend logida `POST /api/auth/register 201` ko'rinishi kerak.

- [ ] **Step 4: Logout va login ni test qilish**

Home screen da logout tugmasini bosing → login screenga qaytishi kerak.

Yana login screen da:
- Email: `test1@example.com`
- Password: `123456`

"Sign In" ni bosing → home screenga o'tishi kerak.

- [ ] **Step 5: Hamma narsa ishlasa, commit**

```bash
cd C:/Users/user/OneDrive/Desktop/Zenly
git add -A
git commit -m "test: verify Phase 1.5 backend integration end-to-end" --allow-empty
```

- [ ] **Step 6: `ignore.md` ni yangilash**

`ignore.md` da Phase 1.5 ostidagi "Yakunlangan fayllar" jadvaliga barcha yaratilgan/o'zgartirilgan fayllarni qo'shing va "Qolgan fayllar" jadvalini bo'shating.

```bash
git add ignore.md
git commit -m "docs: mark Phase 1.5 backend integration complete in ignore.md"
```

---

## Yakuniy Tekshirish

- Backend `/api/auth/google` endpoint ishlaydi
- Flutter `firebase_auth`, `cloud_firestore`, `firebase_storage` paketlari yo'q
- Email register → backend ga POST → JWT olinadi → home
- Email login → backend ga POST → JWT olinadi → home
- Google Sign-In → idToken backendga yuboriladi → JWT olinadi → home
- Logout → server session o'chiriladi → tokenlar tozalanadi
- Phone OTP screen va relevant fayllar o'chirilgan
