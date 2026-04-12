# Architecture

**Blink** follows **Clean Architecture** combined with **MVVM** (Model-View-ViewModel) pattern for a scalable, testable, and maintainable codebase.

---

## 🏛️ Overview

```
┌──────────────────────────────────────────────────┐
│                  Presentation Layer               │
│   (Screens, Widgets, Providers / ViewModels)      │
├──────────────────────────────────────────────────┤
│                   Domain Layer                    │
│      (Entities, Use Cases, Repository Interfaces) │
├──────────────────────────────────────────────────┤
│                    Data Layer                     │
│   (Models, Repository Impls, Data Sources)        │
└──────────────────────────────────────────────────┘
        ↕ Firebase / Google Maps / Device APIs
```

Each layer **only depends on the layer below it**. The Domain layer has zero Flutter or Firebase dependencies — it is pure Dart.

---

## 🗂️ Layers

### 1. Domain Layer (Core Business Logic)

The heart of the app. Contains:

- **Entities** — plain Dart objects representing business data (e.g., `UserEntity`, `LocationEntity`)
- **Repository Interfaces** — abstract contracts (e.g., `AuthRepository`)
- **Use Cases** — single-responsibility classes that execute one business operation (e.g., `ToggleGhostModeUseCase`)

```
domain/
├── entities/
│   ├── user_entity.dart
│   ├── location_entity.dart
│   └── friendship_entity.dart
├── repositories/        ← abstract interfaces
└── usecases/
```

> ✅ No Flutter imports. ✅ No Firebase imports. Pure Dart.

---

### 2. Data Layer (Implementation)

Implements domain interfaces and talks to Firebase:

- **Models** — extend entities, add `fromJson` / `toJson` for Firestore
- **Data Sources** — raw Firebase calls (Firestore, Auth, FCM)
- **Repository Implementations** — implement domain repositories using data sources

```
data/
├── models/
├── datasources/
│   ├── remote/   ← Firebase
│   └── local/    ← Hive cache
└── repositories/  ← implements domain interfaces
```

---

### 3. Presentation Layer (UI)

Built with Flutter + Riverpod:

- **Screens** — full pages of the app
- **Widgets** — reusable UI components
- **Providers** — Riverpod StateNotifiers / AsyncNotifiers acting as ViewModels

```
presentation/
├── screens/      ← Views
├── widgets/      ← Reusable components
└── providers/    ← ViewModels (Riverpod)
```

---

## 🔄 MVVM Pattern

```
View (Screen/Widget)
     │  observes state
     ▼
ViewModel (Riverpod Provider / StateNotifier)
     │  calls use case
     ▼
Use Case (Domain)
     │  calls repository
     ▼
Repository Implementation (Data)
     │  calls data source
     ▼
Firebase / Device API
```

---

## 💉 Dependency Injection

Riverpod is used for both state management and dependency injection.

```dart
// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(firebaseAuthDatasourceProvider),
  );
});

// Use case provider
final signInUseCaseProvider = Provider((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

// ViewModel provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(signInUseCaseProvider));
});
```

---

## 📐 Design Principles

| Principle | How it's applied |
|-----------|-----------------|
| **Single Responsibility** | Each use case does exactly one thing |
| **Open/Closed** | New features = new use cases, not edits |
| **Dependency Inversion** | Domain depends on abstractions, not Firebase |
| **Separation of Concerns** | UI knows nothing about Firebase |
| **DRY** | Shared logic in `core/utils/` |

---

## 🔁 Data Flow Example — Update Location

```
1. LocationService (background) gets GPS coords
2. Calls UpdateLocationUseCase
3. Use case calls LocationRepository (abstract)
4. LocationRepositoryImpl writes to Firestore
5. Firestore stream triggers → friends see new marker position
6. MapProvider (Riverpod) rebuilds map markers
```
