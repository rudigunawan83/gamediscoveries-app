import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../core/storage/local_preferences.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';

const Duration _minimumSplash = Duration(milliseconds: 1400);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _minimumSplash,
  )..forward();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.wait<Object?>(<Future<Object?>>[
      ref.read(authSessionControllerProvider.future),
      Future<void>.delayed(_minimumSplash),
    ]);
    if (!mounted) return;

    final onboardingDone = ref.read(localPreferencesProvider).onboardingDone;
    context.go(onboardingDone ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x660B0B10),
                  Color(0x330B0B10),
                  AppColors.night,
                ],
                stops: <double>[0, 0.45, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 5),
                  const BrandLogo(markSize: 132, fontSize: 32),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.splashTagline,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(flex: 4),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (BuildContext context, Widget? child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: Curves.easeOut.transform(_progress.value),
                          minHeight: 6,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.splashLoading,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
