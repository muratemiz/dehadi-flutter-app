import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../modeller/kelime_modeli.dart';
import '../modeller/kullanici_ilerlemesi.dart';
import '../../cekirdek/araclar/aralikli_tekrar.dart';

class KelimeDeposu {
  static final KelimeDeposu _instance = KelimeDeposu._internal();
  factory KelimeDeposu() => _instance;
  KelimeDeposu._internal();

  static const String _wordsBoxName = 'words';
  static const String _progressBoxName = 'progress';
  static const String _streakBoxName = 'streak';
  static const String _settingsBoxName = 'settings';

  late Box<KelimeModeli> _wordsBox;
  late Box<KullaniciIlerlemesi> _progressBox;
  late Box<SeriVerisi> _streakBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _wordsBox = await Hive.openBox<KelimeModeli>(_wordsBoxName);
      _progressBox = await Hive.openBox<KullaniciIlerlemesi>(_progressBoxName);
      _streakBox = await Hive.openBox<SeriVerisi>(_streakBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      await _loadInitialWords();

      if (_streakBox.isEmpty) {
        await _streakBox.put('main', SeriVerisi.initial());
      }
      _isInitialized = true;
    } catch (e, st) {
      debugPrint('[KelimeDeposu.init] HATA: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<void> resetAndReload() async {
    try {
      await _wordsBox.clear();
      await _progressBox.clear();
      await _loadInitialWords();
    } catch (e, st) {
      debugPrint('[KelimeDeposu.resetAndReload] HATA: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<void> _loadInitialWords() async {
    final jsonString = await rootBundle.loadString('assets/kelimeler.json');
    final List<dynamic> kelimeVerileri = json.decode(jsonString);
    for (final wordJson in kelimeVerileri) {
      final word = KelimeModeli.fromJson(Map<String, dynamic>.from(wordJson));
      await _wordsBox.put(word.id, word);
      if (!_progressBox.containsKey(word.id)) {
        final progress = KullaniciIlerlemesi.initial(word.id);
        await _progressBox.put(word.id, progress);
      }
    }
  }

  List<KelimeModeli> getAllWords() => _wordsBox.values.toList();

  KelimeModeli? getWord(String id) => _wordsBox.get(id);

  KullaniciIlerlemesi? getProgress(String wordId) => _progressBox.get(wordId);

  List<KullaniciIlerlemesi> getAllProgress() => _progressBox.values.toList();

  List<KelimeModeli> getDailyWords({int count = 20}) {
    final rng = Random();
    final allWords = getAllWords();
    final reviewWords = <KelimeModeli>[];
    final newWords = <KelimeModeli>[];

    for (final word in allWords) {
      final progress = getProgress(word.id);
      if (progress == null) {
        newWords.add(word);
        continue;
      }
      if (progress.isLearned) continue;
      if (progress.totalAttempts > 0) {
        reviewWords.add(word);
      } else {
        newWords.add(word);
      }
    }

    reviewWords.shuffle(rng);
    newWords.shuffle(rng);

    final dailyWords = <KelimeModeli>[];
    dailyWords.addAll(reviewWords.take(count));
    if (dailyWords.length < count) {
      dailyWords.addAll(newWords.take(count - dailyWords.length));
    }
    dailyWords.shuffle(rng);
    return dailyWords;
  }

  Future<void> updateProgress(String wordId, bool wasCorrect) async {
    try {
      var progress = _progressBox.get(wordId) ?? KullaniciIlerlemesi.initial(wordId);
      final nextReviewDate = AralikliTekrar.calculateNextReviewDate(
        progress.masteryLevel,
        wasCorrect,
      );
      progress.updateProgress(wasCorrect: wasCorrect, nextReview: nextReviewDate);
      await _progressBox.put(wordId, progress);
      await _updateStreakOnActivity(wasCorrect: wasCorrect);
    } catch (e, st) {
      debugPrint('[KelimeDeposu.updateProgress] HATA: $e');
      debugPrint(st.toString());
    }
  }

  SeriVerisi getSeriVerisi() {
    return _streakBox.get('main') ?? SeriVerisi.initial();
  }

  Future<void> _updateStreakOnActivity({bool wasCorrect = true}) async {
    try {
      final streak = getSeriVerisi();
      streak.updateStreak();
      if (wasCorrect) streak.totalCorrectAnswers++;
      await _streakBox.put('main', streak);
    } catch (e, st) {
      debugPrint('[KelimeDeposu._updateStreakOnActivity] HATA: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> updateQuizStats({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      final streak = getSeriVerisi();
      streak.totalQuizzesTaken++;
      streak.totalCorrectAnswers += correctAnswers;
      streak.updateStreak();
      await _streakBox.put('main', streak);
    } catch (e, st) {
      debugPrint('[KelimeDeposu.updateQuizStats] HATA: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> incrementLearnedWords() async {
    try {
      final streak = getSeriVerisi();
      streak.totalWordsLearned++;
      await _streakBox.put('main', streak);
    } catch (e, st) {
      debugPrint('[KelimeDeposu.incrementLearnedWords] HATA: $e');
      debugPrint(st.toString());
    }
  }

  List<KelimeModeli> getLearnedWords() {
    final learnedIds = _progressBox.values
        .where((p) => p.isLearned)
        .map((p) => p.wordId)
        .toList();
    return allWords.where((w) => learnedIds.contains(w.id)).toList();
  }

  List<KelimeModeli> getUnlearnedWords() {
    final learnedIds = _progressBox.values
        .where((p) => p.isLearned)
        .map((p) => p.wordId)
        .toSet();
    return allWords.where((w) => !learnedIds.contains(w.id)).toList();
  }

  /// Kelime arama ve filtreleme
  List<KelimeModeli> searchWords({String? query, List<String>? levels, bool? isLearned}) {
    var results = getAllWords();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((w) =>
        w.word.toLowerCase().contains(q) ||
        w.meaning.toLowerCase().contains(q)
      ).toList();
    }

    if (levels != null && levels.isNotEmpty) {
      results = results.where((w) => levels.contains(w.level)).toList();
    }

    if (isLearned != null) {
      results = results.where((w) {
        final progress = getProgress(w.id);
        return progress != null && progress.isLearned == isLearned;
      }).toList();
    }

    return results;
  }

  double getOverallProgress() {
    final allProgress = getAllProgress();
    if (allProgress.isEmpty) return 0.0;
    final totalMastery = allProgress.fold<int>(0, (sum, p) => sum + p.masteryLevel);
    return totalMastery / (allProgress.length * 5);
  }

  List<KelimeModeli> get allWords => getAllWords();

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool hasTodaySelection() {
    final savedDate = _settingsBox.get('dailySelectionDate') as String?;
    return savedDate == _getTodayString();
  }

  Future<void> saveDailySelection(List<String> wordIds, int count) async {
    try {
      await _settingsBox.put('dailySelectionDate', _getTodayString());
      await _settingsBox.put('dailyWordIds', wordIds);
      await _settingsBox.put('dailyWordCount', count);
      await _settingsBox.put('currentCardIndex', 0);
    } catch (e, st) {
      debugPrint('[KelimeDeposu.saveDailySelection] HATA: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> saveCurrentCardIndex(int index) async {
    try {
      await _settingsBox.put('currentCardIndex', index);
    } catch (e) {
      debugPrint('[KelimeDeposu.saveCurrentCardIndex] HATA: $e');
    }
  }

  int getSavedCardIndex() {
    return _settingsBox.get('currentCardIndex') as int? ?? 0;
  }

  List<KelimeModeli> getSavedDailyWords() {
    final wordIds = _settingsBox.get('dailyWordIds') as List<dynamic>?;
    if (wordIds == null || wordIds.isEmpty) return [];
    final words = <KelimeModeli>[];
    for (final id in wordIds) {
      final word = getWord(id.toString());
      if (word != null) words.add(word);
    }
    return words;
  }

  int getSavedDailyCount() {
    return _settingsBox.get('dailyWordCount') as int? ?? 10;
  }

  Future<void> clearDailySelection() async {
    try {
      await _settingsBox.delete('dailySelectionDate');
      await _settingsBox.delete('dailyWordIds');
      await _settingsBox.delete('dailyWordCount');
      await _settingsBox.delete('currentCardIndex');
    } catch (e) {
      debugPrint('[KelimeDeposu.clearDailySelection] HATA: $e');
    }
  }

  /// Bugünkü kelimeleri sıfırla: biliyorum=true olanlar kalır,
  /// geri kalanların ilerlemesi sıfırlanır (havuza döner).
  Future<void> resetDailyUnlearnedWords() async {
    try {
      final wordIds = _settingsBox.get('dailyWordIds') as List<dynamic>?;
      if (wordIds == null) return;

      for (final id in wordIds) {
        final progress = _progressBox.get(id.toString());
        if (progress != null && !progress.isLearned) {
          await _progressBox.put(id.toString(), KullaniciIlerlemesi.initial(id.toString()));
        }
      }
      await clearDailySelection();
    } catch (e, st) {
      debugPrint('[KelimeDeposu.resetDailyUnlearnedWords] HATA: $e');
      debugPrint(st.toString());
    }
  }

  /// Çıkış yap: tüm verileri sil, fabrika ayarlarına dön.
  Future<void> logout() async {
    try {
      await _progressBox.clear();
      await _streakBox.clear();
      await _settingsBox.clear();
      await _streakBox.put('main', SeriVerisi.initial());
      await _loadInitialWords();
    } catch (e, st) {
      debugPrint('[KelimeDeposu.logout] HATA: $e');
      debugPrint(st.toString());
    }
  }

  // ─── Onboarding ───
  bool get hasSeenOnboarding =>
      _settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;

  Future<void> setOnboardingSeen() async {
    await _settingsBox.put('hasSeenOnboarding', true);
  }

  // ─── Bildirim ayarları ───
  bool getNotificationEnabled() {
    return _settingsBox.get('notificationEnabled', defaultValue: true) as bool;
  }

  Future<void> setNotificationEnabled(bool value) async {
    await _settingsBox.put('notificationEnabled', value);
  }

  int getNotificationHour() {
    return _settingsBox.get('notificationHour', defaultValue: 20) as int;
  }

  int getNotificationMinute() {
    return _settingsBox.get('notificationMinute', defaultValue: 0) as int;
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    await _settingsBox.put('notificationHour', hour);
    await _settingsBox.put('notificationMinute', minute);
  }

  // ─── Kullanıcı profili ───
  String? getUserName() {
    return _settingsBox.get('userName') as String?;
  }

  Future<void> setUserName(String name) async {
    await _settingsBox.put('userName', name);
  }

  bool get hasUser => getUserName() != null && getUserName()!.isNotEmpty;
}
