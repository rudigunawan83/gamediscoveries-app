import '../../../../core/utils/formatters.dart';

class GameCategory {
  const GameCategory({
    required this.slug,
    required this.name,
    required this.gameCount,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gameCount: parseInt(json['gameCount']),
    );
  }

  final String slug;
  final String name;
  final int gameCount;
}
