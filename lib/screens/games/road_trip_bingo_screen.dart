import 'package:flutter/material.dart';

import '../../styles/card_styles.dart';
import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../styles/text_styles.dart';

class BingoCard {
  final List<String> items;
  final Set<int> spotted = {};
  BingoCard({required this.items});
  void toggle(int index) => spotted.contains(index) ? spotted.remove(index) : spotted.add(index);
  bool get hasBingo {
    final s = {...spotted, 12};
    // rows
    for (int r = 0; r < 5; r++) {
      if (List.generate(5, (c) => r * 5 + c).every(s.contains)) return true;
    }
    // cols
    for (int c = 0; c < 5; c++) {
      if (List.generate(5, (r) => c + r * 5).every(s.contains)) return true;
    }
    // diags
    if (List.generate(5, (i) => i * 6).every(s.contains)) return true;
    if (List.generate(5, (i) => (i + 1) * 4).every(s.contains)) return true;
    return false;
  }
}

class RoadTripBingoScreen extends StatefulWidget {
  final List<String> players;
  const RoadTripBingoScreen({super.key, required this.players});
  @override
  State<RoadTripBingoScreen> createState() => _RoadTripBingoScreenState();
}

class _RoadTripBingoScreenState extends State<RoadTripBingoScreen> {
  final Map<String, BingoCard> _cards = {};
  bool _showRules = false;

  static const Map<String, List<String>> _auCategories = {
    'Vehicles': [
      'Ute', 'Caravan', 'Road Train', 'Police Car', 'Motorcycle', 'Truck',
      'Station Wagon', 'Taxi', 'Ambulance', 'Fire Truck', 'Sports Car', 'Tour Bus', 'Holden'
    ],
    'Buildings': [
      'Petrol Station', 'Pub', 'Woolworths', 'Coles', 'School', 'Post Office', 'Hotel',
      'Hospital', 'Fire Station', 'Police Station', 'Cafe', 'Shopping Centre', 'Bunnings'
    ],
    'Road Signs': [
      'Speed Limit', 'Stop Sign', 'Give Way', 'Kangaroos Ahead', 'No Standing', 'Road Work',
      'School Zone', 'Exit', 'Rest Area', 'Food Sign', 'Fuel Sign', 'Distance Marker',
      'Highway Sign', 'State Border', 'Railway Crossing'
    ],
    'Nature': [
      'Gum Tree', 'Creek', 'Billabong', 'Hill', 'Kookaburra', 'Kangaroo', 'Emu', 'Horse',
      'Cow', 'Sheep', 'Wattle', 'Park', 'Bush'
    ],
    'Other': [
      'Traffic Light', 'Bridge', 'Train Tracks', 'Bus Stop', 'Bike Rack', 'Post Box',
      'Australian Flag', 'Billboard', 'Playground', 'Pedestrian Crossing', 'BBQ Area', 'Surf Club'
    ],
  };

  @override
  void initState() {
    super.initState();
    for (final p in widget.players) {
      _cards[p] = _generateCard();
    }
  }

  BingoCard _generateCard() {
    final items = <String>[];
    final all = _auCategories.values.expand((e) => e).toList();
    all.shuffle();
    items.addAll(all.take(24));
    items.insert(12, 'FREE');
    return BingoCard(items: items);
  }

  void _newCards() {
    setState(() {
      for (final p in widget.players) {
        _cards[p] = _generateCard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Road Trip Bingo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => setState(() => _showRules = !_showRules),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newCards,
        icon: const Icon(Icons.refresh),
        label: const Text('New Cards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          if (_showRules)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('How to Play:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Each player gets a bingo card. Tap items when spotted.'),
                    Text('Get 5 in a row (row/column/diagonal) to win!'),
                    Text('Cards include Australian-themed items.'),
                  ],
                ),
              ),
            ),
          ...widget.players.map((p) => _buildCard(p, _cards[p]!)),
        ],
      ),
    );
  }

  Widget _buildCard(String player, BingoCard card) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(player, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (card.hasBingo)
                  const Chip(label: Text('BINGO'), backgroundColor: Colors.amber),
              ],
            ),
            const SizedBox(height: Spacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: Spacing.sm2,
                mainAxisSpacing: Spacing.sm2,
              ),
              itemCount: 25,
              itemBuilder: (context, index) {
                if (index == 12) {
                  return _freeCell(card);
                }
                final dataIndex = index > 12 ? index - 1 : index;
                final text = card.items[dataIndex];
                final selected = card.spotted.contains(index);
                return GestureDetector(
                  onTap: () => setState(() {
                    card.toggle(index);
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? GameColors.primaryColors['roadTripBingo']!.withValues(alpha: 0.2) : GameColors.primaryColors['roadTripBingo']!.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GameColors.primaryColors['roadTripBingo']!.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(Spacing.sm2),
                    child: Center(
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : GameColors.primaryColors['roadTripBingo']!.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _freeCell(BingoCard card) {
    return Container(
      decoration: BoxDecoration(
        color: GameColors.primaryColors['roadTripBingo']!.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('FREE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

