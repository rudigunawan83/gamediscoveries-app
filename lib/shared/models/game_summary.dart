class GameSummary {
  const GameSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.mobileReady,
    this.description,
    this.thumbnailUrl,
    this.coverUrl,
    this.gameUrl,
    this.category,
    this.platform,
    this.publishedAt,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      gameUrl: json['gameUrl'] as String?,
      category: json['category'] as String?,
      platform: json['platform'] as String?,
      mobileReady: json['mobileReady'] as bool? ?? false,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
    );
  }

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? coverUrl;
  final String? gameUrl;
  final String? category;
  final String? platform;
  final bool mobileReady;
  final DateTime? publishedAt;

  String? get cardImageUrl => _firstNonEmpty(thumbnailUrl, coverUrl);

  String? get heroImageUrl => _firstNonEmpty(coverUrl, thumbnailUrl);

  static String? _firstNonEmpty(String? a, String? b) {
    if (a != null && a.isNotEmpty) return a;
    if (b != null && b.isNotEmpty) return b;
    return null;
  }
}
