# Security Rules

Firestore security rules for **Blink** — ensuring users can only read/write data they are authorized to access.

---

## 🔒 Core Principles

1. **Authentication required** — all operations require a signed-in user
2. **Users can only edit their own data**
3. **Friends can only see each other's location if friendship exists**
4. **Ghost mode is enforced at the rules level**
5. **Block list prevents data access**

---

## 📋 Full Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── Helper Functions ─────────────────────────────

    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isFriendOf(userId) {
      let id1 = request.auth.uid < userId
        ? request.auth.uid + '_' + userId
        : userId + '_' + request.auth.uid;
      return exists(/databases/$(database)/documents/friendships/$(id1));
    }

    function isBlocked(userId) {
      return exists(
        /databases/$(database)/documents/blocked_users/$(userId)/blocked/$(request.auth.uid)
      );
    }

    function isGhostedFrom(targetUserId) {
      let userData = get(/databases/$(database)/documents/users/$(targetUserId)).data;
      return userData.ghostMode == true ||
             request.auth.uid in userData.ghostFromList;
    }

    // ─── Users Collection ─────────────────────────────

    match /users/{userId} {
      // Anyone can read basic profile (for search)
      allow read: if isAuthenticated() && !isBlocked(userId);

      // Only owner can write their own profile
      allow write: if isOwner(userId);
    }

    // ─── Locations Collection ──────────────────────────

    match /locations/{userId} {
      // Only friends can see location, and only if not ghosted
      allow read: if isAuthenticated()
        && (isOwner(userId) || (isFriendOf(userId) && !isGhostedFrom(userId)));

      // Only owner can update their own location
      allow write: if isOwner(userId);
    }

    // ─── Friendships Collection ────────────────────────

    match /friendships/{friendshipId} {
      // Only participants can read
      allow read: if isAuthenticated()
        && request.auth.uid in resource.data.users;

      // Only participants can create/delete
      allow create: if isAuthenticated()
        && request.auth.uid in request.resource.data.users;

      allow delete: if isAuthenticated()
        && request.auth.uid in resource.data.users;

      allow update: if false; // friendships don't get updated, only deleted
    }

    // ─── Friend Requests ──────────────────────────────

    match /friend_requests/{requestId} {
      // Sender or receiver can read
      allow read: if isAuthenticated()
        && (request.auth.uid == resource.data.fromUid
            || request.auth.uid == resource.data.toUid);

      // Only sender can create
      allow create: if isAuthenticated()
        && request.auth.uid == request.resource.data.fromUid
        && request.resource.data.status == 'pending';

      // Only receiver can update (accept/reject)
      allow update: if isAuthenticated()
        && request.auth.uid == resource.data.toUid
        && request.resource.data.status in ['accepted', 'rejected'];

      // Sender can delete (cancel request)
      allow delete: if isAuthenticated()
        && request.auth.uid == resource.data.fromUid;
    }

    // ─── Notifications ────────────────────────────────

    match /notifications/{userId}/items/{notifId} {
      // Only the notification owner can read
      allow read: if isOwner(userId);

      // System/cloud functions write, but authenticated users can mark as read
      allow update: if isOwner(userId)
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead']);

      // Owner can delete their own notifications
      allow delete: if isOwner(userId);

      // Only server (Cloud Functions) should create — deny from client
      allow create: if false;
    }

    // ─── Blocked Users ────────────────────────────────

    match /blocked_users/{userId}/blocked/{blockedId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }

  }
}
```

---

## ☁️ Cloud Functions for Secure Writes

Some operations should be done server-side via Cloud Functions for extra security:

| Operation | Reason |
|-----------|--------|
| Create notification | Client shouldn't write to other user's notifications |
| Accept friend request → create friendship | Atomic transaction needed |
| Send FCM notification | FCM server key must stay secret |
| Delete account (cascade) | Need to delete all related documents safely |

---

## 🛡️ Additional Security Practices

- **Rate limiting:** Firebase automatically limits auth attempts
- **Input validation:** Validate all user inputs on the client before Firestore writes
- **Field validation in rules:**
  ```javascript
  allow create: if request.resource.data.status == 'pending'
    && request.resource.data.fromUid == request.auth.uid
    && request.resource.data.keys().hasAll(['fromUid', 'toUid', 'status', 'createdAt']);
  ```
- **Max document size:** Firestore enforces 1MB per document — no risk for our schema
- **Storage rules:** Restrict avatar uploads to authenticated users only:
  ```javascript
  match /avatars/{userId}/{allPaths=**} {
    allow read: if request.auth != null;
    allow write: if request.auth.uid == userId
      && request.resource.size < 5 * 1024 * 1024; // max 5MB
  }
  ```
