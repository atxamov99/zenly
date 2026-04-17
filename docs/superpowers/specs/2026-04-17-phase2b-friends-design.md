# Phase 2B: Friends — Dizayn Spetsifikatsiyasi

## Maqsad

Foydalanuvchi do'stlar bilan ulanadi: qidirish, so'rov yuborish, qabul qilish, do'stlar joylashuvini xaritada ko'rish. Ghost mode bilan o'zini yashirish.

## Arxitektura

```
Backend (mavjud)
    ↕ HTTP REST
ApiFriendsDatasource / ApiBlockDatasource / ApiProfileDatasource
    ↕
FriendsNotifier / ProfileNotifier (Riverpod AsyncNotifier)
    ↓
UI: MainShell → BottomNavBar → [Map | Friends | Profile]

Backend Socket.IO
    ↓ friend:request_received / accepted / removed
SocketService (mavjud, yangi listener'lar)
    ↓ Stream
FriendsNotifier (state yangilash) + InAppBanner (overlay)
```

## Texnologiyalar

| Komponent | Paket |
|-----------|-------|
| QR kod ko'rsatish | `qr_flutter: ^4.1.0` |
| QR kod o'qish | `mobile_scanner: ^5.0.0` |
| State management | `flutter_riverpod` (mavjud) |
| HTTP | `dio` (mavjud, ApiClient orqali) |
| Real-time | `socket_io_client` (mavjud, SocketService orqali) |

## Navigatsiya

`MainShell` widget — `IndexedStack` bilan 3 tab orasida o'tish:

```
🗺️ Map     — joriy MapScreen (Phase 2A)
👥 Friends — yangi (badge: kelgan so'rovlar soni)
👤 Profile — yangi (settings + ghost mode)
```

Login/register qilingandan so'ng `/main` ga yo'naltirish (avval `/map` edi).

## Friends ekran

3 ta sub-tab (TabBar):

### Tab 1: "Do'stlarim"

- Do'stlar ro'yxati: avatar, displayName, online indicator (yashil nuqta), smartStatus
- Long-press → BottomSheet menu:
  - 📍 Joylashuvga borish (map ga o'tib do'stga zoom)
  - 💔 Do'stlikni bekor qilish (`DELETE /friends/:friendId`)
  - 🚫 Bloklash (`POST /users/:id/block`)
- Bo'sh: "Hali do'st yo'q. Qidirish bo'limidan boshla"

### Tab 2: "So'rovlar"

- 2 ta section:
  - **Kelganlar** (incoming): har birida "Qabul" (yashil) va "Rad" (qizil) tugmalar
  - **Yuborilganlar** (outgoing): har birida "Bekor qilish" tugmasi
- Badge — Friends tab da kelgan so'rovlar soni
- Bo'sh: "Yangi so'rovlar yo'q"

### Tab 3: "Qo'shish"

- Yuqorida: search input (live, debounce 300ms, `GET /friends/search?q=`)
- Pastida: 2 ta tugma — "📱 QR ko'rsatish" va "📷 QR skanerlash"
- Search natijalari: avatar + ism + tugma
  - Hech kim emas → "+ Add" (`POST /friends/request`)
  - Pending so'rov → "Yuborilgan" (disabled)
  - Allaqachon do'st → "✓ Do'st" (disabled)
- Bo'sh natija → "Hech kim topilmadi"

## QR kod funksiyasi

### QR ko'rsatish (Dialog)
- O'z `username` ni QR kod sifatida ko'rsatish (`qr_flutter`)
- Pastida: username text + "Yopish" tugmasi

### QR skanerlash (Full screen)
- `mobile_scanner` bilan kamera ochiladi
- Username topilsa → avtomatik `POST /friends/request` chaqiriladi
- Muvaffaqiyatli bo'lsa → snackbar + ekran yopiladi

## Profile ekran

```
┌─────────────────────────┐
│ Sozlamalar          ✏️  │  ← AppBar + edit (ProfileSetupScreen ga)
├─────────────────────────┤
│   ╭───╮                 │
│   │👤 │  Abdulaziz       │
│   ╰───╯  @abdulaziz     │
│         email@gmail.com │
├─────────────────────────┤
│ 👻 Ghost Mode      ⬜    │  ← faol toggle
│ 🔋 Batareya       (P2C) │  ← disabled, "Tez orada"
│ 🔒 Maxfiylik      (P2C) │  ← disabled
├─────────────────────────┤
│ ℹ️  Ilova haqida   v1.0  │
│ 🚪 Chiqish              │
└─────────────────────────┘
```

### Ghost Mode toggle

- Ekranda toggle bosish:
  1. `PUT /profile` chaqirilad — `{ "privacy": { "ghostMode": true/false } }`
  2. Backend muvaffaqiyatli bo'lsa, `SharedPreferences` ga `ghost_mode` flag yoziladi
  3. `LocationTaskHandler` har sikl boshlanishida bu flag ni o'qiydi — true bo'lsa joylashuv yubormaydi
  4. Map da o'z marker ko'rinishi o'zgaradi (kulrang)
- Backend xatosida toggle qaytariladi va snackbar

## Real-time event'lar

Backend friend hodisalari uchun maxsus socket event emas, balki **`notification:new`** event'i emit qiladi (har xil `type` bilan). `SocketService` ga 1 ta yangi listener qo'shiladi:

| Event | `type` | Reaktsiya |
|-------|--------|-----------|
| `notification:new` | `friend_request_received` | In-app banner ("X sizga so'rov yubordi") + Friends badge++ |
| `notification:new` | `friend_request_accepted` | In-app banner ("X so'rovingizni qabul qildi") + friends list refresh |
| `notification:new` | `friend_removed` | Friends list refresh + map dan marker o'chiriladi |
| `notification:new` | `geozone_entered` / `_exited` | (Phase 3 da ishlatiladi, hozir e'tiborsiz qoldiriladi) |

Notification payload format:
```json
{
  "notification": {
    "type": "friend_request_received",
    "title": "New friend request",
    "body": "Ali sent you a friend request",
    "data": { "friendshipId": "...", "requesterId": "..." }
  }
}
```

### In-app banner

`OverlayEntry` orqali ekranning yuqorisida 3 soniya ko'rinadi:

```
┌─────────────────────────────┐
│ [👤] Ali sizga so'rov       │
│      yubordi               × │
└─────────────────────────────┘
```

- Tap → Friends tab → "So'rovlar" sub-tab ga o'tish
- "×" yoki 3 soniya o'tsa avtomatik yopilish
- Global navigator key orqali har qanday ekran ustidan ko'rsatiladi

## Backend API (mavjud — qo'shish kerak emas)

### Friends
| Endpoint | Vazifa |
|----------|--------|
| `GET /api/friends/search?q=` | Username bo'yicha qidirish |
| `GET /api/friends` | Do'stlar ro'yxati |
| `GET /api/friends/requests` | `{ incoming: [], outgoing: [] }` |
| `POST /api/friends/request` body: `{ username }` | So'rov yuborish |
| `PATCH /api/friends/:requestId/respond` body: `{ action: "accepted"\|"declined" }` | Javob berish |
| `DELETE /api/friends/request/:requestId` | Yuborilgan so'rovni bekor qilish |
| `DELETE /api/friends/:friendId` | Do'stlikni bekor qilish |

### Block
| Endpoint | Vazifa |
|----------|--------|
| `POST /api/blocks/:userId` | Bloklash |
| `GET /api/blocks/` | Bloklanganlar ro'yxati |
| `DELETE /api/blocks/:userId` | Blokdan chiqarish |

### Profile
| Endpoint | Vazifa |
|----------|--------|
| `GET /api/auth/me` | O'z profilini olish (mavjud) |
| `PATCH /api/profile/` body: `{ displayName, username }` | Ism o'zgartirish |
| `POST /api/profile/avatar` | Avatar yuklash (mavjud, Phase 1.5) |
| `PATCH /api/profile/privacy` body: `{ ghostMode }` | Ghost mode toggle |

### Socket events (server → client)
- `notification:new` — `{ notification: { type, title, body, data } }` (yagona event, `type` orqali ajratiladi)

## Yangi fayllar

**Domain:**
- `lib/domain/entities/friend_entity.dart`
- `lib/domain/entities/friend_request_entity.dart`

**Data:**
- `lib/data/datasources/remote/api_friends_datasource.dart`
- `lib/data/datasources/remote/api_block_datasource.dart`
- `lib/data/datasources/remote/api_profile_datasource.dart`

**Presentation — Providers:**
- `lib/presentation/providers/friends_provider.dart`
- `lib/presentation/providers/profile_provider.dart`

**Presentation — Screens:**
- `lib/presentation/screens/main/main_shell.dart`
- `lib/presentation/screens/friends/friends_screen.dart`
- `lib/presentation/screens/friends/widgets/friends_list_tab.dart`
- `lib/presentation/screens/friends/widgets/requests_tab.dart`
- `lib/presentation/screens/friends/widgets/add_friend_tab.dart`
- `lib/presentation/screens/friends/widgets/friend_tile.dart`
- `lib/presentation/screens/friends/widgets/qr_show_dialog.dart`
- `lib/presentation/screens/friends/widgets/qr_scan_screen.dart`
- `lib/presentation/screens/profile/profile_screen.dart`
- `lib/presentation/widgets/in_app_banner.dart`

## O'zgartiriladigan fayllar

- `pubspec.yaml` — `qr_flutter`, `mobile_scanner`
- `lib/services/socket_service.dart` — yangi event listener'lar
- `lib/services/location_task_handler.dart` — ghost mode tekshirish
- `lib/data/datasources/local/token_storage.dart` — ghost mode flag (SharedPrefs)
- `lib/core/constants/api_constants.dart` — friends/profile endpointlar
- `lib/core/router/app_router.dart` — `/main` route (MainShell)
- `lib/main.dart` — global navigator key
- `android/app/src/main/AndroidManifest.xml` — `CAMERA` permission

## Xatolarni boshqarish

- Search bo'sh → "Hech kim topilmadi"
- Network error → snackbar
- Block qilingan user search da ko'rinmaydi (backend filter)
- Allaqachon do'st `/friends/request` → 409 → "Allaqachon do'st"
- QR skan paytida kamera ruxsati rad etilsa → snackbar + Settings ga yo'naltirish
- Socket uzilsa → so'rovlar real-time bo'lmaydi, lekin Friends ekran ochilganda manual refresh

## Phase 2C / Phase 3 ga qoldirilgan

- Battery sharing toggle
- Privacy (location visibility: everyone/friends/circles/none)
- Push notifications
- Notifications center
- Geozones, Circles, Friend profile screen
