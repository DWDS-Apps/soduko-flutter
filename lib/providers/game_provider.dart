import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sudoku_board.dart';
import '../models/game_state.dart';
import '../models/settings_model.dart';
import '../models/player_stats.dart';
import '../services/puzzle_generator.dart';
import '../services/sudoku_solver.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class GameProvider extends ChangeNotifier {
  final StorageService _storage;
  final PuzzleGenerator _generator = PuzzleGenerator();

  GameState? _gameState;
  GameState? get gameState => _gameState;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedRow = -1;
  int _selectedCol = -1;
  int get selectedRow => _selectedRow;
  int get selectedCol => _selectedCol;

  bool _notesMode = false;
  bool get notesMode => _notesMode;

  Timer? _timer;
  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isRunning => _timer != null && _timer!.isActive;

  GameProvider(this._storage);

  // ---- Game Initialization ----
  Future<void> startNewGame(Difficulty difficulty) async {
    _gameState = null;
    _elapsedSeconds = 0;
    _selectedRow = -1;
    _selectedCol = -1;
    _notesMode = false;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 50));

    final (puzzleGrid, solutionGrid) =
        _generator.generatePuzzle(difficulty.startingClues);

    final board = SudokuBoard.fromGrid(puzzleGrid);
    final solution = SudokuBoard.fromGrid(solutionGrid);

    _gameState = GameState(
      board: board,
      solution: solution,
      difficulty: difficulty,
      startTime: DateTime.now(),
    );

    _startTimer();
    await _autoSave();
    notifyListeners();
  }

  Future<void> loadSavedGame() async {
    _isLoading = true;
    notifyListeners();

    final saved = await _storage.loadGame();
    if (saved != null) {
      _gameState = saved;
      _elapsedSeconds = saved.elapsedSeconds;

      if (saved.status == GameStatus.playing) {
        _startTimer();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> hasSavedGame() async {
    return await _storage.hasSavedGame();
  }

  // ---- Cell Selection ----
  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRow = -1;
    _selectedCol = -1;
    notifyListeners();
  }

  // ---- Number Input ----
  void inputNumber(int number) {
    if (_gameState == null ||
        _gameState!.status != GameStatus.playing) return;
    if (_selectedRow < 0 || _selectedCol < 0) return;

    final cell = _gameState!.board.getCell(_selectedRow, _selectedCol);
    if (cell.isGiven) return;

    if (_notesMode) {
      // Toggle note
      _gameState!.board.toggleNote(_selectedRow, _selectedCol, number);

      // Record move
      final move = Move(
        row: _selectedRow,
        col: _selectedCol,
        previousValue: 0,
        newValue: 0,
        previousNotes: Set.from(cell.notes),
        newNotes: Set.from(cell.notes),
      );
      _recordMove(move);
    } else {
      // Place number
      final previousValue = cell.value;

      // Check for conflicts
      final isValid =
          _gameState!.board.isValidPlacement(_selectedRow, _selectedCol, number);

      _gameState!.board.setCellValue(_selectedRow, _selectedCol, number);

      if (!isValid) {
        _gameState = _gameState!.copyWith(
          mistakes: _gameState!.mistakes + 1,
        );
      }

      _gameState!.board.updateConflicts();

      final move = Move(
        row: _selectedRow,
        col: _selectedCol,
        previousValue: previousValue,
        newValue: number,
      );
      _recordMove(move);

      // Check completion
      if (_gameState!.board.isComplete() && !_gameState!.board.hasConflicts()) {
        _completeGame();
      }
    }

    notifyListeners();
    _autoSave();
  }

  void eraseCell() {
    if (_gameState == null ||
        _gameState!.status != GameStatus.playing) return;
    if (_selectedRow < 0 || _selectedCol < 0) return;

    final cell = _gameState!.board.getCell(_selectedRow, _selectedCol);
    if (cell.isGiven) return;

    final move = Move(
      row: _selectedRow,
      col: _selectedCol,
      previousValue: cell.value,
      newValue: 0,
      previousNotes: Set.from(cell.notes),
      newNotes: {},
    );

    _gameState!.board.clearCell(_selectedRow, _selectedCol);
    _gameState!.board.updateConflicts();
    _recordMove(move);
    notifyListeners();
    _autoSave();
  }

  // ---- Notes Mode ----
  void toggleNotesMode() {
    _notesMode = !_notesMode;
    notifyListeners();
  }

  // ---- Hint ----
  void useHint() {
    if (_gameState == null ||
        _gameState!.status != GameStatus.playing) return;
    if (_gameState!.hintsUsed >= AppConstants.maxHints) return;

    final boardGrid = _gameState!.board.toValueGrid();
    final solutionGrid = _gameState!.solution.toValueGrid();
    final hint = SudokuSolver.getHint(boardGrid, solutionGrid);

    if (hint != null) {
      final index = hint.keys.first;
      final value = hint.values.first;
      final row = index ~/ 9;
      final col = index % 9;

      _gameState!.board.setCellValue(row, col, value);
      _gameState!.board.getCell(row, col).isHint = true;
      _gameState!.board.updateConflicts();
      _gameState = _gameState!.copyWith(
        hintsUsed: _gameState!.hintsUsed + 1,
      );

      _selectedRow = row;
      _selectedCol = col;

      if (_gameState!.board.isComplete() && !_gameState!.board.hasConflicts()) {
        _completeGame();
      }

      notifyListeners();
      _autoSave();
    }
  }

  // ---- Undo/Redo ----
  void _recordMove(Move move) {
    final history = List<Move>.from(_gameState!.history);
    final index = _gameState!.historyIndex;

    // Remove any future moves if we're in the middle of history
    if (index < history.length - 1) {
      history.removeRange(index + 1, history.length);
    }

    history.add(move);
    _gameState = _gameState!.copyWith(
      history: history,
      historyIndex: history.length - 1,
    );
  }

  void undo() {
    if (_gameState == null || !_gameState!.canUndo) return;

    final history = _gameState!.history;
    final index = _gameState!.historyIndex;
    final move = history[index];

    final cell = _gameState!.board.getCell(move.row, move.col);
    if (!cell.isGiven) {
      cell.value = move.previousValue;
      cell.notes = Set.from(move.previousNotes);
      cell.isHint = false;
      _gameState!.board.updateConflicts();
    }

    _gameState = _gameState!.copyWith(
      historyIndex: index - 1,
    );
    _selectedRow = move.row;
    _selectedCol = move.col;
    notifyListeners();
    _autoSave();
  }

  void redo() {
    if (_gameState == null || !_gameState!.canRedo) return;

    final history = _gameState!.history;
    final index = _gameState!.historyIndex + 1;
    final move = history[index];

    final cell = _gameState!.board.getCell(move.row, move.col);
    if (!cell.isGiven) {
      cell.value = move.newValue;
      cell.notes = Set.from(move.newNotes);
      _gameState!.board.updateConflicts();
    }

    _gameState = _gameState!.copyWith(
      historyIndex: index,
    );
    _selectedRow = move.row;
    _selectedCol = move.col;
    notifyListeners();
    _autoSave();
  }

  // ---- Timer ----
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameState?.status == GameStatus.playing) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  void pauseGame() {
    _gameState = _gameState!.copyWith(status: GameStatus.paused);
    notifyListeners();
    _autoSave();
  }

  void resumeGame() {
    _gameState = _gameState!.copyWith(status: GameStatus.playing);
    notifyListeners();
  }

  void restartPuzzle() {
    if (_gameState == null) return;
    final (puzzleGrid, solutionGrid) =
        _generator.generatePuzzle(_gameState!.difficulty.startingClues);

    final board = SudokuBoard.fromGrid(puzzleGrid);
    final solution = SudokuBoard.fromGrid(solutionGrid);

    _elapsedSeconds = 0;
    _selectedRow = -1;
    _selectedCol = -1;

    _gameState = GameState(
      board: board,
      solution: solution,
      difficulty: _gameState!.difficulty,
      startTime: DateTime.now(),
    );

    _startTimer();
    notifyListeners();
    _autoSave();
  }

  // ---- Completion ----
  void _completeGame() {
    _timer?.cancel();
    _gameState = _gameState!.copyWith(
      status: GameStatus.won,
      completedTime: DateTime.now(),
    );
    notifyListeners();
    _storage.deleteSave();
  }

  // ---- Auto Save ----
  Future<void> _autoSave() async {
    if (_gameState != null) {
      await _storage.saveGame(
        _gameState!.copyWith(elapsedSeconds: _elapsedSeconds),
      );
    }
  }

  // ---- Cleanup ----
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---- Utility ----
  Set<int> getSameNumberCells(int value) {
    if (value == 0) return {};
    final cells = <int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_gameState?.board.getCell(r, c).value == value) {
          cells.add(r * 9 + c);
        }
      }
    }
    return cells;
  }

  Set<int> getHighlightedCells() {
    if (_selectedRow < 0 || _selectedCol < 0) return {};
    final cells = <int>{};

    // Same row and column
    for (int i = 0; i < 9; i++) {
      cells.add(_selectedRow * 9 + i); // row
      cells.add(i * 9 + _selectedCol); // col
    }

    // Same 3x3 box
    final boxRow = (_selectedRow ~/ 3) * 3;
    final boxCol = (_selectedCol ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        cells.add(r * 9 + c);
      }
    }

    return cells;
  }

  bool isCellHighlighted(int row, int col) {
    if (_selectedRow < 0 || _selectedCol < 0) return false;

    if (row == _selectedRow && col == _selectedCol) return false; // selected cell

    if (row == _selectedRow || col == _selectedCol) return true;
    final boxRow = (_selectedRow ~/ 3) * 3;
    final boxCol = (_selectedCol ~/ 3) * 3;
    if (row >= boxRow && row < boxRow + 3 && col >= boxCol && col < boxCol + 3) {
      return true;
    }
    return false;
  }
}
