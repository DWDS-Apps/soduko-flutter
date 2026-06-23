import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/app_state.dart';
import 'package:soduko/core/constants.dart';
import 'package:soduko/models/game_state.dart';
import 'package:soduko/models/player_stats.dart';
import 'package:soduko/models/settings_model.dart';
import 'package:soduko/models/sudoku_board.dart';
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

void main() {
  group('Edge Cases', () {
    late _TestStorage storage;
    late AppState appState;

    setUp(() {
      storage = _TestStorage();
      appState = AppState(storage);
    });

    group('Empty board handling', () {
      test('SudokuBoard.empty() creates all-zero cells', () {
        final board = SudokuBoard.empty();
        for (int r = 0; r < AppConstants.gridSize; r++) {
          for (int c = 0; c < AppConstants.gridSize; c++) {
            final cell = board.getCell(r, c);
            expect(cell.value, 0);
            expect(cell.isEmpty, isTrue);
            expect(cell.isGiven, isFalse);
            expect(cell.isConflicting, isFalse);
          }
        }
      });

      test('empty board isComplete returns false', () {
        final board = SudokuBoard.empty();
        expect(board.isComplete(), isFalse);
      });

      test('empty board hasConflicts returns false', () {
        final board = SudokuBoard.empty();
        expect(board.hasConflicts(), isFalse);
      });

      test('empty board accepts any valid placement', () {
        final board = SudokuBoard.empty();
        expect(board.isValidPlacement(0, 0, 1), isTrue);
        expect(board.isValidPlacement(8, 8, 9), isTrue);
        expect(board.isValidPlacement(4, 4, 5), isTrue);
      });

      test('empty board toValueGrid returns all zeros', () {
        final board = SudokuBoard.empty();
        final grid = board.toValueGrid();
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            expect(grid[r][c], 0);
          }
        }
      });

      test('empty board JSON roundtrip', () {
        final board = SudokuBoard.empty();
        final json = board.toJson();
        final restored = SudokuBoard.fromJson(json);
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            expect(restored.getCell(r, c).value, 0);
          }
        }
      });
    });

    group('All cells filled', () {
      test('board with all cells filled isComplete returns true', () {
        final board = SudokuBoard.empty();
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            board.setCellValue(r, c, ((r + c) % 9) + 1);
          }
        }
        expect(board.isComplete(), isTrue);
      });

      test('all cells filled but with conflicts returns hasConflicts true', () {
        final board = SudokuBoard.empty();
        // Fill all cells with the same value — guaranteed conflicts
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            board.setCellValue(r, c, 1);
          }
        }
        expect(board.isComplete(), isTrue);
        expect(board.hasConflicts(), isTrue);
      });

      test('all cells filled correctly isComplete true, hasConflicts false', () {
        final board = SudokuBoard.empty();
        final grid = [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ];
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            board.setCellValue(r, c, grid[r][c]);
          }
        }
        expect(board.isComplete(), isTrue);
        expect(board.hasConflicts(), isFalse);
      });

      test('updateConflicts correctly marks all conflicting cells', () {
        final board = SudokuBoard.empty();
        board.setCellValue(0, 0, 5);
        board.setCellValue(0, 1, 5); // row conflict with (0,0)
        board.setCellValue(1, 0, 5); // col conflict with (0,0)
        board.setCellValue(1, 1, 9); // no conflict
        board.updateConflicts();

        expect(board.getCell(0, 0).isConflicting, isTrue);
        expect(board.getCell(0, 1).isConflicting, isTrue);
        expect(board.getCell(1, 0).isConflicting, isTrue);
        expect(board.getCell(1, 1).isConflicting, isFalse);
      });
    });

    group('Save and restore', () {
      test('save and restore game preserves all state', () async {
        await appState.startNewGame(Difficulty.hard);

        // Make some moves
        final board = appState.gameState!.board;
        final solution = appState.gameState!.solution.toValueGrid();
        int movesMade = 0;

        // Make 3 moves, but tick before the LAST move
        // so elapsedSeconds is captured by auto-save
        for (int r = 0; r < 9 && movesMade < 2; r++) {
          for (int c = 0; c < 9 && movesMade < 2; c++) {
            if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
              appState.selectCell(r, c);
              appState.inputNumber(solution[r][c]);
              movesMade++;
            }
          }
        }

        // Now tick twice before the 3rd move
        appState.tick();
        appState.tick();
        expect(appState.elapsedSeconds, 2);

        // Make the 3rd move — this auto-saves with elapsedSeconds=2
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
              appState.selectCell(r, c);
              appState.inputNumber(solution[r][c]);
              movesMade++;
              r = 9; // break outer loop
              break;
            }
          }
        }

        // Save happens on each move via _autoSave
        final hasSave = await storage.hasSavedGame();
        expect(hasSave, isTrue);

        // ---- Restore into a new AppState ----
        final storage2 = _TestStorage();
        // Copy the persisted data
        final savedGameData = await storage.loadGame();
        if (savedGameData != null) {
          await storage2.saveGame(savedGameData);
        }
        final appState2 = AppState(storage2);
        await appState2.loadSavedGame();

        // Verify restored state
        expect(appState2.gameState, isNotNull);
        expect(appState2.gameState!.difficulty, Difficulty.hard);
        expect(appState2.gameState!.status, GameStatus.playing);
        expect(appState2.elapsedSeconds, 2);

        // Verify board state matches
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            expect(
              appState2.gameState!.board.getCell(r, c).value,
              appState.gameState!.board.getCell(r, c).value,
            );
          }
        }

        // Verify undo is preserved
        expect(appState2.gameState!.canUndo, isTrue);
      });

      test('save and restore with no saved game returns null', () async {
        expect(await storage.hasSavedGame(), isFalse);
        final loaded = await storage.loadGame();
        expect(loaded, isNull);
      });

      test('deleteSave clears saved game', () async {
        await appState.startNewGame(Difficulty.easy);
        expect(await storage.hasSavedGame(), isTrue);

        await storage.deleteSave();
        expect(await storage.hasSavedGame(), isFalse);
        final loaded = await storage.loadGame();
        expect(loaded, isNull);
      });
    });

    group('Stats edge cases', () {
      test('PlayerStats defaults are zero', () {
        final stats = PlayerStats();
        expect(stats.gamesPlayed, 0);
        expect(stats.gamesWon, 0);
        expect(stats.currentStreak, 0);
        expect(stats.longestStreak, 0);
        expect(stats.totalHintsUsed, 0);
        expect(stats.averageTime, 0.0);
        expect(stats.winPercentage, 0.0);
        expect(stats.getBestTime(Difficulty.easy), 0);
        expect(stats.getGamesForDifficulty(Difficulty.easy), 0);
      });

      test('recordGame increments stats', () {
        final stats = PlayerStats();
        stats.recordGame(Difficulty.easy, 120, true, hintsUsed: 2);
        expect(stats.gamesPlayed, 1);
        expect(stats.gamesWon, 1);
        expect(stats.currentStreak, 1);
        expect(stats.longestStreak, 1);
        expect(stats.totalHintsUsed, 2);

        // Best time recorded
        expect(stats.getBestTime(Difficulty.easy), 120);
        expect(stats.getGamesForDifficulty(Difficulty.easy), 1);
      });

      test('recordGame with loss increments gamesPlayed but not won', () {
        final stats = PlayerStats();
        stats.recordGame(Difficulty.easy, 60, false, hintsUsed: 1);
        expect(stats.gamesPlayed, 1);
        expect(stats.gamesWon, 0);
        expect(stats.currentStreak, 0);
      });

      test('bestTime tracks minimum', () {
        final stats = PlayerStats();
        stats.recordGame(Difficulty.easy, 200, true);
        stats.recordGame(Difficulty.easy, 150, true);
        stats.recordGame(Difficulty.easy, 300, true);
        expect(stats.getBestTime(Difficulty.easy), 150);
        expect(stats.getGamesForDifficulty(Difficulty.easy), 3);
      });

      test('streak tracking across difficulties', () {
        final stats = PlayerStats();
        stats.recordGame(Difficulty.easy, 100, true);
        expect(stats.currentStreak, 1);
        expect(stats.longestStreak, 1);

        stats.recordGame(Difficulty.medium, 200, true);
        expect(stats.currentStreak, 2);
        expect(stats.longestStreak, 2);

        stats.recordGame(Difficulty.easy, 150, false);
        expect(stats.currentStreak, 0);
        expect(stats.longestStreak, 2);

        stats.recordGame(Difficulty.hard, 300, true);
        expect(stats.currentStreak, 1);
        expect(stats.longestStreak, 2);
      });

      test('bestTime JSON roundtrip', () {
        final stats = PlayerStats();
        stats.recordGame(Difficulty.easy, 120, true);
        stats.recordGame(Difficulty.medium, 240, true);

        final json = stats.toJson();
        final restored = PlayerStats.fromJson(json);

        expect(restored.gamesPlayed, 2);
        expect(restored.gamesWon, 2);
        expect(restored.getBestTime(Difficulty.easy), 120);
        expect(restored.getBestTime(Difficulty.medium), 240);
      });
    });

    group('AppState before game started', () {
      test('inputNumber does nothing without a game', () {
        expect(appState.gameState, isNull);
        appState.inputNumber(5);
        expect(appState.gameState, isNull);
      });

      test('useHint does nothing without a game', () {
        expect(appState.gameState, isNull);
        appState.useHint();
        expect(appState.gameState, isNull);
      });

      test('undo/redo are no-ops without a game', () {
        appState.undo();
        appState.redo();
        expect(appState.gameState, isNull);
      });

      test('pauseGame does nothing without a game', () {
        appState.pauseGame();
        expect(appState.gameState, isNull);
      });

      test('tick does nothing without a game', () {
        expect(appState.elapsedSeconds, 0);
        appState.tick();
        expect(appState.elapsedSeconds, 0);
      });

      test('selectCell sets row/col regardless of game state', () {
        appState.selectCell(3, 5);
        expect(appState.selectedRow, 3);
        expect(appState.selectedCol, 5);
      });
    });

    group('Game completion edge cases', () {
      test('game does not complete with conflicts', () async {
        await appState.startNewGame(Difficulty.easy);
        final solution = appState.gameState!.solution.toValueGrid();
        final board = appState.gameState!.board;

        // Find two editable cells in the same row
        (int, int)? cellA;
        (int, int)? cellB;
        for (int r = 0; r < 9 && cellA == null; r++) {
          final emptyInRow = <int>[];
          for (int c = 0; c < 9; c++) {
            if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
              emptyInRow.add(c);
            }
          }
          if (emptyInRow.length >= 2) {
            cellA = (r, emptyInRow[0]);
            cellB = (r, emptyInRow[1]);
          }
        }

        expect(cellA, isNotNull);
        expect(cellB, isNotNull);

        // Place the correct solution value in cellA
        appState.selectCell(cellA!.$1, cellA.$2);
        appState.inputNumber(solution[cellA.$1][cellA.$2]);
        expect(appState.gameState!.mistakes, 0);

        // Place the SAME value in cellB (same row) to guarantee a conflict
        appState.selectCell(cellB!.$1, cellB.$2);
        appState.inputNumber(solution[cellA.$1][cellA.$2]);

        expect(appState.gameState!.status, GameStatus.playing);
        expect(appState.gameState!.mistakes, 1);
        expect(appState.gameState!.board.hasConflicts(), isTrue);
      });

      test('erase removes conflicts', () async {
        await appState.startNewGame(Difficulty.easy);
        final solution = appState.gameState!.solution.toValueGrid();
        final board = appState.gameState!.board;

        // Find two editable cells in the same row
        (int, int)? cellA;
        (int, int)? cellB;
        for (int r = 0; r < 9 && cellA == null; r++) {
          final emptyInRow = <int>[];
          for (int c = 0; c < 9; c++) {
            if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
              emptyInRow.add(c);
            }
          }
          if (emptyInRow.length >= 2) {
            cellA = (r, emptyInRow[0]);
            cellB = (r, emptyInRow[1]);
          }
        }

        expect(cellA, isNotNull);
        expect(cellB, isNotNull);

        // Place correct value in cellA
        appState.selectCell(cellA!.$1, cellA.$2);
        appState.inputNumber(solution[cellA.$1][cellA.$2]);

        // Place the SAME value in cellB (same row) to create a guaranteed conflict
        appState.selectCell(cellB!.$1, cellB.$2);
        appState.inputNumber(solution[cellA.$1][cellA.$2]);
        expect(appState.gameState!.board.hasConflicts(), isTrue);

        // Erase cellB — conflict should clear
        appState.selectCell(cellB.$1, cellB.$2);
        appState.eraseCell();
        appState.gameState!.board.updateConflicts();
        expect(appState.gameState!.board.hasConflicts(), isFalse);
      });

      test('correct placement increments no mistakes', () async {
        await appState.startNewGame(Difficulty.easy);
        final solution = appState.gameState!.solution.toValueGrid();
        final board = appState.gameState!.board;

        // Find one editable cell
        (int, int)? cell;
        for (int r = 0; r < 9 && cell == null; r++) {
          for (int c = 0; c < 9 && cell == null; c++) {
            if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
              cell = (r, c);
            }
          }
        }

        expect(cell, isNotNull);

        appState.selectCell(cell!.$1, cell.$2);
        appState.inputNumber(solution[cell.$1][cell.$2]);
        expect(appState.gameState!.mistakes, 0);
      });
    });
  });
}
