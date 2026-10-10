import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/screens/register_screen.dart';

import '../../helpers/localized_app.dart';

class _RejectingAuth extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();

  @override
  Future<void> login({required String email, required String password}) =>
      Future<void>.error(
        const ApiException(message: 'Invalid credentials', statusCode: 401),
      );
}

Widget _app(Widget home, Locale locale) => ProviderScope(
  overrides: [authSessionControllerProvider.overrideWith(_RejectingAuth.new)],
  child: localizedApp(home: home, locale: locale),
);

void main() {
  testWidgets('sign in renders and validates in Indonesian', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const LoginScreen(), const Locale('id')));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Belum punya akun? Buat sekarang'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
  });

  testWidgets('wrong credentials show a localized error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const LoginScreen(), const Locale('id')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'rudi@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
  });

  testWidgets('registration uses parameterized length messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(const RegisterScreen(), const Locale('en')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'R');
    await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'short');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 2 characters.'), findsOneWidget);
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });
}
