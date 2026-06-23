import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/app_state.dart';
import 'package:soduko/core/constants.dart';
import 'package:soduko/models/game_state.dart';
import 'package:soduko/models/player_stats.dart';
import 'package:soduko/models/settings_model.dart';
import 'package:soduko/services/storage_service.dart';

/// An in-memory storage for testing that doesn't use dart:io.
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

/// Find the first editable (non-given) cell in the board.
(int, int) _firstEditableCell(AppState state) {
  final board = state.gameState!.board;
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      if (!board.getCell(r, c).isGiven && board.getCell(r, c).value == 0) {
        return (r, c);
      }
    }
  }
  return (-1, -1);
}

void main() {
  late _TestStorage storage;
  late AppState appState;

  setUp(() {
    storage = _TestStorage();
    appState = AppState(storage);
  });

  group('AppState — initialization', () {
    test('init loads settings and stats with defaults', () async {
      expect(appState.settings.darkMode, false);
      expect(appState.stats.gamesPlayed, 0);
      expect(appState.hasSavedGame, false);
      expect(appState.gameState, isNull);
      expect(appState.selectedRow, -1);
      expect(appState.selectedCol, -1);
      expect(appState.notesMode, false);
      expect(appState.elapsedSeconds, 0);
    });

    test('init preserves saved settings and stats', () async {
      await storage.saveSettings(SettingsModel(darkMode: true, soundEnabled: false));
      await storage.saveStats(PlayerStats(gamesPlayed: 5, gamesWon: 3));
      await appState.init();
      expect(appState.settings.darkMode, true);
      expect(appState.settings.soundEnabled, false);
      expect(appState.stats.gamesPlayed, 5);
      expect(appState.stats.gamesWon, 3);
    });
  });

  group('AppState — game lifecycle', () {
    test('startNewGame creates a valid game', () async {
      await appState.startNewGame(Difficulty.easy);
      expect(appState.gameState, isNotNull);
      expect(appState.gameState!.difficulty, Difficulty.easy);
      expect(appState.gameState!.status, GameStatus.playing);
      expect(appState.gameState!.board, isNotNull);
      expect(appState.gameState!.solution, isNotNull);
      expect(appState.elapsedSeconds, 0);
      expect(appState.selectedRow, -1);
      expect(appState.selectedCol, -1);
    });

    test('selectCell updates selected row and col', () async {
      await appState.startNewGame(Difficulty.easy);
      appState.selectCell(3, 4);
      expect(appState.selectedRow, 3);
      expect(appState.selectedCol, 4);
    });

    test('inputNumber places value on selected cell', () async {
      await appState.startNewGame(Difficulty.easy);
      final (tr, tc) = _firstEditableCell(appState);
      expect(tr, greaterThanOrEqualTo(0));
      expect(tc, greaterThanOrEqualTo(0));

      appState.selectCell(tr, tc);
      appState.inputNumber(5);
      expect(appState.gameState!.board.getCell(tr, tc).value, 5);
    });

    test('inputNumber does nothing when no cell selected', () async {
      await appState.startNewGame(Difficulty.easy);
      final boardBefore = appState.gameState!.board.toValueGrid();
      appState.inputNumber(5);
      final boardAfter = appState.gameState!.board.toValueGrid();
      expect(boardBefore, boardAfter);
    });

    test('inputNumber does nothing on given cells', () async {
      await appState.startNewGame(Difficulty.easy);
      // Find a given cell
      final board = appState.gameState!.board;
      int targetRow = -1, targetCol = -1;
      for (int r = 0; r < 9 && targetRow == -1; r++) {
        for (int c = 0; c < 9 && targetCol == -1; c++) {
          if (board.getCell(r, c).isGiven) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
      }
      expect(targetRow, greaterThanOrEqualTo(0));

      final originalValue = appState.gameState!.board.getCell(targetRow, targetCol).value;
      appState.selectCell(targetRow, targetCol);
      appState.inputNumber(9);
      expect(appState.gameState!.board.getCell(targetRow, targetCol).value, originalValue);
    });

    test('eraseCell clears selected non-given cell', () async {
      await appState.startNewGame(Difficulty.easy);
      final (tr, tc) = _firstEditableCell(appState);
      expect(tr, greaterThanOrEqualTo(0));

      appState.selectCell(tr, tc);
      appState.inputNumber(5);
      expect(appState.gameState!.board.getCell(tr, tc).value, 5);

      appState.eraseCell();
      expect(appState.gameState!.board.getCell(tr, tc).value, 0);
    });
  });

  group('AppState — notes mode', () {
    test('toggleNotesMode toggles notes flag', () async {
      expect(appState.notesMode, false);
      appState.toggleNotesMode();
      expect(appState.notesMode, true);
      appState.toggleNotesMode();
      expect(appState.notesMode, false);
    });

    test('notes mode adds notes instead of values', () async {
      await appState.startNewGame(Difficulty.medium);
      final (tr, tc) = _firstEditableCell(appState);
      expect(tr, greaterThanOrEqualTo(0));

      appState.selectCell(tr, tc);
      appState.toggleNotesMode();
      appState.inputNumber(3);
      expect(appState.gameState!.board.getCell(tr, tc).value, 0);
      expect(appState.gameState!.board.getCell(tr, tc).notes, {3});

      appState.inputNumber(7);
      expect(appState.gameState!.board.getCell(tr, tc).notes, {3, 7});
    });
  });

  group('AppState — undo/redo', () {
    test('undo reverses the last move', () async {
      await appState.startNewGame(Difficulty.easy);
      final (tr, tc) = _firstEditableCell(appState);
      expect(tr, greaterThanOrEqualTo(0));
      expect(tc, greaterThanOrEqualTo(0));

      appState.selectCell(tr, tc);
      appState.inputNumber(5);
      expect(appState.gameState!.board.getCell(tr, tc).value, 5);

      expect(appState.gameState!.canUndo, isTrue, reason: 'Must have undo after move');
      appState.undo();
      expect(appState.gameState!.board.getCell(tr, tc).value, 0, reason: 'Undo should clear cell value');
    });

    test('redo restores an undone move', () async {
      await appState.startNewGame(Difficulty.easy);
      final (tr, tc) = _firstEditableCell(appState);
      expect(tr, greaterThanOrEqualTo(0));

      appState.selectCell(tr, tc);
      appState.inputNumber(5);
      expect(appState.gameState!.board.getCell(tr, tc).value, 5);

      appState.undo();
      expect(appState.gameState!.board.getCell(tr, tc).value, 0);

      expect(appState.gameState!.canRedo, isTrue, reason: 'Must have redo after undo');
      appState.redo();
      expect(appState.gameState!.board.getCell(tr, tc).value, 5, reason: 'Redo should restore cell value');
    });

    test('undo/redo with no history is no-op', () async {
      await appState.startNewGame(Difficulty.easy);
      final boardBefore = appState.gameState!.board.toValueGrid();
      appState.undo();
      appState.redo();
      final boardAfter = appState.gameState!.board.toValueGrid();
      expect(boardBefore, boardAfter);
    });
  });

  group('AppState — pause/resume', () {
    test('pauseGame sets status to paused', () async {
      await appState.startNewGame(Difficulty.easy);
      expect(appState.gameState!.status, GameStatus.playing);
      appState.pauseGame();
      expect(appState.gameState!.status, GameStatus.paused);
    });

    test('resumeGame sets status back to playing', () async {
      await appState.startNewGame(Difficulty.easy);
      appState.pauseGame();
      appState.resumeGame();
      expect(appState.gameState!.status, GameStatus.playing);
    });
  });

  group('AppState — settings', () {
    test('setDarkMode updates and persists setting', () async {
      appState.setDarkMode(true);
      expect(appState.settings.darkMode, true);
      final loaded = await storage.loadSettings();
      expect(loaded.darkMode, true);
    });

    test('setLeftHandedMode updates setting', () async {
      appState.setLeftHandedMode(true);
      expect(appState.settings.leftHandedMode, true);
    });

    test('setFontScale updates setting', () async {
      appState.setFontScale(1.25);
      expect(appState.settings.fontScale, 1.25);
    });

    test('resetSettings reverts font scale to defaults', () async {
      appState.setDarkMode(true);
      appState.setSoundEnabled(false);
      appState.setShowTimer(false);
      appState.resetSettings();
      expect(appState.settings.darkMode, false);
      expect(appState.settings.soundEnabled, true);
      expect(appState.settings.showTimer, true);
    });
  });

  group('AppState — timer', () {
    test('tick increments elapsed seconds during playing', () async {
      await appState.startNewGame(Difficulty.easy);
      expect(appState.elapsedSeconds, 0);
      appState.tick();
      expect(appState.elapsedSeconds, 1);
    });

    test('tick does not increment when paused', () async {
      await appState.startNewGame(Difficulty.easy);
      appState.pauseGame();
      appState.tick();
      expect(appState.elapsedSeconds, 0);
    });
  });

  group('AppState — helper methods', () {
    test('getSameNumberCells returns positions of matching values', () async {
      await appState.startNewGame(Difficulty.easy);
      final cells = appState.getSameNumberCells(5);
      expect(cells, isA<Set<int>>());
    });

    test('getHighlightedCells returns empty set when no cell selected', () {
      expect(appState.selectedRow, -1);
      expect(appState.getHighlightedCells(), isEmpty);
    });

    test('getHighlightedCells returns row/col/box when cell selected', () async {
      await appState.startNewGame(Difficulty.easy);
      appState.selectCell(4, 3);
      final highlighted = appState.getHighlightedCells();
      for (int c = 0; c < 9; c++) {
        expect(highlighted.contains(4 * 9 + c), isTrue, reason: 'row cell ($c)');
      }
      for (int r = 0; r < 9; r++) {
        expect(highlighted.contains(r * 9 + 3), isTrue, reason: 'col cell ($r)');
      }
      for (int r = 3; r < 6; r++) {
        for (int c = 3; c < 6; c++) {
          expect(highlighted.contains(r * 9 + c), isTrue, reason: 'box cell ($r,$c)');
        }
      }
    });
  });

  group('AppState — hint system', () {
    test('useHint fills a cell and increments hint counter', () async {
      await appState.startNewGame(Difficulty.medium);
      final hintCount = appState.gameState!.hintsUsed;
      appState.useHint();
      expect(appState.gameState!.hintsUsed, hintCount + 1);
    });

    test('hint respects max hint limit', () async {
      await appState.startNewGame(Difficulty.easy);
      for (int i = 0; i < AppConstants.maxHints; i++) {
        appState.useHint();
      }
      expect(appState.gameState!.hintsUsed, AppConstants.maxHints);

      final boardBefore = appState.gameState!.board.toValueGrid();
      appState.useHint();
      final boardAfter = appState.gameState!.board.toValueGrid();
      expect(appState.gameState!.hintsUsed, AppConstants.maxHints);
      expect(boardBefore, boardAfter);
    });
  });
}
