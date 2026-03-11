import 'package:flutter/foundation.dart';
import '../veri/modeller/kelime_modeli.dart';
import '../veri/modeller/kullanici_ilerlemesi.dart';
import '../veri/depolar/kelime_deposu.dart';

class KelimeSaglayici extends ChangeNotifier {
  final KelimeDeposu _repository;
  
  List<KelimeModeli> _dailyWords = [];
  List<KelimeModeli> _allWords = [];
  int _currentCardIndex = 0;
  bool _isLoading = true;
  bool _hasTodaySelection = false;
  String? _errorMessage;

  // Arama ve filtreleme state'leri
  String _searchQuery = '';
  List<String> _selectedLevels = [];
  bool? _learnedFilter;
  
  final Set<String> _answeredToday = {};

  KelimeSaglayici(this._repository);

  // Getters
  List<KelimeModeli> get dailyWords => _dailyWords;
  List<KelimeModeli> get allWords => _allWords;
  int get currentCardIndex => _currentCardIndex;
  bool get isLoading => _isLoading;
  bool get hasTodaySelection => _hasTodaySelection;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  String get searchQuery => _searchQuery;
  List<String> get selectedLevels => _selectedLevels;
  bool? get learnedFilter => _learnedFilter;
  
  KelimeModeli? get currentWord {
    if (_dailyWords.isEmpty || _currentCardIndex >= _dailyWords.length) return null;
    return _dailyWords[_currentCardIndex];
  }

  bool get hasMoreCards => _currentCardIndex < _dailyWords.length - 1;
  bool get isLastCard => _currentCardIndex == _dailyWords.length - 1;
  int get remainingCards => _dailyWords.length - _currentCardIndex - 1;
  double get progress => _dailyWords.isEmpty 
      ? 0.0 
      : (_currentCardIndex + 1) / _dailyWords.length;

  /// Filtrelenmiş kelime listesi
  List<KelimeModeli> get filteredWords {
    return _repository.searchWords(
      query: _searchQuery.isEmpty ? null : _searchQuery,
      levels: _selectedLevels.isEmpty ? null : _selectedLevels,
      isLearned: _learnedFilter,
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleLevel(String level) {
    if (_selectedLevels.contains(level)) {
      _selectedLevels.remove(level);
    } else {
      _selectedLevels.add(level);
    }
    notifyListeners();
  }

  void setLearnedFilter(bool? value) {
    _learnedFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedLevels.clear();
    _learnedFilter = null;
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.init();
      _allWords = _repository.getAllWords();
      _hasTodaySelection = _repository.hasTodaySelection();
      if (_hasTodaySelection) {
        _dailyWords = _repository.getSavedDailyWords();
        _currentCardIndex = _repository.getSavedCardIndex();
        if (_currentCardIndex > _dailyWords.length) {
          _currentCardIndex = _dailyWords.length;
        }
      }
    } catch (e) {
      _errorMessage = 'Kelimeler yüklenemedi: $e';
      debugPrint('[KelimeSaglayici.init] HATA: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDailyWords() {
    _dailyWords = [];
    _currentCardIndex = 0;
    _hasTodaySelection = false;
    _answeredToday.clear();
    notifyListeners();
  }

  /// Bugünkü kelimeleri sıfırla: öğrenilenleri koru, diğerlerini havuza geri at.
  Future<void> resetDailyAndRefresh() async {
    try {
      await _repository.resetDailyUnlearnedWords();
      _dailyWords = [];
      _currentCardIndex = 0;
      _hasTodaySelection = false;
      _answeredToday.clear();
      _allWords = _repository.getAllWords();
      notifyListeners();
    } catch (e) {
      debugPrint('[KelimeSaglayici.resetDailyAndRefresh] HATA: $e');
    }
  }

  Future<void> loadDailyWords({int count = 20}) async {
    try {
      _dailyWords = _repository.getDailyWords(count: count);
      _currentCardIndex = 0;
      _answeredToday.clear();
      final wordIds = _dailyWords.map((w) => w.id).toList();
      await _repository.saveDailySelection(wordIds, count);
      _hasTodaySelection = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Günlük kelimeler yüklenemedi';
      debugPrint('[KelimeSaglayici.loadDailyWords] HATA: $e');
      notifyListeners();
    }
  }
  
  void loadSavedDailyWords() {
    _dailyWords = _repository.getSavedDailyWords();
    _currentCardIndex = _repository.getSavedCardIndex();
    if (_currentCardIndex > _dailyWords.length) {
      _currentCardIndex = _dailyWords.length;
    }
    notifyListeners();
  }

  Future<void> resetDatabase() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.resetAndReload();
      _allWords = _repository.getAllWords();
      await loadDailyWords();
    } catch (e) {
      _errorMessage = 'Veritabanı sıfırlanamadı';
      debugPrint('[KelimeSaglayici.resetDatabase] HATA: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextCard() {
    if (hasMoreCards) {
      _currentCardIndex++;
      _saveCurrentIndex();
      notifyListeners();
    }
  }

  void previousCard() {
    if (_currentCardIndex > 0) {
      _currentCardIndex--;
      _saveCurrentIndex();
      notifyListeners();
    }
  }

  void goToCard(int index) {
    if (index >= 0 && index < _dailyWords.length) {
      _markUnansweredAsReview(_currentCardIndex);
      _currentCardIndex = index;
      _saveCurrentIndex();
      notifyListeners();
    }
  }
  
  Future<void> _markUnansweredAsReview(int index) async {
    if (index >= 0 && index < _dailyWords.length) {
      final word = _dailyWords[index];
      if (!_answeredToday.contains(word.id)) {
        await _repository.updateProgress(word.id, false);
        _answeredToday.add(word.id);
      }
    }
  }
  
  void _saveCurrentIndex() {
    _repository.saveCurrentCardIndex(_currentCardIndex);
  }

  Future<void> markAsKnown(String wordId) async {
    try {
      await _repository.updateProgress(wordId, true);
      _answeredToday.add(wordId);
      notifyListeners();
    } catch (e) {
      debugPrint('[KelimeSaglayici.markAsKnown] HATA: $e');
    }
  }

  Future<void> markForReview(String wordId) async {
    try {
      await _repository.updateProgress(wordId, false);
      _answeredToday.add(wordId);
      notifyListeners();
    } catch (e) {
      debugPrint('[KelimeSaglayici.markForReview] HATA: $e');
    }
  }

  KullaniciIlerlemesi? getWordProgress(String wordId) {
    return _repository.getProgress(wordId);
  }

  List<KelimeModeli> get learnedWords => _repository.getLearnedWords();
  List<KelimeModeli> get unlearnedWords => _repository.getUnlearnedWords();
  double get overallProgress => _repository.getOverallProgress();

  void resetCards() {
    _currentCardIndex = 0;
    _saveCurrentIndex();
    notifyListeners();
  }
  
  Future<void> markAllCompleted() async {
    await _markUnansweredAsReview(_currentCardIndex);
    _currentCardIndex = _dailyWords.length;
    _saveCurrentIndex();
    notifyListeners();
  }
  
  bool get isAllCompleted => _currentCardIndex >= _dailyWords.length;

  Future<void> refreshWords() async {
    _allWords = _repository.getAllWords();
    await loadDailyWords();
  }
}
