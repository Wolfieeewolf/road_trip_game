import 'package:flutter/material.dart';

import '../styles/card_styles.dart';
import '../styles/spacing.dart';
import '../styles/text_styles.dart';

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
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
          ),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.military_tech,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  _currentRank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$_totalPoints Points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final progress = (achievement.progress / achievement.total * 100).toInt();

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        achievement.icon,
                        color: isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey.shade300
                              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${achievement.points} pts',
                          style: TextStyle(
                            color:
                                isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: achievement.progress / achievement.total,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          color: isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                _buildRankCard(),
                const SizedBox(height: Spacing.xl),

                // Number Plate Classic removed

                // Number Match Achievements
                const _CategoryHeader(
                  title: 'Number Match',
                  icon: Icons.format_list_numbered,
                ),
                ..._achievements['numberPlateMatch']!
                    .map(_buildAchievementCard),
                const SizedBox(height: Spacing.xl),

                // Sound Spy Achievements
                const _CategoryHeader(
                  title: 'Sound Spy',
                  icon: Icons.volume_up,
                ),
                ..._achievements['soundSpy']!.map(_buildAchievementCard),
                const SizedBox(height: Spacing.xl),

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
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: Spacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
