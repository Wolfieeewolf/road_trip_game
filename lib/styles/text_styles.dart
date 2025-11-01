import 'package:flutter/material.dart';

/// Standard text styles for consistent typography throughout the app.
///
/// These styles define the typographic hierarchy and should be used instead of
/// hardcoded TextStyle values.
///
/// ## Usage Examples:
/// ```dart
/// Text('Game Title', style: AppTextStyles.title)
/// Text('Section Heading', style: AppTextStyles.heading)
/// Text('Body content here', style: AppTextStyles.body)
/// ```
///
/// ## Style Hierarchy:
/// - **title**: Page titles, major headings (24px, bold)
/// - **heading**: Section headings (18px, bold)
/// - **subheading**: Sub-sections (16px, semi-bold)
/// - **body**: Regular content (14px)
/// - **caption**: Helper text, metadata (12px, grey)
/// - **label**: Form labels, tags (12px, medium)
///
/// ## Game-Specific:
/// - **score**: Large score displays (24px, bold)
/// - **playerName**: Player identifiers (18px, bold)
class AppTextStyles {
  AppTextStyles._();

  /// Large title text (24px, bold) - Page titles, major headings
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// Section heading text (18px, bold) - Section headers, card titles
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Subheading text (16px, semi-bold) - Sub-sections, important labels
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Regular body text (14px) - Main content, descriptions
  static const TextStyle body = TextStyle(
    fontSize: 14,
  );

  /// Small caption text (12px, grey) - Helper text, timestamps, metadata
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  /// Label text (12px, medium weight) - Form labels, tags, chips
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// Score display text (24px, bold) - Large score numbers in games
  static const TextStyle score = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// Player name text (18px, bold) - Player identifiers, user names
  static const TextStyle playerName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Button text (14px, semi-bold) - Button labels (use with button widgets)
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
