import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../progress/presentation/progress_providers.dart';
import '../data/ad_reward_repository.dart';
import 'ad_reward_providers.dart';

/// "Watch & Earn": a rewarded video worth more XP than a play session,
/// limited per day. Hidden for guests and when ads are not configured.
class WatchAdRewardCard extends ConsumerStatefulWidget {
  const WatchAdRewardCard({this.trailingGap = 0, super.key});

  /// Space added below the card, only when it is visible.
  final double trailingGap;

  @override
  ConsumerState<WatchAdRewardCard> createState() => _WatchAdRewardCardState();
}

class _WatchAdRewardCardState extends ConsumerState<WatchAdRewardCard> {
  bool _busy = false;

  Future<void> _watch() async {
    setState(() => _busy = true);
    final outcome = await ref.read(adRewardFlowProvider).watch();
    if (!mounted) return;
    setState(() => _busy = false);

    ref.invalidate(adRewardStatusProvider);
    if (outcome.xp > 0) {
      ref
        ..invalidate(myProgressProvider)
        ..invalidate(recentXpProvider);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(adRewardMessage(context.l10n, outcome))),
      );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(adRewardStatusProvider).value;
    if (status == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, widget.trailingGap),
      child: _Card(status: status, busy: _busy, onWatch: _watch),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.status,
    required this.busy,
    required this.onWatch,
  });

  final AdRewardStatus status;
  final bool busy;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final available = status.remainingToday > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.ondemand_video_rounded,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.adRewardTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    available
                        ? l10n.adRewardAvailable(
                            status.xpPerAd,
                            status.remainingToday,
                            status.dailyLimit,
                          )
                        : l10n.adRewardExhausted(status.dailyLimit),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: available && !busy ? onWatch : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.onGold,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                visualDensity: VisualDensity.compact,
              ),
              child: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.commonXpReward(status.xpPerAd),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
