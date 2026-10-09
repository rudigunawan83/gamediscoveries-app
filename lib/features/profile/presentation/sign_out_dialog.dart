import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';

/// Returns `true` once the player confirmed and the session was cleared.
Future<bool> confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Sign out?'),
      content: const Text('Your progress stays saved on your account.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Sign Out',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false)) return false;
  await ref.read(authSessionControllerProvider.notifier).logout();
  return true;
}
