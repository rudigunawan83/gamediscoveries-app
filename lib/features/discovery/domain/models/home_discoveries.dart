import '../../../../core/utils/json_parsing.dart';
import '../../../../shared/models/game_summary.dart';

class HomeDiscoveries {
  const HomeDiscoveries({
    required this.featured,
    required this.trending,
    required this.latest,
    required this.popular,
    required this.mobile,
    required this.multiplayer,
    required this.hotGames,
    required this.bestGames,
    required this.mostPlayed,
    required this.exclusiveGames,
  });

  factory HomeDiscoveries.fromJson(Map<String, dynamic> json) {
    List<GameSummary> list(String key) {
      return parseJsonList(json[key], GameSummary.fromJson);
    }

    return HomeDiscoveries(
      featured: list('featured'),
      trending: list('trending'),
      latest: list('latest'),
      popular: list('popular'),
      mobile: list('mobile'),
      multiplayer: list('multiplayer'),
      hotGames: list('hotGames'),
      bestGames: list('bestGames'),
      mostPlayed: list('mostPlayed'),
      exclusiveGames: list('exclusiveGames'),
    );
  }

  final List<GameSummary> featured;
  final List<GameSummary> trending;
  final List<GameSummary> latest;
  final List<GameSummary> popular;
  final List<GameSummary> mobile;
  final List<GameSummary> multiplayer;
  final List<GameSummary> hotGames;
  final List<GameSummary> bestGames;
  final List<GameSummary> mostPlayed;
  final List<GameSummary> exclusiveGames;

  bool get isEmpty =>
      featured.isEmpty &&
      trending.isEmpty &&
      latest.isEmpty &&
      popular.isEmpty &&
      mobile.isEmpty &&
      multiplayer.isEmpty &&
      hotGames.isEmpty &&
      bestGames.isEmpty &&
      mostPlayed.isEmpty &&
      exclusiveGames.isEmpty;
}
