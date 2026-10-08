import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

enum LeaderboardScope {
  global('Global', 'ALL_TIME'),
  weekly('Weekly', 'WEEKLY'),
  monthly('Monthly', 'MONTHLY');

  const LeaderboardScope(this.label, this.type);

  final String label;
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
          : (username ?? 'Player'),
      avatarUrl: user['avatarUrl'] as String?,
      score: parseInt(json['score']),
      gamesPlayed: parseInt(json['gamesPlayed']),
      rankChange: (json['rankChange'] as num?)?.toInt(),
    );
  }

  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int score;
  final int gamesPlayed;
  final int? rankChange;
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
