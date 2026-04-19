# Direct Chat (Phase 3A) — Design Spec

**Status:** Approved by user (2026-04-19)
**Date:** 2026-04-19
**Author:** Abdulaziz + Claude
**Phase:** 3A (Direct Chat) — precedes Phase 3B (Group chat + admin/owner)

---

## 1. Scope (MVP)

**In scope:**
- 1-on-1 real-time text + image messaging between accepted friends
- Read receipts (Telegram-style ✓ / ✓✓ blue)
- Typing indicator
- Message edit + delete (soft delete)
- Image upload to backend `/uploads/messages/`
- Chat entry point: existing **Friends → "Do'stlarim" tab** is repurposed as the chat list. Every friend appears (whether messages exist or not), Instagram/Telegram-DM style. Tap a friend → opens chat screen.

**Out of scope (deferred):**
- Push notifications when offline (in-app banner already exists; FCM push is later)
- Voice messages, files, video, GIFs
- Emoji reactions / stickers / custom emoji picker (system keyboard emojis work)
- Group chat (Phase 3B — built on top of `Conversation` entity defined here)
- Search inside conversations
- Forwarding, replying-to, pinned messages

---

## 2. Architecture Choice

**Approach: Explicit `Conversation` entity** (selected over messages-only).

Rationale:
- Phase 3B (groups) reuses the same `Conversation` model — `participants` array just grows from 2 to N
- Chat-list query becomes a single indexed query instead of an aggregation
- Per-conversation metadata (unread counts, lastMessageAt) is trivial to maintain

---

## 3. Backend (Models, Endpoints, Sockets)

### 3.1 Mongoose models

```js
// models/Conversation.js
{
  _id,
  participants: [ObjectId<User>, ObjectId<User>],   // sorted, unique compound index
  lastMessage: {
    text: String,                  // for image-only msgs: ""
    type: "text" | "image",
    senderId: ObjectId,
    createdAt: Date
  },
  lastMessageAt: Date,             // index, used for chat-list sort
  unread: Map<userIdString, Number>, // unread count per participant
  createdAt, updatedAt
}

// models/Message.js
{
  _id,
  conversationId: ObjectId<Conversation>,   // index
  senderId: ObjectId<User>,
  type: "text" | "image",
  text: String,                             // optional
  imageUrl: String,                         // optional, e.g. "/uploads/messages/<file>"
  createdAt: Date,                          // index, sort
  editedAt: Date,                           // null = never edited
  deletedAt: Date,                          // soft delete; clients render "Bu xabar o'chirildi"
  readBy: [{ userId: ObjectId, readAt: Date }]
}
```

### 3.2 REST endpoints (`routes/chat.routes.js`)

```
GET    /api/chats
       → list of conversations for current user, with last message + unread count

GET    /api/chats/:friendId/messages?before=<cursor>&limit=30
       → paginated messages (newest first), cursor = createdAt of oldest seen message

POST   /api/chats/:friendId/messages
       → send text or image (multipart/form-data when image attached)
       Body: { type: "text"|"image", text?: string }
       File: image (when type=image)

PATCH  /api/chats/messages/:id
       → edit text (sender only, within 24 h of createdAt)
       Body: { text: string }

DELETE /api/chats/messages/:id
       → soft delete (sender only)

POST   /api/chats/:friendId/read
       → mark all unread messages from friendId as read (updates Conversation.unread + Message.readBy)
```

Auth: all routes use existing `requireAuth` middleware (JWT).

### 3.3 Socket events (extend `sockets/index.js`)

```
Client → Server:
  chat:typing_start    { friendId }
  chat:typing_stop     { friendId }

Server → Client (emitted to `user:${friendId}` room):
  chat:message         { message: {...}, conversation: {...} }
  chat:read            { friendId: <reader's id>, conversationId, readAt }
  chat:typing          { friendId: <writer's id>, isTyping: boolean }
  chat:edited          { messageId, text, editedAt }
  chat:deleted         { messageId }
```

Image upload: reuses existing `multer` setup (same disk-storage pattern as avatars). New folder `backend/uploads/messages/`.

---

## 4. Frontend — Domain & Data layers

```
blink/lib/domain/
  entities/
    message_entity.dart          // id, conversationId, senderId, type, text?, imageUrl?,
                                 //   createdAt, editedAt?, deletedAt?, readBy[]
    conversation_entity.dart     // id, otherUserId, lastMessage, lastMessageAt, unreadCount
  repositories/
    chat_repository.dart         // abstract interface
  usecases/chat/
    fetch_conversations_usecase.dart
    fetch_messages_usecase.dart
    send_message_usecase.dart
    edit_message_usecase.dart
    delete_message_usecase.dart
    mark_as_read_usecase.dart

blink/lib/data/
  models/
    message_model.dart           // Message + fromJson/toJson
    conversation_model.dart
  datasources/remote/
    api_chat_datasource.dart     // REST: getChats, getMessages, sendText, sendImage,
                                 //   editMessage, deleteMessage, markRead
    socket_chat_datasource.dart  // Socket: emits typing_start/stop;
                                 //   listens chat:message/read/typing/edited/deleted;
                                 //   exposes Stream<ChatEvent>
  repositories/
    chat_repository_impl.dart    // combines REST + socket streams
```

**Principle:** REST = initial load + mutations. Socket = real-time push (new messages, typing, read receipts). Repository merges both into a single `Stream<List<Message>>` exposed to providers.

---

## 5. Providers (Riverpod)

```dart
// presentation/providers/chat_provider.dart

final apiChatDatasourceProvider     = Provider<ApiChatDatasource>(...);
final socketChatDatasourceProvider  = Provider<SocketChatDatasource>(...);
final chatRepositoryProvider        = Provider<ChatRepository>(...);

// Chat list (powers Friends → "Do'stlarim" tab — every friend gets enriched here)
final conversationsProvider = StreamProvider<Map<String, ConversationEntity>>(...);
//  → keyed by friendId; missing key = no conversation yet
//  → seeded from REST, kept fresh by socket events

// Per-friend message stream
final messagesProvider = StreamProvider.family<List<MessageEntity>, String>(
  (ref, friendId) => ref.watch(chatRepositoryProvider).watchMessages(friendId),
);

// Typing indicator per friend
final typingProvider = StreamProvider.family<bool, String>(
  (ref, friendId) => ref.watch(chatRepositoryProvider).watchTyping(friendId),
);

// Pagination (older messages)
final messagesPaginationProvider = StateNotifierProvider.family<
    MessagesPaginationNotifier, MessagesPaginationState, String>(...);
```

---

## 6. UI screens & widgets

### 6.1 New / modified files

```
blink/lib/presentation/screens/chat/
  chat_screen.dart                // 1-on-1 chat (main)
  widgets/
    message_bubble.dart           // text/image bubble; mine on right, friend's on left
    message_input.dart            // TextField + 📎 image picker + send button
    typing_indicator.dart         // "typing…" 3-dot animation
    chat_app_bar.dart             // friend avatar + name + online status (GlassAppBar)
    image_message_viewer.dart     // full-screen image preview

blink/lib/presentation/screens/friends/widgets/
  friend_tile.dart                // MODIFIED: last-message preview + unread badge
                                  //   + timestamp + online dot on avatar
```

### 6.2 ChatScreen layout

```
┌─────────────────────────────────────────┐
│ ← [avatar] John Doe          [⋮ menu]  │ GlassAppBar
│           online · typing…              │
├─────────────────────────────────────────┤
│                                         │
│  [left]  Salom!                14:23    │ MessageBubble (friend)
│         hi back                14:24 ✓✓ │ MessageBubble (mine, read = blue)
│  [image preview]               14:25    │ MessageBubble image
│         test                   14:26 ✓  │ MessageBubble (delivered)
│                                         │
│  • • •  (typing indicator at bottom)    │
├─────────────────────────────────────────┤
│ [📎] [TextField................] [➤]   │ MessageInput
└─────────────────────────────────────────┘
```

### 6.3 Message long-press menu

**On my own messages:**
- ✏️ Edit (only within 24 h of `createdAt`)
- 🗑 Delete (soft delete on server)
- 📋 Copy (text only)

**On friend's messages:**
- 📋 Copy

**Deleted message rendering:** "🚫 Bu xabar o'chirildi" (faded, no menu).

**Edited message rendering:** small "(tahrirlandi)" tag next to the timestamp.

### 6.4 Friends → "Do'stlarim" tab — updated tile

```
┌──────────────────────────────────────────┐
│ [avatar•] John Doe              14:25    │
│           Salom! Qalaysan?         [3]   │ ← unread badge
└──────────────────────────────────────────┘
```

- Online dot on avatar corner
- Last message preview (text, or "📷 Rasm" for image-only msg)
- Timestamp formatting: today = `HH:mm`, yesterday = "Kecha", older = `DD/MM`
- Unread badge in red with count
- If no conversation yet: render the friend's status message (or empty)

---

## 7. Edge cases

| Situation | Behaviour |
|-----------|-----------|
| Send while offline | Bubble renders immediately with "sending…" status; flushed when socket reconnects. Backend dedupes via `clientMessageId`. |
| Image upload failure | Bubble shows "❌ Yuborilmadi — qayta urinish" with retry button. |
| Message ordering | Server `createdAt` (UTC, ms) is the sort authority; clock skew is ignored. |
| Concurrent edits | Last-write-wins by `editedAt`. |
| Edit attempt after 24 h | Server returns 403; UI menu disables the edit action. |
| Edit attempt on deleted msg | UI hides the menu entirely (`deletedAt != null`). |
| First message — no conversation yet | Backend auto-creates `Conversation` (sorted-participants unique index makes the upsert idempotent). |
| Friendship removed | Existing conversation stays read-only; new sends → 403. |
| Image > 10 MB | Frontend compresses (image_picker `quality: 70`) and rejects > 10 MB; backend also rejects. |
| Typing indicator timeout | If client never emits `typing_stop`, server clears it after 5 s. |
| Multi-device | Each device opens its own socket; server emits to `user:${userId}` so all devices receive every event. |
| Read-receipts privacy | MVP shows for everyone (Telegram default). Privacy toggle is deferred. |

---

## 8. Testing strategy

### Frontend (widget + unit)

```
test/presentation/screens/chat/chat_screen_test.dart
  - renders messages with own vs friend bubble alignment
  - typing indicator appears
  - empty chat shows placeholder

test/presentation/widgets/message_bubble_test.dart
  - text bubble shows text
  - image bubble shows CachedNetworkImage
  - read = ✓✓ blue, delivered = ✓ grey
  - editedAt → "(tahrirlandi)" tag
  - deletedAt → "Bu xabar o'chirildi" placeholder

test/presentation/widgets/message_input_test.dart
  - empty text + no image → send button disabled
  - clears the field after send

test/data/repositories/chat_repository_impl_test.dart
  - REST+socket merge — new socket message appears in stream
  - sendMessage performs optimistic update

test/data/datasources/api_chat_datasource_test.dart
  - REST endpoint shapes (mock Dio)
```

### Backend

The backend has no test framework configured (no jest/supertest/scripts in `backend/package.json`). For MVP, backend correctness is verified manually:
- `curl` / Postman against each endpoint during implementation
- End-to-end smoke test from two devices in the acceptance-criteria section below
- Adding a backend test framework is out of scope for Phase 3A (deferred)

---

## 9. Acceptance criteria (MVP DONE)

- [ ] Two devices exchange real-time messages (< 1 s LAN latency)
- [ ] Image messages render in `CachedNetworkImage` on both sides
- [ ] Read receipts flip ✓ → ✓✓ blue when the chat is opened
- [ ] Typing indicator shows during composition, hides on stop
- [ ] Edits and deletes propagate to both devices immediately
- [ ] Friends tab tile shows last-message preview + unread badge without opening the chat
- [ ] App relaunch reloads all conversations and history
- [ ] `flutter analyze` clean, all frontend tests green
