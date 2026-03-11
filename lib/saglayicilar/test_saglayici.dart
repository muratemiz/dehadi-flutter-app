import 'dart:math';
import 'package:flutter/foundation.dart';
import '../veri/modeller/kelime_modeli.dart';
import '../veri/depolar/kelime_deposu.dart';

enum TestDurumu { baslamadi, devamEdiyor, bitti }
enum TestTuru { cokluSecim, yazarakCevap, eslestirme }

class TestSorusu {
  final KelimeModeli word;
  final List<String> options;
  final int correctIndex;
  String? selectedAnswer;
  bool? isCorrect;

  TestSorusu({
    required this.word,
    required this.options,
    required this.correctIndex,
  });

  String get correctAnswer => options[correctIndex];
}

class EslestirmeCifti {
  final KelimeModeli word;
  String? selectedMeaning;
  bool? isCorrect;

  EslestirmeCifti({required this.word});
}

class TestSaglayici extends ChangeNotifier {
  final KelimeDeposu _repository;
  final Random _random = Random();

  List<TestSorusu> _questions = [];
  int _currentQuestionIndex = 0;
  TestDurumu _state = TestDurumu.baslamadi;
  TestTuru _testTuru = TestTuru.cokluSecim;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  String? _errorMessage;

  // Eşleştirme
  List<EslestirmeCifti> _matchPairs = [];
  List<String> _shuffledMeanings = [];
  int _matchScore = 0;

  // Joker sistemi
  int _jokersRemaining = 3;
  Set<int> _revealedIndices = {};

  TestSaglayici(this._repository);

  List<TestSorusu> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  TestDurumu get state => _state;
  TestTuru get testTuru => _testTuru;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  int get totalQuestions => _questions.length;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  List<EslestirmeCifti> get matchPairs => _matchPairs;
  List<String> get shuffledMeanings => _shuffledMeanings;
  int get matchScore => _matchScore;

  int get jokersRemaining => _jokersRemaining;
  Set<int> get revealedIndices => _revealedIndices;

  TestSorusu? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  bool get hasMoreQuestions => _currentQuestionIndex < _questions.length - 1;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  double get progress => _questions.isEmpty 
      ? 0.0 
      : (_currentQuestionIndex + 1) / _questions.length;
  double get score => totalQuestions == 0 ? 0.0 : _correctAnswers / totalQuestions;
  int get scorePercentage => (score * 100).round();

  Future<void> startQuiz({int questionCount = 20, TestTuru testTuru = TestTuru.cokluSecim}) async {
    _errorMessage = null;
    try {
      await _repository.init();
      _testTuru = testTuru;

      final learnedWords = _repository.getLearnedWords();
      final allWords = _repository.getAllWords();

      if (learnedWords.isEmpty) {
        _state = TestDurumu.bitti;
        notifyListeners();
        return;
      }

      final shuffledWords = List<KelimeModeli>.from(learnedWords)..shuffle(_random);

      if (testTuru == TestTuru.eslestirme) {
        final count = min(5, shuffledWords.length);
        final selected = shuffledWords.take(count).toList();
        _matchPairs = selected.map((w) => EslestirmeCifti(word: w)).toList();
        _shuffledMeanings = selected.map((w) => w.meaning).toList()..shuffle(_random);
        _matchScore = 0;
        _questions = [];
        _correctAnswers = 0;
        _wrongAnswers = 0;
        _state = TestDurumu.devamEdiyor;
        notifyListeners();
        return;
      }

      final selectedWords = shuffledWords.take(questionCount).toList();
      _questions = _generateQuestions(selectedWords, allWords);
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _jokersRemaining = 3;
      _revealedIndices = {};
      _state = TestDurumu.devamEdiyor;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Test başlatılamadı';
      _state = TestDurumu.baslamadi;
      debugPrint('[TestSaglayici.startQuiz] HATA: $e');
      notifyListeners();
    }
  }

  /// Joker kullan — rastgele bir harf açığa çıkar, o harfi döndürür
  String? useJoker() {
    if (_jokersRemaining <= 0 || currentQuestion == null) return null;
    final answer = currentQuestion!.correctAnswer;
    final hiddenIndices = <int>[];
    for (int i = 0; i < answer.length; i++) {
      if (!_revealedIndices.contains(i) && answer[i] != ' ') {
        hiddenIndices.add(i);
      }
    }
    if (hiddenIndices.isEmpty) return null;
    hiddenIndices.shuffle(_random);
    final revealIdx = hiddenIndices.first;
    _revealedIndices.add(revealIdx);
    _jokersRemaining--;
    notifyListeners();
    return answer[revealIdx];
  }

  void resetRevealedForNextQuestion() {
    _revealedIndices = {};
    notifyListeners();
  }

  List<TestSorusu> _generateQuestions(
    List<KelimeModeli> targetWords,
    List<KelimeModeli> allWords,
  ) {
    final questions = <TestSorusu>[];
    for (final word in targetWords) {
      final options = _generateOptions(word, allWords);
      final correctIndex = options.indexOf(word.meaning);
      questions.add(TestSorusu(word: word, options: options, correctIndex: correctIndex));
    }
    questions.shuffle(_random);
    return questions;
  }

  List<String> _generateOptions(KelimeModeli correctWord, List<KelimeModeli> allWords) {
    final options = <String>[correctWord.meaning];
    final otherWords = allWords.where((w) => w.id != correctWord.id).toList()..shuffle(_random);
    for (final word in otherWords) {
      if (options.length >= 4) break;
      if (!options.contains(word.meaning)) options.add(word.meaning);
    }
    while (options.length < 4) {
      options.add('Bilinmiyor ${options.length}');
    }
    options.shuffle(_random);
    return options;
  }

  Future<bool> answerQuestion(String answer) async {
    if (currentQuestion == null) return false;
    try {
      final question = _questions[_currentQuestionIndex];
      question.selectedAnswer = answer;
      final isCorrect = answer == question.correctAnswer;
      question.isCorrect = isCorrect;
      if (isCorrect) { _correctAnswers++; } else { _wrongAnswers++; }
      await _repository.updateProgress(question.word.id, isCorrect);
      notifyListeners();
      return isCorrect;
    } catch (e) {
      debugPrint('[TestSaglayici.answerQuestion] HATA: $e');
      return false;
    }
  }

  Future<bool> checkTypedAnswer(String typedAnswer) async {
    if (currentQuestion == null) return false;
    try {
      final question = _questions[_currentQuestionIndex];
      question.selectedAnswer = typedAnswer;
      final isCorrect = _normalizeForComparison(typedAnswer) ==
          _normalizeForComparison(question.correctAnswer);
      question.isCorrect = isCorrect;
      if (isCorrect) { _correctAnswers++; } else { _wrongAnswers++; }
      await _repository.updateProgress(question.word.id, isCorrect);
      notifyListeners();
      return isCorrect;
    } catch (e) {
      debugPrint('[TestSaglayici.checkTypedAnswer] HATA: $e');
      return false;
    }
  }

  String _normalizeForComparison(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> checkMatch(int pairIndex, String selectedMeaning) async {
    if (pairIndex >= _matchPairs.length) return false;
    try {
      final pair = _matchPairs[pairIndex];
      pair.selectedMeaning = selectedMeaning;
      final isCorrect = selectedMeaning == pair.word.meaning;
      pair.isCorrect = isCorrect;
      if (isCorrect) {
        _matchScore++;
        _correctAnswers++;
      } else {
        _wrongAnswers++;
      }
      await _repository.updateProgress(pair.word.id, isCorrect);
      notifyListeners();
      return isCorrect;
    } catch (e) {
      debugPrint('[TestSaglayici.checkMatch] HATA: $e');
      return false;
    }
  }

  bool get allMatchesCompleted =>
      _matchPairs.isNotEmpty && _matchPairs.every((p) => p.isCorrect != null);

  void nextQuestion() {
    if (hasMoreQuestions) {
      _currentQuestionIndex++;
      _revealedIndices = {};
      notifyListeners();
    } else {
      finishQuiz();
    }
  }

  Future<void> finishQuiz() async {
    _state = TestDurumu.bitti;
    try {
      final total = _testTuru == TestTuru.eslestirme ? _matchPairs.length : totalQuestions;
      await _repository.updateQuizStats(
        correctAnswers: _correctAnswers,
        totalQuestions: total,
      );
    } catch (e) {
      debugPrint('[TestSaglayici.finishQuiz] HATA: $e');
    }
    notifyListeners();
  }

  void resetQuiz() {
    _questions = [];
    _matchPairs = [];
    _shuffledMeanings = [];
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _matchScore = 0;
    _jokersRemaining = 3;
    _revealedIndices = {};
    _state = TestDurumu.baslamadi;
    _errorMessage = null;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index <= _currentQuestionIndex && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }
}
