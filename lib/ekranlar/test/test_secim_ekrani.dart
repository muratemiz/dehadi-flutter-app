import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/test_saglayici.dart';
import 'test_ekrani.dart';
import 'yazarak_test_ekrani.dart';
import 'eslestirme_ekrani.dart';

class TestSecimEkrani extends StatelessWidget {
  const TestSecimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(Tema.spacingMD),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: Renkler.getTextPrimary(isDark)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Test Türü Seç',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Renkler.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Tema.spacingLG),
                  child: Column(
                    children: [
                      _TestTypeCard(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Çoktan Seçmeli',
                        description: '4 şıktan doğru olanını seç',
                        color: Renkler.getSecondary(isDark),
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final provider = context.read<TestSaglayici>();
                          provider.resetQuiz();
                          provider.startQuiz(testTuru: TestTuru.cokluSecim);
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => const TestEkrani()),
                          );
                        },
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: Tema.spacingMD),
                      _TestTypeCard(
                        icon: Icons.edit_outlined,
                        title: 'Yazarak Cevapla',
                        description: 'Kelimenin Türkçe anlamını yaz',
                        color: Renkler.getAccent(isDark),
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final provider = context.read<TestSaglayici>();
                          provider.resetQuiz();
                          provider.startQuiz(testTuru: TestTuru.yazarakCevap);
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => const YazarakTestEkrani()),
                          );
                        },
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: Tema.spacingMD),
                      _TestTypeCard(
                        icon: Icons.compare_arrows_rounded,
                        title: 'Eşleştirme',
                        description: '5 kelime ile 5 anlamı eşleştir',
                        color: Renkler.getTeal(isDark),
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final provider = context.read<TestSaglayici>();
                          provider.resetQuiz();
                          provider.startQuiz(testTuru: TestTuru.eslestirme);
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (_) => const EslestirmeEkrani()),
                          );
                        },
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _TestTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _TestTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Tema.spacingLG),
        decoration: BoxDecoration(
          color: Renkler.getCard(isDark),
          borderRadius: BorderRadius.circular(Tema.cardRadius),
          border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(Tema.radiusMD),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: Tema.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Renkler.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Renkler.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Renkler.getTextSecondary(isDark)),
          ],
        ),
      ),
    );
  }
}
