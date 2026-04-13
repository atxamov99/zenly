# ⚙️ State Management — Riverpod Providers

**Blink** ilovasida **Riverpod** state management va dependency injection uchun ishlatiladi.

---

## 📁 Providers Joylashuvi

```
presentation/providers/
├── auth_provider.dart
├── location_provider.dart
├── friends_provider.dart
├── map_provider.dart
└── ghost_mode_provider.dart    (GHOST_MODE.md'dan)
```

---

## 🔐 Auth Provider
**Fayl:** `presentation/providers/auth_provider.dart`

### `authStateProvider`
- **Turi:** `StreamProvider<User?>`
- **Maqsad:** Firebase auth holati oqimi
- **Ishlatilishi:** Splash screen'da kirganmi yoki yo'qligini aniqlaydi

### `authViewModelProvider`
- **Turi:** `StateNotifierProvider<AuthViewModel, AuthState>`
- **Holatlari:**

| Holat | Tavsif |
|-------|--------|
| `AuthInitial` | Hali hech narsa bo'lmagan |
| `AuthLoading` | Jarayon davom etmoqda |
| `AuthSuccess` | Muvaffaqiyatli kirish |
| `AuthError(message)` | Xatolik |

---

## 📍 Location Provider
**Fayl:** `presentation/providers/location_provider.dart`

### `myLocationProvider`
- **Turi:** `StateProvider<LatLng?>`
- **Maqsad:** Mening hozirgi joylashuvim
- `LocationService` yangi koordinat berganda yangilanadi

### `locationStreamProvider`
- **Turi:** `StreamProvider<Position>`
- **Maqsad:** GPS koordinatlar oqimi

---

## 👥 Friends Provider
**Fayl:** `presentation/providers/friends_provider.dart`

### `friendsProvider`
- **Turi:** `StreamProvider<List<UserEntity>>`
- **Maqsad:** Do'stlar ro'yxati (real-vaqt)
- Firestore `friendships` va `users` kolleksiyasidan o'qiydi

### `friendRequestsProvider`
- **Turi:** `StreamProvider<List<FriendRequestEntity>>`
- **Maqsad:** Kutilayotgan do'stlik so'rovlari
- Firestore `friend_requests` kolleksiyasidan o'qiydi

### `friendsViewModelProvider`
- **Turi:** `StateNotifierProvider`
- **Metodlar:**
  - `sendRequest(uid)` — do'stlik so'rovi yuborish
  - `acceptRequest(requestId)` — qabul qilish
  - `rejectRequest(requestId)` — rad etish
  - `removeFriend(uid)` — do'stlikdan chiqarish
  - `blockUser(uid)` — bloklash
  - `unblockUser(uid)` — blokdan chiqarish

---

## 🗺 Map Provider
**Fayl:** `presentation/providers/map_provider.dart`

### `friendLocationsProvider`
- **Turi:** `StreamProvider<List<LocationEntity>>`
- **Maqsad:** Barcha do'stlarning real-vaqt joylashuvlari
- Har bir do'st uchun Firestore stream'i birlashtiriladi

### `mapMarkersProvider`
- **Turi:** `Provider<Set<Marker>>`
- **Maqsad:** Google Maps uchun markerlar to'plami
- `friendLocationsProvider` va `myLocationProvider`'ga bog'liq
- Avtomatik qayta hisoblanadi

### `mapViewModelProvider`
- **Turi:** `StateNotifierProvider<MapViewModel, MapState>`
- **Metodlar:**
  - `centerOnMe()` — kamerani mening joyimga ko'chirish
  - `centerOnFriend(uid)` — do'st joyiga o'tish
  - `fitAllFriends()` — barcha do'stlarni ko'rsatish

---

## 👻 Ghost Mode Provider
**Fayl:** `presentation/providers/` ichida

### `ghostModeProvider`
- **Turi:** `StateNotifierProvider<GhostModeNotifier, GhostModeState>`

**GhostModeState:**

| Xossa | Turi | Tavsif |
|-------|------|--------|
| `isGlobalGhost` | bool | Global ghost yoqilganmi |
| `ghostedFromUids` | List\<String\> | Selective ghost ro'yxati |

**Metodlar:**
- `toggle()` — global ghost yoq/o'chir
- `toggleForFriend(uid, bool)` — tanlangan do'st uchun

---

## 💉 Dependency Injection Zanjiri

```
FirebaseAuthDatasource
    └── AuthRepositoryImpl
            └── SignInUseCase
                    └── AuthViewModel
                            └── AuthState → UI
```

Riverpod'da har bir qadam `Provider` orqali bog'lanadi:

```
firebaseAuthDatasourceProvider
    ↓
authRepositoryProvider
    ↓
signInUseCaseProvider
    ↓
authViewModelProvider
    ↓
Widget'da ref.watch(authViewModelProvider)
```

---

## 🔁 Provider'lardan Foydalanish (Widget)

### Ma'lumot o'qish
```
// ConsumerWidget yoki Consumer ichida:
ref.watch(friendsProvider)
    .when(
        data: (friends) → do'stlar ro'yxatini ko'rsatish,
        loading: () → skeleton loader,
        error: (e, _) → xato xabari,
    )
```

### Amal bajarish
```
// Tugma bosilganda:
ref.read(ghostModeProvider.notifier).toggle()
ref.read(friendsViewModelProvider.notifier).sendRequest(uid)
```

---

## 📊 Provider Bog'liqliklari Diagrammasi

```
authStateProvider
    │
    └── authViewModelProvider
            │
            └── (kirish muvaffaqiyatli bo'lganda)
                    ├── friendsProvider
                    ├── friendLocationsProvider
                    │       └── mapMarkersProvider
                    │               └── mapViewModelProvider
                    ├── myLocationProvider
                    └── ghostModeProvider
```
