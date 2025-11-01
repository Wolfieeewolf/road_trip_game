import 'package:flutter/material.dart';

import '../styles/spacing.dart';

enum PlayerCardStyle {
  classic,
  numbered,
  sound,
  windmill,
}

class PlayerCard extends StatelessWidget {
  final String playerName;
  final int score;
  final PlayerCardStyle style;
  final Map<String, dynamic>? additionalInfo;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final List<Widget>? actions;
  final bool isActive;
  final VoidCallback? onTap;
  final String? avatarUrl;

  const PlayerCard({
    super.key,
    required this.playerName,
    required this.score,
    this.style = PlayerCardStyle.classic,
    this.additionalInfo,
    this.onIncrement,
    this.onDecrement,
    this.actions,
    this.isActive = true,
    this.onTap,
    this.avatarUrl,
  });

  Color _getStyleColor() {
    switch (style) {
      case PlayerCardStyle.classic:
        return Colors.blue;
      case PlayerCardStyle.numbered:
        return Colors.purple;
      case PlayerCardStyle.sound:
        return Colors.green;
      case PlayerCardStyle.windmill:
        return Colors.orange;
    }
  }

  IconData _getStyleIcon() {
    switch (style) {
      case PlayerCardStyle.classic:
        return Icons.directions_car;
      case PlayerCardStyle.numbered:
        return Icons.format_list_numbered;
      case PlayerCardStyle.sound:
        return Icons.volume_up;
      case PlayerCardStyle.windmill:
        return Icons.wind_power;
    }
  }

  Widget _buildAvatar() {
    if (avatarUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl!),
        radius: 24,
      );
    }

    return CircleAvatar(
      backgroundColor: _getStyleColor().withValues(alpha: 0.2),
      radius: 24,
      child: Text(
        playerName[0].toUpperCase(),
        style: TextStyle(
          color: _getStyleColor(),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    final color = _getStyleColor();

    switch (style) {
      case PlayerCardStyle.numbered:
        if (additionalInfo?['number'] != null) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tag,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  'Number: ${additionalInfo!['number']}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        break;

      case PlayerCardStyle.sound:
        if (additionalInfo?['sound'] != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      additionalInfo!['sound'],
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (additionalInfo?['object'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          additionalInfo!['object'],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }
        break;

      default:
        break;
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStyleColor();

    return Card(
      elevation: isActive ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: isActive ? 0.1 : 0.05),
                color.withValues(alpha: isActive ? 0.05 : 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player info row
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playerName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        _buildAdditionalInfo(),
                      ],
                    ),
                  ),
                  Icon(
                    _getStyleIcon(),
                    color: color.withValues(alpha: 0.5),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Score display
              Center(
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Score controls
              if (isActive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onDecrement != null)
                      _ScoreButton(
                        onPressed: onDecrement!,
                        icon: Icons.remove,
                        label: '-1',
                        color: color,
                      ),
                    if (onIncrement != null)
                      _ScoreButton(
                        onPressed: onIncrement!,
                        icon: Icons.add,
                        label: '+1',
                        color: color,
                      ),
                    ...?actions,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ScoreButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// Example usage:
/*
PlayerCard(
  playerName: 'John Doe',
  score: 42,
  style: PlayerCardStyle.sound,
  additionalInfo: {
    'sound': 'Beep',
    'object': 'Red Cars',
  },
  onIncrement: () {
    // Handle increment
  },
  onDecrement: () {
    // Handle decrement
  },
  actions: [
    IconButton(
      icon: Icon(Icons.volume_up),
      onPressed: () {
        // Play sound
      },
    ),
  ],
  isActive: true,
  onTap: () {
    // Handle tap
  },
  avatarUrl: 'https://example.com/avatar.jpg',
)
*/


