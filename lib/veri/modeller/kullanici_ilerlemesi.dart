import 'package:hive/hive.dart';

part 'kullanici_ilerlemesi.g.dart';

/// ─── KULLANICI İLERLEME MODELİ ───
/// Her kelimenin öğrenilme durumunu takip eder.
/// masteryLevel 0→5 arası: her doğruda +1, yanlışta sıfırlanır.
/// isLearned: kartlarda "Biliyorum" dendiğinde true olur,
///            testte yanlış yapılırsa false'a döner.
@HiveType(typeId: 1)
class KullaniciIlerlemesi extends HiveObject {
  @HiveField(0)
  final String wordId;           // Hangi kelimeye ait

  @HiveField(1)
  int correctCount;              // Toplam doğru sayısı

  @HiveField(2)
  int wrongCount;                // Toplam yanlış sayısı

  @HiveField(3)
  DateTime? lastReviewDate;      // Son tekrar tarihi

  @HiveField(4)
  DateTime? nextReviewDate;      // Sonraki tekrar tarihi (aralıklı tekrar algoritması belirler)

  @HiveField(5)
  int masteryLevel;              // Ustalık seviyesi: 0-5 arası (5 = tamamen öğrenilmiş)

  @HiveField(6)
  bool isLearned;                // true = öğrenildi, kartlarda gösterilmez

  KullaniciIlerlemesi({
    required this.wordId,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.lastReviewDate,
    this.nextReviewDate,
    this.masteryLevel = 0,
    this.isLearned = false,
  });

  /// Toplam deneme sayısı
  int get totalAttempts => correctCount + wrongCount;

  /// Doğru cevap oranı
  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  /// Ustalık yüzdesi (0.0 - 1.0)
  double get masteryPercentage => masteryLevel / 5.0;

  /// Kelime öğrenildi mi kontrolü (mastery 4 veya üzeri)
  bool get isMastered => masteryLevel >= 4;

  /// İlerlemeyi güncelle — doğru/yanlış cevaba göre durumu değiştirir.
  /// ► DOĞRU: masteryLevel +1 artar, kelime "öğrenildi" sayılır.
  /// ► YANLIŞ: masteryLevel sıfırlanır, kelime "öğrenilmedi" listesine geri döner.
  /// Bu davranışı değiştirmek istersen (örn. yanlışta seviye azalsın ama sıfırlanmasın):
  ///   masteryLevel = 0 yerine masteryLevel = max(0, masteryLevel - 1) yazabilirsin.
  void updateProgress({required bool wasCorrect, required DateTime nextReview}) {
    lastReviewDate = DateTime.now();
    nextReviewDate = nextReview;
    
    if (wasCorrect) {
      correctCount++;
      masteryLevel = (masteryLevel + 1).clamp(0, 5); // max 5'e kadar çıkar
      isLearned = true;  // Biliyorum = öğrenildi
    } else {
      wrongCount++;
      masteryLevel = 0;  // Yanlışta sıfırla (sertlik ayarı — değiştirilebilir)
      isLearned = false;  // Tekrar öğrenilecekler listesine geri döner
    }
  }

  factory KullaniciIlerlemesi.initial(String wordId) {
    return KullaniciIlerlemesi(
      wordId: wordId,
      correctCount: 0,
      wrongCount: 0,
      lastReviewDate: null,
      nextReviewDate: DateTime.now(), // Hemen tekrar edilebilir
      masteryLevel: 0,
      isLearned: false,
    );
  }

  @override
  String toString() {
    return 'KullaniciIlerlemesi(wordId: $wordId, mastery: $masteryLevel, correct: $correctCount, wrong: $wrongCount)';
  }
}

/// ─── SERİ VERİSİ MODELİ ───
/// Kullanıcının günlük seri (streak) ve genel istatistiklerini tutar.
/// Üst üste giriş yapılan gün sayısını takip eder ve rozetler verir.
@HiveType(typeId: 2)
class SeriVerisi extends HiveObject {
  @HiveField(0)
  int currentStreak;         // Mevcut seri (ardışık gün sayısı)

  @HiveField(1)
  int longestStreak;         // En uzun seri rekoru

  @HiveField(2)
  DateTime? lastActiveDate;  // Son aktif olduğu gün

  @HiveField(3)
  int totalWordsLearned;     // Toplam öğrenilen kelime

  @HiveField(4)
  int totalQuizzesTaken;     // Toplam çözülen test sayısı

  @HiveField(5)
  int totalCorrectAnswers;   // Toplam doğru cevap

  SeriVerisi({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.totalWordsLearned = 0,
    this.totalQuizzesTaken = 0,
    this.totalCorrectAnswers = 0,
  });

  /// Bugün aktif mi kontrol et ve streak'i güncelle
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActiveDate == null) {
      // İlk giriş
      currentStreak = 1;
      lastActiveDate = today;
    } else {
      final lastDate = DateTime(
        lastActiveDate!.year,
        lastActiveDate!.month,
        lastActiveDate!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Bugün zaten giriş yapılmış
        return;
      } else if (difference == 1) {
        // Ardışık gün
        currentStreak++;
      } else {
        // Seri kırıldı
        currentStreak = 1;
      }
      lastActiveDate = today;
    }

    // En uzun seriyi güncelle
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  /// Bugün aktif mi?
  bool get isActiveToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    return today.isAtSameMomentAs(lastDate);
  }

  factory SeriVerisi.initial() {
    return SeriVerisi(
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
      totalWordsLearned: 0,
      totalQuizzesTaken: 0,
      totalCorrectAnswers: 0,
    );
  }
}
