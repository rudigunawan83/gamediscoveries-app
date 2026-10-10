import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/domain/models/auth_session_state.dart';
import '../../auth/domain/models/auth_user.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/profile_repository.dart';
import '../domain/privacy_settings.dart';
import '../domain/profile_rules.dart';
import 'privacy_controller.dart';
import 'sign_out_dialog.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: session.when(
        data: (AuthSessionState s) {
          final user = s.user;
          if (!s.isAuthenticated || user == null) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: <Widget>[
                SignInRequiredView(
                  icon: Icons.manage_accounts_rounded,
                  title: context.l10n.settingsManageAccountTitle,
                  message: context.l10n.settingsManageAccountMessage,
                ),
                const _LanguageSection(),
              ],
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
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        _ProfileForm(user: user),
        const SizedBox(height: 24),
        const _LanguageSection(),
        const SizedBox(height: 24),
        _SectionTitle(l10n.settingsPrivacy),
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
          label: Text(
            l10n.commonSignOut,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});

  final AuthUser user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.user.displayName,
  );
  late final TextEditingController _username = TextEditingController(
    text: widget.user.username ?? '',
  );
  bool _saving = false;
  bool _showErrors = false;
  bool _taken = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  ProfileDraft get _draft =>
      ProfileDraft(displayName: _name.text, username: _username.text);

  bool get _unchanged => profileUnchanged(
    _draft,
    currentName: widget.user.displayName,
    currentUsername: widget.user.username,
  );

  Future<void> _save() async {
    final l10n = context.l10n;
    final errors = profileFieldErrors(
      _draft,
      currentName: widget.user.displayName,
      currentUsername: widget.user.username,
    );
    setState(() {
      _showErrors = true;
      _taken = false;
    });
    if (errors.isNotEmpty || _unchanged || _saving) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            displayName: _draft.normalizedName,
            username: _draft.normalizedUsername,
          );
      ref.read(authSessionControllerProvider.notifier).updateUser(user);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsProfileSaved)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 409) {
        setState(() => _taken = true);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errors = _showErrors
        ? profileFieldErrors(
            _draft,
            currentName: widget.user.displayName,
            currentUsername: widget.user.username,
          )
        : const <ProfileField>[];
    final nameInvalid = errors.contains(ProfileField.displayName);
    final handleInvalid = _taken || errors.contains(ProfileField.username);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.nickname],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: l10n.settingsDisplayName,
                    helperText: nameInvalid
                        ? null
                        : l10n.settingsDisplayNameHint,
                    errorText: nameInvalid
                        ? l10n.settingsDisplayNameInvalid
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _username,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.username],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: l10n.settingsUsername,
                    prefixText: '@',
                    helperText: handleInvalid
                        ? null
                        : l10n.settingsUsernameHint,
                    errorText: _taken
                        ? l10n.settingsUsernameTaken
                        : errors.contains(ProfileField.username)
                        ? l10n.settingsUsernameInvalid
                        : null,
                  ),
                  onChanged: (_) => setState(() => _taken = false),
                  onFieldSubmitted: (_) => _save(),
                ),
                const Divider(height: 24, color: AppColors.line),
                _InfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.settingsEmail,
                  value: widget.user.email.isNotEmpty ? widget.user.email : '—',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving || _unchanged ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.onGold,
            disabledBackgroundColor: AppColors.surfaceAlt,
            disabledForegroundColor: AppColors.textMuted,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(_saving ? l10n.settingsSaving : l10n.settingsSave),
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

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  String _label(AppLocalizations l10n, AppLanguage language) =>
      switch (language) {
        AppLanguage.system => l10n.settingsSystemDefault,
        AppLanguage.english => l10n.settingsEnglish,
        AppLanguage.indonesian => l10n.settingsIndonesian,
      };

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final deviceLocales = View.of(context).platformDispatcher.locales;
    final strings = lookupAppLocalizations(
      language.locale ?? resolveSupportedLocale(deviceLocales),
    );
    await ref.read(appLanguageProvider.notifier).select(language);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(strings.settingsLanguageChanged)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appLanguageProvider);
    final deviceLanguage = AppLanguage.fromCode(
      resolveSupportedLocale(
        View.of(context).platformDispatcher.locales,
      ).languageCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionTitle(l10n.settingsLanguage),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: Text(
            l10n.settingsLanguageSubtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: RadioGroup<AppLanguage>(
            groupValue: selected,
            onChanged: (AppLanguage? language) {
              if (language != null && language != selected) {
                _change(context, ref, language);
              }
            },
            child: Column(
              children: <Widget>[
                for (final language in AppLanguage.values) ...<Widget>[
                  if (language != AppLanguage.values.first)
                    const Divider(height: 1, indent: 16, color: AppColors.line),
                  RadioListTile<AppLanguage>(
                    value: language,
                    activeColor: AppColors.gold,
                    title: Text(
                      _label(l10n, language),
                      style: TextStyle(
                        fontWeight: language == selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: language == selected
                            ? AppColors.gold
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: language == AppLanguage.system
                        ? Text(
                            _label(l10n, deviceLanguage),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyCard extends ConsumerWidget {
  const _PrivacyCard();

  static (String, String) _labels(
    AppLocalizations l10n,
    PrivacyOption option,
  ) => switch (option) {
    PrivacyOption.showFavorites => (
      l10n.settingsPrivacyShowFavorites,
      l10n.settingsPrivacyShowFavoritesHint,
    ),
    PrivacyOption.showHistory => (
      l10n.settingsPrivacyShowHistory,
      l10n.settingsPrivacyShowHistoryHint,
    ),
    PrivacyOption.showAchievements => (
      l10n.settingsPrivacyShowAchievements,
      l10n.settingsPrivacyShowAchievementsHint,
    ),
    PrivacyOption.showActivity => (
      l10n.settingsPrivacyShowActivity,
      l10n.settingsPrivacyShowActivityHint,
    ),
    PrivacyOption.showOnLeaderboards => (
      l10n.settingsPrivacyShowOnLeaderboards,
      l10n.settingsPrivacyShowOnLeaderboardsHint,
    ),
  };

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    PrivacyOption option,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(privacyControllerProvider.notifier).set(option, value);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(l10n, error))),
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
                  _labels(context.l10n, option).$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _labels(context.l10n, option).$2,
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
