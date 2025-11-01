import 'package:flutter/material.dart';

import 'spacing.dart';

/// Standard button styles for consistent button appearance throughout the app.
///
/// Use these styles to maintain visual consistency across all buttons:
/// ```dart
/// ElevatedButton(
///   style: AppButtonStyles.primary,
///   onPressed: () {},
///   child: Text('Click me'),
/// )
/// ```
class AppButtonStyles {
  AppButtonStyles._();

  /// Primary elevated button style
  static ButtonStyle primary = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.xl,
      vertical: Spacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  /// Secondary outlined button style
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.xl,
      vertical: Spacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  /// Text button style
  static ButtonStyle text = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.lg,
      vertical: Spacing.sm,
    ),
  );

  /// Large button style (full-width or prominent CTAs)
  static ButtonStyle large = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.xl,
      vertical: Spacing.lg,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    minimumSize: const Size.fromHeight(56),
  );

  /// Small compact button style
  static ButtonStyle small = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.md,
      vertical: Spacing.sm,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  /// Icon button with circular background
  static ButtonStyle iconCircular = ElevatedButton.styleFrom(
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(Spacing.md),
  );

  /// Floating action button extended style
  static ButtonStyle fabExtended = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.lg,
      vertical: Spacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
