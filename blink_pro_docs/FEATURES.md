# Features

Complete feature list for the **Blink** app — a production-level Zenly clone.

---

## 🔐 Authentication

- Phone number login with OTP verification (Firebase Phone Auth)
- Email & password registration / login
- Google Sign-In
- Auto-login on app restart (persisted auth state)
- Account deletion with data cleanup

---

## 👤 User Profile

- Display name, username, profile avatar
- Edit profile (name, avatar, emoji, status message)
- Account settings (privacy, notifications, theme)
- Online / offline / idle status
- Last seen timestamp

---

## 👥 Friend System

- Search users by username or phone number
- Send / accept / reject friend requests
- Remove friends
- Block / unblock users
- Friend list with online status badges
- Friend count visible on profile

---

## 🗺️ Live Map

- Real-time map showing all friends' current positions
- Custom avatar markers for each friend
- Tap on a friend marker to open their bottom sheet
- Auto-center map on your own location
- Smooth marker animation on location update
- Cluster nearby friends when zoomed out

---

## 📍 Location Tracking

- Foreground GPS location updates
- Background location updates (even when app is closed)
- Configurable update interval (default: every 10 seconds)
- Last known location fallback
- Reverse geocoding (coordinates → human-readable address)
- Battery-efficient location mode (adaptive accuracy)

---

## 👻 Ghost Mode

- Enable ghost mode to hide from all friends at once
- Selective ghost mode: hide from specific friends
- Ghost mode indicator visible only to the user
- Last location frozen when ghost mode is activated
- Scheduled ghost mode (e.g., automatically ghost at night)

---

## 🔋 Battery Status

- Share current battery percentage with friends
- Battery icon shown on the friend's marker and profile sheet
- Color-coded battery indicator (green / yellow / red)
- Charging status indicator (⚡)
- Auto-update battery status every 60 seconds

---

## 🔔 Notifications

- Push notification for incoming friend requests
- Notification when a friend comes online
- "Wave" feature — send a ping notification to a friend
- Location-based alerts (notify me when a friend is nearby)
- In-app notification center with read/unread state
- FCM token refresh handled automatically

---

## 💬 Activity Feed

- See recent activity of friends (joined, moved to new area)
- "Arrived at X" automatic activity updates
- Timeline of a friend's movement (last 24h)

---

## 🔒 Privacy & Security

- Granular privacy controls per friend
- Firestore security rules enforced on server side
- Location data encrypted in transit
- Users can only read their own friends' data
- Option to set location sharing to "approximate" (city-level only)

---

## 🎨 UI / UX

- Dark mode & light mode support
- Custom animated map markers with friend avatars
- Bottom sheet for friend details (location, battery, last seen)
- Smooth page transitions and micro-animations
- Haptic feedback on key interactions
- Skeleton loaders during data fetch

---

## ⚙️ Settings

- Notification preferences (per type)
- Location sharing frequency
- Ghost mode quick toggle
- Theme switcher
- Account management (logout, delete)
- App version and build info
