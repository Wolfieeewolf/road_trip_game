import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/friends/friend_contact.dart';
import '../../services/friends/friends_controller.dart';
import '../../styles/spacing.dart';
import 'widgets/friend_editor_dialog.dart';

class FriendsManagerScreen extends StatelessWidget {
  const FriendsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Friends'),
      ),
      body: Consumer<FriendsController>(
        builder: (context, friendsController, _) {
          final friends = friendsController.friends;
          if (!friendsController.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (friends.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: Spacing.lg),
                    Text(
                      'No friends saved yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Add friends to invite them quickly without entering codes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _FriendListTile(friend: friend);
            },
            separatorBuilder: (_, __) => const Divider(height: 0),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateFriend(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Friend'),
      ),
    );
  }

  Future<void> _openCreateFriend(BuildContext context) async {
    final friendsController = context.read<FriendsController>();
    await showFriendEditorDialog(
      context: context,
      title: 'Add Friend',
      onSubmit: ({
        required String displayName,
        String? friendCode,
        String? phoneNumber,
      }) {
        friendsController.addFriend(
          displayName: displayName,
          friendCode: friendCode,
          phoneNumber: phoneNumber,
        );
      },
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend});

  final FriendContact friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(friend.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error.withValues(alpha: 0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg2),
        child: Icon(
          Icons.delete_forever,
          color: theme.colorScheme.error,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<FriendsController>().removeFriend(friend.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
          child: Text(
            friend.displayName.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(friend.displayName),
        subtitle: _buildSubtitle(context),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _openEditFriend(context),
          tooltip: 'Edit',
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <String>[];
    if (friend.friendCode != null && friend.friendCode!.isNotEmpty) {
      parts.add('Code: ${friend.friendCode}');
    }
    if (friend.phoneNumber != null && friend.phoneNumber!.isNotEmpty) {
      parts.add(friend.phoneNumber!);
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' • '));
  }

  Future<void> _openEditFriend(BuildContext context) async {
    final friendsController = context.read<FriendsController>();
    await showFriendEditorDialog(
      context: context,
      title: 'Edit Friend',
      initialName: friend.displayName,
      initialFriendCode: friend.friendCode,
      initialPhoneNumber: friend.phoneNumber,
      onSubmit: ({
        required String displayName,
        String? friendCode,
        String? phoneNumber,
      }) {
        friendsController.updateFriend(
          friend.id,
          displayName: displayName,
          friendCode: friendCode,
          phoneNumber: phoneNumber,
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove friend'),
          content: Text('Remove ${friend.displayName} from saved friends?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
