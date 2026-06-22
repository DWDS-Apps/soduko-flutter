import 'dart:math';
import 'sudoku_solver.dart';

class PuzzleGenerator {
  final Random _random = Random();

  List<List<int>> _generateCompleteGrid() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    final empty = _findEmpty(grid);
    if (empty == null) return true;
    final (row, col) = empty;

    final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

    for (final num in numbers) {
      if (SudokuSolver.isValid(grid, row, col, num)) {
        grid[row][col] = num;
        if (_fillGrid(grid)) return true;
        grid[row][col] = 0;
      }
    }
    return false;
  }

  (int, int)? _findEmpty(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return (r, c);
      }
    }
    return null;
  }

  /// Generate a puzzle with [clues] number of starting clues.
  /// Returns (puzzle, solution).
  (List<List<int>>, List<List<int>>) generatePuzzle(int clues) {
    final solution = _generateCompleteGrid();

    final puzzle = solution.map((row) => List<int>.from(row)).toList();

    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(_random);

    int cellsToRemove = 81 - clues;
    int removed = 0;

    for (final (r, c) in positions) {
      if (removed >= cellsToRemove) break;

      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      final testGrid = puzzle.map((row) => List<int>.from(row)).toList();
      final solutions = SudokuSolver.countSolutions(testGrid);

      if (solutions == 1) {
        removed++;
      } else {
        puzzle[r][c] = backup;
      }
    }

    return (puzzle, solution);
  }

  (List<List<int>>, List<List<int>>) generateDailyPuzzle(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final rng = Random(seed);

    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGridSeeded(grid, rng);
    final solution = grid.map((row) => List<int>.from(row)).toList();

    final puzzle = grid.map((row) => List<int>.from(row)).toList();
    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(rng);

    int removed = 0;
    const targetClues = 32;

    for (final (r, c) in positions) {
      if (81 - removed <= targetClues) break;
      final backup = puzzle[r][c];
      puzzle[r][c] = 0;
      final testGrid = puzzle.map((row) => List<int>.from(row)).toList();
      if (SudokuSolver.countSolutions(testGrid) == 1) {
        removed++;
      } else {
        puzzle[r][c] = backup;
      }
    }

    return (puzzle, solution);
  }

  bool _fillGridSeeded(List<List<int>> grid, Random rng) {
    final empty = _findEmpty(grid);
    if (empty == null) return true;
    final (row, col) = empty;

    final numbers = List.generate(9, (i) => i + 1)..shuffle(rng);

    for (final num in numbers) {
      if (SudokuSolver.isValid(grid, row, col, num)) {
        grid[row][col] = num;
        if (_fillGridSeeded(grid, rng)) return true;
        grid[row][col] = 0;
      }
    }
    return false;
  }
}
