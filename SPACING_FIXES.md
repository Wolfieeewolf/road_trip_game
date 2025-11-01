# Spacing Replacements Guide

## Common Replacements:
- `4` → `Spacing.xs`
- `6` → `Spacing.sm2`
- `8` → `Spacing.sm`
- `10` → `Spacing.md2`
- `12` → `Spacing.md`
- `14` → `Spacing.md3`
- `16` → `Spacing.lg`
- `20` → `Spacing.lg2`
- `24` → `Spacing.xl`
- `32` → `Spacing.xxl`

## Pattern Replacements:
### EdgeInsets.all()
- `EdgeInsets.all(4)` → `EdgeInsets.all(Spacing.xs)`
- `EdgeInsets.all(8)` → `EdgeInsets.all(Spacing.sm)`
- `EdgeInsets.all(12)` → `EdgeInsets.all(Spacing.md)`
- `EdgeInsets.all(16)` → `EdgeInsets.all(Spacing.lg)`
- `EdgeInsets.all(20)` → `EdgeInsets.all(Spacing.lg2)`
- `EdgeInsets.all(24)` → `EdgeInsets.all(Spacing.xl)`
- `EdgeInsets.all(32)` → `EdgeInsets.all(Spacing.xxl)`

### SizedBox
- `SizedBox(height: 4)` → `SizedBox(height: Spacing.xs)`
- `SizedBox(height: 8)` → `SizedBox(height: Spacing.sm)`
- `SizedBox(height: 12)` → `SizedBox(height: Spacing.md)`
- `SizedBox(height: 16)` → `SizedBox(height: Spacing.lg)`
- `SizedBox(height: 24)` → `SizedBox(height: Spacing.xl)`
- `SizedBox(height: 32)` → `SizedBox(height: Spacing.xxl)`

(Same for width)

### EdgeInsets.symmetric()
- `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` → `EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm)`
- etc.

Total fixes needed: 250+
