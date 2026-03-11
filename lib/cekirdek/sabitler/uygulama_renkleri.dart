import 'package:flutter/material.dart';

class Renkler {
  // ══════════════════════════════════════════════
  // FASIH TARZI — Mavi gradient + beyaz kartlar
  // ══════════════════════════════════════════════

  // ► ANA RENK — Derin lacivert
  static const Color primary = Color(0xFF1B3B5A);
  static const Color primaryLight = Color(0xFF2D6EB5);
  static const Color primaryDark = Color(0xFF122842);

  // ► BUTON / CTA RENGİ — Parlak mavi
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2563EB);

  // ► VURGU — Mor (progress, rozetler)
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentDark = Color(0xFF7C3AED);

  // ► TEAL — Seviyeler, eşleştirme
  static const Color teal = Color(0xFF06B6D4);
  static const Color tealLight = Color(0xFF22D3EE);

  // ► BAŞARI
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);

  // ► HATA
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // ► UYARI / SERİ
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);

  // ► LIGHT TEMA — Açık mavi arka plan + beyaz kartlar
  static const Color backgroundLight = Color(0xFFF0F5FF);
  static const Color surfaceLight = Color(0xFFE8EFFA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // ► DARK TEMA
  static const Color primaryDarkTheme = Color(0xFF60A5FA);
  static const Color primaryLightDarkTheme = Color(0xFF93C5FD);

  static const Color secondaryDarkTheme = Color(0xFF60A5FA);
  static const Color secondaryLightDarkTheme = Color(0xFF93C5FD);

  static const Color accentDarkTheme = Color(0xFFA78BFA);
  static const Color accentLightDarkTheme = Color(0xFFC4B5FD);

  static const Color tealDarkTheme = Color(0xFF22D3EE);

  static const Color successDarkTheme = Color(0xFF4ADE80);
  static const Color errorDarkTheme = Color(0xFFF87171);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardBorderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ► CAM EFEKTİ
  static Color getGlassColor(bool isDark) => isDark
      ? const Color(0xFF1E293B).withOpacity(0.92)
      : const Color(0xFFFFFFFF).withOpacity(0.92);

  static Color getGlassBorder(bool isDark) => isDark
      ? const Color(0xFF334155).withOpacity(0.5)
      : const Color(0xFFCBD5E1).withOpacity(0.5);

  // ► BUTON RENKLERİ
  static Color getErrorButton(bool isDark) => isDark ? errorDarkTheme : error;
  static Color getSuccessButton(bool isDark) => isDark ? successDarkTheme : success;

  // ══════════════════════════════════════════════
  // GRADİENTLER — Fasih tarzı mavi geçişler
  // ══════════════════════════════════════════════

  // Ana gradient — header, büyük alanlar
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1B3B5A), Color(0xFF2D6EB5), Color(0xFF5BA3D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A5F), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // CTA gradient — butonlar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // İkincil gradient — progress bar'lar
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradientDark = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Pastel gradient — dekoratif
  static const LinearGradient pastelGradient = LinearGradient(
    colors: [Color(0xFF1B3B5A), Color(0xFF2D6EB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pastelGradientDark = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF0F5FF), Color(0xFFE8EFFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ► YARDIMCI METODLAR
  static Color getPrimary(bool isDark) => isDark ? primaryDarkTheme : primary;
  static Color getPrimaryLight(bool isDark) => isDark ? primaryLightDarkTheme : primaryLight;
  static Color getSecondary(bool isDark) => isDark ? secondaryDarkTheme : secondary;
  static Color getAccent(bool isDark) => isDark ? accentDarkTheme : accent;
  static Color getPurple(bool isDark) => isDark ? accentDarkTheme : accent;
  static Color getTeal(bool isDark) => isDark ? tealDarkTheme : teal;
  static Color getSuccess(bool isDark) => isDark ? successDarkTheme : success;
  static Color getError(bool isDark) => isDark ? errorDarkTheme : error;
  static Color getBackground(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color getSurface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color getCard(bool isDark) => isDark ? cardDark : cardLight;
  static Color getCardBorder(bool isDark) => isDark ? cardBorderDark : cardBorderLight;
  static Color getTextPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getTextSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;

  static Color getCardBlue(bool isDark) => isDark ? secondaryDarkTheme.withOpacity(0.15) : secondary.withOpacity(0.1);

  static LinearGradient getHeaderGradient(bool isDark) =>
      isDark ? headerGradientDark : headerGradient;
  static LinearGradient getPrimaryGradient(bool isDark) =>
      isDark ? primaryGradientDark : primaryGradient;
  static LinearGradient getSecondaryGradient(bool isDark) =>
      isDark ? secondaryGradientDark : secondaryGradient;
  static LinearGradient getBackgroundGradient(bool isDark) =>
      isDark ? backgroundGradientDark : backgroundGradientLight;
  static LinearGradient getPastelGradient(bool isDark) =>
      isDark ? pastelGradientDark : pastelGradient;
}
