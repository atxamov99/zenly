# User Flow

Complete user journey through the **Blink** app — from first launch to daily usage.

---

## 1. 🚀 First Launch — Onboarding

```
App Opens
    │
    ├─► Splash Screen (logo animation, 2s)
    │
    ├─► Check Auth State
    │       ├─ Logged in  ──► Go to Home (Map Screen)
    │       └─ Not logged in ──► Onboarding Screens
    │
    └─► Onboarding (3 slides)
            ├─ Slide 1: "See your friends on the map"
            ├─ Slide 2: "Share your battery & status"
            └─ Slide 3: "Go ghost when you need privacy"
                    └─► Get Started Button ──► Auth Screen
```

---

## 2. 🔐 Authentication Flow

```
Auth Screen
    │
    ├─► Phone Number Login
    │       ├─ Enter phone number
    │       ├─ Receive OTP via SMS
    │       ├─ Enter OTP (6 digits)
    │       └─ Verified ──► Profile Setup (new user) or Home
    │
    ├─► Email / Password
    │       ├─ Register: name, email, password
    │       └─ Login: email, password
    │
    └─► Google Sign-In
            └─ One-tap auth ──► Profile Setup (new user) or Home
```

---

## 3. 👤 Profile Setup (New User Only)

```
Profile Setup Screen
    │
    ├─ Enter display name
    ├─ Choose username (unique check)
    ├─ Upload profile photo (optional)
    ├─ Pick profile emoji
    └─ Allow Location Permission prompt
            ├─ Allowed ──► Allow Notification Permission
            └─ Denied  ──► Show explanation, retry or skip
                    └─► Home (Map Screen)
```

---

## 4. 🏠 Home — Map Screen (Daily Usage)

```
Map Screen (Main Hub)
    │
    ├─► See friends as animated markers on map
    ├─► Tap own location → My Profile Sheet
    ├─► Tap friend marker → Friend Detail Sheet
    │       ├─ Name, avatar, last seen
    │       ├─ Battery level
    │       ├─ Current address (reverse geocoded)
    │       ├─ "Wave" button (send ping)
    │       └─ Open full profile
    │
    ├─► Bottom Nav Bar
    │       ├─ 🗺 Map (current)
    │       ├─ 👥 Friends List
    │       ├─ 🔔 Notifications
    │       └─ ⚙️ Settings
    │
    └─► FAB (Floating Action Button)
            └─ Quick Ghost Mode toggle
```

---

## 5. 👥 Friends Flow

```
Friends Screen
    │
    ├─► View current friends (online first)
    ├─► Search bar → find by username or phone
    │
    ├─► Send Friend Request
    │       ├─ Find user
    │       ├─ Tap "Add Friend"
    │       └─ Request sent → pending state
    │
    ├─► Receive Friend Request (notification)
    │       ├─ Accept → mutual friendship created
    │       └─ Reject → request removed
    │
    └─► Friend Options (long press)
            ├─ View Profile
            ├─ Ghost from this person
            ├─ Remove Friend
            └─ Block User
```

---

## 6. 👻 Ghost Mode Flow

```
Ghost Mode Toggle (FAB or Settings)
    │
    ├─► Ghost All — hide from everyone
    │       └─ Location updates stop broadcasting
    │
    └─► Ghost Specific Friend
            ├─ Open friend options
            ├─ Toggle "Ghost from [Name]"
            └─ That friend sees last known location (frozen)
```

---

## 7. 🔔 Notifications Flow

```
Notification Received
    │
    ├─► App in foreground → In-app banner
    ├─► App in background → System push notification
    └─► App closed → System push notification
            └─ Tap notification → deep link to relevant screen
                    ├─ Friend request → Friends screen
                    ├─ Wave → Friend detail sheet on map
                    └─ Nearby alert → Map centered on friend
```

---

## 8. ⚙️ Settings Flow

```
Settings Screen
    │
    ├─► Edit Profile
    ├─► Privacy Settings
    │       ├─ Location sharing: Precise / Approximate / Off
    │       ├─ Battery sharing: On / Off
    │       └─ Last seen: Everyone / Friends / Nobody
    ├─► Notification Preferences
    ├─► Theme (Light / Dark / System)
    ├─► Ghost Mode schedule
    ├─► Blocked Users list
    ├─► Logout
    └─► Delete Account (with confirmation)
```
