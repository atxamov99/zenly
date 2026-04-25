# Blink — Loyiha Roadmap

> **Maqsad:** Zenly-tipidagi real-time joylashuv ulashish ilovasi (Flutter + Node.js/Express/MongoDB + Socket.IO).
> Yangilangan: 2026-04-25.

---

## Phase'lar bo'yicha umumiy holat

| # | Bosqich | Holat | Spec | Plan |
|---|---------|-------|------|------|
| 1 | Foundation + Auth (Firebase) | ✅ DONE | — | `2026-04-12-blink-phase1-auth.md` |
| 1.5 | Backend Integration (Firebase → Custom) | ✅ DONE | `2026-04-15-backend-integration-design.md` | `2026-04-15-blink-phase1.5-backend-integration.md` |
| 2A | Location + Map | ✅ DONE | `2026-04-16-phase2a-location-map-design.md` | `2026-04-16-phase2a-location-map.md` |
| 2B | Friends (search/QR/blocks) | ✅ DONE | `2026-04-17-phase2b-friends-design.md` | `2026-04-17-phase2b-friends.md` |
| 2C | Battery + Privacy + Ghost-from | ✅ DONE (2026-04-25) | _spec yo'q_ | _plan yo'q_ |
| Glass 1 | Liquid Glass dizayn (atom + capsule nav) | ✅ DONE | `2026-04-17-blink-ux-vision.md` | `2026-04-17-glass-phase1.md` |
| Glass 2+ | Vanishing AppBar, Floating Card, Tab Pellet | ✅ DONE (2026-04-25) | `2026-04-17-blink-ux-vision.md` | _plan yo'q_ |
| 3A | Direct Chat (1-on-1) | ✅ DONE | `2026-04-19-direct-chat-design.md` | `2026-04-19-direct-chat.md` |
| 3B | Group Chat (MVP + v2) | ✅ DONE (2026-04-25) | _spec yo'q_ | _plan yo'q_ |
| 3C | Push Notifications (FCM/APNs) | ⏸️ PENDING | _kelajakda_ | _kelajakda_ |
| 4 | Geozones UI + Smart Statuses | ✅ DONE (2026-04-25) | _spec yo'q_ | _plan yo'q_ |
| 5 | Voice/Stickers/Stories | ⏸️ FUTURE | — | — |
| 6 | Battery optimization + analytics | ⏸️ FUTURE | — | — |

---

## ✅ Yakunlangan bosqichlar

### Phase 1 — Foundation + Auth
**Stack:** Flutter + Riverpod + GoRouter + Firebase Auth + Firestore + Clean Architecture.

**Asosiy yutuqlar:**
- Clean Architecture skelet: domain (entities + use cases + abstract repos), data (models + datasources + impls), presentation (providers + screens)
- Email/parol + Google Sign-In + telefon OTP
- Splash → Onboarding → Login/Register → ProfileSetup → Home navigation flow
- AppButton, AppTextField — bazaviy UI komponentlar
- `firebase_options.dart` orqali Firebase loyiha sozlamalari

### Phase 1.5 — Backend Integration (Firebase → Node.js)
**Stack:** Node.js + Express + MongoDB (Mongoose) + JWT + Google OAuth + Socket.IO. Frontend Firebase'dan voz kechib Dio + secure_storage'ga o'tkazildi.

**Asosiy yutuqlar:**
- Firebase Auth + Firestore butunlay olib tashlandi
- `flutter_secure_storage` ichida JWT access/refresh token
- `Dio` interceptor: 401 → `/auth/refresh` → retry
- `POST /api/auth/google`: Google ID token → backend JWT
- Telefon OTP flow olib tashlandi (FCM Phase 3C ga qoldirildi)
- 5 ta yangi datasource + 2 ta repository qayta yozildi

### Phase 2A — Location + Map
**Stack:** `flutter_map` (OpenStreetMap, bepul) + `geolocator` + `flutter_foreground_task` (Android) + `socket_io_client`.

**Asosiy yutuqlar:**
- Foreground service har 10s da `POST /api/location/update`
- Ilova yopiq (background) bo'lsa ham uzatadi
- `friend:location_changed` socket eventi → real-time marker yangilanish
- Markerlar: o'z (pulse animatsiya bilan) + do'stlar (avatar)
- "Menga qayt" tugmasi
- AndroidManifest.xml: 6 ta permission + foreground service

### Phase 2B — Friends
**Stack:** `qr_flutter` (display) + `mobile_scanner` (scan) + Riverpod `AsyncNotifier`.

**Asosiy yutuqlar:**
- 3-tabli MainShell: Map / Friends / Profile (BottomNavBar — Glass capsule)
- Friends ekran 3 sub-tab: Do'stlarim / So'rovlar / Qo'shish
- Username search (debounce 300ms), QR ko'rsatish (dialog), QR skanerlash (kamera)
- Friend so'rov yuborish/qabul qilish/rad etish/bekor qilish
- Block / Unblock
- Ghost Mode toggle (server + SharedPrefs)
- In-app banner (`OverlayEntry`) — `notification:new` socket eventi orqali

### Phase 2C — Battery + Privacy ✅ (2026-04-25)
**Maqsad:** Real batareya foizini do'stlarga uzatish, visibility sozlash, per-friend ghost.

**Privacy enum:** `friends | circles | nobody` (backend bilan moslangan).

**Backend:**
- `User.presence.batteryPercent` + `batteryUpdatedAt`
- `User.privacy.batteryVisibility` + `privacy.ghostFromList: [ObjectId]`
- `POST /location/update` body'da `batteryPercent` qabul qiladi
- `GET /location/visible-friends` — `ghostFromList` filteri + battery visibility check
- Yangi endpoint: `PUT/DELETE /api/profile/ghost-from/:friendId`
- Yangi socket event: `friend:battery_changed`

**Frontend:**
- `LocationTaskHandler` 10s'lik update'ga `Battery().batteryLevel` ni qo'shadi
- `SocketService.onBatteryChanged` Stream
- `FriendsLocationNotifier` socket'dan kelgan battery'ni state'ga yozadi
- `PrivacyNotifier` (3 visibility field'ni boshqaradi)
- ProfileScreen `_PrivacySection`: 3 ListTile + bottom-sheet RadioListTile picker
- Friends long-press menu: "Bu do'stga ko'rinmaslik" → `ghostFromAdd`

### Glass Phase 1 — Liquid Glass dizayn tili
**Inspiratsiya:** Apple iOS 26 Liquid Glass, Zenly bottom nav.

**Yaratilgan komponentlar:**
- `GlassTokens` — blur (8/20/40/80), tint (whites), corner radii, spring physics
- `GlassSurface` — atom widget (BackdropFilter blur + tint + specular border)
- `GlassCapsuleNav` — bottom nav, sliding pellet animatsiya
- `GlassCard`, `GlassFab`, `GlassSheet`, `GlassAppBar`
- `MainShell` shu komponentlarga ko'chirildi

### Glass Phase 2+ — Vanishing/Floating effects ✅ (2026-04-25)
- `GlassSliverAppBar` (yangi) — `SliverAppBar` + `flexibleSpace: GlassSurface(blur: 40)`. `floating: true, snap: true` bilan scroll-down'da yashirinadi.
- ProfileScreen `CustomScrollView` ga ko'chirildi (vanishing AppBar)
- FriendsScreen `Stack` + `AnimatedSlide` + `NotificationListener<ScrollNotification>` (3 ta tab uchun ham ishlaydi)
- InAppBanner GlassSurface'da
- TabBar pellet indikatori (BoxDecoration + tintProminent + specular border)

### Phase 3A — Direct Chat (1-on-1)
**Arxitektura:** Explicit `Conversation` collection (Phase 3B group chat uchun ham qayta ishlatiladi). REST = boshlang'ich + mutatsiya, Socket = real-time push.

**Mongoose models:**
- `Conversation { participants: [ObjectId], lastMessage, lastMessageAt, unread: Map }`
- `Message { conversationId, senderId, type: text|image, text, imageUrl, editedAt, deletedAt, readBy: [{userId, readAt}] }`

**REST endpoints:**
- `GET /api/chats` — conversation list
- `GET /api/chats/:friendId/messages?before=&limit=30`
- `POST /api/chats/:friendId/messages` (multipart: text yoki image)
- `PATCH /api/chats/messages/:id` — edit (faqat 24 soat)
- `DELETE /api/chats/messages/:id` — soft delete
- `POST /api/chats/:friendId/read` — read receipts

**Socket events:**
- C→S: `chat:typing_start`, `chat:typing_stop`
- S→C: `chat:message`, `chat:read`, `chat:typing`, `chat:edited`, `chat:deleted`

**Frontend tarkibi:**
- 7 ta yangi domain fayl, 5 ta data fayl, 7 ta presentation fayl
- ChatScreen: reverse ListView + long-press menu (copy/edit/delete) + image_picker integratsiyasi
- MessageBubble: text/image/deleted rendering, ✓/✓✓ blue receipts, "(tahrirlandi)" tag
- Friends "Do'stlarim" tab DM ro'yxatiga aylantirildi (preview + unread badge)

---

## ⏸️ Qilinmagan bosqichlar

### Phase 3B — Group Chat ✅ (2026-04-25)
**Maqsad:** Bir nechta do'st bilan guruh, real-time matn/rasm xabarlar.

**Backend yutuqlar:**
- `Conversation` modeli: `isGroup`, `title`, `avatarUrl`, `ownerId`, `adminIds[]`. Unique index endi DM uchungina (`partialFilterExpression`)
- 7 ta yangi endpoint: `POST /chats/groups`, `GET /chats/groups/:id/messages`, `POST /chats/groups/:id/messages`, `POST /chats/groups/:id/read`, `PATCH /chats/groups/:id`, `POST /chats/groups/:id/members`, `DELETE /chats/groups/:id/members/:userId`
- Socket events: `chat:group_created`, `chat:group_updated`, `chat:member_added`, `chat:member_removed`. Mavjud `chat:message`, `chat:read`, `chat:edited`, `chat:deleted` group uchun ham ishlaydi (participants array)

**Frontend yutuqlar:**
- `ConversationEntity` ga `isGroup`, `title`, `members[]` (ConversationMember), `ownerId`, `adminIds`
- `ApiChatDatasource` ga 7 ta group method
- `ChatRepositoryImpl` ga separate `_groupMessages`, `_groupConversations` cache + `watchGroups`, `watchGroupMessages`
- `groupsProvider` (StreamProvider), `groupMessagesProvider` (StreamProvider.family)
- 3 ta yangi ekran: `GroupChatScreen`, `NewGroupScreen`, `GroupSettingsScreen`
- Friends tab "Do'stlarim" da yuqorida "Yangi guruh" tugmasi + "Guruhlar" sekilyasi (avatar, title, last message preview, unread badge, timestamp)
- App router: `/new-group`, `/group/:id`, `/group-settings/:id`
- Socket listener'lar: yangi guruh yaratilganda avtomatik qo'shilish, rename real-time, member changes refetch

**v3 / kelajakka qoldirilganlar:** group avatar upload, @mention, typing indicator, read receipts UI, admin tayinlash, pinned messages.

**Migration:** mavjud Mongo'da unique index `participants_1` ni drop qilish kerak (yangi schema partial unique ishlatadi).

### Phase 3C — Push Notifications (FCM)
**Premise:** Backend'da `PushToken.js` model va `push.routes.js` qisman bor — lekin haqiqiy yetkazib berish tizimi (FCM/APNs SDK) ulanmagan.

**Asosiy ishlar:**
- Backend: `firebase-admin` SDK + Apple `apn` paket
- `notifications.js` ichida real push: friend request, message, geozone events
- `Notification` collection unread/seen tizimi
- Quiet hours / mute settings (`User.privacy.notifications`)
- Frontend: `firebase_messaging` ulanish, FCM token registratsiya (`POST /push/register`)
- iOS APNs sertifikati setup
- Notification tap → tegishli ekranga deep link

**Spec va plan kerak.**

### Phase 4 — Geozones UI + Smart Statuses ✅ (2026-04-25)
**Maqsad:** Backend allaqachon tayyor edi (Phase 2A bilan birga keldi). Faqat frontend UI yetishmas edi.

**Frontend yutuqlar:**
- `GeozoneEntity` (id, name, kind: home/study/work/custom, lat/lng, radiusMeters, notifyViewerIds, isActive) + emoji getter
- `ApiGeozoneDatasource` — list/create/update/delete
- `geozonesProvider` (AsyncNotifier) — refresh/create/delete
- `GeozonesScreen` — joylar ro'yxati, empty state, delete tile
- `NewGeozoneScreen` — full-screen FlutterMap pin selector, ChoiceChip kind tanlash, radius slider (50–500m), nom input
- ProfileScreen → "Joylarim" entry
- MapScreen → `CircleLayer` (deepPurple translucent) + emoji marker har bir aktiv joy uchun

**v2 / kelajakka qoldirilgan:** notifyViewers tanlash UI, geozone tahrirlash, visit history, geozone-based privacy.

### Phase 5 — Future polish
- Voice messages (web-audio + Opus encoding)
- Stickers / custom emoji picker
- Stories ("snap" — 24 soatga joylashuv tarixi)
- Friend profile screen (full-page bio + shared geozones)
- Search inside chats
- Forwarding, reply-to, pinned messages
- Multi-device sync (token per device)

### Phase 6 — Optimization & analytics
- Battery optimization: `geolocator` adaptive sampling (movement-based)
- Network: HTTP/2, Brotli compression, CDN for `/uploads`
- Mongo indexes audit + slow-query logging
- Sentry / Crashlytics
- Mixpanel / PostHog event tracking
- A/B testing infra

---

## Qolgan kichik qarzlar (technical debt)

- `flutter analyze` ishlatib bo'lmadi (snap flutter installation broken — `bin/internal/shared.sh` yo'q). User Flutter SDK'ni qayta o'rnatishi kerak yoki `~/flutter` binary'ni manual o'rnatish.
- Backend test framework yo'q (`backend/package.json`'da `jest/supertest` yo'q). Hozirgi tekshirish manual: curl/Postman + 2-qurilma smoke test.
- `UserEntity.locationSharingMode` field "precise|approximate|off" deb e'lon qilingan, lekin backend'da "friends|circles|nobody" — bu field hozir aslida `locationVisibility` ni saqlaydi. Keyingi refactor'da nomini moslashtirish yaxshi bo'ladi.
- iOS-specific Liquid Glass test qilinmagan (faqat Android device'da chizilgan).
- ImageMessageViewer pinch-zoom ishlaydi, lekin double-tap zoom + swipe-down to dismiss yo'q.
- Backend `multer` rasm yuklash limit: hozir 10MB. Real-world'da WebP konversiyasi va thumbnail generation bo'lishi kerak.
- Per-friend ghost `ghostFromList` UI faqat qo'shish uchun bor — qaytarish (unghost) uchun ProfileScreen'da yangi sekilya kerak.

---

## Loyiha statistikasi (taxminiy)

- Backend: 12 route file, 16 model, 11 utility, 2 socket file
- Frontend: ~50 ekran/widget, 9 provider, 20+ datasource/model/entity
- Phase 1 dan beri: ~80 commit (haftada o'rtacha 6)
- Liquid Glass komponentlari: 7 ta atom widget
- Real-time socket events: 9 turi
