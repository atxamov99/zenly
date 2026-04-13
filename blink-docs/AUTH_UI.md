# 🔐 Autentifikatsiya UI

**Blink** ilovasining kirish va ro'yxatdan o'tish ekranlari.

---

## 🔑 Qo'llab-quvvatlanadigan Kirish Usullari

| Usul | Holati | Asosiy/Qo'shimcha |
|------|--------|------------------|
| Telefon (OTP) | ✅ | Asosiy |
| Email / Parol | ✅ | Qo'shimcha |
| Google Sign-In | ✅ | Qo'shimcha |

---

## 📱 Login Screen
**Fayl:** `presentation/screens/auth/login_screen.dart`

### UI Elementlari

```
┌─────────────────────────────────────┐
│                                     │
│          [Blink Logo]               │
│                                     │
│     Telefon raqam bilan kiring      │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ +998  │  901234567          │    │  ← Telefon input
│  └─────────────────────────────┘    │
│                                     │
│      [Davom etish →]                │  ← AppButton (primary)
│                                     │
│  ──────────── yoki ────────────     │
│                                     │
│      [🔵 Google bilan kiring]       │
│      [📧 Email bilan kiring]        │
│                                     │
└─────────────────────────────────────┘
```

### Validatsiya Qoidalari
| Maydon | Qoida |
|--------|-------|
| Telefon | +998 bilan boshlanishi, 12 xona |
| Email | To'g'ri email format |
| Parol | Min 6 ta belgi |

---

## 🔢 OTP Screen
**Fayl:** `presentation/screens/auth/otp_screen.dart`

### UI Elementlari

```
┌─────────────────────────────────────┐
│                                     │
│          Kodni kiriting             │
│                                     │
│   +998 90 123 45 67 ga yuborildi    │  ← Telefon raqam
│                                     │
│    ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  │
│    │  │  │  │  │  │  │  │  │  │  │  │  │  ← 6 ta OTP box
│    └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  │
│                                     │
│         Kodni qayta yuborish        │  ← Countdown timer (5 min)
│              04:32                  │
│                                     │
│           [Tasdiqlash]              │
│                                     │
└─────────────────────────────────────┘
```

### OTP Box Holatlari
| Holat | Ko'rinish |
|-------|----------|
| Bo'sh | Chegara: kulrang |
| Fokusda | Chegara: ko'k, kursor ko'rinadi |
| To'ldirilgan | Chegara: ko'k, raqam ko'rsatiladi |
| Xato | Chegara: qizil, silkinish animatsiyasi |

### Timer Logikasi
- Boshlang'ich vaqt: **5:00**
- Countdown sekundlik kamayadigan
- 0:00 ga yetganda "Qayta yuborish" tugmasi aktiv bo'ladi
- Qayta yuborishda timer qaytadan boshlanadi

---

## 📧 Email / Parol Screen
**Fayl:** `presentation/screens/auth/register_screen.dart`

### UI Elementlari

```
┌─────────────────────────────────────┐
│                                     │
│       Email bilan ro'yxatdan        │
│            o'ting                   │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Email manzil               │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Parol              [👁]    │    │  ← Ko'rsatish/yashirish
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Parolni takrorlang  [👁]   │    │
│  └─────────────────────────────┘    │
│                                     │
│         [Ro'yxatdan o'tish]         │
│                                     │
│    Allaqachon hisobingiz bormi?      │
│           [Kirish]                  │
│                                     │
└─────────────────────────────────────┘
```

---

## 👤 Profile Setup Screen
**Fayl:** `presentation/screens/profile_setup/profile_setup_screen.dart`

Yangi foydalanuvchi birinchi marta kirganda ko'rsatiladi.

```
┌─────────────────────────────────────┐
│                                     │
│      Profilingizni to'ldiring       │
│                                     │
│            ┌──────┐                 │
│            │  🦊  │  [+ Rasm]       │  ← Avatar + Emoji tanlash
│            └──────┘                 │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  To'liq ism                 │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  @username                  │    │  ← Mavjudligi tekshiriladi
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Status xabari (ixtiyoriy)  │    │
│  └─────────────────────────────┘    │
│                                     │
│           [Boshlash 🚀]             │
│                                     │
└─────────────────────────────────────┘
```

### Username Tekshiruvi
- Real-vaqtda Firestore'da mavjudligi tekshiriladi
- ✅ Band emas → yashil belgi
- ❌ Band → qizil xabar

---

## 🔄 Auth Holati (Riverpod)

**Provider:** `presentation/providers/auth_provider.dart`

Ilova ishga tushganda Firebase auth holati tekshiriladi:

```
authStateProvider (StreamProvider)
    │
    ├── User mavjud → Home Screen
    └── User yo'q   → Login Screen
```

---

## 🔒 Xavfsizlik Ko'rsatkichlari

| Element | Tavsif |
|---------|--------|
| OTP muddati | 5 daqiqa |
| Urinishlar | Firebase tomonidan cheklanadi |
| Parol | Firebase hash qiladi (saqlanmaydi) |
| FCM token | Har kirishda yangilanadi |
| JWT token | Firebase SDK avtomatik boshqaradi |

---

## 🚪 Chiqish (Sign Out)

Settings ekranida "Chiqish" bosilganda:

1. Firebase Auth'dan chiqiladi
2. Google Sign-In'dan chiqiladi (agar ishlatilgan bo'lsa)
3. Login Screen'ga yo'naltiriladi
4. Lokal kesh tozalanadi

---

## 🗑 Hisobni O'chirish

Settings → "Hisobni o'chirish" bosqichlari:

1. Foydalanuvchi qayta autentifikatsiya qilinadi (xavfsizlik uchun)
2. Firestore'dagi user + location hujjatlari o'chiriladi
3. Firebase Storage'dagi avatar o'chiriladi
4. Firebase Auth hisob o'chiriladi
5. Login Screen'ga yo'naltiriladi
