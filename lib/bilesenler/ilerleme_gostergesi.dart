import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../cekirdek/sabitler/uygulama_renkleri.dart';

/// ─── DAİRESEL İLERLEME GÖSTERGESİ ───
/// Yüzdelik ilerlemeyi daire şeklinde gösterir.
/// ► BOYUT: radius parametresi (varsayılan: 60)
/// ► ÇİZGİ KALINLIĞI: lineWidth parametresi (varsayılan: 10)
/// ► ANİMASYON SÜRESİ: animationDuration (varsayılan: 800ms)
class IlerlemeGostergesi extends StatelessWidget {
  final double progress;
  final String? label;
  final double radius;
  final double lineWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? center;

  const IlerlemeGostergesi({
    super.key,
    required this.progress,
    this.label,
    this.radius = 60,
    this.lineWidth = 10,
    this.progressColor,
    this.backgroundColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: progress.clamp(0.0, 1.0),
      center: center ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Renkler.textPrimaryDark
                          : Renkler.textPrimaryLight,
                    ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Renkler.textSecondaryDark
                            : Renkler.textSecondaryLight,
                      ),
                ),
            ],
          ),
      progressColor: progressColor ?? Renkler.secondary,
      backgroundColor:
          backgroundColor ?? (isDark ? Renkler.surfaceDark : Colors.grey[200]!),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 800,
    );
  }
}

/// ─── DOĞRUSAL İLERLEME ÇUBUĞU ───
/// Yatay çubuk şeklinde ilerleme gösterir.
/// ► YÜKSEK: height parametresi (varsayılan: 8)
/// ► YÜZDE GÖSTER/GİZLE: showPercentage parametresi
class DogrusalIlerleme extends StatelessWidget {
  final double progress;
  final String? label;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;

  const DogrusalIlerleme({
    super.key,
    required this.progress,
    this.label,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                if (showPercentage)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: progressColor ?? Renkler.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: height,
          percent: progress.clamp(0.0, 1.0),
          progressColor: progressColor ?? Renkler.secondary,
          backgroundColor:
              backgroundColor ?? (isDark ? Renkler.surfaceDark : Colors.grey[200]!),
          barRadius: Radius.circular(height / 2),
          animation: true,
          animationDuration: 800,
        ),
      ],
    );
  }
}
