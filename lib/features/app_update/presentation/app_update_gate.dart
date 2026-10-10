import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/storage/local_preferences.dart';
import '../data/app_update_platform.dart';
import 'app_update_providers.dart';

/// Wraps the whole app: shows a dismissible banner for optional updates and
/// a blocking screen when the installed build is below the supported minimum.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> {
  bool _busy = false;
  bool _hidden = false;

  Future<void> _update(AppUpdateOffer offer) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final device = ref.read(appUpdatePlatformProvider);
      if (offer.fromPlayStore &&
          await device.startPlayUpdate(immediate: offer.isRequired)) {
        return;
      }
      final release = offer.release;
      final url = offer.fromPlayStore || device.platform == 'ios'
          ? release.storeUrl ?? release.apkUrl
          : release.apkUrl ?? release.storeUrl;
      if (url != null) await device.openUrl(url);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _later(AppUpdateOffer offer) async {
    setState(() => _hidden = true);
    await ref
        .read(localPreferencesProvider)
        .setSkippedUpdateBuild(offer.release.latestBuild);
  }

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(appUpdateOfferProvider).value;
    if (offer == null) return widget.child;

    if (offer.isRequired) {
      return Stack(
        children: <Widget>[
          widget.child,
          Positioned.fill(
            child: _RequiredUpdateView(
              offer: offer,
              busy: _busy,
              onUpdate: () => _update(offer),
            ),
          ),
        ],
      );
    }

    final skipped = ref.read(localPreferencesProvider).skippedUpdateBuild;
    if (_hidden || skipped >= offer.release.latestBuild) return widget.child;

    return Stack(
      children: <Widget>[
        widget.child,
        Positioned(
          left: 12,
          right: 12,
          top: MediaQuery.paddingOf(context).top + 8,
          child: _UpdateBanner(
            offer: offer,
            busy: _busy,
            onUpdate: () => _update(offer),
            onLater: () => _later(offer),
          ),
        ),
      ],
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({
    required this.offer,
    required this.busy,
    required this.onUpdate,
    required this.onLater,
  });

  final AppUpdateOffer offer;
  final bool busy;
  final VoidCallback onUpdate;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surfaceAlt,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.system_update_rounded, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Update available: v${offer.release.latestVersion}',
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (offer.release.releaseNotes case final notes?) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                notes,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(onPressed: onLater, child: const Text('Later')),
                TextButton(
                  onPressed: busy ? null : onUpdate,
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequiredUpdateView extends StatelessWidget {
  const _RequiredUpdateView({
    required this.offer,
    required this.busy,
    required this.onUpdate,
  });

  final AppUpdateOffer offer;
  final bool busy;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.night,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.system_update_rounded,
                size: 72,
                color: AppColors.gold,
              ),
              const SizedBox(height: 20),
              Text(
                'Update required',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This version of GameDiscoveries is no longer supported. '
                'Update to v${offer.release.latestVersion} to keep playing.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (offer.release.releaseNotes case final notes?) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  notes,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : onUpdate,
                  child: Text(busy ? 'Opening…' : 'Update now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
