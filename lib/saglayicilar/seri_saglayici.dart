import 'package:flutter/foundation.dart';
import '../veri/modeller/kullanici_ilerlemesi.dart';
import '../veri/depolar/kelime_deposu.dart';

class SeriSaglayici extends ChangeNotifier {
  final KelimeDeposu _repository;
  
  SeriVerisi? _streakData;
  bool _isLoading = true;
  String? _errorMessage;

  SeriSaglayici(this._repository);

  SeriVerisi? get streakData => _streakData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  int get currentStreak => _streakData?.currentStreak ?? 0;
  int get longestStreak => _streakData?.longestStreak ?? 0;
  int get totalWordsLearned => _streakData?.totalWordsLearned ?? 0;
  int get totalQuizzesTaken => _streakData?.totalQuizzesTaken ?? 0;
  int get totalCorrectAnswers => _streakData?.totalCorrectAnswers ?? 0;
  bool get isActiveToday => _streakData?.isActiveToday ?? false;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.init();
      _loadSeriVerisi();
    } catch (e) {
      _errorMessage = 'Seri verisi yüklenemedi';
      debugPrint('[SeriSaglayici.init] HATA: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSeriVerisi() {
    _streakData = _repository.getSeriVerisi();
    notifyListeners();
  }

  Future<void> updateStreak() async {
    _streakData?.updateStreak();
    _loadSeriVerisi();
  }

  Future<void> refresh() async {
    _loadSeriVerisi();
  }

  String getStreakStatus() {
    if (currentStreak == 0) return 'Bugün başla!';
    if (isActiveToday) return '$currentStreak günlük seri!';
    return 'Seriyi korumak için çalış!';
  }

  String getSeriRozetiColor() {
    if (currentStreak >= 30) return 'gold';
    if (currentStreak >= 14) return 'silver';
    if (currentStreak >= 7) return 'bronze';
    return 'default';
  }

  String getMotivationMessage() {
    if (currentStreak == 0) return 'Her gün 5 kelime öğrenerek başla!';
    if (currentStreak < 7) return 'Harika gidiyorsun! ${7 - currentStreak} gün sonra bronz rozet!';
    if (currentStreak < 14) return 'Muhteşem! ${14 - currentStreak} gün sonra gümüş rozet!';
    if (currentStreak < 30) return 'Efsane! ${30 - currentStreak} gün sonra altın rozet!';
    return 'Sen bir şampiyonsun!';
  }

  int get totalWordsInApp => _repository.getAllWords().length;

  double get learnedPercentage {
    if (totalWordsInApp == 0) return 0.0;
    return totalWordsLearned / totalWordsInApp;
  }

  double get overallAccuracy {
    final total = totalQuizzesTaken;
    if (total == 0) return 0.0;
    final totalQuestions = total * 5;
    if (totalQuestions == 0) return 0.0;
    return totalCorrectAnswers / totalQuestions;
  }
}
