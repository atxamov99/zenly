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

## Phase 2C: Battery + Privacy ✅

**Maqsad:** Real batareya foizini do'stlarga uzatish, joylashuv/batareya/oxirgi-faollik ko'rinishini sozlash, ma'lum do'stga "ko'rinmaslik" (per-friend ghost).

**Privacy enum (backend bilan moslangan):** `friends | circles | nobody`

### Backend (✅)
| Fayl | O'zgarish |
|------|-----------|
| `backend/src/models/User.js` | ✅ `presence.batteryPercent`, `presence.batteryUpdatedAt`, `privacy.batteryVisibility`, `privacy.ghostFromList` |
| `backend/src/routes/profile.routes.js` | ✅ `PATCH /privacy` ga `batteryVisibility` qo'shildi; `PUT /profile/ghost-from/:friendId`, `DELETE /profile/ghost-from/:friendId` |
| `backend/src/routes/location.routes.js` | ✅ `POST /update` body'da `batteryPercent` qabul qiladi; visible-friends'da `ghostFromList` filteri + battery visibility check; socket `friend:battery_changed` emit |

### Frontend (✅)
| Fayl | O'zgarish |
|------|-----------|
| `blink/lib/services/location_task_handler.dart` | ✅ `Battery().batteryLevel` o'qiydi va `POST /location/update` bilan birga yuboradi |
| `blink/lib/services/socket_service.dart` | ✅ `friend:battery_changed` listener + `onBatteryChanged` Stream |
| `blink/lib/presentation/providers/location_provider.dart` | ✅ `_batterySub` + `_handleBatteryEvent` |
| `blink/lib/domain/entities/friend_location_entity.dart` | ✅ `copyWith`'da `batteryPercent` parametri |
| `blink/lib/data/datasources/remote/api_profile_datasource.dart` | ✅ `updatePrivacy`, `ghostFromAdd`, `ghostFromRemove` |
| `blink/lib/core/constants/api_constants.dart` | ✅ `ghostFrom(friendId)` URL helper |
| `blink/lib/presentation/providers/profile_provider.dart` | ✅ `PrivacyState` + `PrivacyNotifier` (location/lastSeen/battery visibility) |
| `blink/lib/presentation/screens/profile/profile_screen.dart` | ✅ `_PrivacySection` widget — bottom-sheet picker (3 ListTile: location, battery, lastSeen) |
| `blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart` | ✅ Long-press menu'ga "Bu do'stga ko'rinmaslik" qo'shildi (ghostFromAdd) |

### Manual test (foydalanuvchi bajaradi)
- [ ] ProfileScreen → "Joylashuv ko'rinishi" → bottom-sheet → friends/circles/nobody tanlash → backend yangilanadi
- [ ] ProfileScreen → "Batareya ulashish" → nobody → boshqa qurilmada batareya yo'qoladi
- [ ] LocationTaskHandler 10s da batteryPercent yuboradi → backend logga `batteryPercent: NN`
- [ ] Friends → long-press → "Bu do'stga ko'rinmaslik" → o'sha do'st xaritada sizni ko'rmaydi

### Qolganlar (Phase 2C v2 / future)
- "Mendan ko'rinmaganlar" ro'yxatini ProfileScreen'da chiqarish (qaytarish uchun)
- Battery icon rangi (high/med/low)
- Geozone-based visibility ("uyda bo'lganda yashirin")

---

## Phase 3A: Direct Chat (1-on-1 Messaging)

**Maqsad:** Do'stlar o'rtasida real-time matn + rasm xabarlar, o'qish kvitansiyalari (✓/✓✓), yozish indikatori, tahrirlash + o'chirish (soft delete). Friends → "Do'stlarim" tab endi DM ro'yxati sifatida ishlaydi.

**Arxitektura:** `Conversation` kolleksiyasi (Phase 3B group chat uchun ham qayta ishlatiladi). REST: boshlang'ich yuklash + mutatsiyalar. Socket.IO: real-time push.

**Spec:** `docs/superpowers/specs/2026-04-19-direct-chat-design.md`
**Plan:** `docs/superpowers/plans/2026-04-19-direct-chat.md`

### Backend (barcha fayllar ✅)
| Fayl | Holat |
|------|-------|
| `backend/src/models/Conversation.js` | ✅ participants[], lastMessage, lastMessageAt, unread Map |
| `backend/src/models/Message.js` | ✅ conversationId, senderId, type, text, imageUrl, editedAt, deletedAt, readBy[] |
| `backend/src/routes/chat.routes.js` | ✅ GET /chats, GET /:friendId/messages, POST /:friendId/messages, PATCH/DELETE /messages/:id, POST /:friendId/read |
| `backend/src/sockets/chat.socket.js` | ✅ chat:typing_start / chat:typing_stop handler'lar |
| `backend/src/utils/chat-emit.js` | ✅ emitMessage, emitRead, emitEdited, emitDeleted, emitTyping |
| `backend/src/app.js` | ✅ `/api/chats` route ulandi |
| `backend/src/sockets/index.js` | ✅ registerChatHandlers qo'shildi |
| `backend/src/config/upload.js` | ✅ uploadMessageImage (multer, /uploads/messages/) |

### Frontend — Domain (barcha fayllar ✅)
| Fayl | Holat |
|------|-------|
| `blink/lib/domain/entities/message_entity.dart` | ✅ MessageEntity + MessageReadReceipt + copyWith |
| `blink/lib/domain/entities/conversation_entity.dart` | ✅ ConversationEntity + ConversationLastMessage |
| `blink/lib/domain/repositories/chat_repository.dart` | ✅ abstract interface (fetch/watch/send/edit/delete/markRead/typing) |
| `blink/lib/domain/usecases/chat/send_message_usecase.dart` | ✅ sendText + sendImage |
| `blink/lib/domain/usecases/chat/edit_message_usecase.dart` | ✅ |
| `blink/lib/domain/usecases/chat/delete_message_usecase.dart` | ✅ |
| `blink/lib/domain/usecases/chat/mark_as_read_usecase.dart` | ✅ |

### Frontend — Data (barcha fayllar ✅)
| Fayl | Holat |
|------|-------|
| `blink/lib/data/models/message_model.dart` | ✅ MessageModel + fromApi |
| `blink/lib/data/models/conversation_model.dart` | ✅ ConversationModel + fromApi (unread Map parse) |
| `blink/lib/data/datasources/remote/api_chat_datasource.dart` | ✅ fetchConversationsRaw, fetchMessages, sendText, sendImage, editMessage, deleteMessage, markRead |
| `blink/lib/data/datasources/remote/socket_chat_datasource.dart` | ✅ sealed ChatEvent, 5 event listener, emitTypingStart/Stop |
| `blink/lib/data/repositories/chat_repository_impl.dart` | ✅ REST+socket merge, in-memory cache, optimistic updates |

### Frontend — Presentation (barcha fayllar ✅)
| Fayl | Holat |
|------|-------|
| `blink/lib/presentation/providers/chat_provider.dart` | ✅ conversationsProvider (Map), messagesProvider.family, typingProvider.family |
| `blink/lib/presentation/screens/chat/chat_screen.dart` | ✅ reverse ListView, long-press menu (copy/edit/delete), markAsRead on open |
| `blink/lib/presentation/screens/chat/widgets/message_bubble.dart` | ✅ text/image/deleted rendering, ✓/✓✓ blue receipts, "(tahrirlandi)" tag |
| `blink/lib/presentation/screens/chat/widgets/message_input.dart` | ✅ TextField + image_picker + typing emit |
| `blink/lib/presentation/screens/chat/widgets/typing_indicator.dart` | ✅ 3-dot animation |
| `blink/lib/presentation/screens/chat/widgets/chat_app_bar.dart` | ✅ avatar + name + online + typing status |
| `blink/lib/presentation/screens/chat/widgets/image_message_viewer.dart` | ✅ full-screen preview |

### Frontend — O'zgartirilgan fayllar (✅)
| Fayl | O'zgarish |
|------|-----------|
| `blink/lib/core/constants/api_constants.dart` | ✅ chats, chatMessages(), chatRead(), editMessage(), deleteMessage() |
| `blink/lib/core/router/app_router.dart` | ✅ `/chat/:friendId` route — extra: FriendEntity |
| `blink/lib/presentation/screens/friends/widgets/friend_tile.dart` | ✅ last-message preview, unread badge, timestamp, online dot |
| `blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart` | ✅ conversationsProvider wire, tap → ChatScreen |
| `blink/pubspec.yaml` | ✅ image_picker qo'shildi |

### Manual test (foydalanuvchi bajaradi)
- [ ] 2 qurilmada login → Friends → biriga bosish → ChatScreen ochiladi
- [ ] Matn xabar yuborish → boshqa qurilmada real-time ko'rinadi (< 1s)
- [ ] Rasm yuborish → CachedNetworkImage ikkala tomonda ko'rinadi
- [ ] Chat ochilganda ✓ → ✓✓ ko'k bo'ladi (o'qish kvitansiyasi)
- [ ] Yozayotganda "..." indikator ko'rinadi, to'xtatganda yo'qoladi
- [ ] Long-press → Tahrirlash → ikki tomonda yangilanadi
- [ ] Long-press → O'chirish → "🚫 Bu xabar o'chirildi" ko'rinadi
- [ ] Friends tab → last-message preview + unread badge ko'rinadi
- [ ] App qayta ishga tushganda barcha conversation va messages yuklanadi

---

## Phase 3B: Group Chat — MVP ✅ (2026-04-25)

**Maqsad:** Bir nechta do'st bilan guruh yaratish, real-time matn/rasm xabarlar.

### Backend (✅)
| Fayl | O'zgarish |
|------|-----------|
| `backend/src/models/Conversation.js` | ✅ `isGroup`, `title`, `avatarUrl`, `ownerId`, `adminIds` qo'shildi. Unique index endi DM (isGroup=false) uchungina (`partialFilterExpression`) |
| `backend/src/routes/chat.routes.js` | ✅ Yangi: `POST /chats/groups`, `GET /chats/groups/:id/messages`, `POST /chats/groups/:id/messages` (text+image), `POST /chats/groups/:id/read`, `PATCH /chats/groups/:id` (rename), `POST /chats/groups/:id/members`, `DELETE /chats/groups/:id/members/:userId` |
| `backend/src/routes/chat.routes.js` (existing) | ✅ `GET /chats` populates `participants` (username/displayName/avatarUrl/presence) |

### Backend Socket events (yangi)
- `chat:group_created` — barcha a'zolarga emit
- `chat:group_updated` — rename qilingani haqida
- `chat:member_added`, `chat:member_removed`
- `chat:message` (mavjud) — group conversation'lari uchun ham ishlaydi (participants array)

### Frontend (✅ MVP)
| Fayl | O'zgarish |
|------|-----------|
| `blink/lib/domain/entities/conversation_entity.dart` | ✅ `isGroup`, `title`, `avatarUrl`, `ownerId`, `adminIds`, `members[]` (ConversationMember) |
| `blink/lib/data/models/conversation_model.dart` | ✅ `fromApi` populated `participants` ni `members[]` ga aylantiradi |
| `blink/lib/core/constants/api_constants.dart` | ✅ `groups`, `groupMessages`, `groupRead`, `group(id)`, `groupMembers`, `groupMember` |
| `blink/lib/data/datasources/remote/api_chat_datasource.dart` | ✅ `createGroup`, `fetchGroupMessages`, `sendGroupText`, `sendGroupImage`, `markGroupRead`, `renameGroup`, `addGroupMember`, `removeGroupMember` |
| `blink/lib/domain/repositories/chat_repository.dart` | ✅ Group method'lar interfacega qo'shildi |
| `blink/lib/data/repositories/chat_repository_impl.dart` | ✅ `_groupMessages`, `_groupConversations`, `_groupsCtrl`, `watchGroups`, `watchGroupMessages`, group send/read/rename/members; socket `_onSocketEvent`'ga `isGroup` route logika qo'shildi |
| `blink/lib/presentation/providers/chat_provider.dart` | ✅ `groupsProvider`, `groupMessagesProvider.family` |
| `blink/lib/presentation/screens/chat/group_chat_screen.dart` | ✅ Yangi — text/image messages, sender name labels, reverse ListView |
| `blink/lib/presentation/screens/chat/new_group_screen.dart` | ✅ Yangi — title input + multi-select friend picker |
| `blink/lib/core/router/app_router.dart` | ✅ `/new-group`, `/group/:id` route'lar |
| `blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart` | ✅ "Yangi guruh" tugma + "Guruhlar" section + `_GroupTile` (avatar, title, last message, unread badge, timestamp) |

### Manual test (foydalanuvchi bajaradi)
- [ ] Friends → "Yangi guruh" → 2+ do'st tanlash → nom kiritish → "Yaratish" → GroupChatScreen ochiladi
- [ ] Guruhda matn xabar yuborish → barcha a'zolar real-time ko'radi (socket `chat:message`)
- [ ] Rasm yuborish → ko'rinadi
- [ ] Friends tab → "Guruhlar" sekilyasida groupimiz lastMessage preview + unread badge bilan
- [ ] Guruh tile bosish → GroupChatScreen ochiladi, oxirgi xabarlar yuklanadi

### Phase 3B v2 (qo'shimcha) ✅ (2026-04-25)
| Komponent | Holat | Fayl |
|-----------|-------|------|
| Group settings ekran | ✅ rename, members ro'yxati, add member, remove member (owner only), leave | `group_settings_screen.dart` |
| `chat:group_created` socket listener | ✅ Yangi guruhga avtomatik qo'shilish | `socket_chat_datasource.dart`, `chat_repository_impl.dart` |
| `chat:group_updated` socket listener | ✅ Real-time rename | same |
| `chat:member_added` socket listener | ✅ refetch conversations | same |
| `chat:member_removed` socket listener | ✅ refetch (current user removed bo'lsa cache'dan tushib ketadi) | same |
| `chat:edited` / `chat:deleted` group messages uchun ishlaydi | ✅ `_editMessage` va `_markDeleted` ikkala cache (DM + group) ni tekshiradi | same |
| GroupChatScreen `more_vert` action | ✅ Settings ga olib boradi | `group_chat_screen.dart` |

### MVP'da hali yo'q (Phase 3B v3 / future)
- Group avatar upload (multer endpoint kerak — `POST /chats/groups/:id/avatar`)
- @mention (text orasida `@username` parse + notify)
- Typing indicator group'da (per-conversation typing emit)
- Read receipts UI (kim o'qigan badge)
- Admin tayinlash/olib tashlash UI (owner only)
- Owner transfer
- Pinned messages

### MIGRATION ESLATMA
Mavjud production MongoDB'da `Conversation` collection'ida eski unique index `{participants: 1}` bor (partial filter siz). Yangi schema partial index ishlatadi. Deploy paytida:
```
db.conversations.dropIndex("participants_1")
```
keyin server restart — Mongoose yangi partial unique index'ni avtomatik yaratadi.

## Glass Phase 2+: UI Improvements ✅

| Komponent | Holat | Fayl |
|-----------|-------|------|
| Vanishing Glass AppBar — ProfileScreen | ✅ `CustomScrollView` + `GlassSliverAppBar` (floating + snap) | `glass_sliver_app_bar.dart`, `profile_screen.dart` |
| Vanishing Glass AppBar — FriendsScreen | ✅ `Stack` + `AnimatedSlide` + `NotificationListener<ScrollNotification>` | `friends_screen.dart` |
| Floating Glass Card (InAppBanner) | ✅ `GlassSurface(blur:30, tintOpacity:0.55, radius:20)` | `in_app_banner.dart` |
| Tab Pellet (FriendsScreen TabBar) | ✅ BoxDecoration indicator + `GlassTokens.tintProminent` + borderRadius(20) | `friends_screen.dart` |

### Yangi fayllar
| Fayl | Holat |
|------|-------|
| `blink/lib/presentation/widgets/glass/glass_sliver_app_bar.dart` | ✅ SliverAppBar + GlassSurface flexibleSpace (floating:true, snap:true) |

---

## Phase 4: Geozones UI ✅ (2026-04-25)

**Maqsad:** Backend geozone CRUD allaqachon mavjud (Phase 2A'dan beri). Foydalanuvchi Uy/Maktab/Ish/Maxsus joylarini xaritada belgilaydi, MapScreen'da Circle layer sifatida ko'rsatiladi, ProfileScreen'da boshqaradi.

### Backend (mavjud — yangi ish kerak emas)
- `GET /api/geozones` — joylar ro'yxati
- `POST /api/geozones` — yangi joy yaratish (name, kind, lat, lng, radiusMeters, notifyViewerIds)
- `PATCH /api/geozones/:id` — yangilash
- `DELETE /api/geozones/:id` — o'chirish
- Geozone enter/exit `friend:geozone_event` socket event (`location.routes.js` orqali)
- Smart status: foydalanuvchi joyga kirsa `home/study/work` smart status yangilanadi

### Frontend (✅)
| Fayl | O'zgarish |
|------|-----------|
| `blink/lib/domain/entities/geozone_entity.dart` | ✅ Yangi: id, name, kind, lat/lng, radiusMeters, notifyViewerIds, isActive + emoji getter |
| `blink/lib/data/datasources/remote/api_geozone_datasource.dart` | ✅ Yangi: list, create, update, delete |
| `blink/lib/presentation/providers/geozone_provider.dart` | ✅ Yangi: `geozonesProvider` (AsyncNotifier), refresh/create/delete |
| `blink/lib/presentation/screens/geozones/geozones_screen.dart` | ✅ Yangi — list ekran, empty state, har bir tile uchun delete |
| `blink/lib/presentation/screens/geozones/new_geozone_screen.dart` | ✅ Yangi — full-screen FlutterMap (markazi pin), kind tanlash, nom input, radius slider (50-500m) |
| `blink/lib/core/router/app_router.dart` | ✅ `/geozones`, `/new-geozone` route'lar |
| `blink/lib/presentation/screens/profile/profile_screen.dart` | ✅ "Joylarim" entry |
| `blink/lib/presentation/screens/map/map_screen.dart` | ✅ `CircleLayer` (deepPurple translucent) + emoji marker har bir aktiv joy uchun |

### Manual test (foydalanuvchi bajaradi)
- [ ] Profile → "Joylarim" → bo'sh state ko'rinadi
- [ ] "+ Joy qo'shish" → xarita ochiladi → markazni o'rangan joyga qo'yib, kind/nom/radius tanlab "Saqlash"
- [ ] Geozones ro'yxatida ko'rinadi
- [ ] MapScreen'ga qaytsa → ko'k doira (Circle) + emoji marker
- [ ] Foydalanuvchi shu joyga kirsa → smart status `home/study/work` ga aylanadi → do'stlar marker'ida emoji o'zgaradi
- [ ] List'dan delete bosish → o'chiriladi

### v2 / kelajak
- "Notify viewers" tanlash UI — hozir bo'sh array yuboriladi
- Geozone tahrirlash (rename / radius / lokatsiya)
- Geozone visit history (`GeozoneVisit` model backend'da bor)
- "Geozone-based privacy" (uyda bo'lganda yashirin)

---

## Phase 3C: Push Notifications
_Hali boshlanmadi — `firebase_messaging` + APNs setup kerak. Backend `PushToken.js` model va `push.routes.js` qisman bor, lekin haqiqiy yetkazib berish (FCM/APNs) ulanmagan._

## Phase 5+: Voice/Stickers/Stories/Optimization
_Hali boshlanmadi — kelajak._
