import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/errors/error_messages.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({
    required this.icon,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = title;
    final action = onAction;
    final secondary = onSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.gold),
            ),
            const SizedBox(height: 18),
            if (heading != null) ...<Widget>[
              Text(
                heading,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null && actionLabel != null) ...<Widget>[
              const SizedBox(height: 22),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: action,
                  child: Text(actionLabel!),
                ),
              ),
            ],
            if (secondary != null && secondaryLabel != null) ...<Widget>[
              const SizedBox(height: 8),
              TextButton(onPressed: secondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: Icons.wifi_off_rounded,
      message: friendlyErrorMessage(error),
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

class SignInRequiredView extends StatelessWidget {
  const SignInRequiredView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MessageView(
      icon: icon,
      title: title,
      message: message,
      actionLabel: 'Sign In',
      onAction: () => context.push(AppRoutes.login),
      secondaryLabel: 'Create an account',
      onSecondary: () => context.push(AppRoutes.register),
    );
  }
}
