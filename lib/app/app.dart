import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/app_update/presentation/app_update_gate.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GameDiscoveriesApp extends ConsumerWidget {
  const GameDiscoveriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Game Discoveries',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
      builder: (BuildContext context, Widget? child) =>
          AppUpdateGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
