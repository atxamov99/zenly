# Direct Chat (Phase 3A) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build 1-on-1 real-time text + image messaging between friends, with read receipts, typing indicator, edit + soft-delete, surfaced inside the existing Friends → "Do'stlarim" tab (DM-style).

**Architecture:** Explicit `Conversation` collection so Phase 3B (groups) reuses the model. REST handles initial load + mutations; Socket.io handles real-time push. Frontend follows the existing Clean Architecture (Domain → Data → Presentation) with Riverpod state.

**Tech Stack:**
- Backend: Express, Mongoose, Socket.io, multer (existing). Auth middleware: `backend/src/middleware/auth.js` (use as `router.use(auth)`).
- Frontend: Flutter + Riverpod + Dio + socket_io_client + go_router + cached_network_image + image_picker (NEW dep).
- Test runners: `npm run dev` for backend smoke, `flutter test` for frontend, `flutter analyze` for lint.
- Flutter SDK on this machine: `/c/Users/user/.vscode/flutter/bin/flutter.bat`.

**Spec:** `docs/superpowers/specs/2026-04-19-direct-chat-design.md`

---

## File Structure

### Backend (new files)

```
backend/src/models/Conversation.js
backend/src/models/Message.js
backend/src/routes/chat.routes.js
backend/src/sockets/chat.socket.js          // typing handlers, attached from sockets/index.js
backend/src/utils/chat-emit.js              // helpers: emitMessage, emitRead, emitEdited, emitDeleted, emitTyping
```

### Backend (modified)

```
backend/src/app.js                          // mount chat routes
backend/src/sockets/index.js                // register chat socket handlers
backend/src/config/upload.js                // add uploadMessageImage multer instance
```

### Frontend — Domain

```
blink/lib/domain/entities/message_entity.dart
blink/lib/domain/entities/conversation_entity.dart
blink/lib/domain/repositories/chat_repository.dart
blink/lib/domain/usecases/chat/send_message_usecase.dart
blink/lib/domain/usecases/chat/edit_message_usecase.dart
blink/lib/domain/usecases/chat/delete_message_usecase.dart
blink/lib/domain/usecases/chat/mark_as_read_usecase.dart
```
*(`fetch_conversations_usecase` and `fetch_messages_usecase` are not introduced — providers consume the repository directly to avoid one-line wrappers. YAGNI.)*

### Frontend — Data

```
blink/lib/data/models/message_model.dart
blink/lib/data/models/conversation_model.dart
blink/lib/data/datasources/remote/api_chat_datasource.dart
blink/lib/data/datasources/remote/socket_chat_datasource.dart
blink/lib/data/repositories/chat_repository_impl.dart
```

### Frontend — Presentation

```
blink/lib/presentation/providers/chat_provider.dart
blink/lib/presentation/screens/chat/chat_screen.dart
blink/lib/presentation/screens/chat/widgets/message_bubble.dart
blink/lib/presentation/screens/chat/widgets/message_input.dart
blink/lib/presentation/screens/chat/widgets/typing_indicator.dart
blink/lib/presentation/screens/chat/widgets/chat_app_bar.dart
blink/lib/presentation/screens/chat/widgets/image_message_viewer.dart
```

### Frontend — Modified

```
blink/lib/core/constants/api_constants.dart                   // add chat endpoints
blink/lib/core/router/app_router.dart                         // add /chat/:friendId route
blink/lib/presentation/screens/friends/widgets/friend_tile.dart  // last-message preview + unread + tap nav
blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart  // wire chat data
blink/pubspec.yaml                                            // add image_picker dependency
```

### Tests (new)

```
blink/test/data/models/message_model_test.dart
blink/test/data/models/conversation_model_test.dart
blink/test/data/datasources/remote/api_chat_datasource_test.dart
blink/test/data/repositories/chat_repository_impl_test.dart
blink/test/presentation/screens/chat/widgets/message_bubble_test.dart
blink/test/presentation/screens/chat/widgets/message_input_test.dart
blink/test/presentation/screens/chat/widgets/typing_indicator_test.dart
blink/test/presentation/screens/chat/chat_screen_test.dart
blink/test/presentation/screens/friends/widgets/friend_tile_test.dart
```

---

## Tasks

### Task 1: Backend — Conversation + Message Mongoose models

**Files:**
- Create: `backend/src/models/Conversation.js`
- Create: `backend/src/models/Message.js`

- [ ] **Step 1: Create Conversation model**

```javascript
// backend/src/models/Conversation.js
const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    participants: {
      type: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
      required: true,
      validate: (v) => Array.isArray(v) && v.length >= 2
    },
    lastMessage: {
      text: { type: String, default: "" },
      type: { type: String, enum: ["text", "image"], default: "text" },
      senderId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
      createdAt: { type: Date }
    },
    lastMessageAt: { type: Date, index: true },
    unread: { type: Map, of: Number, default: {} }
  },
  { timestamps: true }
);

// Unique compound index on sorted participants — guarantees a single
// conversation document per pair, regardless of insert order.
conversationSchema.index({ participants: 1 }, { unique: true });

module.exports = mongoose.model("Conversation", conversationSchema);
```

- [ ] **Step 2: Create Message model**

```javascript
// backend/src/models/Message.js
const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
      index: true
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    type: { type: String, enum: ["text", "image"], required: true },
    text: { type: String, default: "" },
    imageUrl: { type: String, default: "" },
    editedAt: { type: Date, default: null },
    deletedAt: { type: Date, default: null },
    readBy: [
      {
        userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        readAt: { type: Date, default: Date.now }
      }
    ]
  },
  { timestamps: true } // adds createdAt + updatedAt; createdAt is sort key
);

messageSchema.index({ conversationId: 1, createdAt: -1 });

module.exports = mongoose.model("Message", messageSchema);
```

- [ ] **Step 3: Verify models load without crashing**

Run: `cd backend && node -e "require('./src/models/Conversation'); require('./src/models/Message'); console.log('OK')"`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add backend/src/models/Conversation.js backend/src/models/Message.js
git commit -m "feat(backend): add Conversation and Message Mongoose models"
```

---

### Task 2: Backend — Multer config for chat image uploads

**Files:**
- Modify: `backend/src/config/upload.js`

- [ ] **Step 1: Extend `upload.js` with `uploadMessageImage`**

Open `backend/src/config/upload.js` and replace its contents with:

```javascript
const path = require("path");
const fs = require("fs");

const multer = require("multer");

const uploadsRoot = path.join(__dirname, "..", "..", "uploads");
const avatarsDir = path.join(uploadsRoot, "avatars");
const messagesDir = path.join(uploadsRoot, "messages");

fs.mkdirSync(avatarsDir, { recursive: true });
fs.mkdirSync(messagesDir, { recursive: true });

function makeStorage(dir) {
  return multer.diskStorage({
    destination: (req, file, cb) => cb(null, dir),
    filename: (req, file, cb) => {
      const safeExt = path.extname(file.originalname || "").toLowerCase() || ".jpg";
      const uniqueName = `${req.user._id.toString()}-${Date.now()}${safeExt}`;
      cb(null, uniqueName);
    }
  });
}

function imageFilter(req, file, cb) {
  if (!file.mimetype || !file.mimetype.startsWith("image/")) {
    return cb(new Error("Only image files are allowed"));
  }
  cb(null, true);
}

const uploadAvatar = multer({
  storage: makeStorage(avatarsDir),
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024 }
});

const uploadMessageImage = multer({
  storage: makeStorage(messagesDir),
  fileFilter: imageFilter,
  limits: { fileSize: 10 * 1024 * 1024 } // 10 MB matches spec edge-case
});

module.exports = {
  uploadAvatar,
  uploadMessageImage
};
```

- [ ] **Step 2: Verify load**

Run: `cd backend && node -e "const u=require('./src/config/upload'); console.log(Object.keys(u))"`
Expected: `[ 'uploadAvatar', 'uploadMessageImage' ]`

- [ ] **Step 3: Commit**

```bash
git add backend/src/config/upload.js
git commit -m "feat(backend): add uploadMessageImage multer instance"
```

---

### Task 3: Backend — chat-emit helpers

**Files:**
- Create: `backend/src/utils/chat-emit.js`

- [ ] **Step 1: Write the helpers**

```javascript
// backend/src/utils/chat-emit.js
const { getIo } = require("../sockets");

function toRoom(userId) {
  return `user:${userId.toString()}`;
}

function emitToParticipants(participants, event, payload) {
  const io = getIo();
  for (const userId of participants) {
    io.to(toRoom(userId)).emit(event, payload);
  }
}

function emitMessage(conversation, message) {
  emitToParticipants(conversation.participants, "chat:message", {
    message,
    conversation
  });
}

function emitRead({ conversationId, readerId, participants, readAt }) {
  emitToParticipants(participants, "chat:read", {
    conversationId: conversationId.toString(),
    friendId: readerId.toString(),
    readAt
  });
}

function emitTyping({ writerId, recipientId, isTyping }) {
  getIo().to(toRoom(recipientId)).emit("chat:typing", {
    friendId: writerId.toString(),
    isTyping
  });
}

function emitEdited({ participants, messageId, text, editedAt }) {
  emitToParticipants(participants, "chat:edited", {
    messageId: messageId.toString(),
    text,
    editedAt
  });
}

function emitDeleted({ participants, messageId }) {
  emitToParticipants(participants, "chat:deleted", {
    messageId: messageId.toString()
  });
}

module.exports = {
  emitMessage,
  emitRead,
  emitTyping,
  emitEdited,
  emitDeleted
};
```

- [ ] **Step 2: Commit**

```bash
git add backend/src/utils/chat-emit.js
git commit -m "feat(backend): add chat socket emit helpers"
```

---

### Task 4: Backend — chat.routes.js (GET list + GET messages)

**Files:**
- Create: `backend/src/routes/chat.routes.js`

- [ ] **Step 1: Skeleton + GET /chats and GET /chats/:friendId/messages**

```javascript
// backend/src/routes/chat.routes.js
const express = require("express");
const mongoose = require("mongoose");

const auth = require("../middleware/auth");
const Conversation = require("../models/Conversation");
const Message = require("../models/Message");
const Friendship = require("../models/Friendship");
const { uploadMessageImage } = require("../config/upload");
const {
  emitMessage,
  emitRead,
  emitEdited,
  emitDeleted
} = require("../utils/chat-emit");

const router = express.Router();
router.use(auth);

function sortedPair(a, b) {
  return [a, b].map((id) => id.toString()).sort();
}

async function ensureFriendship(userIdA, userIdB) {
  const friendship = await Friendship.findOne({
    status: "accepted",
    $or: [
      { requester: userIdA, recipient: userIdB },
      { requester: userIdB, recipient: userIdA }
    ]
  });
  return Boolean(friendship);
}

async function findOrCreateConversation(userIdA, userIdB) {
  const sorted = sortedPair(userIdA, userIdB);
  const existing = await Conversation.findOne({ participants: { $all: sorted, $size: 2 } });
  if (existing) return existing;
  try {
    return await Conversation.create({ participants: sorted, unread: {} });
  } catch (err) {
    if (err.code === 11000) {
      return Conversation.findOne({ participants: { $all: sorted, $size: 2 } });
    }
    throw err;
  }
}

router.get("/", async (req, res, next) => {
  try {
    const userId = req.user._id;
    const conversations = await Conversation.find({ participants: userId })
      .sort({ lastMessageAt: -1 })
      .lean();
    res.json({ conversations });
  } catch (err) {
    next(err);
  }
});

router.get("/:friendId/messages", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.friendId)) {
      return res.status(400).json({ message: "Invalid friendId" });
    }
    const userId = req.user._id;
    const friendId = req.params.friendId;
    const limit = Math.min(parseInt(req.query.limit, 10) || 30, 100);
    const before = req.query.before ? new Date(req.query.before) : null;

    const conversation = await Conversation.findOne({
      participants: { $all: sortedPair(userId, friendId), $size: 2 }
    });
    if (!conversation) {
      return res.json({ messages: [], conversation: null });
    }

    const filter = { conversationId: conversation._id };
    if (before) filter.createdAt = { $lt: before };

    const messages = await Message.find(filter)
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    res.json({ messages, conversation });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
```

- [ ] **Step 2: Mount in `app.js`**

In `backend/src/app.js`, add the import and mount line. Add this near the other `*Routes` requires (after `pushRoutes`):

```javascript
const chatRoutes = require("./routes/chat.routes");
```

And after `app.use("/api/push", pushRoutes);`:

```javascript
app.use("/api/chats", chatRoutes);
```

- [ ] **Step 3: Smoke test (server must be running)**

In a separate shell, start the server: `cd backend && npm run dev`

Then run (replace `<TOKEN>` with a valid JWT):

```bash
curl -s -H "Authorization: Bearer <TOKEN>" http://localhost:4000/api/chats
```

Expected: `{"conversations":[]}` (or list if any exist).

- [ ] **Step 4: Commit**

```bash
git add backend/src/routes/chat.routes.js backend/src/app.js
git commit -m "feat(backend): chat list and message history endpoints"
```

---

### Task 5: Backend — POST text + image, plus PATCH/DELETE/READ

**Files:**
- Modify: `backend/src/routes/chat.routes.js`

- [ ] **Step 1: Append POST /:friendId/messages and friends below**

Add the following routes to `chat.routes.js` BEFORE the `module.exports = router;` line:

```javascript
router.post(
  "/:friendId/messages",
  uploadMessageImage.single("image"),
  async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.friendId)) {
        return res.status(400).json({ message: "Invalid friendId" });
      }
      const userId = req.user._id;
      const friendId = req.params.friendId;

      const friends = await ensureFriendship(userId, friendId);
      if (!friends) {
        return res.status(403).json({ message: "Not friends with this user" });
      }

      const type = req.body.type === "image" ? "image" : "text";
      const text = typeof req.body.text === "string" ? req.body.text : "";
      const imageUrl = req.file ? `/uploads/messages/${req.file.filename}` : "";

      if (type === "text" && !text.trim()) {
        return res.status(400).json({ message: "text required for text message" });
      }
      if (type === "image" && !imageUrl) {
        return res.status(400).json({ message: "image file required for image message" });
      }

      const conversation = await findOrCreateConversation(userId, friendId);
      const message = await Message.create({
        conversationId: conversation._id,
        senderId: userId,
        type,
        text: type === "text" ? text : "",
        imageUrl
      });

      const previewText = type === "text" ? text : "";
      const unread = conversation.unread || new Map();
      const friendUnread = (unread.get?.(friendId.toString()) ?? unread[friendId.toString()] ?? 0) + 1;

      conversation.lastMessage = {
        text: previewText,
        type,
        senderId: userId,
        createdAt: message.createdAt
      };
      conversation.lastMessageAt = message.createdAt;
      conversation.unread.set(friendId.toString(), friendUnread);
      await conversation.save();

      emitMessage(conversation.toObject(), message.toObject());

      res.status(201).json({ message, conversation });
    } catch (err) {
      next(err);
    }
  }
);

router.patch("/messages/:id", async (req, res, next) => {
  try {
    const id = req.params.id;
    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid message id" });
    }
    const newText = typeof req.body.text === "string" ? req.body.text.trim() : "";
    if (!newText) return res.status(400).json({ message: "text required" });

    const message = await Message.findById(id);
    if (!message) return res.status(404).json({ message: "Message not found" });
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not the sender" });
    }
    if (message.deletedAt) {
      return res.status(403).json({ message: "Cannot edit a deleted message" });
    }
    if (message.type !== "text") {
      return res.status(403).json({ message: "Only text messages are editable" });
    }
    const ageMs = Date.now() - new Date(message.createdAt).getTime();
    if (ageMs > 24 * 60 * 60 * 1000) {
      return res.status(403).json({ message: "Edit window has expired" });
    }

    message.text = newText;
    message.editedAt = new Date();
    await message.save();

    const conversation = await Conversation.findById(message.conversationId);
    emitEdited({
      participants: conversation.participants,
      messageId: message._id,
      text: message.text,
      editedAt: message.editedAt
    });

    res.json({ message });
  } catch (err) {
    next(err);
  }
});

router.delete("/messages/:id", async (req, res, next) => {
  try {
    const id = req.params.id;
    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ message: "Invalid message id" });
    }
    const message = await Message.findById(id);
    if (!message) return res.status(404).json({ message: "Message not found" });
    if (message.senderId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not the sender" });
    }
    if (message.deletedAt) {
      return res.json({ message });
    }

    message.deletedAt = new Date();
    await message.save();

    const conversation = await Conversation.findById(message.conversationId);
    emitDeleted({
      participants: conversation.participants,
      messageId: message._id
    });

    res.json({ message });
  } catch (err) {
    next(err);
  }
});

router.post("/:friendId/read", async (req, res, next) => {
  try {
    if (!mongoose.isValidObjectId(req.params.friendId)) {
      return res.status(400).json({ message: "Invalid friendId" });
    }
    const userId = req.user._id;
    const friendId = req.params.friendId;
    const conversation = await Conversation.findOne({
      participants: { $all: sortedPair(userId, friendId), $size: 2 }
    });
    if (!conversation) {
      return res.json({ updated: 0 });
    }

    const readAt = new Date();
    const result = await Message.updateMany(
      {
        conversationId: conversation._id,
        senderId: friendId,
        "readBy.userId": { $ne: userId }
      },
      { $push: { readBy: { userId, readAt } } }
    );

    conversation.unread.set(userId.toString(), 0);
    await conversation.save();

    emitRead({
      conversationId: conversation._id,
      readerId: userId,
      participants: conversation.participants,
      readAt
    });

    res.json({ updated: result.modifiedCount });
  } catch (err) {
    next(err);
  }
});
```

- [ ] **Step 2: Smoke test sending a text message**

With server running and two valid JWTs (replace `<TOKEN_A>` and `<FRIEND_ID>`):

```bash
curl -s -X POST -H "Authorization: Bearer <TOKEN_A>" -H "Content-Type: application/json" \
  -d '{"type":"text","text":"hello"}' \
  http://localhost:4000/api/chats/<FRIEND_ID>/messages
```

Expected: `201` with `{"message":{...},"conversation":{...}}`.

- [ ] **Step 3: Commit**

```bash
git add backend/src/routes/chat.routes.js
git commit -m "feat(backend): chat send/edit/delete/read endpoints"
```

---

### Task 6: Backend — typing socket handlers

**Files:**
- Create: `backend/src/sockets/chat.socket.js`
- Modify: `backend/src/sockets/index.js`

- [ ] **Step 1: Create chat socket module**

```javascript
// backend/src/sockets/chat.socket.js
const { emitTyping } = require("../utils/chat-emit");

function registerChatHandlers(socket) {
  const userId = socket.user._id;

  socket.on("chat:typing_start", (payload = {}) => {
    if (!payload.friendId) return;
    emitTyping({ writerId: userId, recipientId: payload.friendId, isTyping: true });
  });

  socket.on("chat:typing_stop", (payload = {}) => {
    if (!payload.friendId) return;
    emitTyping({ writerId: userId, recipientId: payload.friendId, isTyping: false });
  });
}

module.exports = { registerChatHandlers };
```

- [ ] **Step 2: Wire into `sockets/index.js`**

In `backend/src/sockets/index.js`, add the import near the top:

```javascript
const { registerChatHandlers } = require("./chat.socket");
```

Then inside `io.on("connection", (socket) => { ... })`, AFTER the existing `socket.emit("socket:ready", ...)` line (~line 94), add:

```javascript
    registerChatHandlers(socket);
```

- [ ] **Step 3: Restart server, no errors**

Stop and restart `npm run dev`. Expected: `Server listening on port 4000` with no chat-related errors.

- [ ] **Step 4: Commit**

```bash
git add backend/src/sockets/chat.socket.js backend/src/sockets/index.js
git commit -m "feat(backend): typing indicator socket handlers"
```

---

### Task 7: Frontend — add image_picker dependency + ApiConstants

**Files:**
- Modify: `blink/pubspec.yaml`
- Modify: `blink/lib/core/constants/api_constants.dart`

- [ ] **Step 1: Add `image_picker` to pubspec**

Open `blink/pubspec.yaml` and add under `dependencies:` (alphabetical position):

```yaml
  image_picker: ^1.1.2
```

- [ ] **Step 2: Run pub get**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat pub get
```

Expected: `Got dependencies!`

- [ ] **Step 3: Add chat endpoints to `ApiConstants`**

Append to `blink/lib/core/constants/api_constants.dart` BEFORE the closing `}`:

```dart
  // Chat
  static const String chats = '/chats';
  static String chatMessages(String friendId) => '/chats/$friendId/messages';
  static String chatRead(String friendId) => '/chats/$friendId/read';
  static String editMessage(String messageId) => '/chats/messages/$messageId';
  static String deleteMessage(String messageId) => '/chats/messages/$messageId';
```

- [ ] **Step 4: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/core/constants/api_constants.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add blink/pubspec.yaml blink/pubspec.lock blink/lib/core/constants/api_constants.dart
git commit -m "feat(blink): add image_picker dep and chat endpoints"
```

---

### Task 8: Frontend — domain entities (Message + Conversation)

**Files:**
- Create: `blink/lib/domain/entities/message_entity.dart`
- Create: `blink/lib/domain/entities/conversation_entity.dart`

- [ ] **Step 1: MessageEntity**

```dart
// blink/lib/domain/entities/message_entity.dart
class MessageReadReceipt {
  final String userId;
  final DateTime readAt;
  const MessageReadReceipt({required this.userId, required this.readAt});
}

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String type; // "text" | "image"
  final String text;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final List<MessageReadReceipt> readBy;
  final String? clientMessageId; // optimistic-send dedupe key

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.readBy = const [],
    this.clientMessageId,
  });

  bool isReadBy(String userId) =>
      readBy.any((r) => r.userId == userId);

  MessageEntity copyWith({
    String? id,
    String? text,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<MessageReadReceipt>? readBy,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      text: text ?? this.text,
      imageUrl: imageUrl,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      clientMessageId: clientMessageId,
    );
  }
}
```

- [ ] **Step 2: ConversationEntity**

```dart
// blink/lib/domain/entities/conversation_entity.dart
class ConversationLastMessage {
  final String text;
  final String type;
  final String senderId;
  final DateTime? createdAt;
  const ConversationLastMessage({
    required this.text,
    required this.type,
    required this.senderId,
    this.createdAt,
  });
}

class ConversationEntity {
  final String id;
  final String otherUserId;
  final ConversationLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });
}
```

- [ ] **Step 3: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/domain/entities/message_entity.dart lib/domain/entities/conversation_entity.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add blink/lib/domain/entities/message_entity.dart blink/lib/domain/entities/conversation_entity.dart
git commit -m "feat(blink): MessageEntity and ConversationEntity"
```

---

### Task 9: Frontend — data models with JSON parsing + tests

**Files:**
- Create: `blink/lib/data/models/message_model.dart`
- Create: `blink/lib/data/models/conversation_model.dart`
- Create: `blink/test/data/models/message_model_test.dart`
- Create: `blink/test/data/models/conversation_model_test.dart`

- [ ] **Step 1: Write failing test for MessageModel**

```dart
// blink/test/data/models/message_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:blink/data/models/message_model.dart';

void main() {
  group('MessageModel.fromApi', () {
    test('parses a text message', () {
      final json = {
        '_id': 'm1',
        'conversationId': 'c1',
        'senderId': 'u1',
        'type': 'text',
        'text': 'Salom',
        'imageUrl': '',
        'createdAt': '2026-04-19T12:00:00.000Z',
        'editedAt': null,
        'deletedAt': null,
        'readBy': [
          {'userId': 'u2', 'readAt': '2026-04-19T12:01:00.000Z'}
        ]
      };
      final m = MessageModel.fromApi(json);
      expect(m.id, 'm1');
      expect(m.text, 'Salom');
      expect(m.type, 'text');
      expect(m.readBy, hasLength(1));
      expect(m.readBy.first.userId, 'u2');
      expect(m.editedAt, isNull);
      expect(m.deletedAt, isNull);
    });

    test('parses an image message and edit/delete timestamps', () {
      final json = {
        '_id': 'm2',
        'conversationId': 'c1',
        'senderId': 'u1',
        'type': 'image',
        'text': '',
        'imageUrl': '/uploads/messages/u1-1.jpg',
        'createdAt': '2026-04-19T12:00:00.000Z',
        'editedAt': '2026-04-19T12:05:00.000Z',
        'deletedAt': '2026-04-19T12:10:00.000Z',
        'readBy': []
      };
      final m = MessageModel.fromApi(json);
      expect(m.type, 'image');
      expect(m.imageUrl, '/uploads/messages/u1-1.jpg');
      expect(m.editedAt, isNotNull);
      expect(m.deletedAt, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run test (should fail — file doesn't exist)**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/models/message_model_test.dart
```

Expected: compile error / test failure.

- [ ] **Step 3: Implement MessageModel**

```dart
// blink/lib/data/models/message_model.dart
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.text,
    required super.imageUrl,
    required super.createdAt,
    super.editedAt,
    super.deletedAt,
    super.readBy,
    super.clientMessageId,
  });

  factory MessageModel.fromApi(Map<String, dynamic> json) {
    final readByRaw = (json['readBy'] as List<dynamic>?) ?? const [];
    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      text: (json['text'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String).toUtc(),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String).toUtc(),
      readBy: readByRaw
          .map((e) => MessageReadReceipt(
                userId: (e as Map<String, dynamic>)['userId'].toString(),
                readAt: DateTime.parse(e['readAt'] as String).toUtc(),
              ))
          .toList(),
    );
  }
}
```

- [ ] **Step 4: Run test — should pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/models/message_model_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Write failing test for ConversationModel**

```dart
// blink/test/data/models/conversation_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:blink/data/models/conversation_model.dart';

void main() {
  group('ConversationModel.fromApi', () {
    test('extracts otherUserId, lastMessage, unreadCount', () {
      final json = {
        '_id': 'c1',
        'participants': ['me', 'friend'],
        'lastMessage': {
          'text': 'hello',
          'type': 'text',
          'senderId': 'me',
          'createdAt': '2026-04-19T12:00:00.000Z'
        },
        'lastMessageAt': '2026-04-19T12:00:00.000Z',
        'unread': {'me': 0, 'friend': 3}
      };
      final c = ConversationModel.fromApi(json, currentUserId: 'me');
      expect(c.id, 'c1');
      expect(c.otherUserId, 'friend');
      expect(c.lastMessage?.text, 'hello');
      expect(c.unreadCount, 0); // unread of CURRENT user (me)
      expect(c.lastMessageAt, isNotNull);
    });

    test('returns null lastMessage when missing', () {
      final json = {
        '_id': 'c2',
        'participants': ['me', 'friend2'],
        'unread': {}
      };
      final c = ConversationModel.fromApi(json, currentUserId: 'me');
      expect(c.lastMessage, isNull);
      expect(c.unreadCount, 0);
    });
  });
}
```

- [ ] **Step 6: Run — fails**

- [ ] **Step 7: Implement ConversationModel**

```dart
// blink/lib/data/models/conversation_model.dart
import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
  });

  factory ConversationModel.fromApi(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final participants = ((json['participants'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    ConversationLastMessage? last;
    final lastJson = json['lastMessage'] as Map<String, dynamic>?;
    if (lastJson != null && lastJson['createdAt'] != null) {
      last = ConversationLastMessage(
        text: (lastJson['text'] ?? '').toString(),
        type: (lastJson['type'] ?? 'text').toString(),
        senderId: (lastJson['senderId'] ?? '').toString(),
        createdAt: DateTime.parse(lastJson['createdAt'] as String).toUtc(),
      );
    }

    final unreadMap = (json['unread'] as Map<String, dynamic>?) ?? const {};
    final unreadCount = (unreadMap[currentUserId] as num?)?.toInt() ?? 0;

    return ConversationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      otherUserId: otherUserId,
      lastMessage: last,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String).toUtc(),
      unreadCount: unreadCount,
    );
  }
}
```

- [ ] **Step 8: Run both model tests — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/models/
```

Expected: all tests pass.

- [ ] **Step 9: Commit**

```bash
git add blink/lib/data/models/message_model.dart blink/lib/data/models/conversation_model.dart blink/test/data/models/
git commit -m "feat(blink): MessageModel/ConversationModel with JSON parsing + tests"
```

---

### Task 10: Frontend — abstract ChatRepository

**Files:**
- Create: `blink/lib/domain/repositories/chat_repository.dart`

- [ ] **Step 1: Write the abstract interface**

```dart
// blink/lib/domain/repositories/chat_repository.dart
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  /// One-shot snapshot of the chat list (REST).
  Future<List<ConversationEntity>> fetchConversations();

  /// Live stream of the chat list (REST seed + socket updates).
  Stream<List<ConversationEntity>> watchConversations();

  /// Live stream of messages for a single conversation (REST seed + socket updates).
  /// Newest message at index 0.
  Stream<List<MessageEntity>> watchMessages(String friendId);

  /// Returns the persisted message (with server id, createdAt).
  Future<MessageEntity> sendTextMessage({
    required String friendId,
    required String text,
    required String clientMessageId,
  });

  Future<MessageEntity> sendImageMessage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  });

  Future<MessageEntity> editMessage({
    required String messageId,
    required String newText,
  });

  Future<void> deleteMessage(String messageId);

  Future<void> markAsRead(String friendId);

  /// Live "is friend currently typing?" stream.
  Stream<bool> watchTyping(String friendId);

  void emitTypingStart(String friendId);
  void emitTypingStop(String friendId);

  /// Loads older messages (for pagination).
  Future<List<MessageEntity>> loadOlderMessages({
    required String friendId,
    required DateTime before,
    int limit = 30,
  });
}
```

- [ ] **Step 2: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/domain/repositories/chat_repository.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add blink/lib/domain/repositories/chat_repository.dart
git commit -m "feat(blink): ChatRepository abstract interface"
```

---

### Task 11: Frontend — ApiChatDatasource + tests

**Files:**
- Create: `blink/lib/data/datasources/remote/api_chat_datasource.dart`
- Create: `blink/test/data/datasources/remote/api_chat_datasource_test.dart`

- [ ] **Step 1: Write failing test (mock Dio)**

```dart
// blink/test/data/datasources/remote/api_chat_datasource_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blink/data/datasources/remote/api_chat_datasource.dart';
import 'package:blink/data/datasources/remote/api_client.dart';

class _MockApiClient extends Mock implements ApiClient {}
class _MockDio extends Mock implements Dio {}

void main() {
  late _MockApiClient client;
  late _MockDio dio;
  late ApiChatDatasource ds;

  setUp(() {
    client = _MockApiClient();
    dio = _MockDio();
    when(() => client.dio).thenReturn(dio);
    ds = ApiChatDatasource(client);
  });

  test('fetchConversationsRaw GETs /chats', () async {
    when(() => dio.get('/chats')).thenAnswer(
      (_) async => Response(
        data: {'conversations': []},
        requestOptions: RequestOptions(path: '/chats'),
      ),
    );
    final result = await ds.fetchConversationsRaw();
    expect(result, isA<List<dynamic>>());
    expect(result, isEmpty);
  });

  test('sendText POSTs JSON with type=text', () async {
    when(() => dio.post(
          '/chats/friend1/messages',
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        data: {
          'message': {
            '_id': 'm1',
            'conversationId': 'c1',
            'senderId': 'me',
            'type': 'text',
            'text': 'hello',
            'imageUrl': '',
            'createdAt': '2026-04-19T12:00:00.000Z',
            'editedAt': null,
            'deletedAt': null,
            'readBy': []
          }
        },
        requestOptions: RequestOptions(path: '/chats/friend1/messages'),
      ),
    );
    final m = await ds.sendText(friendId: 'friend1', text: 'hello');
    expect(m.text, 'hello');
    expect(m.type, 'text');
  });
}
```

- [ ] **Step 2: Run — fails**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/datasources/remote/api_chat_datasource_test.dart
```

Expected: compile error.

- [ ] **Step 3: Implement ApiChatDatasource**

```dart
// blink/lib/data/datasources/remote/api_chat_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/message_model.dart';
import 'api_client.dart';

class ApiChatDatasource {
  final ApiClient _client;
  ApiChatDatasource(this._client);
  Dio get _dio => _client.dio;

  Future<List<dynamic>> fetchConversationsRaw() async {
    try {
      final res = await _dio.get(ApiConstants.chats);
      return (res.data['conversations'] as List<dynamic>?) ?? const [];
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch conversations'));
    }
  }

  Future<List<MessageModel>> fetchMessages({
    required String friendId,
    DateTime? before,
    int limit = 30,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.chatMessages(friendId),
        queryParameters: {
          if (before != null) 'before': before.toIso8601String(),
          'limit': limit,
        },
      );
      final list = (res.data['messages'] as List<dynamic>?) ?? const [];
      return list
          .map((e) => MessageModel.fromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch messages'));
    }
  }

  Future<MessageModel> sendText({
    required String friendId,
    required String text,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.chatMessages(friendId),
        data: {'type': 'text', 'text': text},
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send message'));
    }
  }

  Future<MessageModel> sendImage({
    required String friendId,
    required String imagePath,
  }) async {
    try {
      final form = FormData.fromMap({
        'type': 'image',
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(Platform.pathSeparator).last,
        ),
      });
      final res = await _dio.post(
        ApiConstants.chatMessages(friendId),
        data: form,
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send image'));
    }
  }

  Future<MessageModel> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final res = await _dio.patch(
        ApiConstants.editMessage(messageId),
        data: {'text': newText},
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to edit message'));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete(ApiConstants.deleteMessage(messageId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to delete message'));
    }
  }

  Future<void> markRead(String friendId) async {
    try {
      await _dio.post(ApiConstants.chatRead(friendId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to mark as read'));
    }
  }

  String _extract(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
```

- [ ] **Step 4: Run tests — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/datasources/remote/api_chat_datasource_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/data/datasources/remote/api_chat_datasource.dart blink/test/data/datasources/remote/api_chat_datasource_test.dart
git commit -m "feat(blink): ApiChatDatasource with Dio + tests"
```

---

### Task 12: Frontend — SocketChatDatasource

**Files:**
- Create: `blink/lib/data/datasources/remote/socket_chat_datasource.dart`

*(Socket integration is hard to unit-test without a running server. We'll rely on integration smoke + later end-to-end testing on device. This task ships untested code by intent.)*

- [ ] **Step 1: Find existing socket provider/client to reuse**

```bash
grep -n "io(" blink/lib/presentation/providers/socket_provider.dart
```

Expected: shows how the existing socket is constructed (we want to reuse the same `Socket` instance, not open a second one).

- [ ] **Step 2: Read the socket provider to understand its export**

```bash
sed -n '1,80p' blink/lib/presentation/providers/socket_provider.dart
```

Note the provider name (e.g. `socketProvider`) and the type it exposes — `SocketChatDatasource` will receive a `Socket` instance via constructor.

- [ ] **Step 3: Implement the datasource**

```dart
// blink/lib/data/datasources/remote/socket_chat_datasource.dart
import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../models/message_model.dart';
import '../../models/conversation_model.dart';

/// Streams normalized chat events. The repository merges these with REST data.
sealed class ChatEvent {}

class ChatMessageEvent extends ChatEvent {
  final MessageModel message;
  final Map<String, dynamic> conversationRaw;
  ChatMessageEvent(this.message, this.conversationRaw);
}

class ChatReadEvent extends ChatEvent {
  final String conversationId;
  final String friendId;
  final DateTime readAt;
  ChatReadEvent(this.conversationId, this.friendId, this.readAt);
}

class ChatEditedEvent extends ChatEvent {
  final String messageId;
  final String text;
  final DateTime editedAt;
  ChatEditedEvent(this.messageId, this.text, this.editedAt);
}

class ChatDeletedEvent extends ChatEvent {
  final String messageId;
  ChatDeletedEvent(this.messageId);
}

class ChatTypingEvent extends ChatEvent {
  final String friendId;
  final bool isTyping;
  ChatTypingEvent(this.friendId, this.isTyping);
}

class SocketChatDatasource {
  final io.Socket _socket;
  final _events = StreamController<ChatEvent>.broadcast();
  bool _bound = false;

  SocketChatDatasource(this._socket) {
    _bind();
  }

  Stream<ChatEvent> get events => _events.stream;

  void _bind() {
    if (_bound) return;
    _bound = true;

    _socket.on('chat:message', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatMessageEvent(
          MessageModel.fromApi(raw['message'] as Map<String, dynamic>),
          raw['conversation'] as Map<String, dynamic>,
        ));
      } catch (_) {/* malformed payload — ignore */}
    });

    _socket.on('chat:read', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatReadEvent(
          raw['conversationId'] as String,
          raw['friendId'] as String,
          DateTime.parse(raw['readAt'] as String).toUtc(),
        ));
      } catch (_) {}
    });

    _socket.on('chat:edited', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatEditedEvent(
          raw['messageId'] as String,
          raw['text'] as String,
          DateTime.parse(raw['editedAt'] as String).toUtc(),
        ));
      } catch (_) {}
    });

    _socket.on('chat:deleted', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatDeletedEvent(raw['messageId'] as String));
      } catch (_) {}
    });

    _socket.on('chat:typing', (data) {
      try {
        final raw = data as Map<String, dynamic>;
        _events.add(ChatTypingEvent(
          raw['friendId'] as String,
          raw['isTyping'] as bool,
        ));
      } catch (_) {}
    });
  }

  void emitTypingStart(String friendId) {
    _socket.emit('chat:typing_start', {'friendId': friendId});
  }

  void emitTypingStop(String friendId) {
    _socket.emit('chat:typing_stop', {'friendId': friendId});
  }

  Future<void> dispose() async {
    await _events.close();
  }
}
```

- [ ] **Step 4: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/data/datasources/remote/socket_chat_datasource.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/data/datasources/remote/socket_chat_datasource.dart
git commit -m "feat(blink): SocketChatDatasource (chat event stream)"
```

---

### Task 13: Frontend — ChatRepositoryImpl + tests

**Files:**
- Create: `blink/lib/data/repositories/chat_repository_impl.dart`
- Create: `blink/test/data/repositories/chat_repository_impl_test.dart`

- [ ] **Step 1: Write failing tests for the merge logic**

```dart
// blink/test/data/repositories/chat_repository_impl_test.dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:blink/data/datasources/remote/api_chat_datasource.dart';
import 'package:blink/data/datasources/remote/socket_chat_datasource.dart';
import 'package:blink/data/models/message_model.dart';
import 'package:blink/data/repositories/chat_repository_impl.dart';

class _MockApi extends Mock implements ApiChatDatasource {}
class _MockSocket extends Mock implements SocketChatDatasource {}

MessageModel _msg(String id, String convId, String sender, String text) =>
    MessageModel(
      id: id,
      conversationId: convId,
      senderId: sender,
      type: 'text',
      text: text,
      imageUrl: '',
      createdAt: DateTime.parse('2026-04-19T12:00:00Z'),
    );

void main() {
  late _MockApi api;
  late _MockSocket socket;
  late StreamController<ChatEvent> events;
  late ChatRepositoryImpl repo;

  setUp(() {
    api = _MockApi();
    socket = _MockSocket();
    events = StreamController<ChatEvent>.broadcast();
    when(() => socket.events).thenAnswer((_) => events.stream);
    repo = ChatRepositoryImpl(
      api: api,
      socket: socket,
      currentUserId: 'me',
    );
  });

  tearDown(() => events.close());

  test('watchMessages emits REST seed then socket-pushed message', () async {
    when(() => api.fetchMessages(friendId: 'f1', limit: any(named: 'limit')))
        .thenAnswer((_) async => [_msg('m1', 'c1', 'f1', 'hi')]);

    final stream = repo.watchMessages('f1');
    final seed = await stream.first;
    expect(seed.map((m) => m.id).toList(), ['m1']);

    final next = stream.first; // wait for next emission
    final pushed = _msg('m2', 'c1', 'f1', 'second');
    events.add(ChatMessageEvent(pushed, {
      '_id': 'c1',
      'participants': ['me', 'f1'],
      'unread': {'me': 1, 'f1': 0}
    }));
    final updated = await next;
    expect(updated.map((m) => m.id).toList(), ['m2', 'm1']);
  });
}
```

- [ ] **Step 2: Run — fails**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/repositories/chat_repository_impl_test.dart
```

Expected: compile error.

- [ ] **Step 3: Implement ChatRepositoryImpl**

```dart
// blink/lib/data/repositories/chat_repository_impl.dart
import 'dart:async';

import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/api_chat_datasource.dart';
import '../datasources/remote/socket_chat_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiChatDatasource api;
  final SocketChatDatasource socket;
  final String currentUserId;

  /// In-memory caches keyed by friendId for messages, by friendId for conversations.
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, StreamController<List<MessageEntity>>> _messageStreams = {};
  final Map<String, ConversationModel> _conversations = {};
  final StreamController<List<ConversationEntity>> _conversationsCtrl =
      StreamController.broadcast();
  final Map<String, StreamController<bool>> _typing = {};

  late final StreamSubscription _socketSub;

  ChatRepositoryImpl({
    required this.api,
    required this.socket,
    required this.currentUserId,
  }) {
    _socketSub = socket.events.listen(_onSocketEvent);
  }

  void dispose() {
    _socketSub.cancel();
    _conversationsCtrl.close();
    for (final c in _messageStreams.values) {
      c.close();
    }
    for (final c in _typing.values) {
      c.close();
    }
  }

  // ── Conversations ────────────────────────────────────────────

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    final raw = await api.fetchConversationsRaw();
    final list = raw
        .map((e) => ConversationModel.fromApi(
              e as Map<String, dynamic>,
              currentUserId: currentUserId,
            ))
        .toList();
    _conversations
      ..clear()
      ..addEntries(list.map((c) => MapEntry(c.otherUserId, c)));
    _conversationsCtrl.add(_sortedConversations());
    return list;
  }

  @override
  Stream<List<ConversationEntity>> watchConversations() {
    if (_conversations.isEmpty) {
      // seed lazily
      fetchConversations();
    } else {
      // Re-emit current snapshot for late subscribers.
      scheduleMicrotask(
        () => _conversationsCtrl.add(_sortedConversations()),
      );
    }
    return _conversationsCtrl.stream;
  }

  List<ConversationEntity> _sortedConversations() {
    final list = _conversations.values.toList();
    list.sort((a, b) {
      final ad = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return list;
  }

  // ── Messages ─────────────────────────────────────────────────

  @override
  Stream<List<MessageEntity>> watchMessages(String friendId) {
    final ctrl = _messageStreams.putIfAbsent(
      friendId,
      () => StreamController<List<MessageEntity>>.broadcast(),
    );
    // Lazy seed
    api.fetchMessages(friendId: friendId).then((seed) {
      _messages[friendId] = seed;
      ctrl.add(List.unmodifiable(seed));
    }).catchError((_) {/* swallow — UI shows empty */});
    return ctrl.stream;
  }

  @override
  Future<List<MessageEntity>> loadOlderMessages({
    required String friendId,
    required DateTime before,
    int limit = 30,
  }) async {
    final older = await api.fetchMessages(
      friendId: friendId,
      before: before,
      limit: limit,
    );
    final cache = _messages[friendId] ?? <MessageModel>[];
    final merged = [...cache, ...older];
    _messages[friendId] = merged;
    _messageStreams[friendId]?.add(List.unmodifiable(merged));
    return older;
  }

  @override
  Future<MessageEntity> sendTextMessage({
    required String friendId,
    required String text,
    required String clientMessageId,
  }) async {
    final msg = await api.sendText(friendId: friendId, text: text);
    _insertMessage(friendId, msg);
    return msg;
  }

  @override
  Future<MessageEntity> sendImageMessage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  }) async {
    final msg = await api.sendImage(friendId: friendId, imagePath: imagePath);
    _insertMessage(friendId, msg);
    return msg;
  }

  @override
  Future<MessageEntity> editMessage({
    required String messageId,
    required String newText,
  }) async {
    final updated = await api.editMessage(
      messageId: messageId,
      newText: newText,
    );
    _replaceMessage(updated);
    return updated;
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await api.deleteMessage(messageId);
    _markDeleted(messageId);
  }

  @override
  Future<void> markAsRead(String friendId) async {
    await api.markRead(friendId);
    final conv = _conversations[friendId];
    if (conv != null) {
      _conversations[friendId] = ConversationModel(
        id: conv.id,
        otherUserId: conv.otherUserId,
        lastMessage: conv.lastMessage is ConversationLastMessage
            ? conv.lastMessage as ConversationLastMessage
            : null,
        lastMessageAt: conv.lastMessageAt,
        unreadCount: 0,
      );
      _conversationsCtrl.add(_sortedConversations());
    }
  }

  // ── Typing ───────────────────────────────────────────────────

  @override
  Stream<bool> watchTyping(String friendId) {
    final ctrl = _typing.putIfAbsent(
      friendId,
      () => StreamController<bool>.broadcast(),
    );
    return ctrl.stream;
  }

  @override
  void emitTypingStart(String friendId) => socket.emitTypingStart(friendId);
  @override
  void emitTypingStop(String friendId) => socket.emitTypingStop(friendId);

  // ── Socket events → caches ───────────────────────────────────

  void _onSocketEvent(ChatEvent event) {
    switch (event) {
      case ChatMessageEvent e:
        // Determine friendId from the conversation participants.
        final participants = ((e.conversationRaw['participants'] as List?) ?? [])
            .map((x) => x.toString())
            .toList();
        final friendId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        if (friendId.isEmpty) return;
        _insertMessage(friendId, e.message);
        // Refresh conversation cache from raw.
        _conversations[friendId] = ConversationModel.fromApi(
          e.conversationRaw,
          currentUserId: currentUserId,
        );
        _conversationsCtrl.add(_sortedConversations());

      case ChatEditedEvent e:
        for (final msgs in _messages.entries) {
          final idx = msgs.value.indexWhere((m) => m.id == e.messageId);
          if (idx >= 0) {
            final updated = msgs.value[idx].copyWith(
              text: e.text,
              editedAt: e.editedAt,
            ) as MessageModel;
            msgs.value[idx] = updated;
            _messageStreams[msgs.key]?.add(List.unmodifiable(msgs.value));
          }
        }

      case ChatDeletedEvent e:
        _markDeleted(e.messageId);

      case ChatReadEvent e:
        // Mark our outbound messages as read by the friend.
        for (final entry in _messages.entries) {
          var mutated = false;
          final updated = entry.value.map((m) {
            if (m.senderId == currentUserId &&
                !m.isReadBy(e.friendId)) {
              mutated = true;
              return m.copyWith(readBy: [
                ...m.readBy,
                MessageReadReceipt(userId: e.friendId, readAt: e.readAt),
              ]) as MessageModel;
            }
            return m;
          }).toList();
          if (mutated) {
            _messages[entry.key] = updated;
            _messageStreams[entry.key]?.add(List.unmodifiable(updated));
          }
        }

      case ChatTypingEvent e:
        final ctrl = _typing.putIfAbsent(
          e.friendId,
          () => StreamController<bool>.broadcast(),
        );
        ctrl.add(e.isTyping);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────

  void _insertMessage(String friendId, MessageModel msg) {
    final list = _messages.putIfAbsent(friendId, () => <MessageModel>[]);
    if (list.any((m) => m.id == msg.id)) return; // dedupe
    list.insert(0, msg);
    _messageStreams[friendId]?.add(List.unmodifiable(list));
  }

  void _replaceMessage(MessageModel msg) {
    for (final entry in _messages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == msg.id);
      if (idx >= 0) {
        entry.value[idx] = msg;
        _messageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }

  void _markDeleted(String messageId) {
    for (final entry in _messages.entries) {
      final idx = entry.value.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        final m = entry.value[idx];
        entry.value[idx] = m.copyWith(deletedAt: DateTime.now()) as MessageModel;
        _messageStreams[entry.key]?.add(List.unmodifiable(entry.value));
        return;
      }
    }
  }
}
```

- [ ] **Step 4: Run tests — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/data/repositories/chat_repository_impl_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/data/repositories/chat_repository_impl.dart blink/test/data/repositories/chat_repository_impl_test.dart
git commit -m "feat(blink): ChatRepositoryImpl with REST+socket merge + tests"
```

---

### Task 14: Frontend — use cases (4 small files)

**Files:**
- Create: `blink/lib/domain/usecases/chat/send_message_usecase.dart`
- Create: `blink/lib/domain/usecases/chat/edit_message_usecase.dart`
- Create: `blink/lib/domain/usecases/chat/delete_message_usecase.dart`
- Create: `blink/lib/domain/usecases/chat/mark_as_read_usecase.dart`

- [ ] **Step 1: SendMessageUseCase**

```dart
// blink/lib/domain/usecases/chat/send_message_usecase.dart
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repo;
  SendMessageUseCase(this.repo);

  Future<MessageEntity> sendText({
    required String friendId,
    required String text,
    required String clientMessageId,
  }) =>
      repo.sendTextMessage(
        friendId: friendId,
        text: text,
        clientMessageId: clientMessageId,
      );

  Future<MessageEntity> sendImage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  }) =>
      repo.sendImageMessage(
        friendId: friendId,
        imagePath: imagePath,
        clientMessageId: clientMessageId,
      );
}
```

- [ ] **Step 2: EditMessageUseCase**

```dart
// blink/lib/domain/usecases/chat/edit_message_usecase.dart
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

class EditMessageUseCase {
  final ChatRepository repo;
  EditMessageUseCase(this.repo);

  Future<MessageEntity> call({
    required String messageId,
    required String newText,
  }) =>
      repo.editMessage(messageId: messageId, newText: newText);
}
```

- [ ] **Step 3: DeleteMessageUseCase**

```dart
// blink/lib/domain/usecases/chat/delete_message_usecase.dart
import '../../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repo;
  DeleteMessageUseCase(this.repo);

  Future<void> call(String messageId) => repo.deleteMessage(messageId);
}
```

- [ ] **Step 4: MarkAsReadUseCase**

```dart
// blink/lib/domain/usecases/chat/mark_as_read_usecase.dart
import '../../repositories/chat_repository.dart';

class MarkAsReadUseCase {
  final ChatRepository repo;
  MarkAsReadUseCase(this.repo);

  Future<void> call(String friendId) => repo.markAsRead(friendId);
}
```

- [ ] **Step 5: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/domain/usecases/chat/
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add blink/lib/domain/usecases/chat/
git commit -m "feat(blink): chat use cases (send/edit/delete/markRead)"
```

---

### Task 15: Frontend — chat_provider.dart (Riverpod)

**Files:**
- Create: `blink/lib/presentation/providers/chat_provider.dart`

- [ ] **Step 1: Inspect socket_provider for the existing Socket export**

```bash
sed -n '1,80p' blink/lib/presentation/providers/socket_provider.dart
```

Note the provider name (e.g. `socketProvider`) and the type — chat datasource will receive that `Socket` instance.

- [ ] **Step 2: Write the providers**

```dart
// blink/lib/presentation/providers/chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/api_chat_datasource.dart';
import '../../data/datasources/remote/socket_chat_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/chat/delete_message_usecase.dart';
import '../../domain/usecases/chat/edit_message_usecase.dart';
import '../../domain/usecases/chat/mark_as_read_usecase.dart';
import '../../domain/usecases/chat/send_message_usecase.dart';
import 'auth_provider.dart';
import 'socket_provider.dart';

// ── Datasources ─────────────────────────────────────────────

final apiChatDatasourceProvider = Provider<ApiChatDatasource>((ref) {
  return ApiChatDatasource(ref.watch(apiClientProvider));
});

final socketChatDatasourceProvider = Provider<SocketChatDatasource>((ref) {
  final socket = ref.watch(socketProvider);
  final ds = SocketChatDatasource(socket);
  ref.onDispose(ds.dispose);
  return ds;
});

// ── Repository ──────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) {
    throw StateError('chatRepositoryProvider requires an authenticated user');
  }
  final repo = ChatRepositoryImpl(
    api: ref.watch(apiChatDatasourceProvider),
    socket: ref.watch(socketChatDatasourceProvider),
    currentUserId: uid,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

// ── Use cases ───────────────────────────────────────────────

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final editMessageUseCaseProvider = Provider<EditMessageUseCase>((ref) {
  return EditMessageUseCase(ref.watch(chatRepositoryProvider));
});

final deleteMessageUseCaseProvider = Provider<DeleteMessageUseCase>((ref) {
  return DeleteMessageUseCase(ref.watch(chatRepositoryProvider));
});

final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  return MarkAsReadUseCase(ref.watch(chatRepositoryProvider));
});

// ── Streams ─────────────────────────────────────────────────

/// Map of friendId → ConversationEntity (only friends with a conversation).
final conversationsProvider =
    StreamProvider<Map<String, ConversationEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchConversations().map(
        (list) => {for (final c in list) c.otherUserId: c},
      );
});

final messagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, friendId) {
  return ref.watch(chatRepositoryProvider).watchMessages(friendId);
});

final typingProvider =
    StreamProvider.family<bool, String>((ref, friendId) {
  return ref.watch(chatRepositoryProvider).watchTyping(friendId);
});
```

*(Note: `apiClientProvider` and `socketProvider` are defined in existing files — `apiClientProvider` lives next to `auth_provider.dart` per the user_provider pattern; if it lives elsewhere, adjust the import. `socketProvider` is in `socket_provider.dart` — confirm in Step 1.)*

- [ ] **Step 3: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/presentation/providers/chat_provider.dart
```

Expected: `No issues found!` (if there are missing imports for `apiClientProvider` or `socketProvider`, fix them based on Step 1's findings).

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/providers/chat_provider.dart
git commit -m "feat(blink): chat Riverpod providers"
```

---

### Task 16: Frontend — MessageBubble widget + tests

**Files:**
- Create: `blink/lib/presentation/screens/chat/widgets/message_bubble.dart`
- Create: `blink/test/presentation/screens/chat/widgets/message_bubble_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// blink/test/presentation/screens/chat/widgets/message_bubble_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/message_entity.dart';
import 'package:blink/presentation/screens/chat/widgets/message_bubble.dart';

MessageEntity _msg({
  String text = 'hello',
  String type = 'text',
  String imageUrl = '',
  DateTime? editedAt,
  DateTime? deletedAt,
  List<MessageReadReceipt> readBy = const [],
  String senderId = 'me',
}) =>
    MessageEntity(
      id: 'm1',
      conversationId: 'c1',
      senderId: senderId,
      type: type,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.parse('2026-04-19T12:00:00Z'),
      editedAt: editedAt,
      deletedAt: deletedAt,
      readBy: readBy,
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MessageBubble', () {
    testWidgets('text message shows text and time', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(message: _msg(), isMine: true, friendId: 'f1'),
      ));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('mine + read shows ✓✓ blue', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(readBy: [
            MessageReadReceipt(userId: 'f1', readAt: DateTime.now())
          ]),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.byKey(const ValueKey('msg-status-read')), findsOneWidget);
    });

    testWidgets('mine + unread shows ✓ grey', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.byKey(const ValueKey('msg-status-delivered')), findsOneWidget);
    });

    testWidgets('editedAt shows "(tahrirlandi)" tag', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(editedAt: DateTime.now()),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.textContaining('tahrirlandi'), findsOneWidget);
    });

    testWidgets('deleted shows deleted placeholder', (tester) async {
      await tester.pumpWidget(_wrap(
        MessageBubble(
          message: _msg(deletedAt: DateTime.now()),
          isMine: true,
          friendId: 'f1',
        ),
      ));
      expect(find.textContaining("o'chirildi"), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run — fails (no widget yet)**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/chat/widgets/message_bubble_test.dart
```

Expected: compile error.

- [ ] **Step 3: Implement MessageBubble**

```dart
// blink/lib/presentation/screens/chat/widgets/message_bubble.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final String friendId;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.friendId,
    this.onLongPress,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = message.deletedAt != null;
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isMine
        ? GlassTokens.tintProminent
        : Colors.white.withOpacity(0.85);

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: isDeleted ? null : onLongPress,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
              border: Border.all(
                color: GlassTokens.strokeSpecular,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDeleted) ..._deleted()
                else if (message.type == 'image') ..._image(context)
                else _text(),
                const SizedBox(height: 4),
                _meta(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _text() => Text(
        message.text,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      );

  List<Widget> _image(BuildContext context) => [
        GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(GlassTokens.radiusCard - 4),
            child: CachedNetworkImage(
              imageUrl: _imageUrlFull(),
              width: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ];

  List<Widget> _deleted() => const [
        Text(
          "🚫 Bu xabar o'chirildi",
          style: TextStyle(
            color: Colors.black45,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ];

  Widget _meta() {
    final hh = message.createdAt.hour.toString().padLeft(2, '0');
    final mm = message.createdAt.minute.toString().padLeft(2, '0');
    final time = '$hh:$mm';
    final isReadByFriend = message.isReadBy(friendId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.editedAt != null && message.deletedAt == null)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Text(
              '(tahrirlandi)',
              style: TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ),
        Text(time,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        if (isMine && message.deletedAt == null) ...[
          const SizedBox(width: 4),
          if (isReadByFriend)
            const Icon(Icons.done_all,
                key: ValueKey('msg-status-read'),
                size: 14,
                color: Colors.blue)
          else
            const Icon(Icons.done,
                key: ValueKey('msg-status-delivered'),
                size: 14,
                color: Colors.black45),
        ],
      ],
    );
  }

  String _imageUrlFull() {
    if (message.imageUrl.startsWith('http')) return message.imageUrl;
    final host = ApiConstants.socketUrl; // host without /api suffix
    return '$host${message.imageUrl}';
  }
}
```

- [ ] **Step 4: Run tests — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/chat/widgets/message_bubble_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/presentation/screens/chat/widgets/message_bubble.dart blink/test/presentation/screens/chat/widgets/message_bubble_test.dart
git commit -m "feat(blink): MessageBubble widget + tests"
```

---

### Task 17: Frontend — TypingIndicator widget + test

**Files:**
- Create: `blink/lib/presentation/screens/chat/widgets/typing_indicator.dart`
- Create: `blink/test/presentation/screens/chat/widgets/typing_indicator_test.dart`

- [ ] **Step 1: Failing test**

```dart
// blink/test/presentation/screens/chat/widgets/typing_indicator_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/screens/chat/widgets/typing_indicator.dart';

void main() {
  testWidgets('TypingIndicator renders 3 dots', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: TypingIndicator()),
    ));
    expect(find.byKey(const ValueKey('typing-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('typing-dot-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('typing-dot-2')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run — fails**

- [ ] **Step 3: Implement**

```dart
// blink/lib/presentation/screens/chat/widgets/typing_indicator.dart
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = ((_ctrl.value + i * 0.2) % 1.0);
              final opacity = (t < 0.5 ? t * 2 : 2 - t * 2).clamp(0.3, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    key: ValueKey('typing-dot-$i'),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 4: Run — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/chat/widgets/typing_indicator_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/presentation/screens/chat/widgets/typing_indicator.dart blink/test/presentation/screens/chat/widgets/typing_indicator_test.dart
git commit -m "feat(blink): TypingIndicator widget + test"
```

---

### Task 18: Frontend — MessageInput widget + tests

**Files:**
- Create: `blink/lib/presentation/screens/chat/widgets/message_input.dart`
- Create: `blink/test/presentation/screens/chat/widgets/message_input_test.dart`

- [ ] **Step 1: Failing tests**

```dart
// blink/test/presentation/screens/chat/widgets/message_input_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/presentation/screens/chat/widgets/message_input.dart';

void main() {
  group('MessageInput', () {
    testWidgets('send button disabled when text is empty and no image',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (_) {},
            onSendImage: (_) {},
            onTypingChanged: (_) {},
          ),
        ),
      ));
      final btn = tester.widget<IconButton>(
        find.byKey(const ValueKey('send-button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('typing in field enables send and triggers onTypingChanged',
        (tester) async {
      var typingState = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (_) {},
            onSendImage: (_) {},
            onTypingChanged: (v) => typingState = v,
          ),
        ),
      ));
      await tester.enterText(
          find.byKey(const ValueKey('message-input-field')), 'hello');
      await tester.pump();
      expect(typingState, isTrue);
      final btn = tester.widget<IconButton>(
        find.byKey(const ValueKey('send-button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('sending text clears the field', (tester) async {
      String? sent;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(
            onSendText: (t) => sent = t,
            onSendImage: (_) {},
            onTypingChanged: (_) {},
          ),
        ),
      ));
      await tester.enterText(
          find.byKey(const ValueKey('message-input-field')), 'salom');
      await tester.tap(find.byKey(const ValueKey('send-button')));
      await tester.pump();
      expect(sent, 'salom');
      expect(find.text('salom'), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run — fails**

- [ ] **Step 3: Implement MessageInput**

```dart
// blink/lib/presentation/screens/chat/widgets/message_input.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSendText;
  final ValueChanged<String> onSendImage; // imagePath
  final ValueChanged<bool> onTypingChanged;

  const MessageInput({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onTypingChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _ctrl = TextEditingController();
  bool _wasTyping = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final isTyping = _ctrl.text.trim().isNotEmpty;
    if (isTyping != _wasTyping) {
      _wasTyping = isTyping;
      widget.onTypingChanged(isTyping);
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (picked != null) {
      widget.onSendImage(picked.path);
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _ctrl.clear();
    widget.onTypingChanged(false);
    _wasTyping = false;
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _ctrl.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: Colors.white.withOpacity(0.6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                key: const ValueKey('message-input-field'),
                controller: _ctrl,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Xabar yozing…",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(
              key: const ValueKey('send-button'),
              icon: const Icon(Icons.send),
              color: Colors.blue,
              onPressed: canSend ? _send : null,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/chat/widgets/message_input_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add blink/lib/presentation/screens/chat/widgets/message_input.dart blink/test/presentation/screens/chat/widgets/message_input_test.dart
git commit -m "feat(blink): MessageInput widget (text + image picker) + tests"
```

---

### Task 19: Frontend — ChatAppBar + ImageMessageViewer widgets

**Files:**
- Create: `blink/lib/presentation/screens/chat/widgets/chat_app_bar.dart`
- Create: `blink/lib/presentation/screens/chat/widgets/image_message_viewer.dart`

- [ ] **Step 1: ChatAppBar**

```dart
// blink/lib/presentation/screens/chat/widgets/chat_app_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../widgets/glass/glass_app_bar.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final bool isTyping;

  const ChatAppBar({
    super.key,
    required this.displayName,
    required this.isOnline,
    required this.isTyping,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final subtitle = isTyping
        ? 'yozmoqda…'
        : (isOnline ? 'online' : 'offline');
    return GlassAppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: const TextStyle(fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: ImageMessageViewer**

```dart
// blink/lib/presentation/screens/chat/widgets/image_message_viewer.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageMessageViewer extends StatelessWidget {
  final String imageUrl;

  const ImageMessageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/presentation/screens/chat/widgets/chat_app_bar.dart lib/presentation/screens/chat/widgets/image_message_viewer.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/screens/chat/widgets/chat_app_bar.dart blink/lib/presentation/screens/chat/widgets/image_message_viewer.dart
git commit -m "feat(blink): ChatAppBar and ImageMessageViewer widgets"
```

---

### Task 20: Frontend — ChatScreen (composition) + smoke test

**Files:**
- Create: `blink/lib/presentation/screens/chat/chat_screen.dart`
- Create: `blink/test/presentation/screens/chat/chat_screen_test.dart`

- [ ] **Step 1: Failing smoke test (renders empty state without crashing)**

```dart
// blink/test/presentation/screens/chat/chat_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/friend_entity.dart';
import 'package:blink/presentation/screens/chat/chat_screen.dart';

void main() {
  testWidgets('ChatScreen renders without crashing for empty state',
      (tester) async {
    final friend = FriendEntity(
      id: 'f1',
      username: 'john',
      displayName: 'John',
      avatarUrl: null,
      isOnline: false,
      smartStatus: 'offline',
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ChatScreen(friend: friend),
        ),
      ),
    );
    // Either the loading spinner OR the empty state shows up.
    final hasSpinner = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasEmpty = find.textContaining("Xabar").evaluate().isNotEmpty;
    expect(hasSpinner || hasEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Inspect FriendEntity to confirm constructor shape**

```bash
sed -n '1,40p' blink/lib/domain/entities/friend_entity.dart
```

Adjust the test's `FriendEntity(...)` constructor to match the actual fields if they differ.

- [ ] **Step 3: Implement ChatScreen**

```dart
// blink/lib/presentation/screens/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/image_message_viewer.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final FriendEntity friend;
  const ChatScreen({super.key, required this.friend});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Mark conversation as read on entry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markAsReadUseCaseProvider).call(widget.friend.id);
    });
  }

  Future<void> _onLongPress(MessageEntity msg, bool isMine) async {
    final isText = msg.type == 'text';
    final canEdit = isMine &&
        isText &&
        DateTime.now().difference(msg.createdAt).inHours < 24;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            if (isText)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Nusxa olish'),
                onTap: () => Navigator.pop(context, 'copy'),
              ),
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Tahrirlash'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("O'chirish",
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (action == 'edit') {
      await _openEditDialog(msg);
    } else if (action == 'delete') {
      await ref.read(deleteMessageUseCaseProvider).call(msg.id);
    }
  }

  Future<void> _openEditDialog(MessageEntity msg) async {
    final ctrl = TextEditingController(text: msg.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tahrirlash'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty && newText != msg.text) {
      await ref
          .read(editMessageUseCaseProvider)
          .call(messageId: msg.id, newText: newText);
    }
  }

  String _imageUrlFull(String urlOrPath) {
    if (urlOrPath.startsWith('http')) return urlOrPath;
    return '${ApiConstants.socketUrl}$urlOrPath';
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.friend.id));
    final typingAsync = ref.watch(typingProvider(widget.friend.id));
    final myUid = ref.watch(authStateProvider).value;
    final friendId = widget.friend.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(
        displayName: widget.friend.displayName.isNotEmpty
            ? widget.friend.displayName
            : widget.friend.username,
        avatarUrl: widget.friend.avatarUrl,
        isOnline: widget.friend.isOnline,
        isTyping: typingAsync.value ?? false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Xato: $e')),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text("Xabarlar yo'q. Birinchi bo'lib salom yozing."),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        final isMine = m.senderId == myUid;
                        return MessageBubble(
                          message: m,
                          isMine: isMine,
                          friendId: friendId,
                          onLongPress: () => _onLongPress(m, isMine),
                          onImageTap: m.type == 'image' && m.imageUrl.isNotEmpty
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImageMessageViewer(
                                        imageUrl: _imageUrlFull(m.imageUrl),
                                      ),
                                    ),
                                  )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              if (typingAsync.value == true) const TypingIndicator(),
              MessageInput(
                onSendText: (text) {
                  ref.read(sendMessageUseCaseProvider).sendText(
                        friendId: friendId,
                        text: text,
                        clientMessageId:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                      );
                },
                onSendImage: (path) {
                  ref.read(sendMessageUseCaseProvider).sendImage(
                        friendId: friendId,
                        imagePath: path,
                        clientMessageId:
                            DateTime.now().microsecondsSinceEpoch.toString(),
                      );
                },
                onTypingChanged: (isTyping) {
                  final repo = ref.read(chatRepositoryProvider);
                  if (isTyping) {
                    repo.emitTypingStart(friendId);
                  } else {
                    repo.emitTypingStop(friendId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run smoke test — pass**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/chat/chat_screen_test.dart
```

Expected: `All tests passed!` (test only checks the empty/loading state — wiring is exercised on device).

- [ ] **Step 5: Commit**

```bash
git add blink/lib/presentation/screens/chat/chat_screen.dart blink/test/presentation/screens/chat/chat_screen_test.dart
git commit -m "feat(blink): ChatScreen composition + smoke test"
```

---

### Task 21: Frontend — Router add /chat/:friendId route

**Files:**
- Modify: `blink/lib/core/router/app_router.dart`

- [ ] **Step 1: Add the chat route**

In `app_router.dart`:

1. Add the imports near the top (alongside other screen imports):

```dart
import '../../domain/entities/friend_entity.dart';
import '../../presentation/screens/chat/chat_screen.dart';
```

2. Add a constant inside the `AppRoutes` class:

```dart
  static const chat = '/chat';
  static String chatFor(String friendId) => '/chat/$friendId';
```

3. Inside the `routes:` array, append (BEFORE the closing `]`):

```dart
      GoRoute(
        path: '${AppRoutes.chat}/:friendId',
        builder: (context, state) {
          final friend = state.extra as FriendEntity?;
          if (friend == null) {
            // Defensive fallback — without a FriendEntity we can't render the
            // app bar. In practice the caller always passes one.
            return const Scaffold(body: Center(child: Text('Friend not provided')));
          }
          return ChatScreen(friend: friend);
        },
      ),
```

- [ ] **Step 2: Verify analyze**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/core/router/app_router.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add blink/lib/core/router/app_router.dart
git commit -m "feat(blink): add /chat/:friendId route"
```

---

### Task 22: Frontend — friend_tile.dart (last message preview + unread + nav)

**Files:**
- Modify: `blink/lib/presentation/screens/friends/widgets/friend_tile.dart`

- [ ] **Step 1: Replace friend_tile.dart with chat-enriched version**

```dart
// blink/lib/presentation/screens/friends/widgets/friend_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/conversation_entity.dart';
import '../../../../domain/entities/friend_entity.dart';
import '../../../widgets/glass/glass_card.dart';

class FriendTile extends StatelessWidget {
  final FriendEntity friend;
  final ConversationEntity? conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const FriendTile({
    super.key,
    required this.friend,
    this.conversation,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation?.unreadCount ?? 0;
    final preview = _previewLine();

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: friend.avatarUrl != null
                    ? CachedNetworkImageProvider(friend.avatarUrl!)
                    : null,
                child: friend.avatarUrl == null
                    ? Text(
                        friend.displayName.isNotEmpty
                            ? friend.displayName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              if (friend.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onLongPress: onLongPress,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          friend.displayName.isNotEmpty
                              ? friend.displayName
                              : friend.username,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation?.lastMessageAt != null)
                        Text(
                          _formatTime(conversation!.lastMessageAt!),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(
                            fontSize: 12,
                            color: unread > 0
                                ? Colors.black87
                                : Colors.black54,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  String _previewLine() {
    final last = conversation?.lastMessage;
    if (last != null) {
      if (last.type == 'image') return '📷 Rasm';
      if (last.text.isNotEmpty) return last.text;
    }
    return '@${friend.username} · ${friend.smartStatus}';
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final isSameDay = t.year == now.year && t.month == now.month && t.day == now.day;
    if (isSameDay) {
      return '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';
    }
    final yest = now.subtract(const Duration(days: 1));
    final isYesterday =
        t.year == yest.year && t.month == yest.month && t.day == yest.day;
    if (isYesterday) return 'Kecha';
    return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: Add a friend_tile widget test**

```dart
// blink/test/presentation/screens/friends/widgets/friend_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blink/domain/entities/conversation_entity.dart';
import 'package:blink/domain/entities/friend_entity.dart';
import 'package:blink/presentation/screens/friends/widgets/friend_tile.dart';

FriendEntity _friend({bool online = false}) => FriendEntity(
      id: 'f1',
      username: 'john',
      displayName: 'John Doe',
      avatarUrl: null,
      isOnline: online,
      smartStatus: 'idle',
    );

void main() {
  group('FriendTile', () {
    testWidgets('shows last message preview when conversation exists',
        (tester) async {
      final convo = ConversationEntity(
        id: 'c1',
        otherUserId: 'f1',
        lastMessage: ConversationLastMessage(
          text: 'Salom',
          type: 'text',
          senderId: 'f1',
          createdAt: DateTime.now(),
        ),
        lastMessageAt: DateTime.now(),
        unreadCount: 2,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend(), conversation: convo),
        ),
      ));
      expect(find.text('Salom'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('falls back to status when no conversation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend()),
        ),
      ));
      expect(find.textContaining('@john'), findsOneWidget);
      expect(find.textContaining('idle'), findsOneWidget);
    });

    testWidgets('image-only last message shows "📷 Rasm"', (tester) async {
      final convo = ConversationEntity(
        id: 'c1',
        otherUserId: 'f1',
        lastMessage: ConversationLastMessage(
          text: '',
          type: 'image',
          senderId: 'f1',
          createdAt: DateTime.now(),
        ),
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
      );
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FriendTile(friend: _friend(), conversation: convo),
        ),
      ));
      expect(find.text('📷 Rasm'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Run analyze + tests**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/presentation/screens/friends/widgets/friend_tile.dart && /c/Users/user/.vscode/flutter/bin/flutter.bat test test/presentation/screens/friends/widgets/friend_tile_test.dart
```

Expected: clean analyze + all tests pass.

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/screens/friends/widgets/friend_tile.dart blink/test/presentation/screens/friends/widgets/friend_tile_test.dart
git commit -m "feat(blink): friend tile shows chat preview + unread badge"
```

---

### Task 23: Frontend — wire conversationsProvider into FriendsListTab

**Files:**
- Modify: `blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart`

- [ ] **Step 1: Read the current FriendsListTab**

```bash
sed -n '1,120p' blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart
```

- [ ] **Step 2: Wire conversations + chat navigation**

The exact edit depends on the file's current shape, but the integration pattern is:

1. Make `FriendsListTab` a `ConsumerWidget` (or `ConsumerStatefulWidget`).
2. Watch `conversationsProvider` alongside the existing friends provider.
3. For each `FriendEntity friend` rendered, look up `conversationsAsync.value?[friend.id]` and pass it as `FriendTile(... conversation: convo, onTap: () => context.push(AppRoutes.chatFor(friend.id), extra: friend), ...)`.

Example shape (replace the existing `ListView.builder` body with this):

```dart
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/friends_provider.dart';

@override
Widget build(BuildContext context, WidgetRef ref) {
  final friendsAsync = ref.watch(friendsProvider);
  final conversationsAsync = ref.watch(conversationsProvider);
  final convoMap = conversationsAsync.value ?? const {};

  return friendsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(child: Text('Xato: $e')),
    data: (friends) {
      if (friends.isEmpty) {
        return const Center(child: Text("Hali do'st yo'q"));
      }
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: friends.length,
        itemBuilder: (_, i) {
          final friend = friends[i];
          return FriendTile(
            friend: friend,
            conversation: convoMap[friend.id],
            onTap: () => context.push(
              AppRoutes.chatFor(friend.id),
              extra: friend,
            ),
          );
        },
      );
    },
  );
}
```

If the existing build method already has different scaffolding (e.g. wraps in a scroll view or pull-to-refresh), preserve it and only swap the inner item-builder.

- [ ] **Step 3: Verify analyze + run all tests**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze lib/presentation/screens/friends/widgets/friends_list_tab.dart && /c/Users/user/.vscode/flutter/bin/flutter.bat test
```

Expected: clean analyze + all tests pass.

- [ ] **Step 4: Commit**

```bash
git add blink/lib/presentation/screens/friends/widgets/friends_list_tab.dart
git commit -m "feat(blink): friends list shows chat preview + opens ChatScreen on tap"
```

---

### Task 24: Final analyze + manual end-to-end smoke test

**Files:** none (verification only)

- [ ] **Step 1: Full analyze across the project**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Full test run**

```bash
cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat test
```

Expected: all tests pass.

- [ ] **Step 3: Backend running + acceptance smoke**

1. Restart backend: `cd backend && npm run dev`
2. Build & run app on two devices (or one device + one emulator):
   `cd blink && /c/Users/user/.vscode/flutter/bin/flutter.bat run`
3. Walk the acceptance checklist from the spec (`docs/superpowers/specs/2026-04-19-direct-chat-design.md` § 9). Tick each item as it passes:
   - [ ] Real-time text exchange < 1 s LAN latency
   - [ ] Image message renders on both sides via CachedNetworkImage
   - [ ] Read receipts flip ✓ → ✓✓ blue when chat is opened
   - [ ] Typing indicator shows + clears
   - [ ] Edit and delete propagate immediately to both devices
   - [ ] Friends tile shows last-message preview + unread badge without opening chat
   - [ ] App relaunch reloads conversations + history

- [ ] **Step 4: Commit acceptance log**

If any acceptance item failed, file an issue in this plan as a NEW task and fix before declaring DONE. If all pass, no commit needed; the plan ships as the eight prior commits.

---

## Notes for the implementer

- The frontend uses Riverpod 2 (`ConsumerWidget`, `Provider`, `StreamProvider.family`). Stick to that style — there are no `flutter_bloc` references in this codebase.
- Follow the existing Glass design system: `GlassAppBar`, `GlassCard`, `GlassFab`, `GlassSheet`, `GlassSurface`. Use `GlassTokens` for radii / blur / tint values.
- `apiClientProvider` lives in `blink/lib/presentation/providers/auth_provider.dart` (see how `api_user_datasource.dart` is wired in `user_provider.dart`). Confirm at Task 15 Step 2 before relying on the import path.
- `socket_io_client` package is already in `pubspec.yaml` (used by `socket_provider.dart`). The `Socket` instance in `socket_provider.dart` is the one to reuse — do NOT open a second socket.
- All Uzbek copy stays in Uzbek (e.g. "Xabar yozing…", "tahrirlandi", "Bu xabar o'chirildi").
- TDD: write the failing test, watch it fail, then implement. Do not skip the "watch it fail" step — it confirms the test is wired correctly.
- Commit cadence: one commit per task. Don't squash.
