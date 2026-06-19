import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles/spacing.dart';

class SafetyWarning extends StatefulWidget {
  final String? gameSpecificWarning;
  final VoidCallback? onDismiss;
  final bool showAlways;
  final String storageKey;

  const SafetyWarning({
    super.key,
    this.gameSpecificWarning,
    this.onDismiss,
    this.showAlways = false,
    this.storageKey = 'safety_warning_dismissed',
  });

  @override
  State<SafetyWarning> createState() => _SafetyWarningState();
}

class _SafetyWarningState extends State<SafetyWarning>
    with SingleTickerProviderStateMixin {
  bool _isDismissed = false;
  bool _hasChecked = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (!widget.showAlways) {
      _checkIfDismissed();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _checkIfDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDismissed = prefs.getBool(widget.storageKey) ?? false;
      _hasChecked = true;
    });
  }

  Future<void> _dismiss() async {
    if (!widget.showAlways) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(widget.storageKey, true);
    }

    setState(() {
      _isDismissed = true;
    });

    // Play hide animation
    await _animationController.reverse();

    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed || (!widget.showAlways && !_hasChecked)) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.all(Spacing.lg),
          elevation: 4,
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    const Text(
                      'Safety Warning',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'For your safety:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    const _WarningItem(
                      icon: Icons.drive_eta,
                      text: 'The driver should NEVER play while driving',
                    ),
                    const SizedBox(height: Spacing.sm),
                    const _WarningItem(
                      icon: Icons.person,
                      text: 'Only passengers should interact with the app',
                    ),
                    const SizedBox(height: Spacing.sm),
                    const _WarningItem(
                      icon: Icons.visibility,
                      text: 'Keep your eyes on the road at all times',
                    ),
                    if (widget.gameSpecificWarning != null) ...[
                      const SizedBox(height: Spacing.sm),
                      _WarningItem(
                        icon: Icons.info,
                        text: widget.gameSpecificWarning!,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: Spacing.md),
                        ),
                        child: const Text(
                          'I Understand and Agree',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WarningItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage:
/*
SafetyWarning(
  gameSpecificWarning: 'Keep volume at a reasonable level',
  onDismiss: () {
    // Handle dismissal
  },
  showAlways: false,
  storageKey: 'sound_spy_warning_dismissed',
)
*/
