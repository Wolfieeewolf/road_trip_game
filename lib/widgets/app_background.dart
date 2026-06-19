import 'package:flutter/material.dart';

import '../styles/app_theme.dart';

/// Soft mesh-style background used on hero screens.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  final Widget child;
  final bool showOrbs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppTheme.canvas),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showOrbs) ...[
            Positioned(
              top: -80,
              right: -40,
              child: _Orb(
                size: 220,
                color: AppTheme.seed.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 120,
              left: -60,
              child: _Orb(
                size: 180,
                color: AppTheme.accentViolet.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 24,
              child: _Orb(
                size: 140,
                color: AppTheme.accentCoral.withValues(alpha: 0.08),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class AppHeroHeader extends StatelessWidget {
  const AppHeroHeader({
    super.key,
    required this.child,
    this.height = 240,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: _Orb(
                size: 160,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: _Orb(
                size: 200,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
