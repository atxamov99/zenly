# Ghost Mode

Ghost Mode allows users to hide their location from all or selected friends — without them knowing.

---

## 👻 How It Works

When Ghost Mode is active:
- The user's location **stops broadcasting** to Firestore
- Friends continue to see the **last known location** (frozen)
- The user's own UI shows a ghost icon — friends see nothing unusual
- Ghost Mode status is stored in the `users` collection and enforced by Firestore Security Rules

---

## 🗂️ Firestore Fields

```json
// In users/{uid}
{
  "ghostMode": true,          // global ghost (hidden from everyone)
  "ghostFromList": ["uid2", "uid3"]  // selective ghost (hidden from specific friends)
}
```

---

## 🔒 Security Rule Enforcement

Friends are blocked from reading your location at the Firestore rules level:

```javascript
function isGhostedFrom(targetUserId) {
  let userData = get(/databases/$(database)/documents/users/$(targetUserId)).data;
  return userData.ghostMode == true
      || request.auth.uid in userData.ghostFromList;
}

match /locations/{userId} {
  allow read: if isAuthenticated()
    && (isOwner(userId) || (isFriendOf(userId) && !isGhostedFrom(userId)));
}
```

---

## ⚙️ Ghost Mode Implementation

### Toggle Global Ghost Mode

```dart
class GhostModeUseCase {
  final UserRepository _userRepository;

  GhostModeUseCase(this._userRepository);

  Future<void> toggleGhostMode(String uid, bool enable) async {
    await _userRepository.updateUser(uid, {'ghostMode': enable});

    if (enable) {
      // Stop location broadcasting
      LocationService.instance.stopTracking();
    } else {
      // Resume location broadcasting
      LocationService.instance.startTracking(uid);
    }
  }
}
```

### Toggle Selective Ghost (per friend)

```dart
Future<void> toggleGhostFromFriend(String uid, String friendUid, bool hide) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

  if (hide) {
    await docRef.update({
      'ghostFromList': FieldValue.arrayUnion([friendUid]),
    });
  } else {
    await docRef.update({
      'ghostFromList': FieldValue.arrayRemove([friendUid]),
    });
  }
}
```

---

## 📱 UI — Ghost Mode Toggle

  Liquid Glass ios-26

### Quick Toggle FAB on Map

```dart
FloatingActionButton(
  backgroundColor: isGhost ? Colors.purple : Colors.white,
  child: Icon(
    isGhost ? Icons.visibility_off : Icons.visibility,
    color: isGhost ? Colors.white : Colors.black87,
  ),
  onPressed: () {
    ref.read(ghostModeProvider.notifier).toggle();
  },
)
```

### Ghost Mode Indicator (only visible to the user)

When ghost mode is on, a subtle banner appears at the top of the map:

```dart
if (isGhostMode)
  Positioned(
    top: MediaQuery.of(context).padding.top + 8,
    left: 0, right: 0,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_off, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text('Ghost Mode ON', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ),
  )
```

---

## 🕐 Scheduled Ghost Mode

Let users automatically activate ghost mode on a schedule:

```dart
class ScheduledGhost {
  final TimeOfDay startTime;  // e.g., 22:00
  final TimeOfDay endTime;    // e.g., 08:00
  final bool isEnabled;
}
```

Implementation: use a local `flutter_local_notifications` scheduled notification + Workmanager plugin to toggle ghost mode at the specified times.

---

## 📊 Ghost Mode State (Riverpod)

```dart
final ghostModeProvider = StateNotifierProvider<GhostModeNotifier, GhostModeState>((ref) {
  return GhostModeNotifier(
    ref.watch(ghostModeUseCaseProvider),
    ref.watch(currentUidProvider)!,
  );
});

class GhostModeState {
  final bool isGlobalGhost;
  final List<String> ghostedFromUids;

  bool isGhostedFrom(String uid) => isGlobalGhost || ghostedFromUids.contains(uid);
}
```

---

## 📋 Ghost Mode Behavior Summary

| Scenario | What friend sees |
|----------|-----------------|
| Ghost Mode OFF | Real-time location |
| Ghost Mode ON (global) | Last known location (frozen) |
| Ghosted from specific friend | That friend sees last known location |
| Location sharing set to "off" | Friend sees nothing at all |
| Ghost Mode ON + app closed | No updates — location stays frozen |
