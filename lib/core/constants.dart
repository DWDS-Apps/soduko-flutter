class AppConstants {
  static const String appName = 'Sudoku';
  static const String appVersion = '1.0.0';
  static const int gridSize = 9;
  static const int boxSize = 3;
  static const int maxHints = 3;
  static const String saveKey = 'sudoku_save';
  static const String statsKey = 'sudoku_stats';
  static const String settingsKey = 'sudoku_settings';
  static const String dailyKey = 'sudoku_daily';
}

enum Difficulty {
  easy('Easy', 38),
  medium('Medium', 32),
  hard('Hard', 26),
  expert('Expert', 22);

  final String label;
  final int startingClues;
  const Difficulty(this.label, this.startingClues);

  static Difficulty fromString(String s) {
    return Difficulty.values.firstWhere(
      (d) => d.name == s,
      orElse: () => Difficulty.easy,
    );
  }
}
