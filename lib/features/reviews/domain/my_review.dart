import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class MyReview {
  const MyReview({
    required this.id,
    required this.rating,
    required this.content,
    required this.status,
    required this.gameSlug,
    required this.gameTitle,
    this.gameThumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MyReview.fromJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>? ?? const {};
    return MyReview(
      id: json['id'] as String? ?? '',
      rating: parseInt(json['rating']),
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      gameSlug: game['slug'] as String? ?? '',
      gameTitle: game['title'] as String? ?? '',
      gameThumbnailUrl: game['thumbnailUrl'] as String?,
    );
  }

  final String id;
  final int rating;
  final String content;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String gameSlug;
  final String gameTitle;
  final String? gameThumbnailUrl;

  /// Moderators can hide a review; it stays visible to its author only.
  bool get isHidden => status == 'hidden';

  static List<MyReview> listFrom(Object? json) =>
      parseJsonList(json, MyReview.fromJson);
}
