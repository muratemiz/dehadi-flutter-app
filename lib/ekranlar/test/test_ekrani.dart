import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/test_saglayici.dart';
import '../../bilesenler/buzlu_bilesenler.dart';
import 'test_sonuc_ekrani.dart';

class TestEkrani extends StatefulWidget {
  const TestEkrani({super.key});

  @override
  State<TestEkrani> createState() => _TestEkraniState();
}

class _TestEkraniState extends State<TestEkrani> with SingleTickerProviderStateMixin {
  bool _answered = false;
  String? _selectedAnswer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TestSaglayici>();
      if (provider.state == TestDurumu.baslamadi) {
        provider.startQuiz(questionCount: 20, testTuru: TestTuru.cokluSecim);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
          child: Consumer<TestSaglayici>(
            builder: (context, provider, _) {
              switch (provider.state) {
                case TestDurumu.baslamadi:
                  return Center(
                    child: CircularProgressIndicator(color: Renkler.getSecondary(isDark)),
                  );
                case TestDurumu.devamEdiyor:
                  return _buildQuizContent(context, provider, isDark);
                case TestDurumu.bitti:
                  return TestSonucEkrani(
                    correctAnswers: provider.correctAnswers,
                    totalQuestions: provider.totalQuestions,
                    questions: provider.questions,
                    onRetry: () {
                      setState(() {
                        _answered = false;
                        _selectedAnswer = null;
                      });
                      provider.startQuiz(questionCount: 20, testTuru: TestTuru.cokluSecim);
                    },
                    onExit: () {
                      provider.resetQuiz();
                      Navigator.pop(context);
                    },
                  );
              }
            },
          ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, TestSaglayici provider, bool isDark) {
    final question = provider.currentQuestion;
    if (question == null) {
      return Center(
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
            ),
            const SizedBox(height: Tema.spacingLG),
            Text(
              'Henüz öğrenilmiş kelime yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Renkler.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: Tema.spacingLG),
            BuzluButon(text: 'Geri Dön', onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(Tema.spacingLG),
      child: Column(
        children: [
          // Üst bar
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Renkler.getCard(isDark) : Renkler.getSurface(isDark),
                  borderRadius: BorderRadius.circular(Tema.radiusSM),
                  border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
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

          const SizedBox(height: Tema.spacingLG),

          // Kelime kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Renkler.getPrimary(isDark).withOpacity(0.08),
                  Renkler.getSecondary(isDark).withOpacity(0.06),
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
                  'Bu kelimenin anlamı nedir?',
                  style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => Renkler.getPastelGradient(isDark).createShader(bounds),
                  child: Text(
                    question.word.word,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                    textAlign: TextAlign.center,
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
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

          const SizedBox(height: Tema.spacingLG),

          // Şıklar
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == question.correctAnswer;
                  final successColor = Renkler.getSuccess(isDark);
                  final primaryColor = Renkler.getSecondary(isDark);

                  Color bgColor = Renkler.getCard(isDark);
                  Color borderColor = Renkler.getCardBorder(isDark);
                  IconData? trailingIcon;

                  if (_answered) {
                    if (isCorrect) {
                      bgColor = successColor.withOpacity(0.1);
                      borderColor = successColor;
                      trailingIcon = Icons.check_circle_rounded;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Renkler.getError(isDark).withOpacity(0.1);
                      borderColor = Renkler.getError(isDark);
                      trailingIcon = Icons.cancel_rounded;
                    }
                  } else if (isSelected) {
                    bgColor = primaryColor.withOpacity(0.1);
                    borderColor = primaryColor;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: _answered ? null : () => _selectAnswer(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(Tema.radiusMD),
                          border: Border.all(color: borderColor, width: isSelected || (_answered && isCorrect) ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: isSelected || (_answered && isCorrect)
                                    ? LinearGradient(colors: [borderColor.withOpacity(0.2), borderColor.withOpacity(0.05)])
                                    : null,
                                color: isSelected || (_answered && isCorrect) ? null : Renkler.getCardBorder(isDark).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected || (_answered && isCorrect) ? borderColor : Renkler.getTextSecondary(isDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: Renkler.getTextPrimary(isDark),
                                ),
                              ),
                            ),
                            if (trailingIcon != null)
                              Icon(trailingIcon, color: isCorrect ? successColor : Renkler.getError(isDark), size: 22)
                                  .animate().scale(begin: const Offset(0, 0), duration: 300.ms, curve: Curves.elasticOut),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (80 * index).ms).slideX(begin: 0.08, duration: 250.ms);
                }).toList(),
              ),
            ),
          ),

          // Sonraki buton
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: BuzluButon(
                text: provider.isLastQuestion ? 'Sonuçları Gör' : 'Sonraki Soru',
                icon: provider.isLastQuestion ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                onPressed: () {
                  setState(() {
                    _answered = false;
                    _selectedAnswer = null;
                  });
                  if (provider.hasMoreQuestions) {
                    provider.nextQuestion();
                  } else {
                    provider.finishQuiz();
                  }
                },
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });
    await context.read<TestSaglayici>().answerQuestion(answer);
  }
}
