import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/domain/models/auth_session_state.dart';
import '../../auth/domain/models/auth_user.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../domain/privacy_settings.dart';
import 'privacy_controller.dart';
import 'sign_out_dialog.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: session.when(
        data: (AuthSessionState s) {
          final user = s.user;
          if (!s.isAuthenticated || user == null) {
            return const SignInRequiredView(
              icon: Icons.manage_accounts_rounded,
              title: 'Manage your account',
              message: 'Sign in to view and manage your account.',
            );
          }
          return _AccountDetails(user: user);
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(authSessionControllerProvider),
        ),
      ),
    );
  }
}

class _AccountDetails extends ConsumerWidget {
  const _AccountDetails({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              _InfoTile(
                icon: Icons.badge_rounded,
                label: 'Display name',
                value: user.displayName.isNotEmpty ? user.displayName : '—',
              ),
              const Divider(height: 1, indent: 60, color: AppColors.line),
              if (user.username?.isNotEmpty == true) ...<Widget>[
                const Divider(height: 1, indent: 60, color: AppColors.line),
                _InfoTile(
                  icon: Icons.alternate_email_rounded,
                  label: 'Username',
                  value: '@${user.username}',
                ),
              ],
              const Divider(height: 1, indent: 60, color: AppColors.line),
              _InfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: user.email.isNotEmpty ? user.email : '—',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Privacy'),
        const SizedBox(height: 10),
        const _PrivacyCard(),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            if (await confirmAndSignOut(context, ref) && context.mounted) {
              context.pop();
            }
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends ConsumerWidget {
  const _PrivacyCard();

  static const Map<PrivacyOption, (String, String)> _labels =
      <PrivacyOption, (String, String)>{
        PrivacyOption.showFavorites: (
          'Show favorites',
          'Others can see games you saved.',
        ),
        PrivacyOption.showHistory: (
          'Show play history',
          'Others can see what you played recently.',
        ),
        PrivacyOption.showAchievements: (
          'Show achievements',
          'Others can see badges you unlocked.',
        ),
        PrivacyOption.showActivity: (
          'Show activity',
          'Your activity appears in the community feed.',
        ),
        PrivacyOption.showOnLeaderboards: (
          'Show on leaderboards',
          'Your rank is visible on public leaderboards.',
        ),
      };

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    PrivacyOption option,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(privacyControllerProvider.notifier).set(option, value);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacy = ref.watch(privacyControllerProvider);

    return Card(
      child: privacy.when(
        data: (PrivacySettings settings) => Column(
          children: <Widget>[
            for (final option in PrivacyOption.values) ...<Widget>[
              if (option != PrivacyOption.values.first)
                const Divider(height: 1, indent: 16, color: AppColors.line),
              SwitchListTile(
                value: settings[option],
                onChanged: (bool value) => _toggle(context, ref, option, value),
                activeThumbColor: AppColors.onGold,
                activeTrackColor: AppColors.gold,
                title: Text(
                  _labels[option]!.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _labels[option]!.$2,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(privacyControllerProvider),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
