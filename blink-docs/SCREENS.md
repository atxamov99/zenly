# 📱 Ekranlar va Navigatsiya

**Blink** ilovasining barcha ekranlari va ular orasidagi o'tishlar.

---

## 🗂 Ekranlar ro'yxati

### 1. Splash Screen
**Fayl:** `presentation/screens/splash/splash_screen.dart`

- Ilova ochilganda ko'rsatiladi
- Firebase auth holati tekshiriladi
- Agar foydalanuvchi tizimga kirgan bo'lsa → Home
- Aks holda → Onboarding

---

### 2. Onboarding Screen
**Fayl:** `presentation/screens/onboarding/onboarding_screen.dart`

- Yangi foydalanuvchilarga ilova haqida qisqacha tanishtirish
- Tugagach → Login Screen

---

### 3. Auth Ekranlari

#### Login Screen
**Fayl:** `presentation/screens/auth/login_screen.dart`

- Telefon raqam yoki Email/Parol bilan kirish
- Google Sign-In tugmasi
- OTP Screen ga yo'naltiradi

#### OTP Screen
**Fayl:** `presentation/screens/auth/otp_screen.dart`

- 6 xonali OTP kodi kiritish
- Qayta yuborish (resend) tugmasi
- 5 daqiqa muddati

#### Register Screen
**Fayl:** `presentation/screens/auth/register_screen.dart`

- Yangi hisob yaratish (Email/Parol)

---

### 4. Profile Setup Screen
**Fayl:** `presentation/screens/profile_setup/profile_setup_screen.dart`

- Faqat birinchi kirishda ko'rsatiladi
- Ism, username, avatar, emoji tanlash
- Tugagach → Home Screen

---

### 5. Home Screen
**Fayl:** `presentation/screens/home/home_screen.dart`

- **Bottom Navigation Bar** — asosiy wrapper ekran
- 4 tab: Map, Friends, Notifications, Profile

```
┌─────────────────────────────────┐
│           MAP VIEW              │
│    (Google Maps + Markers)      │
│                                 │
│   [Ghost FAB]   [Center FAB]    │
├────┬────────┬──────────┬────────┤
│ 🗺 │ 👥     │ 🔔       │ 👤     │
│Map │Friends │Notif.    │Profile │
└────┴────────┴──────────┴────────┘
```

---

### 6. Map Screen
**Fayl:** `presentation/screens/map/map_screen.dart`

- Real-vaqt xarita
- Do'stlar avatar markerlari
- Ghost Mode FAB
- Marker bosish → Friend Bottom Sheet

**Widgetlar:**
- `widgets/friend_marker.dart` — avatar marker
- `widgets/friend_bottom_sheet.dart` — do'st ma'lumotlari

---

### 7. Friends Screen
**Fayl:** `presentation/screens/friends/friends_screen.dart`

- Do'stlar ro'yxati (online badge bilan)
- Do'st qidirish (username / telefon)
- So'rov yuborish / qabul qilish / rad etish
- Bloklash / blokdan chiqarish

**Widget:** `widgets/friend_list_tile.dart`

---

### 8. Notifications Screen
**Fayl:** `presentation/screens/notifications/notifications_screen.dart`

- Do'stlik so'rovlari
- Wave (ping) xabarlari
- Yaqinlik ogohlantirishlari
- O'qilgan / o'qilmagan holat

---

### 9. Profile Screen
**Fayl:** `presentation/screens/profile/profile_screen.dart`

- Foydalanuvchi ma'lumotlari
- Do'stlar soni
- Online / last seen holati
- Profil tahrirlash tugmasi → Edit Profile Screen

#### Edit Profile Screen
**Fayl:** `presentation/screens/profile/edit_profile_screen.dart`

- Ism, avatar, emoji, status xabari tahrirlash

---

### 10. Settings Screen
**Fayl:** `presentation/screens/settings/settings_screen.dart`

- Bildirishnoma sozlamalari
- Joylashuv ulashish rejimi
- Ghost Mode tez o'chirish/yoqish
- Mavzu (dark/light)
- Hisobni boshqarish (chiqish, o'chirish)

---

## 🔀 Navigatsiya Oqimi

```
App Start
    │
    ▼
Splash Screen
    ├── (kirgan) ──────────────► Home Screen
    │                                │
    └── (kirmagan)                   ├── Map Tab
            │                        ├── Friends Tab
            ▼                        ├── Notifications Tab
        Onboarding                   └── Profile Tab
            │
            ▼
        Login Screen
            ├── Phone → OTP Screen → (yangi) → Profile Setup → Home
            ├── Email → Home
            └── Google → (yangi) → Profile Setup → Home
```

---

## 📐 Navigatsiya Paketi

**GoRouter** ishlatiladi:

```
core/router/app_router.dart
```

| Route | Path | Ekran |
|-------|------|-------|
| Splash | `/` | SplashScreen |
| Login | `/login` | LoginScreen |
| OTP | `/otp` | OtpScreen |
| Profile Setup | `/setup` | ProfileSetupScreen |
| Home | `/home` | HomeScreen |
| Map | `/home/map` | MapScreen |
| Friends | `/home/friends` | FriendsScreen |
| Notifications | `/home/notifications` | NotificationsScreen |
| Profile | `/home/profile` | ProfileScreen |
| Edit Profile | `/profile/edit` | EditProfileScreen |
| Settings | `/settings` | SettingsScreen |
