import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cekirdek/sabitler/uygulama_renkleri.dart';
import '../../cekirdek/tema/uygulama_temasi.dart';
import '../../saglayicilar/kelime_saglayici.dart';
import '../../bilesenler/cevir_kart.dart';

/// ─── KART EKRANI ───
/// Günlük kelime kartlarını gösteren ekran. Kaydırarak kartlar arasında geçiş yapılır.
/// Her kartta "Biliyorum" ve "Tekrar Et" butonları vardır.
/// ► KART GEÇİŞ ANİMASYONU: Duration(milliseconds: 300) değerini değiştir
/// ► İNDİKATÖR LİMİTİ: 15'ten fazla kartta nokta göstergesi gizlenir (değiştirilebilir)
class KartEkrani extends StatefulWidget {
  const KartEkrani({super.key});

  @override
  State<KartEkrani> createState() => _KartEkraniState();
}

class _KartEkraniState extends State<KartEkrani> {
  PageController? _pageController;
  bool _initialized = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
  
  void _initPageController(int initialPage) {
    if (!_initialized) {
      _pageController = PageController(initialPage: initialPage);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Renkler.getBackground(isDark),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Renkler.getBackground(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Renkler.getTextPrimary(isDark),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelime Kartları',
          style: TextStyle(
            color: Renkler.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<KelimeSaglayici>(
            builder: (context, provider, _) {
              return Container(
                margin: const EdgeInsets.only(right: Tema.spacingMD),
                padding: const EdgeInsets.symmetric(
                  horizontal: Tema.spacingMD,
                  vertical: Tema.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: Renkler.getSecondary(isDark).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Tema.radiusMD),
                  border: Border.all(
                    color: Renkler.getSecondary(isDark).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${provider.currentCardIndex + 1}/${provider.dailyWords.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Renkler.getSecondary(isDark),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Renkler.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Consumer<KelimeSaglayici>(
            builder: (context, provider, _) {
              if (provider.dailyWords.isEmpty) {
                return _buildEmptyState(context, isDark);
              }
              
              // PageController'ı kaldığı index'ten başlat
              _initPageController(provider.currentCardIndex);

              return Column(
                children: [
                  const SizedBox(height: Tema.spacingMD),
                  // Progress Bar with glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Tema.spacingLG),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Renkler.getCardBorder(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: provider.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: Renkler.getPrimaryGradient(isDark),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Card Indicators (sadece 15 veya daha az kart varsa göster)
                  if (provider.dailyWords.length <= 15)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Tema.spacingMD),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          provider.dailyWords.length,
                          (index) => _buildIndicator(
                            isDark: isDark,
                            isActive: index == provider.currentCardIndex,
                            isPast: index < provider.currentCardIndex,
                          ),
                        ),
                      ),
                    ),
                  // Cards
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController!,
                      itemCount: provider.dailyWords.length,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        provider.goToCard(index);
                      },
                      itemBuilder: (context, index) {
                        final word = provider.dailyWords[index];
                        return CevirKart(
                          word: word,
                          onKnown: () async {
                            HapticFeedback.lightImpact();
                            await provider.markAsKnown(word.id);
                            _goToNextCard(provider);
                          },
                          onReview: () async {
                            HapticFeedback.lightImpact();
                            await provider.markForReview(word.id);
                            _goToNextCard(provider);
                          },
                        );
                      },
                    ),
                  ),
                  // Bottom Navigation
                  _buildBottomNavigation(context, provider, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required bool isDark,
    required bool isActive,
    required bool isPast,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Renkler.getSecondary(isDark)
            : isPast
                ? Renkler.getSuccess(isDark).withOpacity(0.6)
                : Renkler.getCardBorder(isDark),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tema.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Tema.spacingLG),
              decoration: BoxDecoration(
                color: Renkler.getSuccess(isDark).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 64,
                color: Renkler.getSuccess(isDark),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: Tema.spacingXL),
            Text(
              'Tebrikler!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Renkler.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: Tema.spacingSM),
            Text(
              'Bugünlük tüm kartları tamamladın!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Renkler.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Tema.spacingXL),
            _buildActionButton(
              context: context,
              isDark: isDark,
              text: 'Ana Sayfaya Dön',
              icon: Icons.home_rounded,
              color: Renkler.getPrimary(isDark),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, KelimeSaglayici provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(Tema.spacingLG),
      decoration: BoxDecoration(
        color: Renkler.getCard(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button - Sade, dolgusuz
          TextButton.icon(
            onPressed: provider.currentCardIndex > 0
                ? () {
                    HapticFeedback.selectionClick();
                    _pageController?.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 18,
              color: provider.currentCardIndex > 0
                  ? Renkler.getTextSecondary(isDark)
                  : Renkler.getTextSecondary(isDark).withOpacity(0.4),
            ),
            label: Text(
              'Önceki',
              style: TextStyle(
                color: provider.currentCardIndex > 0
                    ? Renkler.getTextSecondary(isDark)
                    : Renkler.getTextSecondary(isDark).withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Card Counter - Soft badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Tema.spacingMD,
              vertical: Tema.spacingSM,
            ),
            decoration: BoxDecoration(
              color: Renkler.getCard(isDark),
              borderRadius: BorderRadius.circular(Tema.buttonRadius),
              border: Border.all(
                color: Renkler.getCardBorder(isDark),
                width: 1,
              ),
            ),
            child: Text(
              '${provider.remainingCards} kart kaldı',
              style: TextStyle(
                color: Renkler.getTextPrimary(isDark),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          // Next Button - Sade, dolgusuz
          TextButton.icon(
            onPressed: provider.hasMoreCards
                ? () {
                    HapticFeedback.selectionClick();
                    _pageController?.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Text(
              'Sonraki',
              style: TextStyle(
                color: provider.hasMoreCards
                    ? Renkler.getTextSecondary(isDark)
                    : Renkler.getTextSecondary(isDark).withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
            label: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: provider.hasMoreCards
                  ? Renkler.getTextSecondary(isDark)
                  : Renkler.getTextSecondary(isDark).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool isDark,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Tema.spacingLG,
          vertical: Tema.spacingMD,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Tema.buttonRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: Tema.spacingSM),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToNextCard(KelimeSaglayici provider) async {
    if (provider.hasMoreCards) {
      _pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Tüm kartlar tamamlandı
      await provider.markAllCompleted();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Renkler.getCard(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tema.cardRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Renkler.getSuccess(isDark).withOpacity(0.15),
                borderRadius: BorderRadius.circular(Tema.radiusSM),
              ),
              child: Icon(
                Icons.celebration_rounded,
                color: Renkler.getSuccess(isDark),
              ),
            ),
            const SizedBox(width: Tema.spacingMD),
            Text(
              'Tebrikler!',
              style: TextStyle(
                color: Renkler.getTextPrimary(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Bugünün tüm kelime kartlarını tamamladın!',
          style: TextStyle(
            color: Renkler.getTextSecondary(isDark),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(context); // Cards ekranından çık
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Tema.spacingLG,
                vertical: Tema.spacingMD,
              ),
              decoration: BoxDecoration(
                color: Renkler.getPrimary(isDark),
                borderRadius: BorderRadius.circular(Tema.buttonRadius),
              ),
              child: const Text(
                'Ana Sayfaya Dön',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
