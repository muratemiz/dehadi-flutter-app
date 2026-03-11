import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../saglayicilar/kelime_saglayici.dart';
import '../../saglayicilar/seri_saglayici.dart';
import '../../bilesenler/ilerleme_gostergesi.dart';

/// ─── İSTATİSTİK EKRANI ───
/// Seri bilgileri, kelime ilerleme durumu, test istatistikleri ve rozetleri gösterir.
/// ► YENİ ROZET EKLEMEK: _buildAchievements metodundaki achievements listesine
///   yeni _Achievement(...) ekle. isUnlocked koşulunu belirle.
/// ► ROZET EŞİKLERİ: '10 kelime öğren', '25 kelime öğren' gibi eşikleri değiştir
class IstatistikEkrani extends StatelessWidget {
  const IstatistikEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: Renkler.getBackground(isDark),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Renkler.getTextPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'İstatistikler',
          style: TextStyle(color: Renkler.getTextPrimary(isDark), fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        color: Renkler.getBackground(isDark),
        child: Consumer2<KelimeSaglayici, SeriSaglayici>(
          builder: (context, wordProvider, streakProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak Stats
                  _buildStreakStats(context, streakProvider, isDark),
                  const SizedBox(height: 24),

                  // Progress Overview
                  Text(
                    'Kelime İlerlemesi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  _buildProgressOverview(context, wordProvider, isDark),
                  const SizedBox(height: 24),

                  // Quiz Stats
                  Text(
                    'Test İstatistikleri',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  _buildQuizStats(context, streakProvider, isDark),
                  const SizedBox(height: 24),

                  // Achievement Badges
                  Text(
                    'Rozetler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 16),
                  _buildAchievements(context, streakProvider, wordProvider, isDark),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakStats(
      BuildContext context, SeriSaglayici provider, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            title: 'Mevcut Seri',
            value: '${provider.currentStreak}',
            subtitle: 'gün',
            color: Renkler.warning,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            title: 'En Uzun Seri',
            value: '${provider.longestStreak}',
            subtitle: 'gün',
            color: const Color(0xFFFFD700),
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildProgressOverview(
      BuildContext context, KelimeSaglayici provider, bool isDark) {
    final learned = provider.learnedWords.length;
    final total = provider.allWords.length;
    final remaining = total - learned;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IlerlemeGostergesi(
                progress: provider.overallProgress,
                radius: 60,
                lineWidth: 10,
                progressColor: Renkler.getSecondary(isDark),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressItem(
                      label: 'Öğrenildi',
                      value: learned,
                      color: Renkler.getSuccess(isDark),
                    ),
                    const SizedBox(height: 12),
                    _ProgressItem(
                      label: 'Kalan',
                      value: remaining,
                      color: Renkler.getTeal(isDark),
                    ),
                    const SizedBox(height: 12),
                    _ProgressItem(
                      label: 'Toplam',
                      value: total,
                      color: Renkler.getSecondary(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DogrusalIlerleme(
            progress: provider.overallProgress,
            label: 'Genel İlerleme',
            height: 10,
            progressColor: Renkler.getSecondary(isDark),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildQuizStats(
      BuildContext context, SeriSaglayici provider, bool isDark) {
    final accuracy = provider.overallAccuracy;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuizStatItem(
                icon: Icons.quiz_rounded,
                value: '${provider.totalQuizzesTaken}',
                label: 'Toplam Test',
                color: Renkler.getSecondary(isDark),
              ),
              Container(
                width: 1,
                height: 60,
                color: Renkler.getTextSecondary(isDark).withOpacity(0.2),
              ),
              _QuizStatItem(
                icon: Icons.check_circle_rounded,
                value: '${provider.totalCorrectAnswers}',
                label: 'Doğru Cevap',
                color: Renkler.getSuccess(isDark),
              ),
              Container(
                width: 1,
                height: 60,
                color: Renkler.getTextSecondary(isDark).withOpacity(0.2),
              ),
              _QuizStatItem(
                icon: Icons.percent_rounded,
                value: '${(accuracy * 100).round()}%',
                label: 'Başarı Oranı',
                color: accuracy >= 0.7
                    ? Renkler.getSuccess(isDark)
                    : accuracy >= 0.5
                        ? Renkler.getAccent(isDark)
                        : Renkler.error,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildAchievements(BuildContext context, SeriSaglayici streakProvider,
      KelimeSaglayici wordProvider, bool isDark) {
    // ► ROZET LİSTESİ — Yeni rozet eklemek için listeye _Achievement ekle
    // isUnlocked: true olduğunda rozet açılır, false olduğunda kilitli görünür
    // color: rozet rengi, icon: rozet ikonu (Icons.xxx)
    final achievements = [
      _Achievement(
        icon: Icons.bolt,
        title: 'Başlangıç',
        description: 'İlk kelimeni öğren',
        isUnlocked: wordProvider.learnedWords.isNotEmpty,
        color: Renkler.teal,
      ),
      _Achievement(
        icon: Icons.local_fire_department,
        title: 'Bronz Seri',
        description: '7 gün üst üste çalış',    // ► Eşiği değiştirmek için >= 7'yi değiştir
        isUnlocked: streakProvider.longestStreak >= 7,
        color: const Color(0xFFCD7F32),           // Bronz rengi
      ),
      _Achievement(
        icon: Icons.star,
        title: 'Gümüş Seri',
        description: '14 gün üst üste çalış',
        isUnlocked: streakProvider.longestStreak >= 14,
        color: const Color(0xFFC0C0C0),           // Gümüş rengi
      ),
      _Achievement(
        icon: Icons.military_tech,
        title: 'Altın Seri',
        description: '30 gün üst üste çalış',
        isUnlocked: streakProvider.longestStreak >= 30,
        color: const Color(0xFFFFD700),           // Altın rengi
      ),
      _Achievement(
        icon: Icons.school,
        title: 'Öğrenci',
        description: '10 kelime öğren',           // ► Eşiği değiştirmek için >= 10'u değiştir
        isUnlocked: wordProvider.learnedWords.length >= 10,
        color: Renkler.secondary,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        title: 'Uzman',
        description: '25 kelime öğren',
        isUnlocked: wordProvider.learnedWords.length >= 25,
        color: Renkler.success,
      ),
      // ► YENİ ROZET EKLEMEK İÇİN BURAYA KOPYALA-YAPIŞTIR:
      // _Achievement(
      //   icon: Icons.diamond,
      //   title: 'Elmas',
      //   description: '100 kelime öğren',
      //   isUnlocked: wordProvider.learnedWords.length >= 100,
      //   color: const Color(0xFF00BCD4),
      // ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: achievements.asMap().entries.map((entry) {
        final index = entry.key;
        final achievement = entry.value;

        return _AchievementBadge(
          achievement: achievement,
          isDark: isDark,
        ).animate().fadeIn(delay: (700 + index * 100).ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 300.ms,
            );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ProgressItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuizStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuizStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final Color color;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.color,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  final bool isDark;

  const _AchievementBadge({
    required this.achievement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? achievement.color : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 12,
              color: achievement.isUnlocked
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (!achievement.isUnlocked) ...[
            const SizedBox(height: 8),
            Icon(
              Icons.lock,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }
}
