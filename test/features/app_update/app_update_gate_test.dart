import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/app_update/data/app_update_platform.dart';
import 'package:gamediscoveries_mobile/features/app_update/data/app_update_repository.dart';
import 'package:gamediscoveries_mobile/features/app_update/domain/app_release.dart';
import 'package:gamediscoveries_mobile/features/app_update/presentation/app_update_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _apkUrl =
    'https://gamediscoveries.com/downloads/gamediscoveries.apk';
const String _storeUrl = 'https://play.google.com/store/apps/details?id=x';

class _FakeRepo implements AppUpdateRepository {
  _FakeRepo(this.release);

  final AppRelease release;

  @override
  Future<AppRelease> getRelease(String platform) async => release;
}

class _FakeDevice implements AppUpdatePlatform {
  _FakeDevice({required this.build, this.fromPlay = false});

  final int build;
  final bool fromPlay;
  final List<String> opened = <String>[];
  final List<bool> playUpdates = <bool>[];

  @override
  String? get platform => 'android';

  @override
  Future<int> currentBuild() async => build;

  @override
  Future<bool> installedFromPlayStore() async => fromPlay;

  @override
  Future<bool> startPlayUpdate({required bool immediate}) async {
    playUpdates.add(immediate);
    return false;
  }

  @override
  Future<bool> openUrl(String url) async {
    opened.add(url);
    return true;
  }
}

const AppRelease _release = AppRelease(
  latestVersion: '1.3.0',
  latestBuild: 5,
  minSupportedBuild: 3,
  storeUrl: _storeUrl,
  apkUrl: _apkUrl,
  releaseNotes: 'Faster loading',
);

Future<SharedPreferences> _pump(
  WidgetTester tester,
  _FakeDevice device, {
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        appUpdatePlatformProvider.overrideWithValue(device),
        appUpdateRepositoryProvider.overrideWithValue(_FakeRepo(_release)),
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) =>
            AppUpdateGate(child: child!),
        home: const Scaffold(body: Text('home')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return sharedPrefs;
}

void main() {
  test('urgency compares the installed build with the release', () {
    expect(_release.urgencyFor(2), UpdateUrgency.required);
    expect(_release.urgencyFor(3), UpdateUrgency.optional);
    expect(_release.urgencyFor(5), UpdateUrgency.none);
    expect(_release.urgencyFor(0), UpdateUrgency.none);
  });

  testWidgets('APK install gets a banner that downloads the new APK', (
    WidgetTester tester,
  ) async {
    final device = _FakeDevice(build: 4);
    await _pump(tester, device);

    expect(find.text('Update available: v1.3.0'), findsOneWidget);
    expect(find.text('home'), findsOneWidget);

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(device.playUpdates, isEmpty);
    expect(device.opened, <String>[_apkUrl]);
  });

  testWidgets('Later hides the banner until a newer build ships', (
    WidgetTester tester,
  ) async {
    final prefs = await _pump(tester, _FakeDevice(build: 4));

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Update available: v1.3.0'), findsNothing);
    expect(prefs.getInt('appUpdate.skippedBuild'), 5);
  });

  testWidgets('a skipped build shows no banner', (WidgetTester tester) async {
    await _pump(
      tester,
      _FakeDevice(build: 4),
      prefs: <String, Object>{'appUpdate.skippedBuild': 5},
    );

    expect(find.text('Update available: v1.3.0'), findsNothing);
  });

  testWidgets('unsupported Play install is blocked until it updates', (
    WidgetTester tester,
  ) async {
    final device = _FakeDevice(build: 2, fromPlay: true);
    await _pump(tester, device);

    expect(find.text('Update required'), findsOneWidget);

    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();

    expect(device.playUpdates, <bool>[true]);
    expect(device.opened, <String>[_storeUrl]);
    expect(find.text('Update required'), findsOneWidget);
  });
}
