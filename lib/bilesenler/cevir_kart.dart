import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cekirdek/sabitler/uygulama_renkleri.dart';
import '../cekirdek/tema/uygulama_temasi.dart';
import '../veri/modeller/kelime_modeli.dart';

/// ─── ÇEVİR KART BİLEŞENİ ───
/// Kelime kartının ön (İngilizce) ve arka (Türkçe) yüzünü gösterir.
/// Karta dokunarak çevrilir. Alt kısımda "Tekrar Et" ve "Biliyorum" butonları var.
/// ► KART FONT BOYUTU: fontSize: 34 (ön yüz), fontSize: 30 (arka yüz) — değiştirilebilir
/// ► BUTON METİNLERİ: 'Tekrar Et' ve 'Biliyorum' — _buildActionButtons'da değiştir
/// ► SEVİYE RENKLERİ: _getLevelColor metodunda A1-C2 için renk atamaları var
class CevirKart extends StatefulWidget {
  final KelimeModeli word;
  final VoidCallback? onKnown;       // "Biliyorum" butonuna basılınca
  final VoidCallback? onReview;      // "Tekrar Et" butonuna basılınca
  final GlobalKey<FlipCardState>? flipKey;

  const CevirKart({
    super.key,
    required this.word,
    this.onKnown,
    this.onReview,
    this.flipKey,
  });

  @override
  State<CevirKart> createState() => _CevirKartState();
}

class _CevirKartState extends State<CevirKart> {
  bool _isScratched = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(Tema.spacingMD),
      child: Column(
        children: [
          Expanded(
            child: FlipCard(
              key: widget.flipKey,
              direction: FlipDirection.HORIZONTAL,
              flipOnTouch: true,
              onFlip: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isScratched = false;
                });
              },
              front: _buildFrontCard(context, isDark),
              back: _buildBackCard(context, isDark),
            ),
          ),
          const SizedBox(height: Tema.spacingMD),
          _buildActionButtons(context, isDark),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  // ═══════════════════════════════════════════════════════════════
  // ÖN YÜZ - İNGİLİZCE (Frosted Pastel - Glassmorphism)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFrontCard(BuildContext context, bool isDark) {
    return Container(
          decoration: BoxDecoration(
            color: Renkler.getCard(isDark),
            borderRadius: BorderRadius.circular(Tema.cardRadius),
            border: isDark ? Border.all(color: Renkler.getCardBorder(isDark), width: 1) : null,
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Renkler.getSecondary(isDark).withOpacity(0.08),
                        Renkler.getSecondary(isDark).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Renkler.getSecondary(isDark).withOpacity(0.08),
                        Renkler.getSecondary(isDark).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(Tema.spacingLG),
                child: Column(
                  children: [
                    // Top bar - Level and flag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLevelBadge(widget.word.level, isDark),
                        _buildFlagBadge('🇬🇧', 'English', isDark),
                      ],
                    ),
                    const Spacer(flex: 2),
                    // Main word - Prominent (Micro-Hierarchy)
                    Text(
                      widget.word.word.toUpperCase(),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Renkler.getTextPrimary(isDark),
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Tema.spacingSM),
                    // Category - Subtle (Micro-Hierarchy)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Renkler.getSecondary(isDark).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(Tema.radiusSM),
                      ),
                      child: Text(
                        widget.word.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Renkler.getSecondary(isDark),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Definition box
                    _buildDefinitionBox(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: 'Definition',
                      content: widget.word.definition,
                      isDark: isDark,
                      isEnglish: true,
                    ),
                    const Spacer(flex: 2),
                    // Flip hint - Sade, dolgusuz
                    _buildFlipHint(isDark, 'Türkçe için çevir'),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ARKA YÜZ - TÜRKÇE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBackCard(BuildContext context, bool isDark) {
    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Renkler.getPrimary(isDark),
                Renkler.getPrimaryLight(isDark),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Tema.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Renkler.getPrimary(isDark).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft decorative circles
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(Tema.spacingLG),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLevelBadge(widget.word.level, isDark, isBack: true),
                        _buildFlagBadge('🇹🇷', 'Türkçe', isDark, isBack: true),
                      ],
                    ),
                    const Spacer(flex: 2),
                    // Turkish meaning - Prominent
                    Text(
                      widget.word.meaning.toUpperCase(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Renkler.backgroundDark : Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Definition in Turkish
                    _buildDefinitionBox(
                      context,
                      icon: Icons.translate_rounded,
                      title: 'Tanım',
                      content: widget.word.definitionTr,
                      isDark: isDark,
                      isEnglish: false,
                    ),
                    const SizedBox(height: Tema.spacingMD),
                    // Example sentence (Scratch to reveal)
                    _buildExampleBox(context, isDark),
                    const Spacer(flex: 2),
                    // Flip hint
                    _buildFlipHint(isDark, 'İngilizce için çevir', isBack: true),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildLevelBadge(String level, bool isDark, {bool isBack = false}) {
    Color bgColor;
    Color textColor;
    
    if (isBack) {
      bgColor = Colors.white.withOpacity(0.2);
      textColor = isDark ? Renkler.backgroundDark : Colors.white;
    } else {
      bgColor = _getLevelColor(level).withOpacity(0.12);
      textColor = _getLevelColor(level);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Tema.radiusMD),
        border: Border.all(
          color: isBack ? Colors.white.withOpacity(0.3) : textColor.withOpacity(0.2),
        ),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// ► SEVİYE RENKLERİ — Her CEFR seviyesi için farklı renk
  /// HEX kodlarını değiştirerek renkleri özelleştirebilirsin
  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1': return const Color(0xFF22C55E); // Yeşil (en kolay)
      case 'A2': return const Color(0xFF84CC16); // Açık yeşil
      case 'B1': return const Color(0xFFEAB308); // Sarı (orta)
      case 'B2': return const Color(0xFFF97316); // Turuncu
      case 'C1': return const Color(0xFFEF4444); // Kırmızı (zor)
      case 'C2': return const Color(0xFF9333EA); // Mor (en zor)
      default:   return Renkler.primary;
    }
  }

  Widget _buildFlagBadge(String flag, String label, bool isDark, {bool isBack = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isBack 
            ? Colors.white.withOpacity(0.15) 
            : Renkler.getSecondary(isDark).withOpacity(0.08),
        borderRadius: BorderRadius.circular(Tema.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isBack 
                  ? (isDark ? Renkler.backgroundDark.withOpacity(0.8) : Colors.white.withOpacity(0.9))
                  : Renkler.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String? content,
    required bool isDark,
    required bool isEnglish,
  }) {
    final hasContent = content != null && content.isNotEmpty;
    
    // İngilizce taraf için daha okunabilir renkler
    final englishBgColor = isDark 
        ? Renkler.cardDark.withOpacity(0.8)  // Dark mode'da daha belirgin
        : const Color(0xFFF5F8FC);              // Light mode'da hafif mavi-gri
    
    final englishBorderColor = isDark
        ? Renkler.cardBorderDark.withOpacity(0.6)
        : const Color(0xFFDDE5ED);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Tema.spacingMD),
      decoration: BoxDecoration(
        color: isEnglish
            ? englishBgColor
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(Tema.radiusMD),
        border: Border.all(
          color: isEnglish
              ? englishBorderColor
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isEnglish
                    ? Renkler.getTextSecondary(isDark)
                    : (isDark ? Renkler.backgroundDark.withOpacity(0.7) : Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isEnglish
                      ? Renkler.getTextSecondary(isDark)
                      : (isDark ? Renkler.backgroundDark.withOpacity(0.7) : Colors.white.withOpacity(0.7)),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasContent ? content : 'Henüz eklenmemiş',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              fontStyle: hasContent ? FontStyle.italic : FontStyle.normal,
              color: isEnglish
                  ? Renkler.getTextPrimary(isDark)
                  : (isDark 
                      ? (hasContent ? Renkler.backgroundDark.withOpacity(0.95) : Renkler.backgroundDark.withOpacity(0.5))
                      : (hasContent ? Colors.white : Colors.white.withOpacity(0.5))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleBox(BuildContext context, bool isDark) {
    final hasExample = widget.word.exampleSentence != null && 
                       widget.word.exampleSentence!.isNotEmpty;
    
    if (!hasExample) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isScratched = !_isScratched;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Tema.spacingMD),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(Tema.radiusMD),
          border: Border.all(
            color: _isScratched 
                ? Renkler.getSecondary(isDark) 
                : Colors.white.withOpacity(0.2),
            width: _isScratched ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: isDark ? Renkler.backgroundDark.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Example Sentence',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Renkler.backgroundDark.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // English sentence
            Text(
              widget.word.exampleSentence!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Renkler.backgroundDark : Colors.white,
              ),
            ),
            const SizedBox(height: Tema.spacingMD),
            // Scratch to reveal
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isScratched
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildScratchOverlay(isDark),
              secondChild: _buildRevealedTranslation(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Scratch overlay - Sade, dolgusuz görünüm
  Widget _buildScratchOverlay(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: Tema.spacingMD),
      decoration: BoxDecoration(
        color: Renkler.getTextSecondary(isDark).withOpacity(0.3),
        borderRadius: BorderRadius.circular(Tema.radiusSM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: isDark ? Renkler.backgroundDark.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Türkçe çeviri için dokun',
            style: TextStyle(
              color: isDark ? Renkler.backgroundDark.withOpacity(0.8) : Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedTranslation(bool isDark) {
    final translation = widget.word.exampleSentenceTr;
    final hasTranslation = translation != null && translation.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: Tema.spacingMD),
      decoration: BoxDecoration(
        color: Renkler.getSecondary(isDark).withOpacity(0.2),
        borderRadius: BorderRadius.circular(Tema.radiusSM),
        border: Border.all(
          color: Renkler.getSecondary(isDark).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.translate_rounded,
            color: Renkler.getSecondary(isDark),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasTranslation ? translation : 'Çeviri henüz eklenmemiş',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark 
                    ? (hasTranslation ? Renkler.backgroundDark.withOpacity(0.9) : Renkler.backgroundDark.withOpacity(0.5))
                    : (hasTranslation ? Colors.white.withOpacity(0.95) : Colors.white.withOpacity(0.5)),
                fontStyle: hasTranslation ? FontStyle.normal : FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Flip hint - Sade, dolgusuz
  Widget _buildFlipHint(bool isDark, String text, {bool isBack = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Tema.spacingMD, vertical: Tema.spacingSM),
      decoration: BoxDecoration(
        color: isBack 
            ? Colors.white.withOpacity(0.1) 
            : Renkler.getCardBorder(isDark).withOpacity(0.5),
        borderRadius: BorderRadius.circular(Tema.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe_rounded,
            size: 16,
            color: isBack 
                ? (isDark ? Renkler.backgroundDark.withOpacity(0.6) : Colors.white.withOpacity(0.6))
                : Renkler.getTextSecondary(isDark),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isBack 
                  ? (isDark ? Renkler.backgroundDark.withOpacity(0.6) : Colors.white.withOpacity(0.6))
                  : Renkler.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTION BUTTONS - Tekrar Et / Biliyorum (UX Focus)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Tekrar Et - Pastel kırmızı (canlı ama uyumlu)
        _ActionButton(
          icon: Icons.replay_rounded,
          label: 'Tekrar Et',
          color: Renkler.getError(isDark),
          onTap: widget.onReview,
        ),
        // Biliyorum - Pastel yeşil (canlı ama uyumlu)
        _ActionButton(
          icon: Icons.check_circle_outline_rounded,
          label: 'Biliyorum',
          color: Renkler.getSuccess(isDark),
          onTap: widget.onKnown,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(
          horizontal: Tema.spacingLG,
          vertical: Tema.spacingMD,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(Tema.buttonRadius),
          // Inner shadow effect when pressed
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white, size: 22),
            const SizedBox(width: Tema.spacingSM),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
