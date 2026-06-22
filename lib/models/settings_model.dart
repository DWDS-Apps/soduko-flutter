import 'dart:convert';

class SettingsModel {
  bool darkMode;
  bool soundEnabled;
  bool vibrationEnabled;
  bool highlightDuplicates;
  bool autoCheckMistakes;
  bool showTimer;
  bool leftHandedMode;

  SettingsModel({
    this.darkMode = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.highlightDuplicates = true,
    this.autoCheckMistakes = true,
    this.showTimer = true,
    this.leftHandedMode = false,
  });

  SettingsModel copyWith({
    bool? darkMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? highlightDuplicates,
    bool? autoCheckMistakes,
    bool? showTimer,
    bool? leftHandedMode,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      highlightDuplicates: highlightDuplicates ?? this.highlightDuplicates,
      autoCheckMistakes: autoCheckMistakes ?? this.autoCheckMistakes,
      showTimer: showTimer ?? this.showTimer,
      leftHandedMode: leftHandedMode ?? this.leftHandedMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'highlightDuplicates': highlightDuplicates,
        'autoCheckMistakes': autoCheckMistakes,
        'showTimer': showTimer,
        'leftHandedMode': leftHandedMode,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      darkMode: json['darkMode'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      highlightDuplicates: json['highlightDuplicates'] as bool? ?? true,
      autoCheckMistakes: json['autoCheckMistakes'] as bool? ?? true,
      showTimer: json['showTimer'] as bool? ?? true,
      leftHandedMode: json['leftHandedMode'] as bool? ?? false,
    );
  }
}

class DailyChallenge {
  final DateTime date;
  bool completed;
  int bestTimeSeconds;
  bool hintsUsed;

  DailyChallenge({
    required this.date,
    this.completed = false,
    this.bestTimeSeconds = 0,
    this.hintsUsed = false,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'completed': completed,
        'bestTimeSeconds': bestTimeSeconds,
        'hintsUsed': hintsUsed,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final parts = dateStr.split('-');
    return DailyChallenge(
      date: DateTime(int.parse(parts[0]), int.parse(parts[1]),
          int.parse(parts[2])),
      completed: json['completed'] as bool? ?? false,
      bestTimeSeconds: json['bestTimeSeconds'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as bool? ?? false,
    );
  }
}
