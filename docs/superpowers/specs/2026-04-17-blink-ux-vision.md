# Blink — Liquid Glass UI Vision

> Blink uchun **Apple iOS 26.4 / macOS Tahoe Liquid Glass** dizayn tilini to'liq qabul qilish bo'yicha texnik spetsifikatsiya. Hozirgi Material UI elementlarini bosqichma-bosqich glass-rendering bilan almashtiramiz.

---

## Filosofiya

Liquid Glass — Apple'ning yangi dizayn tili (2025 yil iyun WWDC'da e'lon qilindi). U **shisha**ning fizik xususiyatlarini taqlid qiladi:

1. **Refraction** — ostidagi kontent shisha ichidan ko'rinadi, biroz buziladi
2. **Specular Highlights** — yorug'lik shisha qirralarida porlaydi
3. **Dynamic Tinting** — shisha pastdagi rangni o'zlashtiradi
4. **Liquid Morph** — element holatlar orasida **suyuqlik kabi** o'zgaradi (snap emas)
5. **Concentric Geometry** — barcha rounded corner'lar bir-biriga matematik mos
6. **Edge-to-Edge** — kontent shisha ortidan o'tib ketadi, hech qachon "kesilmaydi"

**Asosiy farq Material'dan:** Material — qog'oz qatlamlari (paper). Liquid Glass — **suvga botgan kristall**. Material'da shadow muhim. Glass'da — **what's behind** muhim.

---

## Design Tokens

### Blur Hierarchy

| Daraja | Blur radius | Ishlatish |
|--------|-------------|-----------|
| `glass.thin` | 8pt | Inline chips, badges |
| `glass.regular` | 20pt | Bottom bars, AppBar |
| `glass.thick` | 40pt | Modal sheets, dialoglar |
| `glass.ultra` | 80pt | Lock screen overlay |

### Tint System

```
Surface base:       rgba(255,255,255, 0.06)   ← deyarli ko'rinmas
Surface elevated:   rgba(255,255,255, 0.14)   ← sheet, card
Surface prominent:  rgba(255,255,255, 0.24)   ← active button
Stroke specular:    rgba(255,255,255, 0.42)   ← top edge highlight
Stroke contour:     rgba(0,0,0, 0.08)         ← bottom shadow line
```

Dark mode: `rgba(0,0,0, ...)` ekvivalentlari, lekin specular har doim oq.

### Corner Radii (Concentric)

```
Outer container:    32pt
└─ Inner card:      24pt   (= outer - 8pt padding)
   └─ Button:       16pt   (= inner - 8pt padding)
      └─ Icon bg:   10pt
```

Bu Apple'ning **superellipse** formulasi — to'rtburchak emas, balki **squircle**.

### Spring Physics

Barcha animatsiyalar **bir xil spring** bilan:
```dart
SpringDescription(
  mass: 1.0,
  stiffness: 380,    // tez, lekin yumshoq
  damping: 28,       // 1 ta yengil bounce
)
```

Davomi: ~ 450ms. Hech qachon `Curves.easeInOut` ishlatmang.

### Typography

- SF Pro Rounded (yoki `Inter Display` agar SF mavjud bo'lmasa)
- Metric weights: 400 (body), 590 (emphasized), 700 (title)
- Tracking: -0.02em (tight, glass-readable)

---

## Komponentlar

### 1. BottomNavigationBar → Glass Capsule

**Hozirgi:** Material `BottomNavigationBar`, qattiq oq fon.

**Yangi:** Pastdan **20pt floating** turuvchi **kapsula** shaklidagi shisha bar.

```
┌─────────────────────────────────────┐
│                                     │
│         [Map content here]          │
│                                     │
│                                     │
│      ╭───────────────────────╮     │
│      │ 🗺️    👥•    👤      │     │  ← glass capsule
│      ╰───────────────────────╯     │
│              (20pt margin)          │
└─────────────────────────────────────┘
```

**Spec:**
- Height: 56pt, horizontal margin: 16pt, bottom safe-area + 12pt
- Radius: 28pt (yarim balandlik = ideal capsule)
- Backdrop: `BackdropFilter(blur: 30)` + `surface.elevated`
- Top edge: 1pt `stroke.specular` (ichkari to'g'ri yorug'lik)
- Bottom edge: 0.5pt `stroke.contour`
- Selected tab: ichida **kichik glass pellet** (radius 20, tint.prominent), tab orasida **liquid morph** bilan suriladi (snap emas)

**Liquid morph:** Tab almashtirilganda, pellet **cho'zilib** keyingi tab ostiga **suyuq tarzda** oqib boradi (Apple Dock'dagi kabi).

```dart
// Pseudocode
AnimatedAlign(
  duration: 450ms, curve: spring,
  alignment: Alignment(_index == 0 ? -1 : _index == 1 ? 0 : 1, 0),
  child: GlassPellet(...),
)
// + GestureDetector with onPanUpdate to drag pellet
```

---

### 2. AppBar → Vanishing Glass

**Hozirgi:** `AppBar` qattiq fon, sarlavha matnli.

**Yangi:** AppBar **butunlay yo'q** — kontent ekranning yuqorisidan boshlanadi (status bar ortidan ham). Sarlavha **glass pill** sifatida yuqorida suzadi:

```
┌──────────────────────────────┐
│  ╭───────────╮          ✏️   │   ← glass pill (sarlavha) + edit
│  │ Sozlamalar │              │
│  ╰───────────╯               │
│                              │
│   [scroll content here,      │
│    pill ortidan ko'rinadi]   │
│                              │
```

Scroll'da pill **biroz qisqaradi** (font 20pt → 17pt) va **qattiqroq blur** oladi.

---

### 3. Friend Marker → Glass Bead

**Hozirgi:** `CircleAvatar` + green/grey border + matn.

**Yangi:** **Shisha munchoq** (glass bead) — avatar ichida shisha qatlam, ichkaridan refraktsiya:

```
        ╭─────╮
        │ ⊙   │  ← top specular (oq yarim oy)
        │  Ali │
        │     │  ← bottom shadow (yumshoq)
        ╰─────╯
        Online: pulsing ring
```

**Spec:**
- 56pt diameter
- Avatar image — outer border'dan 4pt ichkarida
- 1pt outer ring: `stroke.specular` (top arc 0°-180°), `stroke.contour` (bottom arc)
- Online → **soft pulse ring** atrofida (40pt → 60pt, opacity 0.4 → 0, 1.6s loop)
- Offline → desaturated (saturation 0.3) va **ichki haze** (avatar ustida 6pt blur)

**Friend label:** marker tagida **glass chip** — `glass.thin` blur, 11pt SF Rounded:
```
   [Ali avatar]
   ╭─────╮
   │ Ali │  ← floating glass chip
   ╰─────╯
```

---

### 4. FriendLocationSheet → Liquid Glass Panel

**Hozirgi:** `showModalBottomSheet` qattiq fon.

**Yangi:** Pastdan ko'tarilayotgan **shisha panel**, **3 ta detent**:
- 80pt (peek — faqat sarlavha)
- 320pt (medium — info + actions)
- Full screen

```
   xarita ko'rinadi
   ───────────────
   ╭───────────────────╮
   │ ───  (drag knob)  │   ← top edge specular
   │  [Ali] · 240m     │
   │  📚 mashg'ulotda  │
   │  ━━━━━━━━━━━━━━  │
   │  [Yo'l] [Pulse]   │
   ╰───────────────────╯
```

**Spec:**
- Top corners: 32pt, bottom: 0 (yopishadi)
- `BackdropFilter(blur: 40)` + `surface.elevated`
- Top inner glow: 8pt height, vertical gradient
- Drag knob: 36pt × 4pt, 2pt radius, color `surface.prominent`
- **Spring drag** — barmoq ortidan **yumshoq kechikish** bilan ergashadi

---

### 5. In-App Banner → Floating Glass Card

**Hozirgi:** Oq Material `Container` + shadow.

**Yangi:** Yuqoridan tushadigan **shisha kartochka**, edge'lari porlaydi:

```
┌──────────────────────────────────┐
│                                  │
│  ╭──────────────────────────╮   │
│  │ ⊙─────────────────────⊙  │   │ ← top specular line
│  │  💬  Ali sizga so'rov    │   │
│  │      yubordi          ✕  │   │
│  ╰──────────────────────────╯   │
│                                  │
```

**Spec:**
- Margin: 12pt, height: 72pt
- Radius: 24pt
- Backdrop: `glass.regular` + `surface.elevated`
- **Top inner glow** (8pt, oq → shaffof)
- Tushishda: -100pt'dan 24pt'ga **spring**, scale 0.92 → 1.0
- Yopilishda: opacity 1 → 0 + scale 1 → 0.94 + blur 40 → 80 (parlayotgan kabi)

---

### 6. Tab Pellet Indicator (FriendsScreen TabBar)

**Hozirgi:** Material `TabBar` ostida 2pt liniya.

**Yangi:** Liniya yo'q. Faqat **glass pellet** active tab orqasida (BottomNav'dagi kabi):

```
   ╭──────╮
   │ Do'st│  ╭So'rov╮  Qo'sh
   ╰──────╯  ╰──────╯
   ↑ active     hover
```

Tab almashtirganda pellet **cho'zilib** suriladi.

---

### 7. Friend Tile → Stacked Glass Card

**Hozirgi:** `ListTile` qattiq fon, divider chiziq.

**Yangi:** Har bir tile alohida **shisha kartochka**, 8pt orasida, hech qanday divider:

```
   ╭────────────────────────────╮
   │ [⊙Ali]  Ali Vali           │
   │         @aliv · ☀️ aktiv   │
   ╰────────────────────────────╯
   ╭────────────────────────────╮
   │ [⊙Bek]  Bek Karim          │
   ...
```

**Spec:**
- Margin: 8pt vertikal, 16pt gorizontal
- Radius: 20pt
- Backdrop: `glass.thin` (subtle)
- Long-press → **liquid scale + glow**: 1.0 → 0.96 → spring back, atrofda **soft outer glow** ko'rinadi (12pt blur, white 30%)

---

### 8. QR Dialog → Frosted Glass Card

**Hozirgi:** Material `Dialog`, oq fon.

**Yangi:** Markazda suzayotgan **frosted glass** kartochka, fon **darken + ultra blur**:

```
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
   ▓                  ▓
   ▓   ╭──────────╮  ▓
   ▓   │ Mening   │  ▓
   ▓   │   QR     │  ▓
   ▓   │ ████ ██  │  ▓   ← QR with subtle inner shadow
   ▓   │ ██ ████  │  ▓
   ▓   │ ████ ██  │  ▓
   ▓   │ @abdul   │  ▓
   ▓   ╰──────────╯  ▓
   ▓                  ▓
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

**Spec:**
- Backdrop fon: `BackdropFilter(blur: 80)` + black 40%
- Card: 280pt × 380pt, radius 32pt
- QR ichida **subtle inner shadow** — qog'ozday emas, shisha ostidan ko'ringanday
- Yopish — markazga **qisilib** + opacity (kameraning aperture'i kabi)

---

### 9. Switch (Ghost Mode) → Liquid Toggle

**Hozirgi:** Material `Switch`.

**Yangi:** Apple-style **liquid toggle**, ON paytida **ichki yorug'lik nafas oladi**:

```
OFF:  ╭─────────╮          ON:   ╭─────────╮
      │  ⚪     │                │     ⚪  │  ← glow
      ╰─────────╯                ╰─────────╯
                                  (subtle inner glow,
                                   pulses 2.4s)
```

**Spec:**
- Track: 56pt × 32pt
- Thumb: 28pt diametr, **shisha bead** kabi (specular top)
- ON → track tint: gradient (top: blue 70%, bottom: blue 90%)
- ON → thumb ichida **breathing glow** (opacity 0.6 → 1.0, 2.4s loop)
- Toggle — **liquid morph** (thumb cho'zilib o'tadi, snap emas)

---

### 10. FAB → Glass Orb

**Hozirgi:** Material `FloatingActionButton`.

**Yangi:** **Shisha sharik** — refraktsiya bilan ostidagi xarita ko'rinadi:

```
         ╭───╮
         │⊙  │  ← specular highlight (top-left)
         │ ⌖ │  ← icon
         │   │  ← bottom shadow gradient
         ╰───╯
```

**Spec:**
- 56pt diametr
- Backdrop: `glass.regular`
- Top-left: 40% opacity oq specular blob (gradient)
- Bottom: 8pt blur shadow (nature-inspired, soft)
- Tap → **liquid squish** (Y scale 0.85, X scale 1.05, spring back)
- Long-press → **tortilib chiqish** (avatardan radial menu chiqishi mumkin — kelajak uchun)

---

### 11. Map Markers Cluster — Liquid Merge

**Hozirgi:** Markerlar ko'p bo'lsa, ustma-ust.

**Yangi:** Ikki marker yaqin bo'lsa — **suyuqlik kabi birlashadi** (metaball effect):

```
   [Ali]  [Bek]  →  zoom out  →  [Ali Bek]  ← bir bead'da
                                  (ichida 2 ta avatar
                                   yarim halqa shaklida)
```

**Spec:** Custom shader (Flutter `FragmentShader`) — distance-field metaball. Yoki MVP uchun: oddiy `AnimatedContainer` ikki marker orasini bog'lab.

---

### 12. Pull-to-Refresh — Liquid Drop

**Hozirgi:** Material `RefreshIndicator` aylanma.

**Yangi:** Yuqoridan **suyuqlik tomchisi** tushadi, content tortilganda **cho'ziladi**, qaytarilganda **silliq qaytadi**:

```
Pulling:        Released:
   ─ ─ ─           ●
    ╲             ●●●
     ●            (drop oqib tushadi)
```

---

## Mikroanimatsiyalar

### Glass Ripple (tap feedback)

Barcha tappable glass elementlarda — Material ripple emas, balki **shisha to'lqin**:
- Tap nuqtasidan **circular wave** tarqaladi
- Ranglar: shaffof → oq 30% → shaffof
- Davomi: 800ms

### Hover/Press Specular Travel

Element ustiga barmoq qo'yilganda — **specular highlight** barmoq ostida harakat qiladi (agar trackpad / Apple Pencil bo'lsa):
- Material'da hover'da rang o'zgaradi. Glass'da — yorug'lik **suriladi**.

### Tab Switch — Map Refraction Wave

Tab almashtirilganda butun ekran ustidan **refraktsiya to'lqini** o'tadi (xuddi shisha eshik silkitilgan kabi):
- 0.4s davomida diagonally
- `FragmentShader` orqali distortion field

### Pulse Reception

Pulse yetganda — ekranda **konsentrik halqalar** chiqadi, har biri **glass with specular**:
```
        ╭───╮
       (  ●  )
      ( (   ) )    ← 3 halqa, kengayadi va so'nadi
     ( (     ) )
```

---

## Flutter Implementation

### Asosiy paketlar

```yaml
# pubspec.yaml ga qo'shish
dependencies:
  glassmorphism: ^3.0.0          # quick glass containers
  flutter_animate: ^4.5.0        # spring animations
  smooth_corner: ^2.1.0          # squircle/superellipse
  liquid_swipe: ^3.1.0           # liquid morph transitions
```

### Asosiy widget — `GlassSurface`

Reusable widget yaratish kerak (bir martalik):

```dart
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;        // 8 | 20 | 40 | 80
  final double tintOpacity; // 0.06 | 0.14 | 0.24
  final double radius;
  final bool specular;

  const GlassSurface({
    required this.child,
    this.blur = 20,
    this.tintOpacity = 0.14,
    this.radius = 24,
    this.specular = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(tintOpacity),
            border: Border(
              top: specular
                  ? BorderSide(color: Colors.white.withOpacity(0.42), width: 1)
                  : BorderSide.none,
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.08), width: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

Barcha komponentlar shu `GlassSurface` ustiga quriladi.

### Spring curve helper

```dart
const kGlassSpring = Cubic(0.32, 0.72, 0, 1);
const kGlassDuration = Duration(milliseconds: 450);
```

---

## Implementation Roadmap

| Faza | Vazifa | Effort |
|------|--------|--------|
| **Glass Phase 1** | `GlassSurface` widget + design tokens | 1 kun |
| **Glass Phase 2** | BottomNav + AppBar + Banner | 2 kun |
| **Glass Phase 3** | Friend marker + tile + sheet | 2 kun |
| **Glass Phase 4** | FAB + Switch + QR dialog | 1 kun |
| **Glass Phase 5** | Mikroanimatsiyalar (ripple, specular, pulse) | 3 kun |
| **Glass Phase 6** | Liquid morphs (tab pellet, marker cluster) | 4 kun |
| **Glass Phase 7** | Custom shaders (refraction wave, metaball) | 1 hafta |

**Jami:** ~3 hafta to'liq Liquid Glass migratsiyasi.

**MVP** (Phase 1-4 — 6 kun): zamonaviy ko'rinish, lekin shader'siz.

---

## Boshlash

Eng mantiqiy birinchi qadam — `GlassSurface` widget yaratish va **BottomNavigationBar**'ni glass capsule bilan almashtirish. Bu eng katta vizual ta'sir, eng kam kod o'zgartirish.

Tayyor bo'lsangiz — Glass Phase 1 plan yozaman.
