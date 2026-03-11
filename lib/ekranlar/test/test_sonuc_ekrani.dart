import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../saglayicilar/test_saglayici.dart';
import '../../bilesenler/ilerleme_gostergesi.dart';

/// ─── TEST SONUÇ EKRANI ───
/// Test bittikten sonra sonuçları gösteren ekran.
/// Doğru/yanlış sayısı, başarı yüzdesi ve soru detayları gösterilir.
/// ► SONUÇ MESAJLARI: resultMessage içindeki yüzde eşiklerini ve metinleri değiştir
///   %90+ = 'Mükemmel!', %70+ = 'Harika!', %50+ = 'İyi!'
class TestSonucEkrani extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final List<TestSorusu> questions;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const TestSonucEkrani({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questions,
    required this.onRetry,
    required this.onExit,
  });

  double get score => totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
  int get scorePercentage => (score * 100).round();

  /// ► SONUÇ MESAJLARI — Yüzde eşiklerini ve metinleri değiştirebilirsin
  String get resultMessage {
    if (scorePercentage >= 90) return 'Mükemmel!';
    if (scorePercentage >= 70) return 'Harika!';
    if (scorePercentage >= 50) return 'İyi!';
    return 'Pratik Yapmaya Devam Et!';
  }

  Color resultColor(bool isDark) {
    if (scorePercentage >= 90) return Renkler.getSuccess(isDark);
    if (scorePercentage >= 70) return Renkler.getSecondary(isDark);
    if (scorePercentage >= 50) return Renkler.getAccent(isDark);
    return Renkler.getPrimary(isDark);
  }

  IconData get resultIcon {
    if (scorePercentage >= 90) return Icons.emoji_events;
    if (scorePercentage >= 70) return Icons.star;
    if (scorePercentage >= 50) return Icons.thumb_up;
    return Icons.school;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = resultColor(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Result Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Renkler.getCard(isDark),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resultIcon,
                    size: 48,
                    color: themeColor,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  resultMessage,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                IlerlemeGostergesi(
                  progress: score,
                  radius: 70,
                  lineWidth: 12,
                  progressColor: themeColor,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$scorePercentage%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      Text(
                        'Başarı',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      icon: Icons.check_circle,
                      value: '$correctAnswers',
                      label: 'Doğru',
                      color: Renkler.getSuccess(isDark),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Renkler.getTextSecondary(isDark).withOpacity(0.2),
                    ),
                    _StatItem(
                      icon: Icons.cancel,
                      value: '${totalQuestions - correctAnswers}',
                      label: 'Yanlış',
                      color: Renkler.error,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Renkler.getTextSecondary(isDark).withOpacity(0.2),
                    ),
                    _StatItem(
                      icon: Icons.quiz,
                      value: '$totalQuestions',
                      label: 'Toplam',
                      color: Renkler.getSecondary(isDark),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Question Review
          Text(
            'Soru Detayları',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final isCorrect = question.isCorrect ?? false;
            final correctColor = Renkler.getSuccess(isDark);
            final wrongColor = Renkler.error;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Renkler.getCard(isDark),
                borderRadius: BorderRadius.circular(16),
                border: isDark
                    ? Border.all(
                        color: isCorrect
                            ? correctColor.withOpacity(0.3)
                            : wrongColor.withOpacity(0.3),
                      )
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? correctColor.withOpacity(0.1)
                          : wrongColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: isCorrect ? correctColor : wrongColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.word.word,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Renkler.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.correctAnswer,
                          style: TextStyle(
                            color: correctColor,
                            fontSize: 14,
                          ),
                        ),
                        if (!isCorrect && question.selectedAnswer != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Senin cevabın: ${question.selectedAnswer}',
                            style: TextStyle(
                              color: wrongColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (800 + index * 100).ms).slideX(begin: 0.1);
          }),
          const SizedBox(height: 24),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExit,
                  icon: Icon(Icons.home_rounded, color: Renkler.getSecondary(isDark)),
                  label: Text(
                    'Ana Sayfa',
                    style: TextStyle(color: Renkler.getSecondary(isDark)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Renkler.getSecondary(isDark)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Renkler.getSecondary(isDark),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
