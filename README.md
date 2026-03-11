# DeHadi - İngilizce Kelime Öğrenme Uygulaması

Flutter ile geliştirilmiş, İngilizce kelime öğrenmeye yönelik mobil uygulama.

## Özellikler

- **997 kelime** - A1, A2, B1, B2, C1, C2 seviyelerine göre sınıflandırılmış
- **Günlük kelime kartları** - Her gün istediğin kadar kelime öğren (5-50 arası)
- **3 farklı test türü** - Çoktan seçmeli, yazarak cevaplama (joker destekli), eşleştirme
- **Adam asmaca tarzı** - Yazma testlerinde hangman stili harf gösterimi
- **Aralıklı tekrar** - Spaced repetition algoritması ile kalıcı öğrenme
- **Seri takibi** - Günlük streak ve motivasyon sistemi
- **Kelime arama** - Tüm kelimeleri ara, filtrele ve detaylarını gör
- **İstatistikler** - İlerleme, başarı rozetleri ve detaylı istatistikler
- **Bildirimler** - Günlük hatırlatma bildirimleri
- **Karanlık mod** - Göz dostu karanlık tema desteği
- **Kullanıcı profili** - İsim girişi ve profil yönetimi

## Kurulum

### Gereksinimler

- Flutter SDK (3.10+)
- Dart SDK (3.10+)
- Xcode (iOS için)
- Android Studio / Android SDK (Android için)

### Çalıştırma

```bash
# Bağımlılıkları yükle
flutter pub get

# Hive model dosyalarını oluştur
dart run build_runner build

# iOS için çalıştır
flutter run -d <ios_device_id>

# Android APK oluştur
flutter build apk --release

# iOS build
flutter build ios --release
```

## Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── uygulama.dart                      # Ana uygulama widget'ı ve route tanımları
├── cekirdek/
│   ├── sabitler/
│   │   └── uygulama_renkleri.dart     # Renk paleti (Fasih teması)
│   ├── tema/
│   │   └── uygulama_temasi.dart       # ThemeData tanımları
│   └── araclar/
│       ├── hata_yonetimi.dart         # Global hata yakalama
│       ├── bildirim_yoneticisi.dart   # Bildirim yönetimi
│       └── aralikli_tekrar.dart       # Spaced repetition algoritması
├── veri/
│   ├── modeller/
│   │   ├── kelime_modeli.dart         # Kelime veri modeli (Hive)
│   │   └── kullanici_ilerlemesi.dart  # İlerleme & seri modeli (Hive)
│   └── depolar/
│       └── kelime_deposu.dart         # Veri erişim katmanı (Singleton)
├── saglayicilar/
│   ├── kelime_saglayici.dart          # Kelime state yönetimi
│   ├── test_saglayici.dart            # Test state yönetimi
│   ├── seri_saglayici.dart            # Streak state yönetimi
│   └── tema_saglayici.dart            # Tema state yönetimi
├── bilesenler/
│   ├── buzlu_bilesenler.dart          # Ortak UI bileşenleri
│   ├── gezinti_cubugu.dart            # Alt navigasyon çubuğu
│   ├── cevir_kart.dart                # Flip card widget
│   ├── seri_rozeti.dart               # Streak badge widget
│   └── ilerleme_gostergesi.dart       # İlerleme göstergeleri
└── ekranlar/
    ├── acilis/acilis_ekrani.dart      # Splash screen
    ├── giris/giris_ekrani.dart        # Kullanıcı giriş ekranı
    ├── onboarding/onboarding_ekrani.dart
    ├── ana_sayfa/ana_ekran.dart       # Ana ekran + profil/ayarlar
    ├── kartlar/kart_ekrani.dart       # Kelime kartları
    ├── test/
    │   ├── test_secim_ekrani.dart     # Test türü seçimi
    │   ├── test_ekrani.dart           # Çoktan seçmeli test
    │   ├── yazarak_test_ekrani.dart   # Yazarak cevaplama testi
    │   ├── eslestirme_ekrani.dart     # Eşleştirme oyunu
    │   └── test_sonuc_ekrani.dart     # Sonuç ekranı
    ├── kelime_listesi/kelime_listesi_ekrani.dart
    └── istatistik/istatistik_ekrani.dart
```

## Teknolojiler

- **Flutter** - Cross-platform UI framework
- **Hive** - Yerel NoSQL veritabanı
- **Provider** - State management
- **flutter_animate** - Animasyon kütüphanesi
- **Google Fonts** - Tipografi
- **flutter_local_notifications** - Bildirimler

## Lisans

Bu proje kişisel kullanım amaçlıdır.
