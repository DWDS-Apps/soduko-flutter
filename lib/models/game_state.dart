import 'sudoku_board.dart';
import '../core/constants.dart';

enum GameStatus { playing, paused, completed, won }

class GameState {
  final SudokuBoard board;
  final SudokuBoard solution;
  final Difficulty difficulty;
  final GameStatus status;
  final int elapsedSeconds;
  final int hintsUsed;
  final List<Move> history;
  final int historyIndex;
  final int mistakes;
  final DateTime? startTime;
  final DateTime? completedTime;

  GameState({
    required this.board,
    required this.solution,
    required this.difficulty,
    this.status = GameStatus.playing,
    this.elapsedSeconds = 0,
    this.hintsUsed = 0,
    this.mistakes = 0,
    List<Move>? history,
    this.historyIndex = -1,
    this.startTime,
    this.completedTime,
  }) : history = history ?? [];

  int get maxHints => AppConstants.maxHints;
  bool get canUndo => historyIndex >= 0;
  bool get canRedo => historyIndex < history.length - 1;
  bool get isComplete => board.isComplete();

  GameState copyWith({
    SudokuBoard? board,
    SudokuBoard? solution,
    Difficulty? difficulty,
    GameStatus? status,
    int? elapsedSeconds,
    int? hintsUsed,
    List<Move>? history,
    int? historyIndex,
    int? mistakes,
    DateTime? startTime,
    DateTime? completedTime,
  }) {
    return GameState(
      board: board ?? this.board,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      mistakes: mistakes ?? this.mistakes,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'board': board.toJson(),
        'solution': solution.toJson(),
        'difficulty': difficulty.name,
        'status': status.name,
        'elapsedSeconds': elapsedSeconds,
        'hintsUsed': hintsUsed,
        'history': history.map((m) => m.toJson()).toList(),
        'historyIndex': historyIndex,
        'mistakes': mistakes,
        'startTime': startTime?.toIso8601String(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: SudokuBoard.fromJson(json['board'] as Map<String, dynamic>),
      solution: SudokuBoard.fromJson(json['solution'] as Map<String, dynamic>),
      difficulty:
          Difficulty.fromString(json['difficulty'] as String? ?? 'easy'),
      status: GameStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => GameStatus.paused,
      ),
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((m) => Move.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      historyIndex: json['historyIndex'] as int? ?? -1,
      mistakes: json['mistakes'] as int? ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String)
          : null,
    );
  }
}

class Move {
  final int row;
  final int col;
  final int previousValue;
  final int newValue;
  final Set<int> previousNotes;
  final Set<int> newNotes;
  final DateTime timestamp;

  Move({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
    Set<int>? previousNotes,
    Set<int>? newNotes,
    DateTime? timestamp,
  })  : previousNotes = previousNotes ?? {},
        newNotes = newNotes ?? {},
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'previousValue': previousValue,
        'newValue': newValue,
        'previousNotes': previousNotes.toList(),
        'newNotes': newNotes.toList(),
      };

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      row: json['row'] as int,
      col: json['col'] as int,
      previousValue: json['previousValue'] as int? ?? 0,
      newValue: json['newValue'] as int? ?? 0,
      previousNotes: (json['previousNotes'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {},
      newNotes:
          (json['newNotes'] as List<dynamic>?)?.map((e) => e as int).toSet() ??
              {},
    );
  }
}
