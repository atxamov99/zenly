# Authentication

**Blink** uses **Firebase Authentication** to handle all user identity flows securely.

---

## 🔐 Supported Auth Methods

| Method | Package | Status |
|--------|---------|--------|
| Phone (OTP) | `firebase_auth` | ✅ Primary |
| Email / Password | `firebase_auth` | ✅ Supported |
| Google Sign-In | `google_sign_in` | ✅ Supported |

---

## 📱 Phone Number (OTP) Flow

This is the **primary** auth method, similar to Zenly.

```
User enters phone number
        │
        ▼
Firebase sends SMS with 6-digit OTP
        │
        ▼
User enters OTP
        │
        ▼
verifyOTP() → PhoneAuthCredential
        │
        ▼
signInWithCredential(credential)
        │
        ├─ New user? → Create profile in Firestore → Profile Setup Screen
        └─ Existing? → Navigate to Home Screen
```

### Implementation

```dart
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+998901234567',
  verificationCompleted: (PhoneAuthCredential credential) async {
    // Auto-retrieval on Android (SMS auto-fill)
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) {
    // Handle error (invalid number, quota exceeded, etc.)
  },
  codeSent: (String verificationId, int? resendToken) {
    // Navigate to OTP screen, store verificationId
    this.verificationId = verificationId;
  },
  codeAutoRetrievalTimeout: (String verificationId) {
    this.verificationId = verificationId;
  },
);

// After user enters OTP:
final credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: otpCode,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

---

## 📧 Email / Password Flow

```dart
// Register
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Reset password
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
```

---

## 🔵 Google Sign-In Flow

```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth?.accessToken,
  idToken: googleAuth?.idToken,
);

await FirebaseAuth.instance.signInWithCredential(credential);
```

---

## 👤 User Profile Creation (First Login)

When a new user authenticates for the first time, a Firestore document is created:

```dart
Future<void> createUserProfile(User firebaseUser) async {
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid);

  final exists = (await docRef.get()).exists;
  if (!exists) {
    await docRef.set({
      'uid': firebaseUser.uid,
      'displayName': firebaseUser.displayName ?? '',
      'email': firebaseUser.email ?? '',
      'phone': firebaseUser.phoneNumber ?? '',
      'photoUrl': firebaseUser.photoURL ?? '',
      'isOnline': true,
      'ghostMode': false,
      'batteryPercent': 100,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## 🔁 Auth State Persistence

Firebase automatically persists the auth session. On app restart:

```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
```

The app checks this stream at startup — if a `User` is present, skip login and go directly to Home.

---

## 🚪 Sign Out

```dart
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut(); // also sign out Google if used
}
```

---

## 🗑️ Account Deletion

```dart
Future<void> deleteAccount(String uid) async {
  // 1. Delete Firestore data
  await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  await FirebaseFirestore.instance.collection('locations').doc(uid).delete();

  // 2. Delete Storage avatars
  await FirebaseStorage.instance.ref('avatars/$uid').delete();

  // 3. Delete Firebase Auth user
  await FirebaseAuth.instance.currentUser?.delete();
}
```

> ⚠️ Account deletion may require re-authentication for security.

---

## 🛡️ Security Considerations

- OTP is valid for **5 minutes**
- Failed OTP attempts are rate-limited by Firebase
- Never store raw passwords — Firebase handles hashing
- FCM token is refreshed on each login and stored in Firestore
- Auth tokens (JWT) are automatically managed and refreshed by Firebase SDK
