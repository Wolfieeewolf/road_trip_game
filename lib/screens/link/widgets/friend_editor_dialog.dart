import 'package:flutter/material.dart';

import '../../../styles/spacing.dart';

Future<bool?> showFriendEditorDialog({
  required BuildContext context,
  String? title,
  String? initialName,
  String? initialFriendCode,
  String? initialPhoneNumber,
  required void Function({
    required String displayName,
    String? friendCode,
    String? phoneNumber,
  }) onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return _FriendEditorDialog(
        title: title,
        initialName: initialName,
        initialFriendCode: initialFriendCode,
        initialPhoneNumber: initialPhoneNumber,
        onSubmit: onSubmit,
      );
    },
  );
}

class _FriendEditorDialog extends StatefulWidget {
  const _FriendEditorDialog({
    this.title,
    this.initialName,
    this.initialFriendCode,
    this.initialPhoneNumber,
    required this.onSubmit,
  });

  final String? title;
  final String? initialName;
  final String? initialFriendCode;
  final String? initialPhoneNumber;
  final void Function({
    required String displayName,
    String? friendCode,
    String? phoneNumber,
  }) onSubmit;

  @override
  State<_FriendEditorDialog> createState() => _FriendEditorDialogState();
}

class _FriendEditorDialogState extends State<_FriendEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _codeController =
        TextEditingController(text: widget.initialFriendCode ?? '');
    _phoneController =
        TextEditingController(text: widget.initialPhoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSaving = true;
    });

    widget.onSubmit(
      displayName: _nameController.text,
      friendCode: _codeController.text,
      phoneNumber: _phoneController.text,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title ?? 'Add Friend'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Friend code (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g. ABC123',
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
                border: OutlineInputBorder(),
                hintText: '+1 (555) 123-4567',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSubmit,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      contentPadding: const EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg2, Spacing.xl, 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor:
          theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
    );
  }
}
