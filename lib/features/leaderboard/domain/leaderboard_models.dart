import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

enum LeaderboardScope {
  global('ALL_TIME'),
  weekly('WEEKLY'),
  monthly('MONTHLY');

  const LeaderboardScope(this.type);

  final String type;
}

class LeaderboardSummary {
  const LeaderboardSummary({
    required this.code,
    required this.name,
    required this.type,
  });

  factory LeaderboardSummary.fromJson(Map<String, dynamic> json) {
    return LeaderboardSummary(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  final String code;
  final String name;
  final String type;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.score,
    required this.gamesPlayed,
    this.avatarUrl,
    this.rankChange,
    this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final displayName = user['displayName'] as String?;
    final username = user['username'] as String?;

    return LeaderboardEntry(
      rank: parseInt(json['rank']),
      userId: user['id'] as String? ?? '',
      name: (displayName?.isNotEmpty ?? false)
          ? displayName!
          : (username ?? ''),
      avatarUrl: user['avatarUrl'] as String?,
      score: parseInt(json['score']),
      gamesPlayed: parseInt(json['gamesPlayed']),
      rankChange: (json['rankChange'] as num?)?.toInt(),
      level: (user['level'] as num?)?.toInt(),
    );
  }

  final int rank;
  final String userId;

  /// Empty when the server sent neither a display name nor a username.
  final String name;
  final String? avatarUrl;
  final int score;
  final int gamesPlayed;
  final int? rankChange;

  /// Server-computed player level; `null` if the player has no progress yet.
  final int? level;
}

class LeaderboardDetail {
  const LeaderboardDetail({
    required this.name,
    required this.items,
    required this.totalParticipants,
    this.me,
    this.periodEndsAt,
  });

  factory LeaderboardDetail.fromJson(Map<String, dynamic> json) {
    final meta = json['leaderboard'] as Map<String, dynamic>? ?? const {};
    final period = meta['period'] as Map<String, dynamic>?;
    final me = json['me'] as Map<String, dynamic>?;

    return LeaderboardDetail(
      name: meta['name'] as String? ?? '',
      items: parseJsonList(json['items'], LeaderboardEntry.fromJson),
      me: me == null ? null : LeaderboardEntry.fromJson(me),
      totalParticipants: parseInt(json['totalParticipants']),
      periodEndsAt: parseDate(period?['endAt']),
    );
  }

  final String name;
  final List<LeaderboardEntry> items;
  final LeaderboardEntry? me;
  final int totalParticipants;
  final DateTime? periodEndsAt;
}
