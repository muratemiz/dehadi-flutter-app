import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/kelime_saglayici.dart';
import '../../veri/modeller/kelime_modeli.dart';

class KelimeListesiEkrani extends StatefulWidget {
  const KelimeListesiEkrani({super.key});

  @override
  State<KelimeListesiEkrani> createState() => _KelimeListesiEkraniState();
}

class _KelimeListesiEkraniState extends State<KelimeListesiEkrani> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              _buildSearchBar(isDark),
              _buildFilterChips(isDark),
              Expanded(child: _buildWordList(isDark)),
            ],
          ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tema.spacingMD, vertical: Tema.spacingSM),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Renkler.getTextPrimary(isDark)),
            onPressed: () {
              context.read<KelimeSaglayici>().clearFilters();
              Navigator.pop(context);
            },
          ),
          Text(
            'Kelimelerim',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Renkler.getTextPrimary(isDark),
            ),
          ),
          const Spacer(),
          Consumer<KelimeSaglayici>(
            builder: (context, p, _) {
              return Text(
                '${p.filteredWords.length} kelime',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Renkler.getTextSecondary(isDark),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => context.read<KelimeSaglayici>().setSearchQuery(value),
        style: TextStyle(color: Renkler.getTextPrimary(isDark)),
        decoration: InputDecoration(
          hintText: 'Kelime veya anlam ara...',
          hintStyle: TextStyle(color: Renkler.getTextSecondary(isDark)),
          prefixIcon: Icon(Icons.search_rounded, color: Renkler.getTextSecondary(isDark)),
          suffixIcon: Consumer<KelimeSaglayici>(
            builder: (context, p, _) {
              if (p.searchQuery.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.clear_rounded, color: Renkler.getTextSecondary(isDark)),
                onPressed: () {
                  _searchController.clear();
                  p.setSearchQuery('');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Consumer<KelimeSaglayici>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Tema.spacingSM),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG),
            child: Row(
              children: [
                _StatusChip(
                  label: 'Tümü',
                  isSelected: provider.learnedFilter == null,
                  onTap: () => provider.setLearnedFilter(null),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Öğrenildi',
                  isSelected: provider.learnedFilter == true,
                  onTap: () => provider.setLearnedFilter(
                    provider.learnedFilter == true ? null : true,
                  ),
                  isDark: isDark,
                  color: Renkler.getSuccess(isDark),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Öğrenilmedi',
                  isSelected: provider.learnedFilter == false,
                  onTap: () => provider.setLearnedFilter(
                    provider.learnedFilter == false ? null : false,
                  ),
                  isDark: isDark,
                  color: Renkler.getError(isDark),
                ),
                const SizedBox(width: 12),
                for (final level in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) ...[
                  _LevelChip(
                    level: level,
                    isSelected: provider.selectedLevels.contains(level),
                    onTap: () => provider.toggleLevel(level),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordList(bool isDark) {
    return Consumer<KelimeSaglayici>(
      builder: (context, provider, _) {
        final words = provider.filteredWords;
        if (words.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: Renkler.getTextSecondary(isDark)),
                const SizedBox(height: Tema.spacingMD),
                Text('Sonuç bulunamadı', style: TextStyle(color: Renkler.getTextSecondary(isDark))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG, vertical: Tema.spacingSM),
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            final progress = provider.getWordProgress(word.id);
            final isLearned = progress?.isLearned ?? false;

            return _WordListItem(
              word: word,
              isLearned: isLearned,
              masteryLevel: progress?.masteryLevel ?? 0,
              isDark: isDark,
              onTap: () => _showWordDetail(context, word, progress, isDark),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 * (index % 20)));
          },
        );
      },
    );
  }

  void _showWordDetail(BuildContext context, KelimeModeli word, dynamic progress, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Renkler.getCard(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(Tema.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Renkler.getCardBorder(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Tema.spacingLG),
              Text(
                word.word,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Renkler.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: Tema.spacingSM),
              Text(
                word.meaning,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Renkler.getSecondary(isDark),
                ),
              ),
              const SizedBox(height: Tema.spacingMD),
              if (word.definition != null && word.definition!.isNotEmpty) ...[
                Text(
                  word.definition!,
                  style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 14),
                ),
                const SizedBox(height: Tema.spacingSM),
              ],
              if (word.exampleSentence != null && word.exampleSentence!.isNotEmpty) ...[
                  Container(
                  padding: const EdgeInsets.all(Tema.spacingMD),
                  decoration: BoxDecoration(
                    color: Renkler.getSecondary(isDark).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(Tema.radiusSM),
                  ),
                  child: Text(
                    '"${word.exampleSentence!}"',
                    style: TextStyle(
                      color: Renkler.getTextPrimary(isDark),
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: Tema.spacingSM),
              ],
              Row(
                children: [
                  _LevelBadge(level: word.level, isDark: isDark),
                  const SizedBox(width: Tema.spacingSM),
                  if (progress != null) ...[
                    Icon(
                      progress.isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: progress.isLearned ? Renkler.getSuccess(isDark) : Renkler.getTextSecondary(isDark),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      progress.isLearned ? 'Öğrenildi' : 'Öğrenilmedi',
                      style: TextStyle(
                        color: progress.isLearned ? Renkler.getSuccess(isDark) : Renkler.getTextSecondary(isDark),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Seviye: ${progress.masteryLevel}/5',
                      style: TextStyle(color: Renkler.getTextSecondary(isDark), fontSize: 13),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Tema.spacingLG),
            ],
          ),
        );
      },
    );
  }
}

class _WordListItem extends StatelessWidget {
  final KelimeModeli word;
  final bool isLearned;
  final int masteryLevel;
  final bool isDark;
  final VoidCallback onTap;

  const _WordListItem({
    required this.word,
    required this.isLearned,
    required this.masteryLevel,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Tema.spacingSM),
        padding: const EdgeInsets.all(Tema.spacingMD),
        decoration: BoxDecoration(
          color: Renkler.getCard(isDark),
          borderRadius: BorderRadius.circular(Tema.radiusMD),
          border: isDark ? Border.all(color: Renkler.getCardBorder(isDark)) : null,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Renkler.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.meaning,
                    style: TextStyle(
                      fontSize: 14,
                      color: Renkler.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            _LevelBadge(level: word.level, isDark: isDark),
            const SizedBox(width: Tema.spacingSM),
            Icon(
              isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isLearned ? Renkler.getSuccess(isDark) : Renkler.getCardBorder(isDark),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Renkler.getSecondary(isDark);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : Renkler.getCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Renkler.getCardBorder(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? chipColor : Renkler.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String level;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _LevelChip({
    required this.level,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Renkler.getSecondary(isDark).withOpacity(0.15) : Renkler.getCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Renkler.getSecondary(isDark) : Renkler.getCardBorder(isDark),
          ),
        ),
        child: Text(
          level,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Renkler.getSecondary(isDark) : Renkler.getTextSecondary(isDark),
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  final bool isDark;

  const _LevelBadge({required this.level, required this.isDark});

  Color _getColor() {
    switch (level) {
      case 'A1': return const Color(0xFF22C55E);
      case 'A2': return const Color(0xFF4ADE80);
      case 'B1': return const Color(0xFF3B82F6);
      case 'B2': return const Color(0xFF60A5FA);
      case 'C1': return const Color(0xFF8B5CF6);
      case 'C2': return const Color(0xFFA78BFA);
      default: return Renkler.getTextSecondary(isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        level,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}
