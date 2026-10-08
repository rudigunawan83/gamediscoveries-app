import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';
import '../../../shared/models/game_summary.dart';
import '../../community/domain/community_models.dart';

class GameDetail {
  const GameDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.tags,
    required this.mobileReady,
    this.description,
    this.instructions,
    this.thumbnailUrl,
    this.coverUrl,
    this.gameUrl,
    this.embedUrl,
    this.category,
    this.developer,
    this.orientation,
    this.width,
    this.height,
  });

  factory GameDetail.fromJson(Map<String, dynamic> json) {
    return GameDetail(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      gameUrl: json['gameUrl'] as String?,
      embedUrl: json['embedUrl'] as String?,
      category: json['category'] as String?,
      developer: json['developer'] as String?,
      mobileReady: json['mobileReady'] as bool? ?? false,
      orientation: json['orientation'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
          .map((dynamic t) => t.toString())
          .toList(growable: false),
    );
  }

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? instructions;
  final String? thumbnailUrl;
  final String? coverUrl;
  final String? gameUrl;
  final String? embedUrl;
  final String? category;
  final String? developer;
  final bool mobileReady;
  final String? orientation;
  final int? width;
  final int? height;
  final List<String> tags;

  String? get heroImageUrl =>
      (coverUrl?.isNotEmpty ?? false) ? coverUrl : thumbnailUrl;

  String? get playUrl => (embedUrl?.isNotEmpty ?? false) ? embedUrl : gameUrl;

  bool get isLandscape {
    final value = orientation?.toLowerCase();
    if (value == 'landscape') return true;
    if (value == 'portrait') return false;
    final w = width;
    final h = height;
    return w != null && h != null && w > h;
  }

  GameSummary toSummary() {
    return GameSummary(
      id: id,
      slug: slug,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      coverUrl: coverUrl,
      gameUrl: gameUrl,
      category: category,
      mobileReady: mobileReady,
    );
  }
}

class GameReview {
  const GameReview({
    required this.id,
    required this.rating,
    required this.content,
    required this.author,
    this.createdAt,
  });

  factory GameReview.fromJson(Map<String, dynamic> json) {
    return GameReview(
      id: json['id'] as String? ?? '',
      rating: parseInt(json['rating']),
      content: json['content'] as String? ?? '',
      author: CommunityUser.fromJson(
        json['author'] as Map<String, dynamic>? ?? const {},
      ),
      createdAt: parseDate(json['createdAt']),
    );
  }

  final String id;
  final int rating;
  final String content;
  final CommunityUser author;
  final DateTime? createdAt;
}

class ReviewSummary {
  const ReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    this.items = const <GameReview>[],
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    return ReviewSummary(
      averageRating: parseDouble(summary['averageRating']),
      reviewCount: parseInt(summary['reviewCount']),
      items: parseJsonList(json['items'], GameReview.fromJson),
    );
  }

  final double averageRating;
  final int reviewCount;
  final List<GameReview> items;
}
