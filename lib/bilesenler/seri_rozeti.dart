import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cekirdek/sabitler/uygulama_renkleri.dart';

/// ─── SERİ ROZETİ ───
/// Günlük giriş serisini gösteren büyük rozet bileşeni.
/// Seri uzunluğuna göre renk ve ikon değişir:
///   30+ gün = Altın, 14+ gün = Gümüş, 7+ gün = Bronz
/// ► EŞİKLERİ DEĞİŞTİR: _badgeColor ve _badgeIcon getter'larındaki sayıları değiştir
class SeriRozeti extends StatelessWidget {
  final int streak;
  final bool isActiveToday;
  final bool showAnimation;

  const SeriRozeti({
    super.key,
    required this.streak,
    this.isActiveToday = false,
    this.showAnimation = true,
  });

  Color get _badgeColor {
    if (streak >= 30) return const Color(0xFFFFD700); // Gold
    if (streak >= 14) return const Color(0xFFC0C0C0); // Silver
    if (streak >= 7) return const Color(0xFFCD7F32); // Bronze
    return Renkler.secondary;
  }

  IconData get _badgeIcon {
    if (streak >= 30) return Icons.military_tech;
    if (streak >= 14) return Icons.star;
    if (streak >= 7) return Icons.local_fire_department;
    return Icons.bolt;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _badgeColor.withOpacity(0.2),
            _badgeColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _badgeColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isActiveToday
            ? [
                BoxShadow(
                  color: _badgeColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _badgeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _badgeIcon,
              color: _badgeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$streak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Renkler.textPrimaryDark
                      : Renkler.textPrimaryLight,
                ),
              ),
              Text(
                'Günlük Seri',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Renkler.textSecondaryDark
                      : Renkler.textSecondaryLight,
                ),
              ),
            ],
          ),
          if (isActiveToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Renkler.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Renkler.success,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Bugün',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Renkler.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (showAnimation && isActiveToday) {
      badge = badge.animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 2000.ms,
            color: _badgeColor.withOpacity(0.3),
          );
    }

    return badge;
  }
}

/// ─── MİNİ SERİ ROZETİ ───
/// App bar'da sağ üstte gösterilen küçük seri rozeti.
/// ► ALEV RENGİ: flameOrange rengini değiştirerek rozet rengini özelleştir
class MiniSeriRozeti extends StatelessWidget {
  final int streak;
  final bool isActiveToday;

  const MiniSeriRozeti({
    super.key,
    required this.streak,
    this.isActiveToday = false,
  });

  // ► ALEV RENGİ — Bu rengi değiştirerek mini rozet rengini özelleştirebilirsin
  static const Color flameOrange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: flameOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: flameOrange.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: flameOrange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: flameOrange,
            ),
          ),
        ],
      ),
    );
  }
}
