# 🧩 UI Komponentlar (Widgets)

**Blink** ilovasidagi barcha qayta ishlatiladigan widget komponentlar.

---

## 📁 Umumiy Widgetlar
`presentation/widgets/`

---

### `AppButton`
**Fayl:** `widgets/app_button.dart`

Ilovaning asosiy tugmasi. Primary, secondary va destructive variantlari mavjud.

| Prop | Turi | Tavsif |
|------|------|--------|
| `label` | String | Tugma matni |
| `onPressed` | VoidCallback? | Bosish handleri (null = disabled) |
| `isLoading` | bool | Loading spinner ko'rsatish |
| `variant` | ButtonVariant | primary / secondary / danger |
| `fullWidth` | bool | To'liq kenglik |

---

### `AppTextField`
**Fayl:** `widgets/app_text_field.dart`

Styled matn kiritish maydoni.

| Prop | Turi | Tavsif |
|------|------|--------|
| `controller` | TextEditingController | Matn kontroleri |
| `hint` | String | Placeholder matni |
| `label` | String? | Ustidagi label |
| `obscure` | bool | Parol uchun yashirish |
| `keyboardType` | TextInputType | Klaviatura turi |
| `validator` | String? Function(String?)? | Validatsiya |
| `prefixIcon` | Widget? | Chapdan icon |

---

### `AvatarWidget`
**Fayl:** `widgets/avatar_widget.dart`

Foydalanuvchi avatarini ko'rsatadi — tarmoqdan yoki emoji fallback bilan.

| Prop | Turi | Tavsif |
|------|------|--------|
| `imageUrl` | String? | Avatar URL |
| `emoji` | String? | Fallback emoji |
| `radius` | double | Doira radiusi |
| `showOnlineBadge` | bool | Yashil online nuqta |
| `isOnline` | bool | Online holati |

**Ko'rinish:**
```
┌──────────┐
│  🦊 yoki │  ← Emoji yoki rasm
│  [Avatar]│
│      🟢  │  ← Online badge (ixtiyoriy)
└──────────┘
```

---

### `BatteryIndicator`
**Fayl:** `widgets/battery_indicator.dart`

Foydalanuvchi batareyasini ko'rsatadi.

| Prop | Turi | Tavsif |
|------|------|--------|
| `percent` | int | 0–100 batareya foizi |
| `isCharging` | bool | Zaryadlanish holati |
| `size` | double | Icon o'lchami |

**Rang logikasi:**
| Foiz | Rang |
|------|------|
| 60–100 | 🟢 Yashil |
| 20–59 | 🟡 Sariq |
| 0–19 | 🔴 Qizil |

**Ko'rinish:**
```
⚡ 85%    ← zaryadlanayotganda
🔋 42%    ← oddiy holat
🪫 8%     ← kritik
```

---

### `LoadingOverlay`
**Fayl:** `widgets/loading_overlay.dart`

Asinxron operatsiyalar vaqtida ekran ustiga loading effekti qo'yadi.

| Prop | Turi | Tavsif |
|------|------|--------|
| `isLoading` | bool | Ko'rsatish/yashirish |
| `child` | Widget | Asosiy content |
| `message` | String? | Loading matni |

---

## 📁 Xarita Widgetlari
`presentation/screens/map/widgets/`

---

### `FriendMarker`
**Fayl:** `map/widgets/friend_marker.dart`

Google Maps uchun do'stning avatar markeri. `BitmapDescriptor` sifatida render qilinadi.

**Ishlash tartibi:**
1. Do'stning avatar URL'i olinadi
2. Canvas'da aylana shaklida chiziladi
3. Chegara (border) qo'shiladi — rang holat bo'yicha
4. `BitmapDescriptor.fromBytes()` orqali markerga aylanadi

**Chegara ranglari:**
| Holat | Rang |
|-------|------|
| Online | Ko'k |
| Idle | Sariq |
| Offline | Kulrang |
| Ghost Mode | Binafsha |

---

### `FriendBottomSheet`
**Fayl:** `map/widgets/friend_bottom_sheet.dart`

Xaritada marker bosilganda pastdan chiqadigan panel.

**Ko'rsatiladigan ma'lumotlar:**
- Do'stning avatari + ismi + username
- Hozirgi manzili (reverse geocoded)
- Oxirgi yangilanish vaqti
- Batareya foizi va zaryadlanish holati
- Wave (ping) yuborish tugmasi
- Ghost qilish tugmasi

```
┌─────────────────────────────────┐
│  ▬▬▬  (drag handle)            │
│                                 │
│  [Avatar] Alex Karimov          │
│           @alex_k               │
│                                 │
│  📍 Chilonzor, Toshkent         │
│  🕐 2 daqiqa oldin              │
│  🔋 74%                         │
│                                 │
│  [👋 Wave]    [👻 Ghost]        │
└─────────────────────────────────┘
```

---

## 📁 Friends Widgetlari
`presentation/screens/friends/widgets/`

---

### `FriendListTile`
**Fayl:** `friends/widgets/friend_list_tile.dart`

Do'stlar ro'yxatidagi bir qator.

| Element | Tavsif |
|---------|--------|
| Chap | Avatar + online badge |
| O'rta | Ism, username, oxirgi ko'rish vaqti |
| O'ng | Batareya + xarita tugmasi |

---

## 🎨 Dizayn Konstantalari

Barcha rang, o'lcham va matnlar:
```
core/constants/app_colors.dart   — ranglar
core/constants/app_sizes.dart    — padding, radius, icon o'lchamlari
core/constants/app_strings.dart  — barcha UI matnlar (lokalizatsiya uchun)
```

---

## 🖼 Skeleton Loaderlar

Ma'lumot yuklanayotganda skeleton (skelet) ko'rsatiladi:

- Do'stlar ro'yxatida: `FriendListTile` o'rniga shimmer effektli to'rtburchak
- Xaritada: markerlar yuklanguncha standart pin
- Profile'da: avatar o'rniga kulrang doira
