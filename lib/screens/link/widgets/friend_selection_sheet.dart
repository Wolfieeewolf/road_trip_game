import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/friends/friend_contact.dart';
import '../../../services/friends/friends_controller.dart';
import '../../../styles/spacing.dart';

Future<List<FriendContact>?> showFriendSelectionSheet({
  required BuildContext context,
  List<String>? initiallySelectedIds,
}) {
  return showModalBottomSheet<List<FriendContact>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _FriendSelectionSheet(
        initiallySelectedIds: initiallySelectedIds ?? const [],
      );
    },
  );
}

class _FriendSelectionSheet extends StatefulWidget {
  const _FriendSelectionSheet({required this.initiallySelectedIds});

  final List<String> initiallySelectedIds;

  @override
  State<_FriendSelectionSheet> createState() => _FriendSelectionSheetState();
}

class _FriendSelectionSheetState extends State<_FriendSelectionSheet> {
  late final Set<String> _selectedIds;
  String _searchValue = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initiallySelectedIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final friendsController = context.watch<FriendsController>();
    final friends = _filteredFriends(friendsController);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: Spacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  Text(
                    'Invite Friends',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedIds.length} selected',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search friends',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchValue = value;
                  });
                },
              ),
            ),
            if (friends.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Text(
                  'No friends found. Add friends first to invite them quickly.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = _selectedIds.contains(friend.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(friend.id);
                          } else {
                            _selectedIds.remove(friend.id);
                          }
                        });
                      },
                      title: Text(friend.displayName),
                      subtitle: _buildSubtitle(friend),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () {
                              final selectedFriends = friendsController.friends
                                  .where((friend) =>
                                      _selectedIds.contains(friend.id))
                                  .toList();
                              Navigator.of(context).pop(selectedFriends);
                            },
                      child: const Text('Send invites'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FriendContact> _filteredFriends(FriendsController controller) {
    if (_searchValue.trim().isEmpty) {
      return controller.friends;
    }
    return controller.search(_searchValue);
  }

  Widget? _buildSubtitle(FriendContact friend) {
    final parts = <String>[];
    if (friend.phoneNumber != null && friend.phoneNumber!.isNotEmpty) {
      parts.add(friend.phoneNumber!);
    }
    if (friend.friendCode != null && friend.friendCode!.isNotEmpty) {
      parts.add('Code: ${friend.friendCode}');
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' • '));
  }
}
