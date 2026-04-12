# State Management

**Blink** uses **Riverpod** as the primary state management solution. For more complex event-driven flows (e.g., authentication), **Bloc** is optionally used.

---

## 📦 Why Riverpod?

| Feature | Riverpod |
|---------|----------|
| Compile-time safety | ✅ |
| No BuildContext required | ✅ |
| Dependency injection built-in | ✅ |
| Testable out of the box | ✅ |
| Supports async with `AsyncValue` | ✅ |
| Works with streams (Firestore) | ✅ |

---

## 🧩 Provider Types Used

### `Provider` — for pure values & dependencies
```dart
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
```

### `StateNotifierProvider` — for mutable state
```dart
final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ref.watch(friendRepositoryProvider));
});
```

### `StreamProvider` — for Firestore real-time streams
```dart
final friendsLocationsProvider = StreamProvider<List<LocationEntity>>((ref) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return ref.watch(locationRepositoryProvider).watchFriendsLocations(uid);
});
```

### `FutureProvider` — for one-time async calls
```dart
final userProfileProvider = FutureProvider.family<UserEntity, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUserById(uid);
});
```

---

## 🗂️ Provider Organization

```
lib/presentation/providers/
├── auth_provider.dart          # Auth state (logged in / out)
├── user_provider.dart          # Current user profile
├── location_provider.dart      # Own location stream
├── friends_provider.dart       # Friends list + requests
├── map_provider.dart           # Map camera, markers state
├── ghost_mode_provider.dart    # Ghost mode toggle state
└── notification_provider.dart  # Notification list
```

---

## 🔄 Auth State Flow (Riverpod + Firebase)

```dart
// Watches Firebase auth stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Derived: is user logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});
```

---

## 🗺️ Map State

```dart
class MapState {
  final LatLng? myLocation;
  final List<FriendMarker> friendMarkers;
  final bool isGhostMode;
  final bool isLoading;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._locationRepo) : super(MapState.initial());

  void updateMyLocation(LatLng pos) {
    state = state.copyWith(myLocation: pos);
  }

  void toggleGhostMode() {
    state = state.copyWith(isGhostMode: !state.isGhostMode);
  }
}
```

---

## 🧱 Bloc Usage (Optional — Auth & Complex Flows)

For auth screens with multi-step logic (OTP, retries), **Bloc** provides cleaner event/state separation:

```
AuthEvent
├── PhoneSubmitted
├── OtpSubmitted
├── GoogleSignInPressed
└── LogoutRequested

AuthState
├── AuthInitial
├── AuthLoading
├── AuthAuthenticated
├── AuthUnauthenticated
└── AuthError
```

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._signInUseCase) : super(AuthInitial()) {
    on<PhoneSubmitted>(_onPhoneSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
  }

  Future<void> _onPhoneSubmitted(PhoneSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInUseCase.verifyPhone(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(OtpSent()),
    );
  }
}
```

---

## ⚡ AsyncValue Pattern

All async providers use `AsyncValue` for clean UI handling:

```dart
// In widget:
ref.watch(friendsLocationsProvider).when(
  data: (locations) => MapWidget(locations: locations),
  loading: () => const CircularProgressIndicator(),
  error: (err, _) => ErrorWidget(err.toString()),
);
```

---

## 🔁 State Refresh Strategy

| Trigger | Action |
|---------|--------|
| App goes foreground | Re-subscribe to Firestore streams |
| User updates profile | Invalidate `userProfileProvider` |
| Friend request accepted | Refresh `friendsProvider` |
| Location changes | `locationProvider` auto-updates via stream |
