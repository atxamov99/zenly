# 🗺️ Xarita UI (Google Maps)

**Blink** ilovasida Google Maps integratsiyasi va xarita interfeysining to'liq tavsifi.

---

## 📦 Paketlar

| Paket | Versiya | Maqsad |
|-------|---------|--------|
| `google_maps_flutter` | ^2.5.0 | Asosiy xarita widget |
| `google_maps_cluster_manager` | ^3.0.0 | Markerlarni guruhlash |

---

## 🗺 Xarita Widget Sozlamalari

**Fayl:** `presentation/screens/map/map_screen.dart`

Asosiy xarita quyidagi sozlamalar bilan ochiladi:

| Sozlama | Qiymat | Sabab |
|---------|--------|-------|
| `initialCameraPosition` | Toshkent (41.2995, 69.2401), zoom 13 | Default joylashuv |
| `myLocationEnabled` | `false` | Custom marker ishlatiladi |
| `myLocationButtonEnabled` | `false` | Custom FAB ishlatiladi |
| `zoomControlsEnabled` | `false` | Toza dizayn |
| `compassEnabled` | `false` | Toza dizayn |
| `mapType` | `MapType.normal` | Standart stil |

---

## 🎨 Custom Xarita Stili

Dark/Light mavzuga qarab xarita rangi o'zgaradi.

**Stil fayllari:**
```
assets/map_styles/
├── dark_map.json    ← Qoʻngʻir-kulrang, past kontrastli
└── light_map.json   ← Toza oq, minimal labellar
```

Stil `onMapCreated` callback'da qo'llaniladi.

---

## 👤 Avatar Markerlar

Har bir do'st xaritada **dumaloq avatar marker** ko'rinishida chiqadi.

### Marker yaratish jarayoni

```
Avatar URL
    │
    ▼
HTTP orqali rasm yuklanadi
    │
    ▼
Canvas'da aylana shaklida cliplanadi
    │
    ▼
Ko'k chegara (border) qo'shiladi
    │
    ▼
PNG bytes → BitmapDescriptor
    │
    ▼
Marker(icon: descriptor)
```

### Marker ko'rinishi

```
    ╭──────╮
   ╱  👤   ╲   ← Do'st avatari
  │  rasm   │
   ╲        ╱
    ╰──────╯
   🔵 Ko'k chegara → Online
   🟡 Sariq chegara → Idle  
   ⚫ Kulrang chegara → Offline
```

---

## 📍 Markerlar To'plami

Xaritada ikki turdagi marker bo'ladi:

### 1. Mening markerim
- `MarkerId('me')`
- `zIndex: 1.0` — boshqalar ustida turadi
- Bosish → Mening profil sheet'im

### 2. Do'stlar markerlari
- `MarkerId(friendUid)`
- Bosish → `FriendBottomSheet` ochiladi

---

## 🔵 Markerlarni Guruhlash (Clustering)

Ko'p do'stlar yaqin bo'lganda ular guruhlanadi:

```
Zoom OUT (uzoq):          Zoom IN (yaqin):
                          
    [3]    ← 3 do'st      [👤] [👤] [👤]
                          
    [5]    ← 5 do'st      [👤] [👤] [👤]
                          [👤] [👤]
```

**Cluster marker ko'rinishi:** Raqamli badge (masalan, `3`, `12`)

---

## 🎥 Kamera Boshqaruvi

### Do'st markeriga o'tish
Marker bosilganda kamera silliq animatsiya bilan o'sha joyga o'tadi:
- **Zoom:** 15.5
- **Animatsiya:** `animateCamera()`

### Barcha do'stlarni ko'rsatish
"Fit All" tugmasi barcha do'stlar ko'rinadigan darajada kamerani sozlaydi:
- Chegaralarni hisoblab, `LatLngBounds` yaratiladi
- 80px padding qo'shiladi
- `CameraUpdate.newLatLngBounds()` ishlatiladi

---

## 🕹 Xarita UI Elementlari

```
┌─────────────────────────────────────┐
│  👻 Ghost Mode ON          [banner] │  ← Faqat ghost mode'da
│                                     │
│              [Xarita]               │
│                                     │
│    [👤Alex]  [👤Bobur]              │  ← Do'st markerlari
│                    [👤Men]          │  ← Mening markerim
│                                     │
│                            [🎯]     │  ← Mening joyimga qaytish FAB
│                            [👻]     │  ← Ghost Mode FAB
│                                     │
├─────────────────────────────────────┤
│  🗺  │  👥  │  🔔  │  👤           │  ← Bottom Nav
└─────────────────────────────────────┘
```

---

## 🎛 FAB Tugmalari (Map Screen)

### Ghost Mode FAB
| Holat | Rang | Icon |
|-------|------|------|
| Ghost OFF | Oq | `visibility` |
| Ghost ON | Binafsha | `visibility_off` |

### Center (Mening joyim) FAB
- Bosish → Kamera mening joylashuvimga o'tadi
- Zoom: 15.0
- Icon: `my_location`

---

## 🔄 Real-Vaqt Yangilanish

Do'stlar joylashuvi Firestore stream orqali yangilanadi:

```
Firestore stream
    │
    ▼
MapProvider (Riverpod)
    │
    ▼
_buildMarkers() chaqiriladi
    │
    ▼
setState() → GoogleMap qayta quriladi
    │
    ▼
Marker silliq ko'chadi
```

> Marker o'rnini o'zgartirish animatsiyasi uchun `flutter_animarker` paketi ishlatilishi mumkin.

---

## 🌐 API Kalitlari

| Platforma | Joylashuv |
|-----------|-----------|
| Android | `android/app/src/main/AndroidManifest.xml` → `MAPS_API_KEY` |
| iOS | `ios/Runner/AppDelegate.swift` → `GMSServices.provideAPIKey(...)` |

> ⚠️ API kalitlarni hech qachon Git'ga qo'shmang!
