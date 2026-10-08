import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class CommunityUser {
  const CommunityUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    return CommunityUser(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  String get name =>
      (displayName?.isNotEmpty ?? false) ? displayName! : username;
}

class CommunityGame {
  const CommunityGame({
    required this.id,
    required this.slug,
    required this.title,
    this.thumbnailUrl,
  });

  factory CommunityGame.fromJson(Map<String, dynamic> json) {
    return CommunityGame(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  final String id;
  final String slug;
  final String title;
  final String? thumbnailUrl;
}

/// A post card shown in the community feed. Activity feed items and
/// discussion posts are both normalised to this shape.
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.reactionCount,
    required this.commentCount,
    this.type,
    this.game,
    this.createdAt,
  });

  factory CommunityPost.fromPostJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>?;
    return CommunityPost(
      id: json['id'] as String? ?? '',
      type: json['type'] as String?,
      author: CommunityUser.fromJson(
        json['author'] as Map<String, dynamic>? ?? const {},
      ),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      reactionCount: parseInt(json['reactionCount']),
      commentCount: parseInt(json['commentCount']),
      game: game == null ? null : CommunityGame.fromJson(game),
      createdAt: parseDate(json['createdAt']),
    );
  }

  factory CommunityPost.fromFeedJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>?;
    return CommunityPost(
      id: json['id'] as String? ?? '',
      type: json['activityType'] as String?,
      author: CommunityUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
      title: '',
      content: json['message'] as String? ?? '',
      reactionCount: parseInt(json['reactionCount']),
      commentCount: parseInt(json['commentCount']),
      game: game == null ? null : CommunityGame.fromJson(game),
      createdAt: parseDate(json['createdAt']),
    );
  }

  final String id;
  final String? type;
  final CommunityUser author;
  final String title;
  final String content;
  final int reactionCount;
  final int commentCount;
  final CommunityGame? game;
  final DateTime? createdAt;

  String get typeLabel {
    final raw = (type ?? '').replaceAll('_', ' ').toLowerCase();
    if (raw.isEmpty) return '';
    return raw[0].toUpperCase() + raw.substring(1);
  }
}

class CommunityFeedPage {
  const CommunityFeedPage({required this.items, this.nextCursor});

  factory CommunityFeedPage.fromJson(Map<String, dynamic> json) {
    return CommunityFeedPage(
      items: parseJsonList(json['items'], CommunityPost.fromFeedJson),
      nextCursor: json['nextCursor'] as String?,
    );
  }

  final List<CommunityPost> items;
  final String? nextCursor;
}

class CommunityHome {
  const CommunityHome({required this.trendingDiscussions});

  factory CommunityHome.fromJson(Map<String, dynamic> json) {
    return CommunityHome(
      trendingDiscussions: parseJsonList(
        json['trendingDiscussions'],
        CommunityPost.fromPostJson,
      ),
    );
  }

  final List<CommunityPost> trendingDiscussions;
}
