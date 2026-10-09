import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import 'avatar_controller.dart';

enum _AvatarAction { gallery, camera, remove }

/// Lets the player pick a new avatar (gallery or camera) or remove the
/// current one, then reports the outcome with a snackbar.
Future<void> editAvatar(
  BuildContext context,
  WidgetRef ref, {
  required bool hasAvatar,
}) async {
  final action = await showModalBottomSheet<_AvatarAction>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Change avatar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_rounded,
              color: AppColors.gold,
            ),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(_AvatarAction.gallery),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_camera_rounded,
              color: AppColors.gold,
            ),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(_AvatarAction.camera),
          ),
          if (hasAvatar)
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: const Text(
                'Remove photo',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  final controller = ref.read(avatarControllerProvider.notifier);
  try {
    switch (action) {
      case _AvatarAction.gallery:
      case _AvatarAction.camera:
        final updated = await controller.pickAndUpload(
          action == _AvatarAction.camera
              ? ImageSource.camera
              : ImageSource.gallery,
        );
        if (updated) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Avatar updated.')),
          );
        }
      case _AvatarAction.remove:
        await controller.remove();
        messenger.showSnackBar(
          const SnackBar(content: Text('Avatar removed.')),
        );
    }
  } on PlatformException {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          "Couldn't open the camera or photos. Check the app permissions.",
        ),
      ),
    );
  } on AvatarTooLargeException catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(error.toString())));
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(error))),
    );
  }
}
