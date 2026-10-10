import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/storage/local_preferences.dart';

class _OnboardingPage {
  const _OnboardingPage({required this.words, required this.body});

  /// Rendered as "Word. Word. Word." with the middle word highlighted.
  final List<String> words;
  final String body;
}

List<_OnboardingPage> _pages(AppLocalizations l10n) => <_OnboardingPage>[
  _OnboardingPage(
    words: <String>[
      l10n.onboardingSlide1Word1,
      l10n.onboardingSlide1Word2,
      l10n.onboardingSlide1Word3,
    ],
    body: l10n.onboardingSlide1Body,
  ),
  _OnboardingPage(
    words: <String>[
      l10n.onboardingSlide2Word1,
      l10n.onboardingSlide2Word2,
      l10n.onboardingSlide2Word3,
    ],
    body: l10n.onboardingSlide2Body,
  ),
  _OnboardingPage(
    words: <String>[
      l10n.onboardingSlide3Word1,
      l10n.onboardingSlide3Word2,
      l10n.onboardingSlide3Word3,
    ],
    body: l10n.onboardingSlide3Body,
  ),
];

const int _pageCount = 3;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(String route) async {
    await ref.read(localPreferencesProvider).markOnboardingDone();
    if (!mounted) return;
    context.go(AppRoutes.home);
    if (route != AppRoutes.home) context.push(route);
  }

  void _next() {
    if (_isLast) {
      _finish(AppRoutes.home);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = _pages(l10n);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/onboarding_hero.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, AppColors.night],
                stops: <double>[0.4, 0.68],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedOpacity(
                    opacity: _index > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      tooltip: l10n.commonBack,
                      onPressed: _index > 0
                          ? () => _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            )
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (int i) => setState(() => _index = i),
                    itemBuilder: (BuildContext context, int i) =>
                        _PageText(page: pages[i]),
                  ),
                ),
                _Dots(count: pages.length, index: _index),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _isLast ? l10n.onboardingGetStarted : l10n.commonNext,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () =>
                      _finish(_isLast ? AppRoutes.login : AppRoutes.home),
                  child: Text(
                    _isLast ? l10n.onboardingHaveAccount : l10n.commonSkip,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageText extends StatelessWidget {
  const _PageText({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                for (var i = 0; i < page.words.length; i++)
                  TextSpan(
                    text: '${page.words[i]}. ',
                    style: TextStyle(color: i == 1 ? AppColors.gold : null),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.onboardingPageIndicator(index + 1, count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppColors.gold : AppColors.line,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}
