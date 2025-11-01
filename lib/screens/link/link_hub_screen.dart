import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth/auth_controller.dart';
import '../../services/friends/friend_contact.dart';
import '../../services/friends/friends_controller.dart';
import '../../services/link/link_controller.dart';
import '../../services/link/link_session.dart';
import '../../styles/spacing.dart';
import '../game_selection_screen.dart';
import 'friends_manager_screen.dart';
import 'widgets/friend_selection_sheet.dart';

class LinkHubScreen extends StatefulWidget {
  const LinkHubScreen({super.key});

  @override
  State<LinkHubScreen> createState() => _LinkHubScreenState();
}

class _LinkHubScreenState extends State<LinkHubScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isInvitingFriends = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = context.watch<LinkController>();
    final auth = context.watch<AuthController>();
    final friends = context.watch<FriendsController>();
    final session = link.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Linking'),
      ),
      body: RefreshIndicator(
        onRefresh: () => link.refreshSession(),
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            _buildProfileCard(theme, auth),
            const SizedBox(height: Spacing.lg),
            _buildFriendsCard(theme, friends, link),
            const SizedBox(height: Spacing.lg),
            if (link.error != null && link.error!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    link.error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            if (session == null)
              _buildNoSessionCard(theme, link)
            else
              _buildActiveSessionCard(theme, link, session),
            const SizedBox(height: Spacing.lg),
            if (session == null) _buildJoinCard(theme, link),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, AuthController auth) {
    final user = auth.user!;
    final code = auth.friendCode ?? '------';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Profile',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.displayName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Row(
                        children: [
                          Icon(Icons.link,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'Friend code: $code',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard(
      ThemeData theme, FriendsController friends, LinkController link) {
    if (!friends.isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final friendCount = friends.friends.length;
    final hasFriends = friendCount > 0;
    final isBusy = _isInvitingFriends || link.isBusy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Saved Friends',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    friendCount.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openFriendsManager(),
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              hasFriends
                  ? 'Pick friends to send them an SMS invite with your game code.'
                  : 'Save friends to invite them without sharing codes manually.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (!hasFriends || isBusy)
                        ? null
                        : () => _inviteSavedFriends(),
                    icon: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(hasFriends
                        ? 'Invite saved friends'
                        : 'Add friends first'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFriendsManager() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FriendsManagerScreen()),
    );
  }

  Future<void> _inviteSavedFriends() async {
    if (_isInvitingFriends) return;
    final friendsController = context.read<FriendsController>();
    final linkController = context.read<LinkController>();
    final authController = context.read<AuthController>();

    if (!friendsController.isInitialized || friendsController.friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add friends first to send invites.')),
      );
      return;
    }

    final selectedFriends = await showFriendSelectionSheet(
      context: context,
    );
    if (!mounted || selectedFriends == null || selectedFriends.isEmpty) {
      return;
    }

    final selectedGame = await _pickGame();
    if (!mounted || selectedGame == null) {
      return;
    }

    setState(() {
      _isInvitingFriends = true;
    });

    try {
      if (linkController.session == null) {
        await linkController.hostNewSession();
      }
      var session = linkController.session;
      if (session == null) {
        await linkController.refreshSession();
        session = linkController.session;
      }
      if (!mounted) return;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start session. Try again.')),
        );
        return;
      }

      final hostName = authController.user?.displayName ?? 'A friend';
      final messageBody =
          '$hostName invited you to play ${selectedGame.name} in Road Trip Games! Join with code ${session.code}.';

      final recipients = selectedFriends
          .map((friend) => friend.phoneNumber)
          .whereType<String>()
          .where((phone) => phone.isNotEmpty)
          .toList();

      if (recipients.isNotEmpty) {
        await _launchSms(recipients, messageBody);
      }

      final noPhoneFriends = selectedFriends
          .where((friend) =>
              friend.phoneNumber == null || friend.phoneNumber!.isEmpty)
          .toList();
      if (noPhoneFriends.isNotEmpty) {
        await _showManualShareDialog(
            session.code, selectedGame.name, noPhoneFriends);
      }

      await Clipboard.setData(ClipboardData(text: session.code));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Session code ${session.code} copied to clipboard')),
        );
      }

      await friendsController.importFromSession(session);
    } finally {
      if (mounted) {
        setState(() {
          _isInvitingFriends = false;
        });
      }
    }
  }

  Future<Game?> _pickGame() async {
    final games = GameSelectionScreen.games;
    return showModalBottomSheet<Game>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(Spacing.lg),
                child: Text(
                  'Choose a game',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return ListTile(
                      leading: Icon(game.icon, color: game.color),
                      title: Text(game.name),
                      subtitle: Text(game.description),
                      onTap: () => Navigator.of(context).pop(game),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: games.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchSms(List<String> recipients, String body) async {
    if (recipients.isEmpty) return;
    final separator =
        defaultTargetPlatform == TargetPlatform.iOS ? ',' : ';';
    final path = recipients.join(separator);
    final uri = Uri(
      scheme: 'sms',
      path: path,
      queryParameters: {'body': body},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open SMS app.')),
      );
    }
  }

  Future<void> _showManualShareDialog(
    String code,
    String gameName,
    List<FriendContact> friendsWithoutPhone,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share code manually'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send this code to your friends:'),
              const SizedBox(height: Spacing.sm),
              SelectableText(
                code,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (friendsWithoutPhone.isNotEmpty) ...[
                const SizedBox(height: Spacing.md),
                const Text('Friends without phone numbers:'),
                const SizedBox(height: Spacing.sm),
                ...friendsWithoutPhone
                    .map((friend) => Text(friend.displayName)),
              ],
              const SizedBox(height: Spacing.md),
              Text(
                'Ask them to open Road Trip Games and enter the code to join your ${gameName.toLowerCase()} game.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoSessionCard(ThemeData theme, LinkController link) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start a linked game',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Create a session and share the join code with friends. Anyone with the code can join from their device.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            ElevatedButton.icon(
              onPressed: link.isBusy ? null : () => link.hostNewSession(),
              icon: const Icon(Icons.groups),
              label: link.isBusy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Host new session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinCard(ThemeData theme, LinkController link) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join a friend\'s session',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Enter session code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Spacing.md),
            ElevatedButton.icon(
              onPressed: link.isBusy
                  ? null
                  : () => link.joinSession(_codeController.text),
              icon: const Icon(Icons.login),
              label: link.isBusy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Join session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard(
    ThemeData theme,
    LinkController link,
    LinkSession session,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.waves, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Session ${session.code}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Share this code with anyone you want to play with. They can join from their own device.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
            const SizedBox(height: Spacing.md),
            Text(
              'Participants (${session.participants.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...session.sortedParticipants.map(
              (participant) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                  child: Text(
                    participant.displayName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(participant.displayName),
                subtitle: participant.id == session.host.id
                    ? const Text('Host')
                    : null,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: link.isBusy ? null : () => link.refreshSession(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: Spacing.md),
                OutlinedButton.icon(
                  onPressed: link.isBusy ? null : () => link.leaveSession(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Leave session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
