import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class CommunityUser {
  const CommunityUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.level,
  });

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    return CommunityUser(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      level: level == null ? null : parseInt(level),
    );
  }

  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  /// XP level; `null` when the author has no progress yet.
  final int? level;

  String get name =>
      (displayName?.isNotEmpty ?? false) ? displayName! : username;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'level': level,
  };
}

class CommunityGame {
  const CommunityGame({
    required this.id,
    required this.slug,
    required this.title,
    this.thumbnailUrl,
    this.categories = const <String>[],
  });

  factory CommunityGame.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    return CommunityGame(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      categories: categories is List
          ? categories.whereType<String>().toList(growable: false)
          : const <String>[],
    );
  }

  final String id;
  final String slug;
  final String title;
  final String? thumbnailUrl;
  final List<String> categories;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'slug': slug,
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'categories': categories,
  };
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
    this.postId,
    this.type,
    this.game,
    this.createdAt,
    this.viewCount = 0,
    this.viewerReaction,
  });

  factory CommunityPost.fromPostJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>?;
    final id = json['id'] as String? ?? '';
    return CommunityPost(
      id: id,
      postId: id.isEmpty ? null : id,
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
      viewCount: parseInt(json['viewCount']),
      viewerReaction: json['viewerReaction'] as String?,
    );
  }

  factory CommunityPost.fromFeedJson(Map<String, dynamic> json) {
    final game = json['game'] as Map<String, dynamic>?;
    final entityId = json['entityId'] as String?;
    return CommunityPost(
      id: json['id'] as String? ?? '',
      postId: json['entityType'] == 'post' && (entityId?.isNotEmpty ?? false)
          ? entityId
          : null,
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

  /// The discussion post this card opens; `null` for activity items that
  /// are not posts (e.g. "played a game").
  final String? postId;
  final String? type;
  final CommunityUser author;
  final String title;
  final String content;
  final int reactionCount;
  final int commentCount;
  final CommunityGame? game;
  final DateTime? createdAt;
  final int viewCount;

  /// The signed-in viewer's reaction (`like`, ...), if any.
  final String? viewerReaction;

  bool get likedByViewer => viewerReaction != null;

  CommunityPost withReaction(String? reaction) {
    final delta = (reaction != null ? 1 : 0) - (likedByViewer ? 1 : 0);
    final count = reactionCount + delta;
    return CommunityPost(
      id: id,
      postId: postId,
      type: type,
      author: author,
      title: title,
      content: content,
      reactionCount: count < 0 ? 0 : count,
      commentCount: commentCount,
      game: game,
      createdAt: createdAt,
      viewCount: viewCount,
      viewerReaction: reaction,
    );
  }

  String get typeLabel {
    final raw = (type ?? '').replaceAll('_', ' ').toLowerCase();
    if (raw.isEmpty) return '';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  /// Same shape as the API's `CommunityPostDto`, readable by [fromPostJson].
  Map<String, dynamic> toPostJson() => <String, dynamic>{
    'id': postId ?? id,
    'type': type,
    'author': author.toJson(),
    'title': title,
    'content': content,
    'reactionCount': reactionCount,
    'commentCount': commentCount,
    'game': game?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
    'viewCount': viewCount,
    'viewerReaction': viewerReaction,
  };
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.author,
    required this.content,
    this.parentId,
    this.createdAt,
    this.replies = const <CommunityComment>[],
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String? ?? '',
      parentId: json['parentId'] as String?,
      author: CommunityUser.fromJson(
        json['author'] as Map<String, dynamic>? ?? const {},
      ),
      content: json['content'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      replies: parseJsonList(json['replies'], CommunityComment.fromJson),
    );
  }

  final String id;
  final String? parentId;
  final CommunityUser author;
  final String content;
  final DateTime? createdAt;

  /// The API nests at most one level of replies.
  final List<CommunityComment> replies;
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

enum CommunityPostSort {
  latest('latest'),
  trending('trending'),
  mostLiked('most_liked');

  const CommunityPostSort(this.apiValue);

  final String apiValue;
}

class CommunityPostPage {
  const CommunityPostPage({required this.items, this.nextCursor});

  factory CommunityPostPage.fromJson(Map<String, dynamic> json) {
    return CommunityPostPage(
      items: parseJsonList(json['items'], CommunityPost.fromPostJson),
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
