import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsing.dart';

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.requirementType,
    required this.progress,
    required this.target,
    required this.rewardXp,
    required this.status,
    this.expiresAt,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requirementType: json['requirementType'] as String? ?? '',
      progress: parseInt(json['progress']),
      target: parseInt(json['target']),
      rewardXp: parseInt(json['rewardXp']),
      status: json['status'] as String? ?? '',
      expiresAt: parseDate(json['expiresAt']),
    );
  }

  final String id;
  final String title;
  final String description;
  final String requirementType;
  final int progress;
  final int target;
  final int rewardXp;
  final String status;
  final DateTime? expiresAt;

  bool get isCompleted =>
      status.toUpperCase() == 'COMPLETED' || (target > 0 && progress >= target);

  double get ratio => target <= 0 ? 0 : progress / target;
}

class MyMissions {
  const MyMissions({
    required this.daily,
    required this.weekly,
    this.dailyExpiresAt,
    this.weeklyExpiresAt,
  });

  factory MyMissions.fromJson(Map<String, dynamic> json) {
    return MyMissions(
      daily: parseJsonList(json['daily'], Mission.fromJson),
      weekly: parseJsonList(json['weekly'], Mission.fromJson),
      dailyExpiresAt: parseDate(json['dailyExpiresAt']),
      weeklyExpiresAt: parseDate(json['weeklyExpiresAt']),
    );
  }

  final List<Mission> daily;
  final List<Mission> weekly;
  final DateTime? dailyExpiresAt;
  final DateTime? weeklyExpiresAt;
}
