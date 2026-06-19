import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight game-feel effects: confetti bursts, bouncy taps,
/// score pops and staggered entrances. No external dependencies.
class GameFx {
  GameFx._();

  static final math.Random _random = math.Random();

  static bool _hapticsEnabled = true;
  static bool _hapticsPrefLoaded = false;

  /// Settings screen updates this when the vibration toggle changes.
  static set hapticsEnabled(bool value) {
    _hapticsEnabled = value;
    _hapticsPrefLoaded = true;
  }

  static void _haptic(Future<void> Function() fire) {
    if (!_hapticsPrefLoaded) {
      _hapticsPrefLoaded = true;
      SharedPreferences.getInstance().then((prefs) {
        _hapticsEnabled = prefs.getBool('vibrationEnabled') ?? true;
      });
    }
    if (_hapticsEnabled) fire();
  }

  /// Fires a full-screen confetti burst above everything.
  /// Optionally shows a short celebration message.
  static void celebrate(
    BuildContext context, {
    String? message,
    Color? color,
  }) {
    _haptic(HapticFeedback.mediumImpact);
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ConfettiOverlay(
        message: message,
        accent: color,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// Small floating "+1" style toast that drifts up and fades.
  static void scoreFloat(
    BuildContext context, {
    required String text,
    Color color = const Color(0xFF10B981),
  }) {
    _haptic(HapticFeedback.lightImpact);
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    final dx = 0.25 + _random.nextDouble() * 0.5;
    entry = OverlayEntry(
      builder: (_) => _ScoreFloat(
        text: text,
        color: color,
        horizontalFactor: dx,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

// ---------------------------------------------------------------------------
// Confetti

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay({
    required this.onDone,
    this.message,
    this.accent,
  });

  final VoidCallback onDone;
  final String? message;
  final Color? accent;

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  static const _palette = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _particles = List.generate(90, (_) {
      final colors =
          widget.accent != null ? [widget.accent!, ..._palette] : _palette;
      return _ConfettiParticle(
        color: colors[random.nextInt(colors.length)],
        startX: random.nextDouble(),
        // Burst from two side cannons plus a top sprinkle.
        kind: random.nextInt(3),
        velocity: 0.55 + random.nextDouble() * 0.85,
        drift: (random.nextDouble() - 0.5) * 0.7,
        size: 6 + random.nextDouble() * 7,
        spin: (random.nextDouble() - 0.5) * 14,
        shape: random.nextInt(3),
        delay: random.nextDouble() * 0.18,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              );
            },
          ),
          if (widget.message != null)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  // Pop in, hold, fade out.
                  final scale =
                      t < 0.15 ? Curves.easeOutBack.transform(t / 0.15) : 1.0;
                  final opacity =
                      t > 0.75 ? (1 - (t - 0.75) / 0.25).clamp(0.0, 1.0) : 1.0;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.message!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.kind,
    required this.velocity,
    required this.drift,
    required this.size,
    required this.spin,
    required this.shape,
    required this.delay,
  });

  final Color color;
  final double startX;
  final int kind; // 0 left cannon, 1 right cannon, 2 top sprinkle
  final double velocity;
  final double drift;
  final double size;
  final double spin;
  final int shape; // 0 rect, 1 circle, 2 strip
  final double delay;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      double x;
      double y;
      switch (p.kind) {
        case 0: // left cannon: shoots up-right then falls
          x = size.width * (0.05 + t * (0.25 + p.startX * 0.45));
          y = size.height * (0.85 - p.velocity * 1.5 * t + 1.3 * t * t);
        case 1: // right cannon
          x = size.width * (0.95 - t * (0.25 + p.startX * 0.45));
          y = size.height * (0.85 - p.velocity * 1.5 * t + 1.3 * t * t);
        default: // top sprinkle
          x = size.width * (p.startX + p.drift * t);
          y = size.height * (-0.05 + (p.velocity + 0.4) * t);
      }

      final fade = t > 0.8 ? (1 - (t - 0.8) / 0.2) : 1.0;
      paint.color = p.color.withValues(alpha: fade.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      switch (p.shape) {
        case 0:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size * 0.65,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
        default:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 0.4,
                height: p.size * 1.4,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// Floating score text

class _ScoreFloat extends StatefulWidget {
  const _ScoreFloat({
    required this.text,
    required this.color,
    required this.horizontalFactor,
    required this.onDone,
  });

  final String text;
  final Color color;
  final double horizontalFactor;
  final VoidCallback onDone;

  @override
  State<_ScoreFloat> createState() => _ScoreFloatState();
}

class _ScoreFloatState extends State<_ScoreFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return IgnorePointer(
      // Positioned needs an enclosing Stack; the overlay itself doesn't
      // provide one for this subtree.
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_controller.value);
              final opacity = _controller.value > 0.6
                  ? (1 - (_controller.value - 0.6) / 0.4)
                  : 1.0;
              final scale = _controller.value < 0.2
                  ? Curves.easeOutBack.transform(_controller.value / 0.2)
                  : 1.0;
              return Positioned(
                left: size.width * widget.horizontalFactor - 40,
                top: size.height * 0.55 - t * 140,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouncy tap wrapper

/// Wraps any widget and gives it a springy press-down/release animation.
class BouncyTap extends StatefulWidget {
  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 240),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _controller.forward();

  void _up(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _cancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : _down,
      onTapUp: widget.onTap == null ? null : _up,
      onTapCancel: widget.onTap == null ? null : _cancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 -
              (1 - widget.pressedScale) *
                  Curves.easeOut.transform(_controller.value);
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score pop counter

/// Displays a number that pops (scale-pulse) every time it changes.
class ScorePop extends StatefulWidget {
  const ScorePop({
    super.key,
    required this.value,
    this.style,
    this.popColor,
  });

  final int value;
  final TextStyle? style;
  final Color? popColor;

  @override
  State<ScorePop> createState() => _ScorePopState();
}

class _ScorePopState extends State<ScorePop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(ScorePop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Quick pop up to ~1.45x then settle with a slight overshoot.
        final scale = 1 + 0.45 * math.sin(t * math.pi) * (1 - t * 0.4);
        final baseStyle = widget.style ?? const TextStyle();
        final color = t > 0 && t < 1 && widget.popColor != null
            ? Color.lerp(widget.popColor, baseStyle.color, t)
            : baseStyle.color;
        return Transform.scale(
          scale: scale,
          child: Text(
            '${widget.value}',
            style: baseStyle.copyWith(color: color),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Staggered entrance

/// Fades + slides its child in once, after [delay]. Use with a per-item
/// delay for staggered list/grid entrances.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offset = const Offset(0, 0.12),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing attention widget (e.g. BINGO badge)

/// Continuously pulses its child — use sparingly for win states.
class PulseGlow extends StatefulWidget {
  const PulseGlow({super.key, required this.child});

  final Widget child;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(scale: 1 + t * 0.08, child: child);
      },
      child: widget.child,
    );
  }
}
