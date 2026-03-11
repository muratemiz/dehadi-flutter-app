<h1 align="center">DeHadi — İngilizce Kelime Öğrenme Uygulaması</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-Personal-green?style=for-the-badge" />
</p>

<p align="center">
  Bilimsel aralıklı tekrar algoritması ile İngilizce kelime öğrenmeyi kalıcı ve eğlenceli hale getiren cross-platform mobil uygulama.
</p>

---

## ✨ Özellikler

| | Özellik | Açıklama |
|--|---------|----------|
| 🧠 | **Aralıklı Tekrar** | Yanlış bildiğin kelimeleri sık, doğru bildiğini seyrek göstererek kalıcı öğrenme |
| 📚 | **997 Kelime** | A1–C2 CEFR seviyelerine göre sınıflandırılmış kapsamlı kelime havuzu |
| 🃏 | **Flip Kartlar** | Ön yüz İngilizce, arka yüz Türkçe karşılık + tanım + örnek cümle |
| 🎯 | **3 Test Modu** | Çoktan seçmeli · Yazarak cevaplama (hangman) · Eşleştirme oyunu |
| 🔥 | **Streak Takibi** | Günlük çalışma serisi ve motivasyon sistemi |
| 📊 | **İstatistikler** | Doğruluk oranı, ilerleme grafikleri ve başarı rozetleri |
| 🔍 | **Kelime Kütüphanesi** | Tüm kelimeleri ara, seviyeye göre filtrele |
| 🌙 | **Karanlık Mod** | Tam karanlık tema desteği |
| 🔔 | **Günlük Bildirim** | Her gün hatırlatıcı ile düzenli çalışma alışkanlığı |

---

## 📸 Ekran Görüntüleri

<p align="center">
  <img src="screenshots/screenshot_3.png"  width="18%" alt="Giriş" />
  <img src="screenshots/screenshot_2.png"  width="18%" alt="Tanıtım" />
  <img src="screenshots/screenshot_4.png"  width="18%" alt="Ana Ekran" />
  <img src="screenshots/screenshot_6.png"  width="18%" alt="Kart — İngilizce" />
  <img src="screenshots/screenshot_7.png"  width="18%" alt="Kart — Türkçe" />
</p>

<p align="center">
  <img src="screenshots/screenshot_9.png"  width="18%" alt="Çoktan Seçmeli" />
  <img src="screenshots/screenshot_10.png" width="18%" alt="Yazarak Test" />
  <img src="screenshots/screenshot_13.png" width="18%" alt="Test Sonucu" />
  <img src="screenshots/screenshot_11.png" width="18%" alt="Kelime Listesi" />
  <img src="screenshots/screenshot_12.png" width="18%" alt="İstatistikler" />
</p>

---

## 🚀 Kurulum

### 1. Projeyi İndir

```bash
git clone https://github.com/muratemiz/dehadi-flutter-app.git
cd dehadi-flutter-app
```

### 2. Bağımlılıkları Yükle & Çalıştır

```bash
flutter pub get
dart run build_runner build
flutter run
```

### 3. Build Al

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

> **Gereksinimler:** Flutter 3.10+ · Dart 3.10+ · Xcode 14+ *(iOS)* · Android Studio *(Android)*

---

## 🗂️ Proje Yapısı

```
lib/
├── 📄 main.dart / uygulama.dart
│
├── 🔧 cekirdek/
│   ├── sabitler/         # Renk paleti
│   ├── tema/             # ThemeData
│   └── araclar/          # Hata yönetimi · Bildirim · Spaced Repetition
│
├── 🗄️ veri/
│   ├── modeller/         # Kelime & ilerleme modelleri (Hive)
│   ├── depolar/          # Veri erişim katmanı
│   └── kelimeler/        # 997 kelimelik JSON
│
├── ⚙️ saglayicilar/      # Kelime · Test · Streak · Tema (Provider)
│
├── 🧩 bilesenler/        # Flip card · Navigasyon · Streak badge
│
└── 📱 ekranlar/
    ├── acilis / giris / onboarding
    ├── ana_sayfa / kartlar
    ├── test/             # Çoktan seçmeli · Yazarak · Eşleştirme · Sonuç
    ├── kelime_listesi
    └── istatistik
```

---

## 🛠️ Teknolojiler

| Paket | Kullanım Amacı |
|-------|----------------|
| [provider](https://pub.dev/packages/provider) | State management |
| [hive](https://pub.dev/packages/hive) + [hive_flutter](https://pub.dev/packages/hive_flutter) | Yerel veritabanı |
| [flip_card](https://pub.dev/packages/flip_card) | Kart çevirme efekti |
| [flutter_animate](https://pub.dev/packages/flutter_animate) | Animasyonlar |
| [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | Günlük bildirimler |
| [google_fonts](https://pub.dev/packages/google_fonts) | Tipografi |
| [percent_indicator](https://pub.dev/packages/percent_indicator) | İlerleme göstergeleri |

---

## 📄 Lisans

Bu proje kişisel kullanım amaçlıdır. © 2026 DeHadi
