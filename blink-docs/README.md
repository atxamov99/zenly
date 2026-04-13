# 📱 Blink — Frontend Documentation

Zenly-ilhomlangan real-vaqt joylashuv ilovasi **Blink** uchun to'liq frontend hujjatlari.

---

## 📂 Hujjatlar ro'yxati

| Fayl | Tavsif |
|------|--------|
| [SCREENS.md](./SCREENS.md) | Barcha ekranlar va navigatsiya |
| [WIDGETS.md](./WIDGETS.md) | Qayta ishlatiladigan UI komponentlar |
| [MAPS_UI.md](./MAPS_UI.md) | Xarita va markerlar (Google Maps) |
| [GHOST_MODE_UI.md](./GHOST_MODE_UI.md) | Ghost Mode UI va animatsiyalar |
| [AUTH_UI.md](./AUTH_UI.md) | Autentifikatsiya ekranlari |
| [PROVIDERS.md](./PROVIDERS.md) | Riverpod state management |
| [THEME.md](./THEME.md) | Ranglar, shriftlar, mavzu |
| [FOLDER_FRONTEND.md](./FOLDER_FRONTEND.md) | Frontend papka tuzilmasi |
| [FEATURES_UI.md](./FEATURES_UI.md) | UI funksiyalar ro'yxati |

---

## 🛠 Tech Stack (Frontend)

| Texnologiya | Maqsad |
|-------------|--------|
| **Flutter** | Cross-platform UI framework |
| **Riverpod** | State management + DI |
| **Google Maps Flutter** | Interaktiv xarita |
| **GoRouter** | Navigatsiya |
| **Hive** | Lokal kesh |
| **Cached Network Image** | Avatar rasmlari |

---

## 🏛 Arxitektura qisqacha

```
Presentation Layer  (Screens + Widgets + Providers)
        ↓
Domain Layer        (Use Cases + Entities)
        ↓
Data Layer          (Firebase + Local Cache)
```

Presentation qatlami faqat **Domain** bilan ishlaydi — Firebase haqida hech narsa bilmaydi.
