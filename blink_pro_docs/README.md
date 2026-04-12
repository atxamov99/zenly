# Blink — Zenly Clone (PRO)

**Blink** is a production-level real-time location sharing app inspired by Zenly. Built with Flutter and Firebase, it allows friends to see each other's live locations on an interactive map, share battery levels, enable ghost mode, and stay connected with push notifications.

---

## 🚀 Tech Stack

| Layer             | Technology                           |
|-------------------|---------------------------------------|
| UI Framework      | Flutter (Dart)                       |
| State Management  | Riverpod (+ Bloc for complex flows)  |
| Backend           | Firebase (Auth, Firestore, FCM)      |
| Maps              | Google Maps Flutter Plugin           |
| Location          | `geolocator` + `background_locator`  |
| Notifications     | Firebase Cloud Messaging (FCM)       |
| Storage           | Firebase Storage (avatars, media)    |
| Architecture      | Clean Architecture + MVVM            |

---

## 📱 Core Features

- 🗺️ **Live Map** — see all friends' real-time positions on a shared map
- 👻 **Ghost Mode** — go invisible to all or selected friends
- 🔋 **Battery Sharing** — friends can see your current battery percentage
- 🔔 **Push Notifications** — friend requests, location alerts, activity pings
- 👥 **Friend System** — send/accept/remove/block friends
- 🕐 **Last Seen** — when a friend was last active
- 📍 **Location History** — trace recent movement of a friend
- 🌍 **Geocoding** — reverse geocode coordinates into readable addresses
- 🔒 **Privacy Controls** — granular control over who sees what

---

## 📁 Project Structure

```
lib/
├── core/               # Constants, theme, router, utilities
├── data/               # Repositories, Firebase data sources, DTOs
├── domain/             # Entities, use cases, repository interfaces
├── presentation/       # UI screens, widgets, ViewModels
└── main.dart
```

---

## 🛠️ Getting Started

See [SETUP.md](SETUP.md) for full Flutter + Firebase setup instructions.

---

## 📄 Documentation Index

| File | Description |
|------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Clean Architecture + MVVM overview |
| [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md) | Full project folder tree |
| [AUTH.md](AUTH.md) | Authentication flows (phone, email, Google) |
| [DATABASE.md](DATABASE.md) | Firestore collections & schema |
| [API.md](API.md) | External APIs used (Maps, Firebase) |
| [LOCATION.md](LOCATION.md) | GPS & background location tracking |
| [MAPS.md](MAPS.md) | Google Maps integration |
| [GHOST_MODE.md](GHOST_MODE.md) | Ghost mode logic & privacy |
| [BATTERY_STATUS.md](BATTERY_STATUS.md) | Battery % sharing implementation |
| [REALTIME.md](REALTIME.md) | Firestore real-time streams |
| [NOTIFICATIONS.md](NOTIFICATIONS.md) | FCM push notifications |
| [SECURITY.md](SECURITY.md) | Firestore security rules |
| [PERFORMANCE.md](PERFORMANCE.md) | Performance optimizations |
| [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) | Riverpod / Bloc strategy |
| [USER_FLOW.md](USER_FLOW.md) | Full user journey |
| [UX_UI.md](UX_UI.md) | Design language, gestures, screens |
| [WIREFRAMES.md](WIREFRAMES.md) | Layout wireframes |
| [TESTING.md](TESTING.md) | Unit, widget & integration tests |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Android & iOS build & release |
| [ROADMAP.md](ROADMAP.md) | Upcoming features & milestones |
| [CODE_SNIPPETS.md](CODE_SNIPPETS.md) | Reusable code examples |

---

## 👤 Author

**Abdulaziz** — [n1565559@gmail.com](mailto:n1565559@gmail.com)
