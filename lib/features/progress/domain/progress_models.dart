import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.title,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.progressPercentage,
    required this.isMaxLevel,
  });

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      level: parseInt(json['level']),
      title: json['title'] as String? ?? '',
      totalXp: parseInt(json['totalXp']),
      currentLevelXp: parseInt(json['currentLevelXp']),
      nextLevelXp: parseInt(json['nextLevelXp']),
      progressPercentage: parseDouble(json['progressPercentage']),
      isMaxLevel: json['isMaxLevel'] as bool? ?? false,
    );
  }

  final int level;
  final String title;
  final int totalXp;
  final int currentLevelXp;
  final int nextLevelXp;
  final double progressPercentage;
  final bool isMaxLevel;

  double get progress => isMaxLevel ? 1 : progressPercentage / 100;
}

class ProgressStats {
  const ProgressStats({
    required this.totalGameSessions,
    required this.uniqueGamesPlayed,
    required this.favorites,
    required this.currentStreak,
    required this.longestStreak,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalGameSessions: parseInt(json['totalGameSessions']),
      uniqueGamesPlayed: parseInt(json['uniqueGamesPlayed']),
      favorites: parseInt(json['favorites']),
      currentStreak: parseInt(json['currentStreak']),
      longestStreak: parseInt(json['longestStreak']),
    );
  }

  final int totalGameSessions;
  final int uniqueGamesPlayed;
  final int favorites;
  final int currentStreak;
  final int longestStreak;
}

class UserProgress {
  const UserProgress({
    required this.userName,
    required this.level,
    required this.stats,
    this.avatarUrl,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return UserProgress(
      userName: user['name'] as String? ?? '',
      avatarUrl: user['avatarUrl'] as String?,
      level: LevelInfo.fromJson(
        json['level'] as Map<String, dynamic>? ?? const {},
      ),
      stats: ProgressStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String userName;
  final String? avatarUrl;
  final LevelInfo level;
  final ProgressStats stats;
}

class XpTransaction {
  const XpTransaction({
    required this.id,
    required this.ruleCode,
    required this.xpAmount,
    required this.description,
    this.createdAt,
  });

  factory XpTransaction.fromJson(Map<String, dynamic> json) {
    return XpTransaction(
      id: json['transactionId'] as String? ?? '',
      ruleCode: json['ruleCode'] as String? ?? '',
      xpAmount: parseInt(json['xpAmount']),
      description: json['description'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }

  final String id;
  final String ruleCode;
  final int xpAmount;
  final String description;
  final DateTime? createdAt;

  static List<XpTransaction> listFrom(Object? json) {
    final map = json as Map<String, dynamic>? ?? const {};
    return parseJsonList(map['items'], XpTransaction.fromJson);
  }
}
