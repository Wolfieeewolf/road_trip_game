import 'package:flutter/material.dart';

import 'spacing.dart';

/// Standard card styling for consistent card appearance throughout the app.
///
/// Use these constants to ensure all cards have the same visual treatment.
///
/// ## Usage Examples:
/// ```dart
/// // Standard card with elevation
/// Card(
///   elevation: AppCardStyles.elevation,
///   shape: AppCardStyles.shape,
///   child: Padding(
///     padding: AppCardStyles.padding,
///     child: YourContent(),
///   ),
/// )
///
/// // Simple usage
/// Card(
///   child: Padding(
///     padding: AppCardStyles.padding,
///     child: YourContent(),
///   ),
/// )
/// ```
class AppCardStyles {
  AppCardStyles._();

  /// Standard card elevation (4.0) - Creates subtle shadow
  ///
  /// Use this instead of custom boxShadow for consistency
  static const double elevation = 4.0;

  /// Standard card border radius (16.0) - Modern, friendly feel
  static const double borderRadius = 16.0;

  /// Small border radius (8.0) - For nested elements or compact cards
  static const double borderRadiusSmall = 8.0;

  /// Standard card padding - 16px all around
  ///
  /// Most cards should use this for inner content padding
  static const EdgeInsets padding = EdgeInsets.all(Spacing.lg);

  /// Standard card margin - 8px vertical spacing
  ///
  /// Use between cards in a list
  static const EdgeInsets margin = EdgeInsets.symmetric(vertical: Spacing.sm);

  /// Get standard card shape with default border radius
  static RoundedRectangleBorder get shape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      );

  /// Get small card shape with reduced border radius
  ///
  /// Use for nested cards or more compact designs
  static RoundedRectangleBorder get shapeSmall => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      );
}
