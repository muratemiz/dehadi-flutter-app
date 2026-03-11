import 'dart:math';

/// ─── ARALIKLI TEKRAR ALGORİTMASI ───
/// Leitner sistemi: Doğru cevaplanan kelimeler giderek daha geç tekrar edilir,
/// yanlış cevaplananlara ertesi gün tekrar sorulur.
///
/// ► TEKRAR ARALIKLARINI DEĞİŞTİRMEK:
///   Doğru cevap formülü: 2^seviye gün (0→1, 1→2, 2→4, 3→8, 4→16, 5→32 gün)
///   Bu formülü değiştirerek daha sık veya seyrek tekrar ayarlayabilirsin.
///   Örnek: pow(2, masteryLevel) yerine (masteryLevel + 1) * 2 yazarsan
///   aralıklar: 2, 4, 6, 8, 10, 12 gün olur (daha düzgün artış).
///
/// ► YANLIŞ CEVAP: Şu an 1 gün sonra tekrar soruyor.
///   Aynı gün tekrar istersen return 0 yapabilirsin.
class AralikliTekrar {
  /// Bir sonraki tekrar gün sayısını hesaplar
  /// Doğru: 2^seviye gün sonra | Yanlış: 1 gün sonra
  static int calculateNextReviewDays(int masteryLevel, bool wasCorrect) {
    if (wasCorrect) {
      // Seviye 0→1 gün, 1→2 gün, 2→4 gün, 3→8 gün, 4→16 gün, 5→32 gün
      return pow(2, masteryLevel).toInt();
    } else {
      return 1; // Yanlışta ertesi gün tekrar sor (değiştirilebilir)
    }
  }

  /// Yeni mastery seviyesini hesaplar
  /// [currentLevel]: Mevcut seviye (0-5)
  /// [wasCorrect]: Cevap doğru mu?
  /// Returns: Yeni mastery seviyesi
  static int calculateNewMasteryLevel(int currentLevel, bool wasCorrect) {
    if (wasCorrect) {
      // Doğru: Seviyeyi 1 artır (max 5)
      return (currentLevel + 1).clamp(0, 5);
    } else {
      // Yanlış: Seviyeyi sıfırla
      return 0;
    }
  }

  /// Bir sonraki tekrar tarihini hesaplar
  /// [masteryLevel]: Mevcut ustalık seviyesi
  /// [wasCorrect]: Cevap doğru mu?
  /// Returns: Sonraki tekrar tarihi
  static DateTime calculateNextReviewDate(int masteryLevel, bool wasCorrect) {
    final days = calculateNextReviewDays(masteryLevel, wasCorrect);
    return DateTime.now().add(Duration(days: days));
  }

  /// Kelimenin bugün tekrar edilmesi gerekiyor mu?
  /// [nextReviewDate]: Sonraki tekrar tarihi
  /// Returns: Bugün tekrar edilmeli mi?
  static bool isDueForReview(DateTime? nextReviewDate) {
    if (nextReviewDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return !reviewDate.isAfter(today);
  }

  /// Kelimenin öğrenilme yüzdesini hesaplar
  /// [masteryLevel]: Ustalık seviyesi (0-5)
  /// Returns: Yüzde (0.0 - 1.0)
  static double getMasteryPercentage(int masteryLevel) {
    return masteryLevel / 5.0;
  }
}
