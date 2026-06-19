import 'package:flutter/material.dart';

import '../styles/app_theme.dart';
import '../styles/game_colors.dart';
import '../styles/spacing.dart';
import '../widgets/game_shell.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  final Map<String, Map<String, dynamic>> _gameStats = {};

  // Sample time periods for filtering
  final List<String> _timePeriods = [
    'All Time',
    'This Month',
    'This Week',
    'Today'
  ];
  String _selectedPeriod = 'All Time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    // Simulate loading statistics from storage
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Sample data - in real app, load from SharedPreferences or database
    setState(() {
      // Removed Number Plate Classic stats

      _gameStats['numberPlateMatch'] = {
        'gamesPlayed': 38,
        'totalMatches': 127,
        'luckyNumber': '7',
        'averagePerGame': 3.3,
        'bestGame': 9,
        'topPlayer': 'Player 2',
      };

      _gameStats['soundSpy'] = {
        'gamesPlayed': 31,
        'totalSpots': 245,
        'correctGuesses': 89,
        'mostUsedSound': 'Beep',
        'bestSpotter': 'Player 3',
        'bestGuesser': 'Player 1',
      };

      _gameStats['windmill'] = {
        'gamesPlayed': 27,
        'totalWindmills': 342,
        'averagePerGame': 12.7,
        'bestGame': 45,
        'topSpotter': 'Player 4',
        'longestStreak': 8,
      };

      _isLoading = false;
    });
  }

  Widget _buildGameStatsCard(String gameId) {
    final stats = _gameStats[gameId];
    if (stats == null) return const SizedBox.shrink();

    return GamePanel(
      accent: GameColors.primaryColors[gameId],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatRow(
            label: 'Games Played',
            value: stats['gamesPlayed']?.toString() ?? '0',
            icon: Icons.gamepad,
          ),
          const Divider(),
          if (gameId == 'numberPlateMatch') ...[
            _StatRow(
              label: 'Total Matches',
              value: stats['totalMatches']?.toString() ?? '0',
              icon: Icons.check_circle,
            ),
            _StatRow(
              label: 'Lucky Number',
              value: stats['luckyNumber']?.toString() ?? 'N/A',
              icon: Icons.filter_7,
            ),
          ] else if (gameId == 'soundSpy') ...[
            _StatRow(
              label: 'Total Spots',
              value: stats['totalSpots']?.toString() ?? '0',
              icon: Icons.visibility,
            ),
            _StatRow(
              label: 'Correct Guesses',
              value: stats['correctGuesses']?.toString() ?? '0',
              icon: Icons.psychology,
            ),
          ] else if (gameId == 'windmill') ...[
            _StatRow(
              label: 'Total Windmills',
              value: stats['totalWindmills']?.toString() ?? '0',
              icon: Icons.wind_power,
            ),
            _StatRow(
              label: 'Average per Game',
              value: stats['averagePerGame']?.toString() ?? '0',
              icon: Icons.analytics,
            ),
          ],
          const Divider(),
          _StatRow(
            label: 'Best Game',
            value: stats['bestGame']?.toString() ?? '0',
            icon: Icons.emoji_events,
          ),
          _StatRow(
            label: 'Top Player',
            value: stats['topPlayer']?.toString() ?? 'N/A',
            icon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    int totalGamesPlayed = _gameStats.values
        .fold(0, (sum, stats) => sum + (stats['gamesPlayed'] as int));

    return Column(
      children: [
        _buildStatsTile(
          title: 'Total Games Played',
          value: totalGamesPlayed.toString(),
          icon: Icons.games,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: Spacing.lg),

        // Game type breakdown
        GamePanel(
          accent: AppTheme.seed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GameSectionTitle(
                icon: Icons.pie_chart_rounded,
                title: 'Games breakdown',
                color: AppTheme.seed,
              ),
              const SizedBox(height: Spacing.lg),
              _buildGameBreakdown(
                  'Number Match',
                  _gameStats['numberPlateMatch']?['gamesPlayed'] ?? 0,
                  GameColors.primaryColors['numberPlateMatch']!),
              _buildGameBreakdown(
                  'Sound Spy',
                  _gameStats['soundSpy']?['gamesPlayed'] ?? 0,
                  GameColors.primaryColors['soundSpy']!),
              _buildGameBreakdown(
                  'Windmill Count',
                  _gameStats['windmill']?['gamesPlayed'] ?? 0,
                  GameColors.primaryColors['windmill']!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameBreakdown(String gameName, int gamesPlayed, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(gameName),
            ),
            Text(
              '$gamesPlayed games',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            tween: Tween(end: gamesPlayed / 50), // Max value for visualization
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
      ],
    );
  }

  Widget _buildStatsTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GamePanel(
      accent: color,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Number Plates'),
            Tab(text: 'Sound Spy'),
            Tab(text: 'Windmill'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Time period selector
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Time Period',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedPeriod,
                    items: _timePeriods.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                        // Reload statistics for selected period
                        _loadStatistics();
                      });
                    },
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Overview tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: _buildOverallStats(),
                      ),

                      // Number Plates tab (classic removed)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Column(
                          children: [
                            _buildGameStatsCard('numberPlateMatch'),
                          ],
                        ),
                      ),

                      // Sound Spy tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: _buildGameStatsCard('soundSpy'),
                      ),

                      // Windmill tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: _buildGameStatsCard('windmill'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: Spacing.sm),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
