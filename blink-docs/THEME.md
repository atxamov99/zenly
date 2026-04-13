# 🎨 Mavzu va Dizayn Tizimi

**Blink** ilovasining rang, shrift, o'lcham va vizual identifikatsiya tizimi.

---

## 🌗 Mavzu Rejimlari

Ilova ikki mavzuni qo'llab-quvvatlaydi:

| Rejim | Fayl |
|-------|------|
| Light (kunduzgi) | `core/theme/light_theme.dart` |
| Dark (tungi) | `core/theme/dark_theme.dart` |
| Bosh fayl | `core/theme/app_theme.dart` |

Foydalanuvchi Settings'dan rejimni o'zgartira oladi. Tizim rejimiga avtomatik moslashish ham mavjud.

---

## 🎨 Ranglar
**Fayl:** `core/constants/app_colors.dart`

### Asosiy Ranglar (Brand)

| Nom | Hex | Ko'rinish | Ishlatilishi |
|-----|-----|-----------|-------------|
| `primary` | `#4F46E5` | 🔵 Ko'k-binafsha | Tugmalar, aktiv holat |
| `primaryLight` | `#818CF8` | 💜 Och binafsha | Hover, border |
| `ghost` | `#7C3AED` | 🟣 To'q binafsha | Ghost Mode |
| `accent` | `#06B6D4` | 🔵 Moviy | Ikkinchi darajali aksent |

### Holat Ranglari

| Nom | Hex | Ishlatilishi |
|-----|-----|-------------|
| `online` | `#22C55E` | Online badge, marker chegara |
| `idle` | `#EAB308` | Idle holat |
| `offline` | `#6B7280` | Offline, last seen |
| `error` | `#EF4444` | Xato xabarlari |
| `warning` | `#F59E0B` | Ogohlantirish |
| `success` | `#10B981` | Muvaffaqiyat |

### Batareya Ranglari

| Foiz | Rang | Hex |
|------|------|-----|
| 60–100% | Yashil | `#22C55E` |
| 20–59% | Sariq | `#EAB308` |
| 0–19% | Qizil | `#EF4444` |

### Light Mavzu Fon Ranglari

| Nom | Hex | Ishlatilishi |
|-----|-----|-------------|
| `background` | `#FFFFFF` | Asosiy fon |
| `surface` | `#F9FAFB` | Karta, sheet fonlari |
| `border` | `#E5E7EB` | Chegaralar |
| `textPrimary` | `#111827` | Asosiy matn |
| `textSecondary` | `#6B7280` | Ikkinchi darajali matn |

### Dark Mavzu Fon Ranglari

| Nom | Hex | Ishlatilishi |
|-----|-----|-------------|
| `background` | `#0F172A` | Asosiy fon |
| `surface` | `#1E293B` | Karta, sheet fonlari |
| `border` | `#334155` | Chegaralar |
| `textPrimary` | `#F8FAFC` | Asosiy matn |
| `textSecondary` | `#94A3B8` | Ikkinchi darajali matn |

---

## 🔤 Shriftlar
**Fayl:** `assets/fonts/` + `core/constants/app_sizes.dart`

**Asosiy shrift:** `Inter`

| Stil | O'lcham | Qalinlik | Ishlatilishi |
|------|---------|---------|-------------|
| `displayLarge` | 32sp | Bold | Ekran sarlavhalari |
| `headlineMedium` | 24sp | SemiBold | Karta sarlavhalari |
| `titleLarge` | 18sp | SemiBold | Navigatsiya sarlavhalari |
| `bodyLarge` | 16sp | Regular | Asosiy matn |
| `bodyMedium` | 14sp | Regular | Ikkinchi darajali matn |
| `labelSmall` | 11sp | Medium | Badge, chip |

---

## 📐 O'lchamlar
**Fayl:** `core/constants/app_sizes.dart`

### Padding / Margin

| Nom | Qiymat | Ishlatilishi |
|-----|--------|-------------|
| `xs` | 4dp | Mini bo'shliq |
| `sm` | 8dp | Kichik bo'shliq |
| `md` | 16dp | Standart padding |
| `lg` | 24dp | Katta bo'shliq |
| `xl` | 32dp | Ekran padding |

### Border Radius

| Nom | Qiymat | Ishlatilishi |
|-----|--------|-------------|
| `radiusSm` | 8dp | Input'lar |
| `radiusMd` | 12dp | Karta |
| `radiusLg` | 20dp | Bottom sheet |
| `radiusXl` | 100dp | Pill tugmalar |
| `radiusFull` | 9999dp | Avatar, badge |

### Avatar O'lchamlari

| Nom | O'lcham | Ishlatilishi |
|-----|---------|-------------|
| `avatarXs` | 28dp | Bottom nav badge |
| `avatarSm` | 36dp | List tile |
| `avatarMd` | 48dp | Profile header |
| `avatarLg` | 72dp | Profile ekran |
| `markerSize` | 100dp | Xarita markeri |

---

## ✨ Animatsiyalar va Effektlar

### Sahifa O'tishlari
- Standard: `fadeIn` + `slideUp` kombinatsiyasi
- Bottom sheet: pastdan tepaga siljish
- Modal: fade in

### Marker Animatsiyasi
- Do'st joylashuvi o'zgarganda marker silliq ko'chadi
- Davomiyligi: 300ms
- Easing: `Curves.easeInOut`

### Haptic Feedback
- Asosiy tugma bosishda: `HapticFeedback.lightImpact()`
- Ghost Mode yoqishda: `HapticFeedback.mediumImpact()`
- Xatolikda: `HapticFeedback.heavyImpact()`

### Skeleton Loader
- Rang: `surface` rangi + shimmer effekti
- Davomiyligi: 1.5 sekund loop

---

## 🗺 Xarita Stillari

| Mavzu | Tavsif | Fayl |
|-------|--------|------|
| Dark | Qoʻngʻir-kulrang, past kontrastli | `assets/map_styles/dark_map.json` |
| Light | Toza oq, minimal labellar | `assets/map_styles/light_map.json` |

Bepul xarita stillari: [https://mapstyle.withgoogle.com](https://mapstyle.withgoogle.com)

---

## 🧱 Bottom Navigation Bar

4 tab:

| Tab | Icon | Label |
|-----|------|-------|
| 1 | `map_outlined` / `map` | Xarita |
| 2 | `people_outlined` / `people` | Do'stlar |
| 3 | `notifications_outlined` / `notifications` | Xabarlar |
| 4 | `person_outlined` / `person` | Profil |

- Aktiv tab: `primary` rang
- Nofaol tab: `textSecondary` rang
- Xabarlar ikonasida o'qilmagan xabarlar soni ko'rsatiladi (badge)
