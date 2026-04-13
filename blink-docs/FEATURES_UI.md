# ✨ UI Funksiyalar Ro'yxati

**Blink** ilovasining barcha foydalanuvchi interfeysi funksiyalari.

---

## 🔐 Autentifikatsiya

| Funksiya | Tavsif | Ekran |
|----------|--------|-------|
| Telefon OTP | 6 xonali kod bilan kirish | `otp_screen.dart` |
| Email/Parol | Ro'yxatdan o'tish va kirish | `register_screen.dart` |
| Google Sign-In | Bir bosish bilan kirish | `login_screen.dart` |
| Auto-kirish | Ilova qayta ochilganda token tekshirish | `splash_screen.dart` |
| Chiqish | Barcha sessiyalarni tugatish | `settings_screen.dart` |
| Hisob o'chirish | To'liq ma'lumotlarni o'chirish | `settings_screen.dart` |

---

## 👤 Foydalanuvchi Profili

| Funksiya | Tavsif | Ekran |
|----------|--------|-------|
| Avatar yuklash | Galereyadan rasm tanlash | `profile_setup_screen.dart` |
| Emoji tanlash | Profil emoji belgilash | `profile_setup_screen.dart` |
| Status xabari | Qisqa holat matni | `edit_profile_screen.dart` |
| Online/Offline | Real-vaqt faollik holati | `profile_screen.dart` |
| Last seen | Oxirgi faollik vaqti | `profile_screen.dart` |

---

## 👥 Do'stlar Tizimi

| Funksiya | Tavsif | Ekran |
|----------|--------|-------|
| Qidirish | Username yoki telefon bo'yicha | `friends_screen.dart` |
| So'rov yuborish | Do'stlik taklifini yuborish | `friends_screen.dart` |
| So'rovni qabul qilish | Kelgan taklifni qabul qilish | `notifications_screen.dart` |
| So'rovni rad etish | Taklifni rad etish | `notifications_screen.dart` |
| Do'stni o'chirish | Do'stlikdan chiqarish | `friends_screen.dart` |
| Bloklash | Foydalanuvchini bloklash | `friends_screen.dart` |
| Online badge | Do'st yonida yashil nuqta | `friends_screen.dart` |
| Do'stlar soni | Profil sahifasida ko'rsatish | `profile_screen.dart` |

---

## 🗺️ Jonli Xarita

| Funksiya | Tavsif | Widget/Ekran |
|----------|--------|-------------|
| Real-vaqt xarita | Google Maps widget | `map_screen.dart` |
| Avatar markerlar | Har do'st uchun dumaloq avatar | `friend_marker.dart` |
| Marker bosilishi | Bottom sheet ochiladi | `friend_bottom_sheet.dart` |
| Mening joyim | O'z markerim (boshqalardan ustida) | `map_screen.dart` |
| Markazlashtirish | Mening joyimga FAB | `map_screen.dart` |
| Do'stga o'tish | Marker bosilganda kamera siljiydi | `map_provider.dart` |
| Barcha ko'rsatish | Barcha do'stlar ko'rinadigan zoom | `map_provider.dart` |
| Guruhlash | Yaqin markerlarni birlashtirish | `map_screen.dart` |

---

## 📍 Joylashuv Kuzatish

| Funksiya | Tavsif | Joylashuv |
|----------|--------|----------|
| Foreground GPS | Ilova ochiqligida kuzatish | `location_service.dart` |
| Background GPS | Ilova yopiqda ham kuzatish | `location_service.dart` |
| Manzil aniqlash | GPS → O'qish mumkin manzil | `geocoding_service.dart` |
| Aniqlik rejimi | High/Balanced/Low/Lowest | `location_service.dart` |
| Joylashuv rejimlari | Precise / Approximate / Off | `settings_screen.dart` |

---

## 👻 Ghost Mode

| Funksiya | Tavsif | UI |
|----------|--------|-----|
| Global ghost | Barcha do'stlardan yashirish | Map FAB, Settings |
| Selective ghost | Tanlangan do'stlardan yashirish | Friends Screen |
| Ghost banner | Faqat o'ziga ko'rinadi | Map Screen top |
| Scheduled ghost | Vaqt oralig'ida avtomatik | Settings Screen |

---

## 🔋 Batareya Holati

| Funksiya | Tavsif | Widget |
|----------|--------|--------|
| Foiz ko'rsatish | 0–100% son va icon | `battery_indicator.dart` |
| Rang ko'rsatish | Yashil/Sariq/Qizil | `battery_indicator.dart` |
| Zaryadlanish | ⚡ belgisi bilan | `battery_indicator.dart` |
| Do'st markeri | Avatar markerida foiz | `friend_marker.dart` |
| Bottom sheet | Do'st ma'lumot paneli | `friend_bottom_sheet.dart` |
| Avtomatik yangilash | Har 60 soniyada | `battery_service.dart` |

---

## 🔔 Bildirishnomalar

| Funksiya | Tavsif | Ekran |
|----------|--------|-------|
| Do'stlik so'rovi | Push notification | Notifications |
| Online xabari | Do'st onlayn bo'lganda | Notifications |
| Wave / Ping | Maxsus signal yuborish | Friend Bottom Sheet |
| Yaqinlik ogohlantirish | Do'st yaqin kelganda | Notifications |
| O'qilgan/O'qilmagan | Holat belgilash | `notifications_screen.dart` |
| Badge | Bottom nav'da son | `home_screen.dart` |

---

## 💬 Faollik Lentasi

| Funksiya | Tavsif |
|----------|--------|
| So'nggi harakatlar | Do'stlarning yangi hududga kelishi |
| Avtomatik yangilanish | "X joyga keldi" xabarlari |
| 24 soat tarixi | Do'stning kun bo'yi harakati |

---

## 🎨 UI / UX

| Funksiya | Tavsif |
|----------|--------|
| Dark / Light mavzu | Foydalanuvchi tanlaydi |
| Skeleton loader | Yuklanish vaqtida |
| Silliq animatsiyalar | Sahifa o'tishlari, marker harakati |
| Haptic feedback | Tugma bosishda tebranish |
| Bottom sheet | Do'st ma'lumotlari |
| Custom markerlar | Avatar asosida xarita markerlari |

---

## ⚙️ Sozlamalar

| Sozlama | Tavsif |
|---------|--------|
| Bildirishnomalar | Har tur uchun alohida yoq/o'chir |
| Joylashuv tezligi | GPS yangilanish intervali |
| Ghost Mode | Tez o'chirish/yoqish |
| Mavzu | Dark / Light / System |
| Hisob | Chiqish, o'chirish |
| Ilova haqida | Versiya va build raqami |
