/// Standard spacing constants for consistent UI spacing throughout the app.
///
/// These constants replace hardcoded numeric values to ensure visual consistency
/// and make it easy to adjust spacing app-wide.
///
/// ## Usage Examples:
/// ```dart
/// // Vertical spacing between elements
/// SizedBox(height: Spacing.md)
///
/// // Padding around content
/// EdgeInsets.all(Spacing.lg)
///
/// // Symmetric padding
/// EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.md)
/// ```
///
/// ## Spacing Scale Philosophy:
/// - **xs to sm**: Tight spacing within components (icons, labels)
/// - **md to lg**: Standard spacing between related elements
/// - **xl to xxl**: Large spacing between sections or major UI blocks
class Spacing {
  Spacing._();

  /// Tiny spacing (2px) - For very tight spacing, borders, or subtle separations
  static const double xxs = 2;

  /// Extra small spacing (4px) - Tight spacing within components
  static const double xs = 4;

  /// Small-2 spacing (6px) - Intermediate tight spacing
  static const double sm2 = 6;

  /// Small spacing (8px) - Compact spacing between related elements
  static const double sm = 8;

  /// Medium-2 spacing (10px) - Intermediate spacing
  static const double md2 = 10;

  /// Medium spacing (12px) - Standard spacing within cards and containers
  static const double md = 12;

  /// Medium-3 spacing (14px) - Intermediate spacing
  static const double md3 = 14;

  /// Large spacing (16px) - **Most common** - Default padding for most UI elements
  static const double lg = 16;

  /// Large-2 spacing (20px) - Generous spacing for comfortable layouts
  static const double lg2 = 20;

  /// Extra large spacing (24px) - Section spacing, major element separation
  static const double xl = 24;

  /// Extra extra large spacing (32px) - Page-level spacing, major sections
  static const double xxl = 32;
}

