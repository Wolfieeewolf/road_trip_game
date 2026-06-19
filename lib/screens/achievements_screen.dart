import 'package:flutter/material.dart';

import '../styles/app_theme.dart';
import '../styles/spacing.dart';
import '../widgets/game_fx.dart';
import '../widgets/game_shell.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;
  final Map<String, List<Achievement>> _achievements = {};
  int _totalPoints = 0;
  String _currentRank = 'Rookie Traveler';

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    // Simulate loading from storage
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      // Removed Number Plate Classic achievements

      // Number Match Achievements
      _achievements['numberPlateMatch'] = [
        Achievement(
          title: 'Lucky Starter',
          description: 'Get your first number match',
          points: 5,
          isUnlocked: true,
          progress: 1,
          total: 1,
          icon: Icons.casino,
        ),
        Achievement(
          title: 'Number Wizard',
          description: 'Match 25 plates with your number',
          points: 20,
          isUnlocked: false,
          progress: 18,
          total: 25,
          icon: Icons.looks_one,
        ),
      ];

      // Sound Spy Achievements
      _achievements['soundSpy'] = [
        Achievement(
          title: 'First Spot',
          description: 'Make your first sound',
          points: 5,
          isUnlocked: true,
          progress: 1,
          total: 1,
          icon: Icons.volume_up,
        ),
        Achievement(
          title: 'Master Guesser',
          description: 'Correctly guess 20 objects',
          points: 30,
          isUnlocked: false,
          progress: 15,
          total: 20,
          icon: Icons.psychology,
        ),
        Achievement(
          title: 'Sound Expert',
          description: 'Use all available sounds',
          points: 15,
          isUnlocked: false,
          progress: 6,
          total: 8,
          icon: Icons.music_note,
        ),
      ];

      // Windmill Achievements
      _achievements['windmill'] = [
        Achievement(
          title: 'Wind Watcher',
          description: 'Spot your first windmill',
          points: 5,
          isUnlocked: true,
          progress: 1,
          total: 1,
          icon: Icons.wind_power,
        ),
        Achievement(
          title: 'Windmill Expert',
          description: 'Spot 100 windmills',
          points: 25,
          isUnlocked: false,
          progress: 67,
          total: 100,
          icon: Icons.timeline,
        ),
        Achievement(
          title: 'Quick Spotter',
          description: 'Spot 5 windmills in one minute',
          points: 20,
          isUnlocked: false,
          progress: 3,
          total: 5,
          icon: Icons.speed,
        ),
      ];

      // Calculate total points and rank
      _calculateTotalPoints();
      _isLoading = false;
    });
  }

  void _calculateTotalPoints() {
    int points = 0;
    for (var category in _achievements.values) {
      for (var achievement in category) {
        if (achievement.isUnlocked) {
          points += achievement.points;
        }
      }
    }
    _totalPoints = points;
    _currentRank = _calculateRank(points);
  }

  String _calculateRank(int points) {
    if (points >= 100) return 'Road Trip Legend';
    if (points >= 75) return 'Expert Traveler';
    if (points >= 50) return 'Seasoned Explorer';
    if (points >= 25) return 'Adventure Seeker';
    return 'Rookie Traveler';
  }

  Widget _buildRankCard() {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg2),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seed.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const PulseGlow(
            child: Text('🏆', style: TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            _currentRank,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$_totalPoints points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final progress = (achievement.progress / achievement.total * 100).toInt();
    final accent = isLocked ? Colors.grey : AppTheme.accentViolet;

    return GamePanel(
      accent: isLocked ? null : const Color(0xFFFFC107),
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Opacity(
        opacity: isLocked ? 0.65 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : achievement.icon,
                    color: accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm2,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${achievement.points} pts',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      tween: Tween(
                        end: achievement.progress / achievement.total,
                      ),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  '$progress%',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Achievements',
      subtitle: 'Milestones from the open road',
      color: AppTheme.accentViolet,
      icon: Icons.emoji_events_rounded,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                FadeSlideIn(child: _buildRankCard()),
                const SizedBox(height: Spacing.xl),

                // Number Match Achievements
                const FadeSlideIn(
                  delay: Duration(milliseconds: 80),
                  child: _CategoryHeader(
                    title: 'Number Match',
                    icon: Icons.format_list_numbered,
                  ),
                ),
                ..._achievements['numberPlateMatch']!
                    .map(_buildAchievementCard),
                const SizedBox(height: Spacing.lg),

                // Sound Spy Achievements
                const _CategoryHeader(
                  title: 'Sound Spy',
                  icon: Icons.volume_up,
                ),
                ..._achievements['soundSpy']!.map(_buildAchievementCard),
                const SizedBox(height: Spacing.lg),

                // Windmill Achievements
                const _CategoryHeader(
                  title: 'Windmill',
                  icon: Icons.wind_power,
                ),
                ..._achievements['windmill']!.map(_buildAchievementCard),
              ],
            ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final int points;
  final bool isUnlocked;
  final int progress;
  final int total;
  final IconData icon;

  Achievement({
    required this.title,
    required this.description,
    required this.points,
    required this.isUnlocked,
    required this.progress,
    required this.total,
    required this.icon,
  });
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CategoryHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: GameSectionTitle(
        icon: icon,
        title: title,
        color: AppTheme.accentViolet,
      ),
    );
  }
}
