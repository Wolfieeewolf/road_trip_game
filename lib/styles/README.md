# Road Trip Game Design System

This directory contains the complete design system for the Road Trip Game Flutter app. Use these files to ensure visual consistency and maintainability across the entire application.

## 📂 Files Overview

### `game_colors.dart`
Game-specific color palette with unique colors for each of the 6 games.

**When to use:**
- Game screen AppBars
- Game-specific buttons and accents
- Score badges and highlights

**Example:**
```dart
AppBar(
  backgroundColor: GameColors.primaryColors['soundSpy'],
  title: Text('Sound Spy'),
)
```

### `spacing.dart`
Complete spacing scale from 2px to 32px for consistent layout spacing.

**When to use:**
- **Instead of:** `SizedBox(height: 16)`
- **Use:** `SizedBox(height: Spacing.lg)`
- All padding and margin values
- Widget spacing in rows and columns

**Common values:**
- `Spacing.lg` (16px) - **Most common** - Default padding
- `Spacing.md` (12px) - Internal card spacing
- `Spacing.sm` (8px) - Tight spacing
- `Spacing.xl` (24px) - Section spacing
- `Spacing.xxl` (32px) - Page-level spacing

**Example:**
```dart
Padding(
  padding: EdgeInsets.all(Spacing.lg),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: Spacing.md),
      Text('Content'),
    ],
  ),
)
```

### `text_styles.dart`
Typographic hierarchy for all text in the app.

**When to use:**
- **Instead of:** `TextStyle(fontSize: 18, fontWeight: FontWeight.bold)`
- **Use:** `AppTextStyles.heading`
- All text that needs specific styling

**Common styles:**
- `AppTextStyles.title` - Page titles (24px, bold)
- `AppTextStyles.heading` - Section headers (18px, bold)
- `AppTextStyles.body` - Regular content (14px)
- `AppTextStyles.caption` - Helper text (12px, grey)

**Example:**
```dart
Text('Game Statistics', style: AppTextStyles.heading)
Text('Description here', style: AppTextStyles.body)
```

### `card_styles.dart`
Standard card styling constants and shapes.

**When to use:**
- All Card widgets
- Consistent elevation and border radius
- Standard padding and margins

**Example:**
```dart
Card(
  elevation: AppCardStyles.elevation,
  shape: AppCardStyles.shape,
  child: Padding(
    padding: AppCardStyles.padding,
    child: YourContent(),
  ),
)
```

### `button_styles.dart`
Pre-defined button styles for common use cases.

**When to use:**
- Primary action buttons
- Secondary/outlined buttons
- Icon buttons
- Large call-to-action buttons

**Example:**
```dart
ElevatedButton(
  style: AppButtonStyles.primary,
  onPressed: () {},
  child: Text('Start Game'),
)
```

## 🎨 Design Principles

### Consistency
- **Use constants, not magic numbers**: Replace all hardcoded values
- **One source of truth**: All design decisions in this folder
- **Easy updates**: Change once, update everywhere

### Hierarchy
- **Visual levels**: Use spacing and text styles to create clear hierarchy
- **Importance**: Larger spacing = more important separation
- **Readability**: Consistent text styles improve comprehension

### Maintainability
- **Well-documented**: Every constant has clear documentation
- **Examples included**: Copy-paste-ready code snippets
- **Type-safe**: Use constants, get autocomplete and compile-time checking

## 🚀 Quick Start

### 1. Import what you need
```dart
import '../styles/spacing.dart';
import '../styles/game_colors.dart';
import '../styles/text_styles.dart';
```

### 2. Replace hardcoded values
**Before:**
```dart
SizedBox(height: 16)
EdgeInsets.all(12)
TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
```

**After:**
```dart
SizedBox(height: Spacing.lg)
EdgeInsets.all(Spacing.md)
AppTextStyles.heading
```

### 3. Use game colors for game screens
```dart
// Game-specific theming
final gameColor = GameColors.primaryColors['numberPlateMatch']!;

AppBar(
  backgroundColor: gameColor,
  foregroundColor: Colors.white,
)
```

## 📏 Spacing Scale Reference

| Constant | Size | Use Case |
|----------|------|----------|
| `Spacing.xxs` | 2px | Borders, very tight spacing |
| `Spacing.xs` | 4px | Icon-text gaps, tight spacing |
| `Spacing.sm2` | 6px | Grid spacing |
| `Spacing.sm` | 8px | Related elements |
| `Spacing.md2` | 10px | Intermediate spacing |
| `Spacing.md` | 12px | Card internal spacing |
| `Spacing.md3` | 14px | Intermediate spacing |
| `Spacing.lg` | 16px | **Default padding** ⭐ |
| `Spacing.lg2` | 20px | Generous spacing |
| `Spacing.xl` | 24px | Section separation |
| `Spacing.xxl` | 32px | Page-level spacing |

## 🎮 Game Colors Reference

| Game | Color | Hex | Theme |
|------|-------|-----|-------|
| Number Plate Match | Purple | `#7C4DFF` | Strategic, focused |
| Sound Spy | Green | `#4CAF50` | Playful, active |
| Windmill | Orange | `#FFB74D` | Energetic, outdoor |
| Colour Chase | Indigo | `#3F51B5` | Vibrant, colorful |
| Sign Scramble | Teal | `#009688` | Observant, road |
| Road Trip Bingo | Pink | `#E040FB` | Fun, classic |

## ✅ Benefits

### For Developers
- ✅ Faster development (no guessing values)
- ✅ Autocomplete support
- ✅ Compile-time safety
- ✅ Easy refactoring

### For Designers
- ✅ Consistent visual language
- ✅ Easy to update designs
- ✅ Clear design documentation

### For Users
- ✅ Professional, polished UI
- ✅ Consistent experience
- ✅ Better accessibility

## 🔄 Making Changes

### Adding a new spacing value
1. Add to `spacing.dart` with clear documentation
2. Use descriptive naming (xs, sm, md, lg, xl, xxl)
3. Update this README with the new value

### Adding a new game color
1. Add to `game_colors.dart` primaryColors map
2. Use descriptive color name and comment
3. Update game colors reference table

### Adding a new text style
1. Add to `text_styles.dart` with size and weight
2. Document the use case clearly
3. Update text styles hierarchy docs

## 📚 Additional Resources

- [Flutter Material Design](https://material.io/design)
- [Flutter Design Patterns](https://flutter.dev/docs/cookbook)
- [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

---

**Last Updated:** 2025
**Maintainer:** Road Trip Game Team
