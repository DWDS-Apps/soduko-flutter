import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/services/puzzle_generator.dart';
import 'package:soduko/services/sudoku_solver.dart';

void main() {
  group('PuzzleGenerator', () {
    late PuzzleGenerator generator;

    setUp(() {
      generator = PuzzleGenerator();
    });

    test('generatePuzzle returns a puzzle and solution', () {
      final (puzzle, solution) = generator.generatePuzzle(32);
      
      // Puzzle should have exactly 32 given clues (or close to it for random generation)
      int givenCount = 0;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle[r][c] != 0) givenCount++;
        }
      }
      expect(givenCount, 32);

      // Solution should have all cells filled
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(solution[r][c], greaterThan(0));
          expect(solution[r][c], lessThanOrEqualTo(9));
        }
      }
    });

    test('generatePuzzle creates a valid puzzle (no conflicts)', () {
      final (puzzle, _) = generator.generatePuzzle(38);
      
      // Verify no conflicts in the clues
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle[r][c] != 0) {
            // Temporarily remove cell value and re-check
            final temp = puzzle[r][c];
            puzzle[r][c] = 0;
            expect(SudokuSolver.isValid(puzzle, r, c, temp), isTrue,
                reason: 'Conflict at ($r, $c) = $temp');
            puzzle[r][c] = temp;
          }
        }
      }
    });

    test('generatePuzzle creates puzzle with unique solution', () {
      final (puzzle, _) = generator.generatePuzzle(38);
      final testGrid = puzzle.map((row) => List<int>.from(row)).toList();
      expect(SudokuSolver.countSolutions(testGrid), 1);
    });

    test('generatePuzzle creates solution that matches puzzle clues', () {
      final (puzzle, solution) = generator.generatePuzzle(26);
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (puzzle[r][c] != 0) {
            expect(puzzle[r][c], solution[r][c],
                reason: 'Solution must match given at ($r, $c)');
          }
        }
      }
    });

    test('generates different puzzles for different difficulties', () {
      final (easyPuzzle, _) = generator.generatePuzzle(38);
      final (hardPuzzle, _) = generator.generatePuzzle(22);
      
      int easyClues = 0, hardClues = 0;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (easyPuzzle[r][c] != 0) easyClues++;
          if (hardPuzzle[r][c] != 0) hardClues++;
        }
      }
      expect(easyClues, greaterThan(hardClues));
    });

    test('solution is valid (all rows, cols, boxes have 1-9)', () {
      final (_, solution) = generator.generatePuzzle(32);
      
      // Check rows
      for (int r = 0; r < 9; r++) {
        expect({...solution[r]}.length, 9,
            reason: 'Row $r does not have all 9 numbers');
      }
      
      // Check columns
      for (int c = 0; c < 9; c++) {
        final colSet = {for (int r = 0; r < 9; r++) solution[r][c]};
        expect(colSet.length, 9,
            reason: 'Column $c does not have all 9 numbers');
      }
      
      // Check 3x3 boxes
      for (int br = 0; br < 3; br++) {
        for (int bc = 0; bc < 3; bc++) {
          final boxSet = <int>{};
          for (int r = br * 3; r < br * 3 + 3; r++) {
            for (int c = bc * 3; c < bc * 3 + 3; c++) {
              boxSet.add(solution[r][c]);
            }
          }
          expect(boxSet.length, 9,
              reason: 'Box ($br,$bc) does not have all 9 numbers');
        }
      }
    });
  });

  group('Daily puzzle', () {
    test('generateDailyPuzzle produces deterministic output', () {
      final generator = PuzzleGenerator();
      final date = DateTime(2026, 6, 23);
      
      final (puzzle1, _) = generator.generateDailyPuzzle(date);
      final (puzzle2, _) = generator.generateDailyPuzzle(date);
      
      // Same date should produce same puzzle
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(puzzle1[r][c], puzzle2[r][c],
              reason: 'Puzzles differ at ($r,$c)');
        }
      }
    });

    test('different dates produce different puzzles', () {
      final generator = PuzzleGenerator();
      
      final (puzzle1, _) = generator.generateDailyPuzzle(DateTime(2026, 6, 22));
      final (puzzle2, _) = generator.generateDailyPuzzle(DateTime(2026, 6, 23));
      
      // They should differ somewhere (extremely unlikely to be identical)
      bool different = false;
      for (int r = 0; r < 9 && !different; r++) {
        for (int c = 0; c < 9 && !different; c++) {
          if (puzzle1[r][c] != puzzle2[r][c]) different = true;
        }
      }
      expect(different, isTrue);
    });
  });
}
