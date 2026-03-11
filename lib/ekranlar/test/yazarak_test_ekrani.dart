import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/test_saglayici.dart';
import '../../bilesenler/buzlu_bilesenler.dart';
import 'test_sonuc_ekrani.dart';

class YazarakTestEkrani extends StatefulWidget {
  const YazarakTestEkrani({super.key});

  @override
  State<YazarakTestEkrani> createState() => _YazarakTestEkraniState();
}

class _YazarakTestEkraniState extends State<YazarakTestEkrani>
    with TickerProviderStateMixin {
  final _answerController = TextEditingController();
  final _focusNode = FocusNode();
  bool? _lastResult;
  bool _showResult = false;
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _checkAnswer() async {
    final typed = _answerController.text.trim();
    if (typed.isEmpty) return;
    final provider = context.read<TestSaglayici>();
    final isCorrect = await provider.checkTypedAnswer(typed);
    HapticFeedback.mediumImpact();
    setState(() {
      _lastResult = isCorrect;
      _showResult = true;
    });
    if (isCorrect) {
      _bounceController.forward(from: 0);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _useJoker() {
    final provider = context.read<TestSaglayici>();
    final revealed = provider.useJoker();
    if (revealed != null) {
      HapticFeedback.heavyImpact();
      _bounceController.forward(from: 0);
    }
  }

  void _nextQuestion() {
    final provider = context.read<TestSaglayici>();
    if (provider.isLastQuestion) {
      provider.finishQuiz();
    } else {
      provider.nextQuestion();
    }
    setState(() {
      _lastResult = null;
      _showResult = false;
      _answerController.clear();
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
          child: Consumer<TestSaglayici>(
            builder: (context, provider, _) {
              if (provider.state == TestDurumu.bitti) {
                return TestSonucEkrani(
                  correctAnswers: provider.correctAnswers,
                  totalQuestions: provider.totalQuestions,
                  questions: provider.questions,
                  onRetry: () {
                    setState(() {
                      _showResult = false;
                      _lastResult = null;
                      _answerController.clear();
                    });
                    provider.startQuiz(questionCount: 20, testTuru: TestTuru.yazarakCevap);
                  },
                  onExit: () {
                    provider.resetQuiz();
                    Navigator.pop(context);
                  },
                );
              }

              final question = provider.currentQuestion;
              if (question == null) {
                return _buildEmptyState(isDark);
              }

              return _buildQuizContent(context, provider, question, isDark);
            },
          ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tema.spacingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: Renkler.getPastelGradient(isDark),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_outlined, size: 56, color: Colors.white),
            ).animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
            const SizedBox(height: Tema.spacingLG),
            Text(
              'Henüz öğrenilmiş kelime yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Renkler.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: Tema.spacingSM),
            Text(
              'Önce kartlardan kelime öğrenin!',
              style: TextStyle(color: Renkler.getTextSecondary(isDark)),
            ),
            const SizedBox(height: Tema.spacingLG),
            BuzluButon(text: 'Geri Dön', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, TestSaglayici provider, TestSorusu question, bool isDark) {
    final answer = question.correctAnswer;
    final typedText = _answerController.text;
    final revealed = provider.revealedIndices;

    return Padding(
      padding: const EdgeInsets.all(Tema.spacingLG),
      child: Column(
        children: [
          // Üst bar: kapat + ilerleme + sayaç
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Renkler.getCard(isDark),
                  borderRadius: BorderRadius.circular(Tema.radiusSM),
                  border: Border.all(color: Renkler.getCardBorder(isDark)),
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: Renkler.getTextPrimary(isDark), size: 20),
                  onPressed: () {
                    provider.resetQuiz();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Renkler.getCardBorder(isDark),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: provider.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: Renkler.getPastelGradient(isDark),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: Renkler.getHeaderGradient(isDark),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const Spacer(flex: 2),

          // İngilizce kelime — gradient kartı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Renkler.getPrimary(isDark).withOpacity(0.08),
                  Renkler.getAccent(isDark).withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Tema.cardRadius),
              border: Border.all(color: Renkler.getSecondary(isDark).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'Bu kelimenin Türkçe anlamı?',
                  style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => Renkler.getPastelGradient(isDark).createShader(bounds),
                  child: Text(
                    question.word.word,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                if (question.word.level.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Renkler.getAccent(isDark).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.word.level,
                      style: TextStyle(color: Renkler.getAccent(isDark), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: Tema.spacingXL),

          // Adam asmaca çizgileri
          AnimatedBuilder(
            animation: _showResult
                ? (_lastResult == true ? _bounceAnimation : _shakeAnimation)
                : const AlwaysStoppedAnimation(0),
            builder: (context, child) {
              final offset = !_showResult ? 0.0 : (_lastResult == true ? 0.0 : _shakeAnimation.value);
              final scale = !_showResult ? 1.0 : (_lastResult == true ? _bounceAnimation.value : 1.0);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: _buildLetterBlanks(answer, typedText, revealed, isDark),
          ),

          const SizedBox(height: Tema.spacingLG),

          // Giriş alanı + Joker
          if (!_showResult) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Renkler.getCard(isDark),
                      borderRadius: BorderRadius.circular(Tema.buttonRadius),
                      border: Border.all(color: Renkler.getSecondary(isDark).withOpacity(0.3), width: 2),
                    ),
                    child: TextField(
                      controller: _answerController,
                      focusNode: _focusNode,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Renkler.getTextPrimary(isDark),
                        letterSpacing: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cevabı yaz...',
                        hintStyle: TextStyle(color: Renkler.getTextSecondary(isDark).withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _checkAnswer(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Joker butonu
                GestureDetector(
                  onTap: provider.jokersRemaining > 0 ? _useJoker : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: provider.jokersRemaining > 0
                          ? LinearGradient(colors: [
                              Renkler.getSecondary(isDark),
                              Renkler.getAccent(isDark),
                            ])
                          : null,
                      color: provider.jokersRemaining > 0 ? null : Renkler.getCardBorder(isDark),
                      borderRadius: BorderRadius.circular(Tema.buttonRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: provider.jokersRemaining > 0 ? Colors.white : Renkler.getTextSecondary(isDark),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.jokersRemaining}',
                          style: TextStyle(
                            color: provider.jokersRemaining > 0 ? Colors.white : Renkler.getTextSecondary(isDark),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),
              ],
            ),
            const SizedBox(height: Tema.spacingMD),
            SizedBox(
              width: double.infinity,
              child: BuzluButon(
                text: 'Kontrol Et',
                icon: Icons.check_rounded,
                onPressed: _checkAnswer,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],

          // Sonuç gösterimi
          if (_showResult) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Tema.spacingMD),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _lastResult == true
                      ? [Renkler.getSuccess(isDark).withOpacity(0.15), Renkler.getSuccess(isDark).withOpacity(0.05)]
                      : [Renkler.getError(isDark).withOpacity(0.15), Renkler.getError(isDark).withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(Tema.radiusMD),
                border: Border.all(
                  color: (_lastResult == true ? Renkler.getSuccess(isDark) : Renkler.getError(isDark)).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_lastResult == true ? Renkler.getSuccess(isDark) : Renkler.getError(isDark)).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _lastResult == true ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
                      color: _lastResult == true ? Renkler.getSuccess(isDark) : Renkler.getError(isDark),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastResult == true ? 'Harika, doğru!' : 'Yanlış!',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _lastResult == true ? Renkler.getSuccess(isDark) : Renkler.getError(isDark),
                          ),
                        ),
                        if (_lastResult != true) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Doğru cevap: ${question.correctAnswer}',
                            style: TextStyle(
                              color: Renkler.getTextSecondary(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: Tema.spacingMD),
            SizedBox(
              width: double.infinity,
              child: BuzluButon(
                text: provider.isLastQuestion ? 'Sonuçları Gör' : 'Sonraki Soru',
                icon: provider.isLastQuestion ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                onPressed: _nextQuestion,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ],

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildLetterBlanks(String answer, String typedText, Set<int> revealed, bool isDark) {
    final chars = answer.split('');
    final primary = Renkler.getPrimary(isDark);
    final success = Renkler.getSuccess(isDark);
    final error = Renkler.getError(isDark);
    final accent = Renkler.getAccent(isDark);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: List.generate(chars.length, (i) {
        final char = chars[i];
        final isSpace = char == ' ';
        if (isSpace) return const SizedBox(width: 14);

        final isRevealed = revealed.contains(i);
        String display = '';
        Color slotColor = Renkler.getCardBorder(isDark);
        Color textColor = Renkler.getTextPrimary(isDark);
        Color bgColor = Renkler.getCard(isDark);

        if (_showResult) {
          display = char;
          if (_lastResult == true) {
            slotColor = success;
            bgColor = success.withOpacity(0.1);
            textColor = success;
          } else {
            slotColor = error;
            bgColor = error.withOpacity(0.1);
            textColor = error;
          }
        } else if (isRevealed) {
          display = char;
          slotColor = accent;
          bgColor = accent.withOpacity(0.1);
          textColor = accent;
        } else if (i < typedText.length) {
          display = typedText[i];
          slotColor = primary;
          bgColor = primary.withOpacity(0.08);
          textColor = primary;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              bottom: BorderSide(
                color: slotColor,
                width: display.isEmpty ? 3 : 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              display,
              key: ValueKey('$i-$display'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}
