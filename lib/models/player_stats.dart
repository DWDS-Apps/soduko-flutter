import '../core/constants.dart';

class PlayerStats {
  int gamesPlayed;
  int gamesWon;
  int currentStreak;
  int longestStreak;
  Map<String, int> bestTimes;
  Map<String, int> totalTimes;
  Map<String, int> gamesByDifficulty;
  int totalHintsUsed;

  PlayerStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    Map<String, int>? bestTimes,
    Map<String, int>? totalTimes,
    Map<String, int>? gamesByDifficulty,
    this.totalHintsUsed = 0,
  })  : bestTimes = bestTimes ?? {},
        totalTimes = totalTimes ?? {},
        gamesByDifficulty = gamesByDifficulty ?? {};

  double get winPercentage =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;

  double get averageTime => gamesWon > 0
      ? (totalTimes.values.fold(0, (a, b) => a + b)) / gamesWon
      : 0;

  int getBestTime(Difficulty d) => bestTimes[d.name] ?? 0;
  int getGamesForDifficulty(Difficulty d) => gamesByDifficulty[d.name] ?? 0;

  void recordGame(Difficulty difficulty, int timeSeconds, bool won,
      {int hintsUsed = 0}) {
    gamesPlayed++;
    totalHintsUsed += hintsUsed;
    gamesByDifficulty[difficulty.name] =
        (gamesByDifficulty[difficulty.name] ?? 0) + 1;

    if (won) {
      gamesWon++;
      currentStreak++;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
      final current = totalTimes[difficulty.name] ?? 0;
      totalTimes[difficulty.name] = current + timeSeconds;
      final best = bestTimes[difficulty.name];
      if (best == null || timeSeconds < best) {
        bestTimes[difficulty.name] = timeSeconds;
      }
    } else {
      currentStreak = 0;
    }
  }

  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'bestTimes': bestTimes,
        'totalTimes': totalTimes,
        'gamesByDifficulty': gamesByDifficulty,
        'totalHintsUsed': totalHintsUsed,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      bestTimes: (json['bestTimes'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      totalTimes: (json['totalTimes'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      gamesByDifficulty: (json['gamesByDifficulty'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
    );
  }
}
