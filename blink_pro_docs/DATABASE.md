# Database — Firestore Schema

**Blink** uses **Cloud Firestore** as its primary database. Below is the full schema with all collections, documents, and fields.

---

## 🗂️ Collections Overview

```
firestore/
├── users/                  # User profiles
├── locations/              # Live location data
├── friendships/            # Friend relationships
├── friend_requests/        # Pending requests
├── notifications/          # In-app notifications
└── blocked_users/          # Block list
```

---

## 👤 `users` Collection

**Path:** `/users/{userId}`

```json
{
  "uid": "string",
  "displayName": "string",
  "username": "string",           // unique
  "email": "string",
  "phone": "string",
  "photoUrl": "string",
  "emoji": "string",              // profile emoji (e.g. "🦊")
  "statusMessage": "string",
  "isOnline": "boolean",
  "lastSeen": "Timestamp",
  "ghostMode": "boolean",
  "ghostFromList": ["uid1", "uid2"],   // selectively hidden from
  "batteryPercent": "number",          // 0–100
  "isCharging": "boolean",
  "locationSharingMode": "string",     // "precise" | "approximate" | "off"
  "createdAt": "Timestamp",
  "fcmToken": "string"
}
```

---

## 📍 `locations` Collection

**Path:** `/locations/{userId}`

```json
{
  "uid": "string",
  "latitude": "number",
  "longitude": "number",
  "accuracy": "number",           // in meters
  "altitude": "number",
  "speed": "number",
  "heading": "number",
  "address": "string",            // reverse geocoded
  "city": "string",
  "country": "string",
  "updatedAt": "Timestamp"
}
```

> One document per user, updated in-place on each location change.

---

## 👥 `friendships` Collection

**Path:** `/friendships/{friendshipId}`

The `friendshipId` is a combination of two UIDs, always sorted alphabetically to ensure uniqueness:
`{uid1}_{uid2}` where `uid1 < uid2`

```json
{
  "id": "string",
  "users": ["uid1", "uid2"],
  "createdAt": "Timestamp",
  "initiator": "string"          // uid of who sent the request
}
```

---

## 📬 `friend_requests` Collection

**Path:** `/friend_requests/{requestId}`

```json
{
  "id": "string",
  "fromUid": "string",
  "toUid": "string",
  "status": "string",            // "pending" | "accepted" | "rejected"
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

## 🔔 `notifications` Collection

**Path:** `/notifications/{userId}/items/{notificationId}`

```json
{
  "id": "string",
  "type": "string",              // "friend_request" | "wave" | "nearby" | "accepted"
  "fromUid": "string",
  "message": "string",
  "isRead": "boolean",
  "createdAt": "Timestamp",
  "data": {                      // extra payload depending on type
    "requestId": "string"
  }
}
```

---

## 🚫 `blocked_users` Collection

**Path:** `/blocked_users/{userId}/blocked/{blockedUserId}`

```json
{
  "blockedUid": "string",
  "blockedAt": "Timestamp"
}
```

---

## 🔍 Firestore Indexes

Required composite indexes for efficient queries:

| Collection | Fields | Order |
|------------|--------|-------|
| `friend_requests` | `toUid`, `status`, `createdAt` | DESC |
| `friendships` | `users` (array), `createdAt` | DESC |
| `notifications/{uid}/items` | `isRead`, `createdAt` | DESC |

---

## ⚡ Query Examples

### Get all friends of a user
```dart
firestore
  .collection('friendships')
  .where('users', arrayContains: currentUid)
  .snapshots();
```

### Get pending friend requests for a user
```dart
firestore
  .collection('friend_requests')
  .where('toUid', isEqualTo: currentUid)
  .where('status', isEqualTo: 'pending')
  .snapshots();
```

### Watch a friend's live location
```dart
firestore
  .collection('locations')
  .doc(friendUid)
  .snapshots();
```

---

## 📏 Estimated Data Sizes

| Document | Avg size | Updates/day |
|----------|----------|-------------|
| User profile | ~400 bytes | Low |
| Location | ~250 bytes | ~8,640/day (every 10s) |
| Friendship | ~150 bytes | Low |
| Notification | ~200 bytes | Moderate |
