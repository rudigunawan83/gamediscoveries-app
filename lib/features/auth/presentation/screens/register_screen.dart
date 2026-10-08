import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/error_messages.dart';
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
  String? _error;

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
      setState(() {
        _error = error is ApiException && error.statusCode == 409
            ? 'An account with this email already exists.'
            : error is ApiException && error.statusCode == 400
            ? error.message
            : friendlyErrorMessage(error);
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: 'Create your account',
      subtitle: 'Earn XP, unlock achievements and compete with players.',
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
                  decoration: const InputDecoration(
                    hintText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (String? v) => (v ?? '').trim().length < 2
                      ? 'Use at least 2 characters.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: validatePassword,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        AuthErrorText(_error),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Create Account'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.pushReplacement(AppRoutes.login),
          child: const Text('Already have an account? Sign in'),
        ),
      ],
    );
  }
}
