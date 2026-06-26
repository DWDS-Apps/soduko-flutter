import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/puzzle_generator.dart';
import 'models/player_stats.dart';
import 'models/settings_model.dart';
import 'core/constants.dart';
import 'models/sudoku_board.dart';
import 'models/game_state.dart';
import 'services/sudoku_solver.dart';

/// Central application state — replaces provider.
class AppState extends ChangeNotifier {
  final StorageService storage;
  final PuzzleGenerator generator = PuzzleGenerator();

  // Game state
  GameState? gameState;
  int selectedRow = -1;
  int selectedCol = -1;
  bool notesMode = false;
  int elapsedSeconds = 0;

  // Settings
  SettingsModel settings = SettingsModel();

  // Stats
  PlayerStats stats = PlayerStats();

  AppState(this.storage);

  Future<void> init() async {
    settings = await storage.loadSettings();
    stats = await storage.loadStats();
    notifyListeners();
  }

  bool get hasSavedGame => _hasSavedGameCache;
  bool _hasSavedGameCache = false;

  Future<void> checkSavedGame() async {
    _hasSavedGameCache = await storage.hasSavedGame();
    notifyListeners();
  }

  // ---- Game Lifecycle ----
  Future<void> startNewGame(Difficulty difficulty) async {
    gameState = null;
    selectedRow = -1;
    selectedCol = -1;
    notesMode = false;
    elapsedSeconds = 0;
    notifyListeners();

    final (puzzleGrid, solutionGrid) =
        generator.generatePuzzle(difficulty.startingClues);
    final board = SudokuBoard.fromGrid(puzzleGrid);
    final solution = SudokuBoard.fromGrid(solutionGrid);

    gameState = GameState(
      board: board,
      solution: solution,
      difficulty: difficulty,
      startTime: DateTime.now(),
    );
    notifyListeners();
    _autoSave();
  }

  Future<void> loadSavedGame() async {
    final saved = await storage.loadGame();
    if (saved != null) {
      gameState = saved;
      elapsedSeconds = saved.elapsedSeconds;
      notifyListeners();
    }
  }

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void inputNumber(int number) {
    if (gameState == null || gameState!.status != GameStatus.playing) return;
    if (selectedRow < 0 || selectedCol < 0) return;

    final cell = gameState!.board.getCell(selectedRow, selectedCol);
    if (cell.isGiven) return;

    if (notesMode) {
      final prevNotes = Set<int>.from(cell.notes);
      gameState!.board.toggleNote(selectedRow, selectedCol, number);
      final newNotes = Set<int>.from(cell.notes);
      _recordMove(Move(
        row: selectedRow,
        col: selectedCol,
        previousValue: 0,
        newValue: 0,
        previousNotes: prevNotes,
        newNotes: newNotes,
      ));
    } else {
      final previousValue = cell.value;
      final previousNotes = Set<int>.from(cell.notes);
      final isValid =
          gameState!.board.isValidPlacement(selectedRow, selectedCol, number);
      gameState!.board.setCellValue(selectedRow, selectedCol, number);

      if (!isValid) {
        gameState = gameState!.copyWith(mistakes: gameState!.mistakes + 1);
      }
      gameState!.board.updateConflicts();

      _recordMove(Move(
        row: selectedRow,
        col: selectedCol,
        previousValue: previousValue,
        newValue: number,
        previousNotes: previousNotes,
        newNotes: {},
      ));

      if (gameState!.board.isComplete() && !gameState!.board.hasConflicts()) {
        _completeGame();
      }
    }
    notifyListeners();
    _autoSave();
  }

  void eraseCell() {
    if (gameState == null || gameState!.status != GameStatus.playing) return;
    if (selectedRow < 0 || selectedCol < 0) return;

    final cell = gameState!.board.getCell(selectedRow, selectedCol);
    if (cell.isGiven) return;

    gameState!.board.clearCell(selectedRow, selectedCol);
    gameState!.board.updateConflicts();
    notifyListeners();
    _autoSave();
  }

  void toggleNotesMode() {
    notesMode = !notesMode;
    notifyListeners();
  }

  void useHint() {
    if (gameState == null || gameState!.status != GameStatus.playing) return;
    if (gameState!.hintsUsed >= AppConstants.maxHints) return;

    final boardGrid = gameState!.board.toValueGrid();
    final solutionGrid = gameState!.solution.toValueGrid();
    final hint = SudokuSolver.getHint(boardGrid, solutionGrid);

    if (hint != null) {
      final index = hint.keys.first;
      final value = hint.values.first;
      final row = index ~/ 9;
      final col = index % 9;

      gameState!.board.setCellValue(row, col, value);
      gameState!.board.getCell(row, col).isHint = true;
      gameState!.board.updateConflicts();
      gameState = gameState!.copyWith(hintsUsed: gameState!.hintsUsed + 1);
      selectedRow = row;
      selectedCol = col;

      if (gameState!.board.isComplete() && !gameState!.board.hasConflicts()) {
        _completeGame();
      }
      notifyListeners();
      _autoSave();
    }
  }

  void undo() {
    if (gameState == null || !gameState!.canUndo) return;
    final history = gameState!.history;
    final index = gameState!.historyIndex;
    final move = history[index];

    final cell = gameState!.board.getCell(move.row, move.col);
    if (!cell.isGiven) {
      cell.value = move.previousValue;
      cell.notes = Set.from(move.previousNotes);
      cell.isHint = false;
      gameState!.board.updateConflicts();
    }
    gameState = gameState!.copyWith(historyIndex: index - 1);
    selectedRow = move.row;
    selectedCol = move.col;
    notifyListeners();
    _autoSave();
  }

  void redo() {
    if (gameState == null || !gameState!.canRedo) return;
    final history = gameState!.history;
    final index = gameState!.historyIndex + 1;
    final move = history[index];

    final cell = gameState!.board.getCell(move.row, move.col);
    if (!cell.isGiven) {
      cell.value = move.newValue;
      cell.notes = Set.from(move.newNotes);
      gameState!.board.updateConflicts();
    }
    gameState = gameState!.copyWith(historyIndex: index);
    selectedRow = move.row;
    selectedCol = move.col;
    notifyListeners();
    _autoSave();
  }

  void pauseGame() {
    if (gameState == null || gameState!.status != GameStatus.playing) return;
    gameState = gameState!.copyWith(status: GameStatus.paused);
    notifyListeners();
  }

  void resumeGame() {
    if (gameState == null) return;
    gameState = gameState!.copyWith(status: GameStatus.playing);
    notifyListeners();
  }

  void restartPuzzle() {
    if (gameState == null) return;
    final (puzzleGrid, solutionGrid) =
        generator.generatePuzzle(gameState!.difficulty.startingClues);
    final board = SudokuBoard.fromGrid(puzzleGrid);
    final solution = SudokuBoard.fromGrid(solutionGrid);
    elapsedSeconds = 0;
    selectedRow = -1;
    selectedCol = -1;
    gameState = GameState(
        board: board,
        solution: solution,
        difficulty: gameState!.difficulty,
        startTime: DateTime.now());
    notifyListeners();
    _autoSave();
  }

  void _recordMove(Move move) {
    final history = List<Move>.from(gameState!.history);
    final index = gameState!.historyIndex;
    if (index < history.length - 1) {
      history.removeRange(index + 1, history.length);
    }
    history.add(move);
    gameState =
        gameState!.copyWith(history: history, historyIndex: history.length - 1);
  }

  void _completeGame() {
    stats.recordGame(gameState!.difficulty, elapsedSeconds, true,
        hintsUsed: gameState!.hintsUsed);
    storage.saveStats(stats);
    gameState = gameState!
        .copyWith(status: GameStatus.won, completedTime: DateTime.now());
    storage.deleteSave();
    notifyListeners();
  }

  Future<void> _autoSave() async {
    if (gameState != null && gameState!.status != GameStatus.won) {
      await storage
          .saveGame(gameState!.copyWith(elapsedSeconds: elapsedSeconds));
    }
  }

  // ---- Settings ----
  void setDarkMode(bool v) {
    settings.darkMode = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setSoundEnabled(bool v) {
    settings.soundEnabled = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setVibrationEnabled(bool v) {
    settings.vibrationEnabled = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setHighlightDuplicates(bool v) {
    settings.highlightDuplicates = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setAutoCheckMistakes(bool v) {
    settings.autoCheckMistakes = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setShowTimer(bool v) {
    settings.showTimer = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setLeftHandedMode(bool v) {
    settings.leftHandedMode = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  void setFontScale(double v) {
    settings.fontScale = v;
    storage.saveSettings(settings);
    notifyListeners();
  }

  /// Called by the game timer each second.
  void tick() {
    if (gameState?.status == GameStatus.playing) {
      elapsedSeconds++;
      notifyListeners();
    }
  }

  // ---- Helpers ----
  void resetSettings() {
    settings = SettingsModel();
    storage.saveSettings(settings);
    notifyListeners();
  }

  Set<int> getSameNumberCells(int value) {
    if (value == 0 || gameState == null) return {};
    final cells = <int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (gameState!.board.getCell(r, c).value == value) cells.add(r * 9 + c);
      }
    }
    return cells;
  }

  Set<int> getHighlightedCells() {
    if (selectedRow < 0 || selectedCol < 0) return {};
    final cells = <int>{};
    for (int i = 0; i < 9; i++) {
      cells.add(selectedRow * 9 + i);
      cells.add(i * 9 + selectedCol);
    }
    final boxRow = (selectedRow ~/ 3) * 3;
    final boxCol = (selectedCol ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        cells.add(r * 9 + c);
      }
    }
    return cells;
  }
}
