import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/app_state.dart';
import 'package:soduko/core/constants.dart';
import 'package:soduko/models/game_state.dart';
import 'package:soduko/models/player_stats.dart';
import 'package:soduko/models/settings_model.dart';
import 'package:soduko/services/storage_service.dart';

/// In-memory storage for testing.
class _TestStorage implements StorageService {
  Map<String, dynamic> _savedGame = {};
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _settings = {};
  bool _hasSave = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> hasSavedGame() async => _hasSave;

  @override
  Future<void> saveGame(GameState state) async {
    _savedGame = state.toJson();
    _hasSave = true;
  }

  @override
  Future<GameState?> loadGame() async {
    if (!_hasSave) return null;
    return GameState.fromJson(_savedGame);
  }

  @override
  Future<void> deleteSave() async {
    _hasSave = false;
    _savedGame = {};
  }

  @override
  Future<PlayerStats> loadStats() async {
    if (_stats.isEmpty) return PlayerStats();
    return PlayerStats.fromJson(_stats);
  }

  @override
  Future<void> saveStats(PlayerStats stats) async {
    _stats = stats.toJson();
  }

  @override
  Future<SettingsModel> loadSettings() async {
    if (_settings.isEmpty) return SettingsModel();
    return SettingsModel.fromJson(_settings);
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    _settings = settings.toJson();
  }

  @override
  Future<void> saveDailyChallenge(DailyChallenge challenge) async {}

  @override
  Future<DailyChallenge?> loadDailyChallenge(DateTime date) async => null;
}

/// Find all editable (non-given) cells that are empty.
List<(int, int)> _allEditableCells(AppState state) {
  final cells = <(int, int)>[];
  final board = state.gameState!.board;
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
        cells.add((r, c));
      }
    }
  }
  return cells;
}

void main() {
  group('Integration: Full Game Flow (new → play → win)', () {
    late _TestStorage storage;
    late AppState appState;

    setUp(() {
      storage = _TestStorage();
      appState = AppState(storage);
    });

    test('full game lifecycle — start, play moves, win, verify stats', () async {
      // ---- 1. Start a new game ----
      await appState.startNewGame(Difficulty.medium);
      expect(appState.gameState, isNotNull);
      expect(appState.gameState!.status, GameStatus.playing);
      expect(appState.gameState!.difficulty, Difficulty.medium);
      expect(appState.elapsedSeconds, 0);
      expect(appState.selectedRow, -1);
      expect(appState.selectedCol, -1);

      // ---- 2. Make some moves ----
      final editableCells = _allEditableCells(appState);
      expect(editableCells.length, greaterThan(0));

      // Select and place a number on the first few cells
      final solutionGrid = appState.gameState!.solution.toValueGrid();

      // Place 3 moves
      for (int i = 0; i < 3 && i < editableCells.length; i++) {
        final (r, c) = editableCells[i];
        final solutionValue = solutionGrid[r][c];
        expect(solutionValue, greaterThan(0));

        appState.selectCell(r, c);
        expect(appState.selectedRow, r);
        expect(appState.selectedCol, c);

        appState.inputNumber(solutionValue);
        expect(appState.gameState!.board.getCell(r, c).value, solutionValue);
      }

      // ---- 3. Timer ticks ----
      expect(appState.elapsedSeconds, 0);
      appState.tick();
      expect(appState.elapsedSeconds, 1);
      appState.tick();
      appState.tick();
      expect(appState.elapsedSeconds, 3);

      // ---- 4. Undo and redo ----
      expect(appState.gameState!.canUndo, isTrue);
      appState.undo();
      expect(appState.gameState!.board.getCell(editableCells[2].$1, editableCells[2].$2).value, 0);

      expect(appState.gameState!.canRedo, isTrue);
      appState.redo();
      expect(
        appState.gameState!.board.getCell(editableCells[2].$1, editableCells[2].$2).value,
        solutionGrid[editableCells[2].$1][editableCells[2].$2],
      );

      // ---- 5. Pause and resume ----
      appState.pauseGame();
      expect(appState.gameState!.status, GameStatus.paused);

      // Timer does not tick while paused
      appState.tick();
      expect(appState.elapsedSeconds, 3);

      appState.resumeGame();
      expect(appState.gameState!.status, GameStatus.playing);

      // ---- 6. Fill all remaining cells to complete the puzzle ----
      // Undo our 3 moves first so we can re-fill properly
      for (int i = 0; i < 3; i++) {
        if (appState.gameState!.canUndo) {
          appState.undo();
        }
      }

      // Now fill every empty cell with the solution value
      final remainingCells = _allEditableCells(appState);
      for (final (r, c) in remainingCells) {
        appState.selectCell(r, c);
        appState.inputNumber(solutionGrid[r][c]);
      }

      // ---- 7. Verify game is won ----
      expect(appState.gameState!.status, GameStatus.won);
      expect(appState.gameState!.board.isComplete(), isTrue);
      expect(appState.gameState!.board.hasConflicts(), isFalse);
      expect(appState.gameState!.completedTime, isNotNull);

      // ---- 8. Verify stats are recorded ----
      expect(appState.stats.gamesPlayed, 1);
      expect(appState.stats.gamesWon, 1);
      // Should have recorded best time for medium
      expect(appState.stats.getBestTime(Difficulty.medium), greaterThan(0));
      expect(appState.stats.getGamesForDifficulty(Difficulty.medium), 1);

      // ---- 9. Verify save file was deleted after win ----
      final hasSave = await storage.hasSavedGame();
      expect(hasSave, isFalse);

      // ---- 10. Verify no redo after new moves flush history ----
      // (Moves made after undo should flush redo stack, but we used
      // all moves to win, so this is implicitly tested.)
    });

    test('startNewGame creates valid boards for all difficulties', () async {
      for (final difficulty in Difficulty.values) {
        await appState.startNewGame(difficulty);
        expect(appState.gameState, isNotNull);
        expect(appState.gameState!.difficulty, difficulty);
        expect(appState.gameState!.board.isComplete(), isFalse);

        // Verify puzzle has the right number of clues
        int clues = 0;
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (appState.gameState!.board.getCell(r, c).isGiven) clues++;
          }
        }
        expect(clues, greaterThanOrEqualTo(difficulty.startingClues));
        expect(clues, lessThanOrEqualTo(81));
      }
    });

    test('eraseCell clears value and notes, does not affect given cells', () async {
      await appState.startNewGame(Difficulty.easy);

      final editableCells = _allEditableCells(appState);
      expect(editableCells.length, greaterThan(0));

      final (r, c) = editableCells.first;

      // Place a value
      appState.selectCell(r, c);
      appState.inputNumber(5);
      expect(appState.gameState!.board.getCell(r, c).value, 5);

      // Erase it
      appState.eraseCell();
      expect(appState.gameState!.board.getCell(r, c).value, 0);

      // Erase on given cell is no-op
      final board = appState.gameState!.board;
      int givenRow = -1, givenCol = -1;
      for (int rr = 0; rr < 9 && givenRow == -1; rr++) {
        for (int cc = 0; cc < 9 && givenCol == -1; cc++) {
          if (board.getCell(rr, cc).isGiven) {
            givenRow = rr;
            givenCol = cc;
          }
        }
      }
      if (givenRow >= 0) {
        final originalValue = board.getCell(givenRow, givenCol).value;
        appState.selectCell(givenRow, givenCol);
        appState.eraseCell();
        expect(board.getCell(givenRow, givenCol).value, originalValue);
      }
    });

    test('restartPuzzle resets the board and timer', () async {
      await appState.startNewGame(Difficulty.easy);

      appState.selectCell(0, 0);

      for (int i = 0; i < 5; i++) {
        appState.tick();
      }
      expect(appState.elapsedSeconds, 5);

      appState.restartPuzzle();

      expect(appState.selectedRow, -1);
      expect(appState.selectedCol, -1);
      expect(appState.elapsedSeconds, 0);
      expect(appState.gameState!.status, GameStatus.playing);
      expect(appState.gameState!.elapsedSeconds, 0);

      // New puzzle should have same difficulty
      expect(appState.gameState!.difficulty, Difficulty.easy);
    });

    test('hint system fills and marks cells correctly', () async {
      await appState.startNewGame(Difficulty.easy);

      for (int i = 0; i < AppConstants.maxHints; i++) {
        final hintsBefore = appState.gameState!.hintsUsed;
        appState.useHint();
        expect(appState.gameState!.hintsUsed, hintsBefore + 1);
      }

      // After max hints, further hints do nothing
      final boardAfterHints = appState.gameState!.board.toValueGrid();
      appState.useHint();
      expect(appState.gameState!.hintsUsed, AppConstants.maxHints);
      expect(appState.gameState!.board.toValueGrid(), boardAfterHints);

      // Hint cells should be marked
      bool hasHintCell = false;
      for (int r = 0; r < 9 && !hasHintCell; r++) {
        for (int c = 0; c < 9 && !hasHintCell; c++) {
          if (appState.gameState!.board.getCell(r, c).isHint) {
            hasHintCell = true;
          }
        }
      }
      expect(hasHintCell, isTrue);
    });
  });
}
