# 👻 Ghost Mode UI

Ghost Mode — foydalanuvchining barcha yoki tanlangan do'stlardan joylashuvini yashirish imkoniyati.

---

## 🎯 Ghost Mode Turlari

| Tur | Tavsif |
|-----|--------|
| **Global Ghost** | Barcha do'stlardan yashiriladi |
| **Selective Ghost** | Faqat tanlangan do'stlardan yashiriladi |

---

## 🖼 UI Elementlari

### 1. Ghost Mode FAB (Map Screen)

Xaritaning o'ng pastki qismida joylashgan aylana tugma.

| Holat | Fon rangi | Icon rangi | Icon |
|-------|-----------|------------|------|
| Ghost OFF | Oq | Qora | `visibility` |
| Ghost ON | Binafsha | Oq | `visibility_off` |

---

### 2. Ghost Mode Banner (Map Screen)

Ghost Mode yoqilganda xaritaning yuqori qismida chiqadigan kichik banner.

**Ko'rinishi:**
```
┌─────────────────────────────┐
│  👻  Ghost Mode ON          │  ← Binafsha fon
└─────────────────────────────┘
```

**Xususiyatlari:**
- Faqat foydalanuvchining o'ziga ko'rinadi
- Do'stlar hech narsa ko'rmaydi
- Binafsha fon, oq matn, `visibility_off` icon

---

### 3. Selective Ghost (Friends Screen)

Do'stlar ro'yxatida har bir do'st yonida ghost tugmasi:

```
┌─────────────────────────────────────┐
│ [👤] Alex Karimov          [👻 ●]  │  ← Ghost yoqilgan (to'ldirilgan)
│ [👤] Bobur Toshev          [👻 ○]  │  ← Ghost o'chirilgan (bo'sh)
└─────────────────────────────────────┘
```

---

### 4. Settings → Ghost Mode

Settings ekranida Ghost Mode uchun alohida bo'lim:

```
┌─────────────────────────────────────┐
│ 👻 Ghost Mode                       │
│                                     │
│ Global ghost        [ Toggle ●──○ ] │
│                                     │
│ Scheduled ghost                  >  │
│   22:00 – 08:00                     │
│                                     │
│ Ghosted from (2 friends)         >  │
└─────────────────────────────────────┘
```

---

## ⏰ Scheduled Ghost Mode UI

Foydalanuvchi vaqt oralig'ini belgilaydi, ihlova avtomatik ghost mode'ni yoqadi/o'chiradi.

```
┌──────────────────────────────────┐
│ ⏰ Scheduled Ghost               │
│                                  │
│ Start time     [22:00  ▼]        │
│ End time       [08:00  ▼]        │
│                                  │
│ Enabled        [ Toggle ●──○ ]   │
│                                  │
│        [Save]                    │
└──────────────────────────────────┘
```

---

## 🔄 Ghost Mode Holati (Riverpod)

**Provider:** `presentation/providers/` — `ghostModeProvider`

**GhostModeState xossalari:**

| Xossa | Turi | Tavsif |
|-------|------|--------|
| `isGlobalGhost` | bool | Global ghost yoqilganmi |
| `ghostedFromUids` | List\<String\> | Yashirilgan do'stlar UID'lari |

**Foydali metod:** `isGhostedFrom(uid)` — berilgan do'stdan yashirilganmi?

---

## 🗄 Firestore Ma'lumotlari

Ghost Mode holati `users/{uid}` hujjatida saqlanadi:

```
ghostMode: true/false         ← Global ghost
ghostFromList: [uid1, uid2]   ← Selective ghost ro'yxati
```

---

## 🔒 Xavfsizlik Qoidasi

Ghost mode Firestore Security Rules darajasida ham himoyalanadi — do'stlar ghost foydalanuvchining joylashuvini o'qiy olmaydi.

---

## 📊 Ghost Mode Xulosa Jadvali

| Holat | Do'st nima ko'radi |
|-------|-------------------|
| Ghost Mode OFF | Real-vaqt joylashuv |
| Ghost Mode ON (global) | Oxirgi ma'lum joylashuv (muzlatilgan) |
| Selective ghost | Faqat o'sha do'st muzlatilgan joylashuvni ko'radi |
| Joylashuv = "off" | Do'st hech narsa ko'rmaydi |
| Ghost ON + ilova yopiq | Yangilanish yo'q, joylashuv muzlagan |
