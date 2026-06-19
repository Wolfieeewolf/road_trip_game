import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/auth_controller.dart';
import '../../services/link/link_controller.dart';
import '../../styles/app_theme.dart';
import '../../styles/spacing.dart';
import '../../widgets/app_background.dart';
import '../../widgets/modern_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthController>();
    final link = context.read<LinkController>();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await auth.login(_nameController.text);
      await link.initialize();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.xl),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.warmGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.seed.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                Text(
                  'Road Trip\nGames',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'Pick a display name so friends can spot you in linked games.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.inkMuted,
                  ),
                ),
                const SizedBox(height: Spacing.xxl),
                ModernPanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your traveler name',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: Spacing.lg),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            hintText: 'e.g. RoadTripChamp',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Please enter a display name';
                            }
                            if (trimmed.length < 3) {
                              return 'Display name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: Spacing.lg),
                          Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GradientPrimaryButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  label: 'Get started',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: Spacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
