import 'package:flutter/material.dart';

import '../styles/app_theme.dart';
import '../styles/spacing.dart';
import 'game_fx.dart';

/// Shared "gamified" chrome for in-game screens: a bold gradient header in
/// the game's signature colour, chunky 3D buttons and playful player tiles.
/// Inspired by arcade mobile games while keeping the game rules untouched.

Color _darken(Color color, [double amount = 0.25]) =>
    Color.lerp(color, Colors.black, amount)!;

Color _lighten(Color color, [double amount = 0.2]) =>
    Color.lerp(color, Colors.white, amount)!;

/// Scaffold replacement for game screens.
class GameShell extends StatelessWidget {
  const GameShell({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.body,
    this.subtitle,
    this.onHelp,
    this.actions = const [],
    this.floatingActionButton,
    this.headerExtra,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final Widget body;
  final VoidCallback? onHelp;

  /// Extra circular header buttons shown before the help button.
  final List<Widget> actions;
  final Widget? floatingActionButton;

  /// Optional widget rendered inside the header below the title row
  /// (e.g. a live scoreboard strip).
  final Widget? headerExtra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          _GameHeader(
            title: title,
            subtitle: subtitle,
            color: color,
            icon: icon,
            onHelp: onHelp,
            actions: actions,
            extra: headerExtra,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.title,
    required this.color,
    required this.icon,
    this.subtitle,
    this.onHelp,
    this.actions = const [],
    this.extra,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onHelp;
  final List<Widget> actions;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        topPadding + Spacing.sm,
        Spacing.lg,
        Spacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_lighten(color, 0.08), color, _darken(color, 0.25)],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Big watermark icon for depth.
            Positioned(
              right: -28,
              top: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GameHeaderButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    for (final action in actions) ...[
                      action,
                      const SizedBox(width: Spacing.sm),
                    ],
                    if (onHelp != null)
                      GameHeaderButton(
                        icon: Icons.help_outline_rounded,
                        onTap: onHelp!,
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (extra != null) ...[
                  const SizedBox(height: Spacing.md),
                  extra!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular translucent button used in the game header.
class GameHeaderButton extends StatelessWidget {
  const GameHeaderButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

/// Chunky arcade-style button with a solid "3D" bottom edge that presses
/// down when tapped (Crossy Road style).
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.color,
    required this.onTap,
    required this.child,
    this.depth = 5,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final double depth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final edge = _darken(widget.color, 0.35);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        margin: EdgeInsets.only(
          top: _pressed ? widget.depth : 0,
          bottom: _pressed ? 0 : widget.depth,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: edge,
              offset: Offset(0, _pressed ? 1 : widget.depth),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// White panel with a chunky tinted bottom edge — the standard surface
/// for in-game content.
class GamePanel extends StatelessWidget {
  const GamePanel({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.margin,
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final edge = accent?.withValues(alpha: 0.25) ??
        Theme.of(context).colorScheme.outlineVariant;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: edge, offset: const Offset(0, 4)),
          ...AppTheme.softShadow(),
        ],
      ),
      // ListTiles and ink splashes paint on the nearest Material; provide a
      // transparent one so the decorated background doesn't hide them.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Section heading inside a game screen: coloured icon bubble + bold title.
class GameSectionTitle extends StatelessWidget {
  const GameSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Player tile with rank medal, gradient avatar and popping score chip.
class GamePlayerTile extends StatelessWidget {
  const GamePlayerTile({
    super.key,
    required this.name,
    required this.score,
    required this.color,
    this.rank,
    this.isLeader = false,
    this.subtitle,
    this.scoreSuffix,
    this.avatar,
    this.trailing,
  });

  final String name;
  final int score;
  final Color color;

  /// 1-based rank; ranks 1-3 get medal colours.
  final int? rank;
  final bool isLeader;
  final String? subtitle;
  final String? scoreSuffix;

  /// Replaces the default initial-letter avatar (e.g. a colour dot).
  final Widget? avatar;
  final Widget? trailing;

  static const _medalColors = [
    Color(0xFFFFC107), // gold
    Color(0xFFB0BEC5), // silver
    Color(0xFFBF8970), // bronze
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medal = rank != null && rank! >= 1 && rank! <= 3
        ? _medalColors[rank! - 1]
        : null;

    return GamePanel(
      accent: isLeader ? const Color(0xFFFFC107) : color,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm2,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              avatar ??
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_lighten(color, 0.15), _darken(color, 0.15)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
              if (isLeader)
                const Positioned(
                  top: -10,
                  right: -4,
                  child: Text('👑', style: TextStyle(fontSize: 16)),
                ),
              if (medal != null)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: medal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: Spacing.sm),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, _darken(color, 0.2)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScorePop(
                  value: score,
                  popColor: Colors.amber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (scoreSuffix != null)
                  Text(
                    scoreSuffix!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanding "how to play" card with a friendly look.
class GameRulesCard extends StatelessWidget {
  const GameRulesCard({
    super.key,
    required this.visible,
    required this.color,
    required this.rules,
  });

  final bool visible;
  final Color color;
  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : GamePanel(
              accent: color,
              margin: const EdgeInsets.only(bottom: Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameSectionTitle(
                    icon: Icons.menu_book_rounded,
                    title: 'How to play',
                    color: color,
                  ),
                  const SizedBox(height: Spacing.md),
                  ...rules.map(
                    (rule) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 18, color: color),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              rule,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
