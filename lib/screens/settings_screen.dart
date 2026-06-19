import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles/spacing.dart';
import '../widgets/game_fx.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _autoResetScores = false;

  final List<String> _languages = const [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _autoResetScores = prefs.getBool('autoResetScores') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.xl, 0, Spacing.xl, Spacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tune the experience to match your crew.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Spacing.xl),
                  _SettingsSection(
                    title: 'Audio & Haptics',
                    children: [
                      _SettingSwitchTile(
                        icon: Icons.graphic_eq,
                        title: 'Sound effects',
                        subtitle: 'Enable game sounds and ambient cues.',
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() => _soundEnabled = value);
                          _saveSetting('soundEnabled', value);
                        },
                      ),
                      _SettingSwitchTile(
                        icon: Icons.vibration,
                        title: 'Vibration',
                        subtitle: 'Use haptic feedback for key actions.',
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() => _vibrationEnabled = value);
                          GameFx.hapticsEnabled = value;
                          _saveSetting('vibrationEnabled', value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xl),
                  _SettingsSection(
                    title: 'Appearance',
                    children: [
                      _SettingSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        subtitle: 'Use a dark interface when available.',
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() => _darkMode = value);
                          _saveSetting('darkMode', value);
                        },
                      ),
                      _LanguageSelector(
                        languages: _languages,
                        selectedLanguage: _selectedLanguage,
                        onSelected: (language) {
                          setState(() => _selectedLanguage = language);
                          _saveSetting('language', language);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xl),
                  _SettingsSection(
                    title: 'Gameplay',
                    children: [
                      _SettingSwitchTile(
                        icon: Icons.refresh_rounded,
                        title: 'Auto-reset scores',
                        subtitle: 'Reset scores when starting a new game.',
                        value: _autoResetScores,
                        onChanged: (value) {
                          setState(() => _autoResetScores = value);
                          _saveSetting('autoResetScores', value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xl),
                  _SettingsSection(
                    title: 'About',
                    children: const [
                      _AboutTile(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: Spacing.lg),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: child,
            )),
      ],
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.md2),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.languages,
    required this.selectedLanguage,
    required this.onSelected,
  });

  final List<String> languages;
  final String selectedLanguage;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Choose the language used across the app.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: languages.map((language) {
                final isSelected = language == selectedLanguage;
                return ChoiceChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (_) => onSelected(language),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      child: ListTile(
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.info_outline,
            color: colorScheme.tertiary,
          ),
        ),
        title: const Text('Version 1.0.0'),
        subtitle: Text(
          'You are all set with the latest adventure pack.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: FilledButton.tonal(
          onPressed: () {},
          child: const Text('Check for updates'),
        ),
      ),
    );
  }
}
