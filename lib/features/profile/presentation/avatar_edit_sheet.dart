import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
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
    builder: (BuildContext context) {
      final l10n = context.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l10n.profileChangeAvatar,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.gold,
              ),
              title: Text(l10n.profileChooseFromGallery),
              onTap: () => Navigator.of(context).pop(_AvatarAction.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.gold,
              ),
              title: Text(l10n.profileTakePhoto),
              onTap: () => Navigator.of(context).pop(_AvatarAction.camera),
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                title: Text(
                  l10n.profileRemovePhoto,
                  style: const TextStyle(color: AppColors.danger),
                ),
                onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (action == null || !context.mounted) {
    return;
  }

  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
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
            SnackBar(content: Text(l10n.profileAvatarUpdated)),
          );
        }
      case _AvatarAction.remove:
        await controller.remove();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.profileAvatarRemoved)),
        );
    }
  } on PlatformException {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.profileAvatarPermissionError)),
    );
  } on AvatarTooLargeException {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.profileAvatarTooLarge(AvatarController.maxUploadMb)),
      ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
    );
  }
}
