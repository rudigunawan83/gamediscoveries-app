import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../core/network/api_exception.dart';
import '../providers/auth_session_controller.dart';
import '../widgets/auth_form_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;
  Object? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authSessionControllerProvider.notifier)
          .register(
            email: _email.text.trim(),
            password: _password.text,
            displayName: _name.text.trim(),
          );
      if (!mounted) return;
      context.canPop() ? context.pop() : context.go(AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _errorText(AppLocalizations l10n) {
    final error = _error;
    if (error == null) return null;
    return error is ApiException && error.statusCode == 409
        ? l10n.authEmailTaken
        : error is ApiException && error.statusCode == 400
        ? error.message
        : friendlyErrorMessage(l10n, error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthFormScaffold(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      children: <Widget>[
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.nickname],
                  decoration: InputDecoration(
                    hintText: l10n.authDisplayNameHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (String? v) =>
                      (v ?? '').trim().length < minDisplayNameLength
                      ? l10n.authMinCharacters(minDisplayNameLength)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: l10n.authEmailHint,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (String? v) => validateEmail(l10n, v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: l10n.authPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscure
                          ? l10n.authShowPassword
                          : l10n.authHidePassword,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (String? v) => validatePassword(l10n, v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AuthErrorText(_errorText(l10n)),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(l10n.authCreateAccount),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.pushReplacement(AppRoutes.login),
          child: Text(l10n.authHaveAccount),
        ),
      ],
    );
  }
}
