import 'package:flutter/material.dart';

import '../../styles/game_colors.dart';
import '../../styles/spacing.dart';
import '../../widgets/game_fx.dart';
import '../../widgets/game_shell.dart';

class BingoCard {
  final List<String> items;
  final Set<int> spotted = {};
  BingoCard({required this.items});
  void toggle(int index) =>
      spotted.contains(index) ? spotted.remove(index) : spotted.add(index);
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
  final String? sessionId;

  const RoadTripBingoScreen({
    super.key,
    required this.players,
    this.sessionId,
  });

  @override
  State<RoadTripBingoScreen> createState() => _RoadTripBingoScreenState();
}

class _RoadTripBingoScreenState extends State<RoadTripBingoScreen> {
  final Map<String, BingoCard> _cards = {};
  final Set<String> _celebrated = {};
  bool _showRules = false;

  static const Map<String, List<String>> _auCategories = {
    'Vehicles': [
      'Ute',
      'Caravan',
      'Road Train',
      'Police Car',
      'Motorcycle',
      'Truck',
      'Station Wagon',
      'Taxi',
      'Ambulance',
      'Fire Truck',
      'Sports Car',
      'Tour Bus',
      'Holden'
    ],
    'Buildings': [
      'Petrol Station',
      'Pub',
      'Woolworths',
      'Coles',
      'School',
      'Post Office',
      'Hotel',
      'Hospital',
      'Fire Station',
      'Police Station',
      'Cafe',
      'Shopping Centre',
      'Bunnings'
    ],
    'Road Signs': [
      'Speed Limit',
      'Stop Sign',
      'Give Way',
      'Kangaroos Ahead',
      'No Standing',
      'Road Work',
      'School Zone',
      'Exit',
      'Rest Area',
      'Food Sign',
      'Fuel Sign',
      'Distance Marker',
      'Highway Sign',
      'State Border',
      'Railway Crossing'
    ],
    'Nature': [
      'Gum Tree',
      'Creek',
      'Billabong',
      'Hill',
      'Kookaburra',
      'Kangaroo',
      'Emu',
      'Horse',
      'Cow',
      'Sheep',
      'Wattle',
      'Park',
      'Bush'
    ],
    'Other': [
      'Traffic Light',
      'Bridge',
      'Train Tracks',
      'Bus Stop',
      'Bike Rack',
      'Post Box',
      'Australian Flag',
      'Billboard',
      'Playground',
      'Pedestrian Crossing',
      'BBQ Area',
      'Surf Club'
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
      _celebrated.clear();
    });
  }

  void _onCellTapped(String player, BingoCard card, int index) {
    setState(() {
      card.toggle(index);
    });
    if (card.hasBingo && !_celebrated.contains(player)) {
      _celebrated.add(player);
      GameFx.celebrate(
        context,
        message: 'BINGO! $player wins!',
        color: GameColors.primaryColors['roadTripBingo'],
      );
    } else if (card.spotted.contains(index)) {
      GameFx.scoreFloat(
        context,
        text: 'Spotted!',
        color: GameColors.primaryColors['roadTripBingo']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bingoColor = GameColors.primaryColors['roadTripBingo']!;

    return GameShell(
      title: 'Road Trip Bingo',
      subtitle: 'Spot it, tap it, five in a row!',
      color: bingoColor,
      icon: Icons.grid_on_rounded,
      onHelp: () => setState(() => _showRules = !_showRules),
      floatingActionButton: ChunkyButton(
        color: bingoColor,
        onTap: _newCards,
        borderRadius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New Cards',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          GameRulesCard(
            visible: _showRules,
            color: bingoColor,
            rules: const [
              'Each player gets a bingo card. Tap items when spotted.',
              'Get 5 in a row (row/column/diagonal) to win!',
              'Cards include Australian-themed items.',
            ],
          ),
          ...widget.players.toList().asMap().entries.map(
                (entry) => FadeSlideIn(
                  delay: Duration(milliseconds: 90 * entry.key),
                  child: _buildCard(entry.value, _cards[entry.value]!),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildCard(String player, BingoCard card) {
    final bingoColor = GameColors.primaryColors['roadTripBingo']!;

    return GamePanel(
      accent: card.hasBingo ? const Color(0xFFFFC107) : bingoColor,
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GameSectionTitle(
                  icon: Icons.person_rounded,
                  title: player,
                  color: bingoColor,
                ),
              ),
              if (card.hasBingo)
                const PulseGlow(
                  child: Chip(
                    label: Text(
                      'BINGO',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    backgroundColor: Colors.amber,
                  ),
                ),
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
              final bingoColor = GameColors.primaryColors['roadTripBingo']!;
              return BouncyTap(
                pressedScale: 0.88,
                onTap: () => _onCellTapped(player, card, index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  decoration: BoxDecoration(
                    color: selected
                        ? bingoColor
                        : bingoColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? bingoColor
                          : bingoColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: bingoColor.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(Spacing.sm2),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : bingoColor.withValues(alpha: 0.9),
                      ),
                      child: Text(text, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _freeCell(BingoCard card) {
    final bingoColor = GameColors.primaryColors['roadTripBingo']!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bingoColor.withValues(alpha: 0.85),
            bingoColor.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: Colors.white, size: 18),
            Text(
              'FREE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
