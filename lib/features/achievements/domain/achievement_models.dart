import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.isSecret,
    required this.isUnlocked,
    required this.progressValue,
    required this.targetValue,
    required this.rewardXp,
    this.icon,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      icon: json['icon'] as String?,
      isSecret: json['isSecret'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: parseDate(json['unlockedAt']),
      progressValue: parseInt(json['progressValue']),
      targetValue: parseInt(json['targetValue']),
      rewardXp: parseInt(json['rewardXp']),
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String? icon;
  final bool isSecret;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progressValue;
  final int targetValue;
  final int rewardXp;

  bool get hidden => isSecret && !isUnlocked;
}

class AchievementList {
  const AchievementList({
    required this.items,
    required this.totalDefinitions,
    required this.userUnlocked,
  });

  factory AchievementList.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>? ?? const {};
    final items = parseJsonList(json['items'], Achievement.fromJson);
    final total = parseInt(overview['activeDefinitions']);

    return AchievementList(
      items: items,
      totalDefinitions: total > 0 ? total : items.length,
      userUnlocked: parseInt(overview['userUnlocked']),
    );
  }

  final List<Achievement> items;
  final int totalDefinitions;
  final int userUnlocked;

  List<String> get categories {
    final seen = <String>{};
    return <String>[
      for (final item in items)
        if (item.category.isNotEmpty && seen.add(item.category)) item.category,
    ];
  }
}
