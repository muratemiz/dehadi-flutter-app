import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/test_saglayici.dart';
import '../../bilesenler/buzlu_bilesenler.dart';

class EslestirmeEkrani extends StatefulWidget {
  const EslestirmeEkrani({super.key});

  @override
  State<EslestirmeEkrani> createState() => _EslestirmeEkraniState();
}

class _EslestirmeEkraniState extends State<EslestirmeEkrani> {
  int? _selectedWordIndex;
  final Set<int> _matchedWordIndices = {};
  final Set<String> _matchedMeanings = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
          child: Consumer<TestSaglayici>(
            builder: (context, provider, _) {
              if (provider.matchPairs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Tema.spacingLG),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 64, color: Renkler.getTextSecondary(isDark)),
                        const SizedBox(height: Tema.spacingMD),
                        Text(
                          'Henüz öğrenilmiş kelime yok.\nÖnce kartlardan kelime öğrenin!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 16),
                        ),
                        const SizedBox(height: Tema.spacingLG),
                        BuzluButon(text: 'Geri Dön', onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                );
              }

              final allDone = provider.allMatchesCompleted;

              return Padding(
                padding: const EdgeInsets.all(Tema.spacingLG),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Renkler.getTextPrimary(isDark)),
                          onPressed: () {
                            provider.resetQuiz();
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: Tema.spacingSM),
                        Text(
                          'Eşleştirme',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Renkler.getTextPrimary(isDark),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${provider.matchScore}/${provider.matchPairs.length}',
                          style: TextStyle(
                            color: Renkler.getSecondary(isDark),
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Tema.spacingMD),
                    Text(
                      'Soldaki kelimeyi, sağdaki anlamıyla eşleştirin',
                      style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 14),
                    ),
                    const SizedBox(height: Tema.spacingLG),
                    Expanded(
                      child: Row(
                        children: [
                          // Sol: kelimeler
                          Expanded(
                            child: Column(
                              children: List.generate(provider.matchPairs.length, (i) {
                                final pair = provider.matchPairs[i];
                                final isMatched = _matchedWordIndices.contains(i);
                                final isSelected = _selectedWordIndex == i;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: isMatched ? null : () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedWordIndex = i);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isMatched
                                            ? (pair.isCorrect == true
                                                ? Renkler.getSuccess(isDark).withOpacity(0.15)
                                                : Renkler.getError(isDark).withOpacity(0.15))
                                            : isSelected
                                                ? Renkler.getSecondary(isDark).withOpacity(0.15)
                                                : Renkler.getCard(isDark),
                                        borderRadius: BorderRadius.circular(Tema.radiusMD),
                                        border: Border.all(
                                          color: isMatched
                                              ? (pair.isCorrect == true
                                                  ? Renkler.getSuccess(isDark)
                                                  : Renkler.getError(isDark))
                                              : isSelected
                                                  ? Renkler.getSecondary(isDark)
                                                  : Renkler.getCardBorder(isDark),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          pair.word.word,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isMatched
                                                ? Renkler.getTextSecondary(isDark)
                                                : Renkler.getTextPrimary(isDark),
                                            decoration: isMatched ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(width: Tema.spacingMD),
                          // Sağ: anlamlar
                          Expanded(
                            child: Column(
                              children: List.generate(provider.shuffledMeanings.length, (i) {
                                final meaning = provider.shuffledMeanings[i];
                                final isMatched = _matchedMeanings.contains(meaning);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: (isMatched || _selectedWordIndex == null) ? null : () async {
                                      HapticFeedback.mediumImpact();
                                      final wordIdx = _selectedWordIndex!;
                                      final isCorrect = await provider.checkMatch(wordIdx, meaning);
                                      setState(() {
                                        _matchedWordIndices.add(wordIdx);
                                        if (isCorrect) _matchedMeanings.add(meaning);
                                        _selectedWordIndex = null;
                                      });
                                      if (!isCorrect) {
                                        // Yanlış eşleşmede doğru anlamı göster
                                        final correctMeaning = provider.matchPairs[wordIdx].word.meaning;
                                        setState(() => _matchedMeanings.add(correctMeaning));
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isMatched
                                            ? Renkler.getCardBorder(isDark).withOpacity(0.5)
                                            : Renkler.getCard(isDark),
                                        borderRadius: BorderRadius.circular(Tema.radiusMD),
                                        border: Border.all(color: Renkler.getCardBorder(isDark)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          meaning,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isMatched
                                                ? Renkler.getTextSecondary(isDark)
                                                : Renkler.getTextPrimary(isDark),
                                            decoration: isMatched ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Tema.spacingLG),
                    if (allDone) ...[
                      Container(
                        padding: const EdgeInsets.all(Tema.spacingMD),
                        decoration: BoxDecoration(
                          color: Renkler.getSuccess(isDark).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(Tema.radiusMD),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.celebration_rounded, color: Renkler.getSuccess(isDark)),
                            const SizedBox(width: 8),
                            Text(
                              '${provider.matchScore}/${provider.matchPairs.length} doğru eşleştirme!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Renkler.getSuccess(isDark),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                      const SizedBox(height: Tema.spacingMD),
                      SizedBox(
                        width: double.infinity,
                        child: BuzluButon(
                          text: 'Tamamla',
                          icon: Icons.check_rounded,
                          onPressed: () async {
                            await provider.finishQuiz();
                            if (context.mounted) {
                              provider.resetQuiz();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ),
    );
  }
}
