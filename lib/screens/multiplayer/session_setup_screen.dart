import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/game_session.dart';
import '../../services/firebase/game_session_service.dart';
import '../../styles/spacing.dart';
import '../games/games_screen.dart';

class SessionSetupScreen extends StatefulWidget {
  final String gameType;
  final String gameName;
  final List<String> localPlayers;

  const SessionSetupScreen({
    super.key,
    required this.gameType,
    required this.gameName,
    required this.localPlayers,
  });

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  final GameSessionService _sessionService = GameSessionService();
  final TextEditingController _codeController = TextEditingController();

  bool _isCreating = false;
  bool _isJoining = false;
  String? _createdCode;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final session = await _sessionService.createSession(
        gameType: widget.gameType,
        hostId: widget.localPlayers.first,
        players: widget.localPlayers,
      );

      setState(() {
        _createdCode = session.sessionId;
        _isCreating = false;
      });

      // Navigate to game with session
      if (mounted) {
        _navigateToGame(session);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create session: $e';
        _isCreating = false;
      });
    }
  }

  Future<void> _joinSession() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty || code.length != 6) {
      setState(() {
        _error = 'Please enter a valid 6-character code';
      });
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final session = await _sessionService.joinSession(
        sessionCode: code,
        playerName: widget.localPlayers.first,
      );

      if (session == null) {
        setState(() {
          _error = 'Session not found or already completed';
          _isJoining = false;
        });
        return;
      }

      // Navigate to game with session
      if (mounted) {
        _navigateToGame(session);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to join session: $e';
        _isJoining = false;
      });
    }
  }

  void _navigateToGame(GameSession session) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GamesScreen(
          gameType: widget.gameType,
          players: session.players,
          sessionId: session.sessionId,
        ),
      ),
    );
  }

  void _playSolo() {
    // Play without multiplayer sync
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GamesScreen(
          gameType: widget.gameType,
          players: widget.localPlayers,
          sessionId: null, // No session = local only
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gameName} - Multiplayer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Play with Friends',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Sync scores in real-time across multiple devices',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),

              // Create Session Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    children: [
                      const Icon(Icons.add_circle_outline, size: 48),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'Create New Game',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Start a game and share the code with friends',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.lg),
                      if (_createdCode != null) ...[
                        Text(
                          'Your Game Code:',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.all(Spacing.md),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _createdCode!,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _createdCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Code copied!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isCreating ? null : _createSession,
                        icon: _isCreating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.create),
                        label:
                            Text(_isCreating ? 'Creating...' : 'Create Game'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Text(
                      'OR',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Join Session Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    children: [
                      const Icon(Icons.login, size: 48),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'Join Existing Game',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        'Enter the game code to join',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.lg),
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Game Code',
                          hintText: 'Enter 6-character code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[A-Za-z0-9]')),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      ElevatedButton.icon(
                        onPressed: _isJoining ? null : _joinSession,
                        icon: _isJoining
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Text(_isJoining ? 'Joining...' : 'Join Game'),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Error Message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Play Solo Button
              OutlinedButton(
                onPressed: _playSolo,
                child: const Text('Play Solo (No Sync)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
