import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/services/sudoku_solver.dart';

void main() {
  group('SudokuSolver.isValid', () {
    final emptyGrid = List.generate(9, (_) => List.filled(9, 0));

    test('empty grid accepts any placement', () {
      expect(SudokuSolver.isValid(emptyGrid, 0, 0, 5), isTrue);
      expect(SudokuSolver.isValid(emptyGrid, 4, 7, 1), isTrue);
      expect(SudokuSolver.isValid(emptyGrid, 8, 8, 9), isTrue);
    });

    test('detects row conflict', () {
      final grid = emptyGrid.map((row) => List<int>.from(row)).toList();
      grid[0][3] = 5;
      expect(SudokuSolver.isValid(grid, 0, 0, 5), isFalse);
      expect(SudokuSolver.isValid(grid, 0, 0, 3), isTrue);
    });

    test('detects column conflict', () {
      final grid = emptyGrid.map((row) => List<int>.from(row)).toList();
      grid[5][0] = 7;
      expect(SudokuSolver.isValid(grid, 2, 0, 7), isFalse);
      expect(SudokuSolver.isValid(grid, 2, 0, 2), isTrue);
    });

    test('detects 3x3 box conflict', () {
      final grid = emptyGrid.map((row) => List<int>.from(row)).toList();
      grid[1][1] = 9; // top-left box at (0,0)-(2,2)
      expect(SudokuSolver.isValid(grid, 2, 0, 9), isFalse);
      expect(SudokuSolver.isValid(grid, 0, 2, 9), isFalse);
      expect(SudokuSolver.isValid(grid, 3, 0, 9), isTrue); // different box
    });

    test('same cell does not conflict with itself', () {
      final grid = emptyGrid.map((row) => List<int>.from(row)).toList();
      grid[4][4] = 3;
      // Checking (4,4) with value 3 should not conflict with itself
      expect(SudokuSolver.isValid(grid, 4, 4, 3), isTrue);
    });
  });

  group('SudokuSolver.solve', () {
    test('solves an empty grid', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      expect(SudokuSolver.solve(grid), isTrue);
      // All cells should be filled with 1-9
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(grid[r][c], greaterThan(0));
          expect(grid[r][c], lessThanOrEqualTo(9));
        }
      }
    });

    test('solves a partially filled valid puzzle', () {
      final grid = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      expect(SudokuSolver.solve(grid), isTrue);
      // Verify each row has 1-9
      for (int r = 0; r < 9; r++) {
        final rowSet = {...grid[r]};
        expect(rowSet.length, 9);
      }
      // Verify each column has 1-9
      for (int c = 0; c < 9; c++) {
        final colSet = {for (int r = 0; r < 9; r++) grid[r][c]};
        expect(colSet.length, 9);
      }
    });

    test('solved grid passes all validation checks', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      final solved = SudokuSolver.solve(grid);
      expect(solved, isTrue);
      
      // After solving, the grid should be valid
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(grid[r][c], greaterThan(0));
          expect(grid[r][c], lessThanOrEqualTo(9));
          expect(SudokuSolver.isValid(grid, r, c, grid[r][c]), isTrue);
        }
      }
    });

    test('partially solved valid puzzle is handled correctly', () {
      // This puzzle has no conflicts but might have multiple solutions
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 1;
      grid[0][1] = 2;
      final result = SudokuSolver.solve(grid);
      expect(result, isTrue);
      // Verify given cells preserved
      expect(grid[0][0], 1);
      expect(grid[0][1], 2);
    });
  });

  group('SudokuSolver.countSolutions', () {
    test('empty grid has many solutions', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      expect(SudokuSolver.countSolutions(grid), greaterThan(1));
    });

    test('complete grid has exactly 1 solution', () {
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
      expect(SudokuSolver.countSolutions(grid), 1);
    });

    test('puzzle with multiple solutions returns > 1', () {
      // A puzzle that's known to have multiple solutions
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 1;
      grid[0][1] = 2;
      grid[0][2] = 3;
      grid[0][3] = 4;
      grid[0][4] = 5;
      grid[0][5] = 6;
      grid[0][6] = 7;
      grid[0][7] = 8;
      grid[0][8] = 9;
      // With just one row filled, there should be many solutions
      expect(SudokuSolver.countSolutions(grid), greaterThan(1));
    });
  });

  group('SudokuSolver.getHint', () {
    test('returns hint for first empty cell', () {
      final board = List.generate(9, (_) => List.filled(9, 5));
      final solution = List.generate(9, (_) => List.filled(9, 5));
      board[2][2] = 0; // Make one cell empty
    
      final hint = SudokuSolver.getHint(board, solution);
      expect(hint, isNotNull);
      // Should return the first empty cell (2,2) with value 5
      expect(hint!.keys.first, 2 * 9 + 2);
      expect(hint.values.first, 5);
    });

    test('returns null for complete board', () {
      final board = List.generate(9, (_) => List.filled(9, 5));
      final solution = List.generate(9, (_) => List.filled(9, 5));
      expect(SudokuSolver.getHint(board, solution), isNull);
    });
  });
}
