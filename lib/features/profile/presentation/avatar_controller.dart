import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/domain/models/auth_user.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../progress/presentation/progress_providers.dart';
import '../data/avatar_repository.dart';

final imagePickerProvider = Provider<ImagePicker>((Ref ref) => ImagePicker());

class AvatarTooLargeException implements Exception {
  const AvatarTooLargeException();

  @override
  String toString() => 'Image must be 5 MB or smaller.';
}

/// `true` while an avatar upload or removal is in flight.
class AvatarController extends Notifier<bool> {
  static const int maxUploadBytes = 5 * 1024 * 1024;

  @override
  bool build() => false;

  /// Returns `false` when the player cancelled the picker.
  Future<bool> pickAndUpload(ImageSource source) async {
    if (state) {
      return false;
    }

    final file = await ref
        .read(imagePickerProvider)
        .pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          requestFullMetadata: false,
        );
    if (file == null) {
      return false;
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > maxUploadBytes) {
      throw const AvatarTooLargeException();
    }

    // ASP.NET only binds multipart parts that carry a filename as files.
    final fileName = file.name.isEmpty ? 'avatar.jpg' : file.name;
    await _run(
      () =>
          ref.read(avatarRepositoryProvider).upload(bytes, fileName: fileName),
    );
    return true;
  }

  Future<void> remove() async {
    if (state) {
      return;
    }
    await _run(() => ref.read(avatarRepositoryProvider).remove());
  }

  Future<void> _run(Future<AuthUser> Function() request) async {
    state = true;
    try {
      final user = await request();
      ref.read(authSessionControllerProvider.notifier).updateUser(user);
      ref.invalidate(myProgressProvider);
    } finally {
      state = false;
    }
  }
}

final avatarControllerProvider = NotifierProvider<AvatarController, bool>(
  AvatarController.new,
);
