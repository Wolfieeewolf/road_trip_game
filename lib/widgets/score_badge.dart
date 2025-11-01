import 'package:flutter/material.dart';

import '../styles/spacing.dart';

/// Reusable score badge widget for displaying player scores consistently.
///
/// Example:
/// ```dart
/// ScoreBadge(
///   score: 42,
///   label: 'Score',
///   backgroundColor: Colors.purple,
/// )
/// ```
class ScoreBadge extends StatelessWidget {
  final int score;
  final String? label;
  final Color? backgroundColor;
  final Color? textColor;

  const ScoreBadge({
    super.key,
    required this.score,
    this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final fgColor = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            '$score',
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
