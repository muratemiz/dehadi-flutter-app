import 'package:flutter/material.dart';
import '../cekirdek/sabitler/uygulama_renkleri.dart';

/// Kenarında dönen ışık efekti olan kart
class AnimatedGlowCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double glowWidth;
  final Duration duration;
  final bool enabled;

  const AnimatedGlowCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.glowWidth = 2,
    this.duration = const Duration(seconds: 3),
    this.enabled = true,
  });

  @override
  State<AnimatedGlowCard> createState() => _AnimatedGlowCardState();
}

class _AnimatedGlowCardState extends State<AnimatedGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedGlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius + widget.glowWidth),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0,
              endAngle: 6.28,
              transform: GradientRotation(_controller.value * 6.28),
              colors: isDark
                  ? [
                      Renkler.primaryDarkTheme.withOpacity(0.6),
                      Renkler.secondaryDarkTheme.withOpacity(0.6),
                      Renkler.accentDarkTheme.withOpacity(0.6),
                      Renkler.primaryDarkTheme.withOpacity(0.6),
                    ]
                  : [
                      Renkler.primary.withOpacity(0.5),
                      Renkler.secondary.withOpacity(0.5),
                      Renkler.accent.withOpacity(0.5),
                      Renkler.primary.withOpacity(0.5),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Renkler.primaryDarkTheme : Renkler.primary)
                    .withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: EdgeInsets.all(widget.glowWidth),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: widget.child,
      ),
    );
  }
}

/// Soft glow efektli buton
class GlowButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsets padding;
  final bool outlined;

  const GlowButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.outlined = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Renkler.getPrimary(isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius + 2),
              gradient: widget.outlined
                  ? SweepGradient(
                      center: Alignment.center,
                      transform: GradientRotation(_controller.value * 6.28),
                      colors: [
                        primaryColor.withOpacity(_isHovered ? 0.8 : 0.4),
                        Renkler.getSecondary(isDark).withOpacity(_isHovered ? 0.8 : 0.4),
                        Renkler.getAccent(isDark).withOpacity(_isHovered ? 0.8 : 0.4),
                        primaryColor.withOpacity(_isHovered ? 0.8 : 0.4),
                      ],
                    )
                  : null,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            padding: widget.outlined ? const EdgeInsets.all(2) : null,
            child: child,
          );
        },
        child: Material(
          color: widget.outlined
              ? (isDark ? Renkler.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.outlined
                    ? null
                    : LinearGradient(
                        colors: [
                          primaryColor.withOpacity(_isHovered ? 1.0 : 0.9),
                          Renkler.getSecondary(isDark).withOpacity(_isHovered ? 1.0 : 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft glass efektli kart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark 
            ? Renkler.cardDark.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? 
              (isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Renkler.primary.withOpacity(0.1)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Renkler.primary).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
