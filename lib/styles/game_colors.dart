import 'package:flutter/material.dart';

/// Game-specific color palette for consistent theming across all game screens.
///
/// Each game has a unique primary color that's used for AppBars, buttons, and accents.
/// This ensures visual distinction between different games while maintaining consistency.
///
/// Example usage:
/// ```dart
/// Container(
///   color: GameColors.primaryColors['soundSpy'],
///   child: Text('Sound Spy Game'),
/// )
/// ```
class GameColors {
  GameColors._();

  /// Primary colors for each game type.
  ///
  /// Each color has been carefully selected to:
  /// - Be visually distinct from other games
  /// - Have good contrast with white text
  /// - Match the game's theme and feel
  static const Map<String, Color> primaryColors = {
    'numberPlateMatch': Color(0xFF7C4DFF), // Purple - Strategic, focused
    'soundSpy': Color(0xFF4CAF50), // Green - Playful, active
    'windmill': Color(0xFFFFB74D), // Orange - Energetic, outdoor
    'colorChase': Color(0xFF3F51B5), // Indigo - Vibrant, colorful
    'signScramble': Color(0xFF009688), // Teal - Observant, road-focused
    'roadTripBingo': Color(0xFFE040FB), // Pink - Fun, classic game
  };

  /// Get primary color for a specific game ID.
  ///
  /// Returns the color if found, null otherwise.
  /// Consider using the map directly with null-checking for better type safety.
  static Color? getGameColor(String gameId) {
    return primaryColors[gameId];
  }
}
