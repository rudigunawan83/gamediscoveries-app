import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/features/discovery/domain/models/game_list_query.dart';
import 'package:gamediscoveries_mobile/features/discovery/domain/models/home_discoveries.dart';

void main() {
  test('HomeDiscoveries parses sections and tolerates missing ones', () {
    final home = HomeDiscoveries.fromJson(<String, dynamic>{
      'featured': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': '6f1c1d2e-0000-0000-0000-000000000001',
          'slug': 'super-racer',
          'title': 'Super Racer',
          'thumbnailUrl': 'https://img.test/thumb.jpg',
          'coverUrl': null,
          'category': 'Racing',
          'mobileReady': true,
          'publishedAt': '2026-10-01T10:00:00+00:00',
        },
      ],
      'trending': <Map<String, dynamic>>[],
    });

    expect(home.featured, hasLength(1));
    expect(home.featured.single.title, 'Super Racer');
    expect(home.featured.single.mobileReady, isTrue);
    expect(home.featured.single.heroImageUrl, 'https://img.test/thumb.jpg');
    expect(home.featured.single.publishedAt, isNotNull);
    expect(home.popular, isEmpty);
    expect(home.isEmpty, isFalse);
  });

  test('GameListQuery only sends populated filters', () {
    const query = GameListQuery(
      pageSize: 12,
      mobileReady: true,
      sort: GameSort.newest,
      search: '',
    );

    expect(query.toQueryParameters(), <String, dynamic>{
      'page': 1,
      'pageSize': 12,
      'mobileReady': true,
      'sort': 'newest',
    });
  });
}
