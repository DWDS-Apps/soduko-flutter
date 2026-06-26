import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/models/sudoku_cell.dart';
import 'package:soduko/models/sudoku_board.dart';

void main() {
  group('SudokuCell', () {
    test('creates cell with defaults', () {
      final cell = SudokuCell(row: 2, col: 5);
      expect(cell.row, 2);
      expect(cell.col, 5);
      expect(cell.value, 0);
      expect(cell.isGiven, isFalse);
      expect(cell.isConflicting, isFalse);
      expect(cell.notes, isEmpty);
      expect(cell.isHint, isFalse);
      expect(cell.isEmpty, isTrue);
      expect(cell.hasValue, isFalse);
      expect(cell.hasNotes, isFalse);
    });

    test('creates cell with values', () {
      final cell =
          SudokuCell(row: 0, col: 8, value: 7, isGiven: true, notes: {1, 2, 3});
      expect(cell.value, 7);
      expect(cell.isGiven, isTrue);
      expect(cell.notes, {1, 2, 3});
      expect(cell.hasValue, isTrue);
      expect(cell.isEmpty, isFalse);
      expect(cell.hasNotes, isTrue);
    });

    test('copy produces independent cell', () {
      final cell = SudokuCell(row: 3, col: 3, value: 5, notes: {4, 6});
      final copy = cell.copy();
      expect(copy.row, cell.row);
      expect(copy.col, cell.col);
      expect(copy.value, cell.value);
      expect(copy.notes, cell.notes);

      // Modify original — copy should be unaffected
      cell.value = 9;
      cell.notes.add(7);
      expect(copy.value, 5);
      expect(copy.notes, {4, 6});
    });

    test('JSON roundtrip', () {
      final cell =
          SudokuCell(row: 7, col: 2, value: 3, isGiven: true, notes: {1, 8});
      final json = cell.toJson();
      final restored = SudokuCell.fromJson(json);
      expect(restored.row, cell.row);
      expect(restored.col, cell.col);
      expect(restored.value, cell.value);
      expect(restored.isGiven, cell.isGiven);
      expect(restored.notes, cell.notes);
      // Non-serialized fields should be default
      expect(restored.isConflicting, isFalse);
      expect(restored.isHint, isFalse);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{'row': 0, 'col': 0};
      final cell = SudokuCell.fromJson(json);
      expect(cell.row, 0);
      expect(cell.col, 0);
      expect(cell.value, 0);
      expect(cell.isGiven, isFalse);
      expect(cell.notes, isEmpty);
    });
  });

  group('SudokuBoard', () {
    test('empty board has all cells with value 0', () {
      final board = SudokuBoard.empty();
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = board.getCell(r, c);
          expect(cell.value, 0);
          expect(cell.isEmpty, isTrue);
          expect(cell.row, r);
          expect(cell.col, c);
        }
      }
    });

    test('fromGrid creates board with given values', () {
      final grid =
          List.generate(9, (r) => List.generate(9, (c) => (r == c) ? 1 : 0));
      final board = SudokuBoard.fromGrid(grid);
      for (int i = 0; i < 9; i++) {
        expect(board.getCell(i, i).value, 1);
        expect(board.getCell(i, i).isGiven, isTrue);
      }
      expect(board.getCell(0, 1).value, 0);
      expect(board.getCell(0, 1).isGiven, isFalse);
    });

    test('setCellValue updates value and clears notes/hint', () {
      final board = SudokuBoard.empty();
      board.getCell(4, 4).notes = {1, 2, 3};
      board.getCell(4, 4).isHint = true;

      board.setCellValue(4, 4, 7);
      expect(board.getCell(4, 4).value, 7);
      expect(board.getCell(4, 4).notes, isEmpty);
      expect(board.getCell(4, 4).isHint, isFalse);
    });

    test('toggleNote adds and removes notes', () {
      final board = SudokuBoard.empty();
      board.toggleNote(0, 0, 5);
      expect(board.getCell(0, 0).notes, {5});

      board.toggleNote(0, 0, 5);
      expect(board.getCell(0, 0).notes, isEmpty);
    });

    test('clearCell only clears non-given cells', () {
      final board = SudokuBoard.empty();
      board.setCellValue(0, 0, 3);
      board.getCell(0, 0).isGiven = false;
      board.getCell(1, 1).isGiven = true;
      board.setCellValue(1, 1, 5);

      board.clearCell(0, 0);
      expect(board.getCell(0, 0).value, 0);

      board.clearCell(1, 1);
      expect(board.getCell(1, 1).value, 5); // given cells are preserved
    });

    test('isValidPlacement detects row/col/box conflicts', () {
      final board = SudokuBoard.empty();
      board.setCellValue(0, 3, 5); // row 0, col 3

      // Row conflict
      expect(board.isValidPlacement(0, 0, 5), isFalse);
      // Column conflict
      expect(board.isValidPlacement(4, 3, 5), isFalse);
      // Box conflict (same 3x3 box: rows 0-2, cols 0-2)
      board.setCellValue(2, 1, 7);
      expect(board.isValidPlacement(2, 1, 7), isTrue); // same cell
      expect(board.isValidPlacement(0, 2, 7), isFalse); // same box
      // Valid placement
      expect(board.isValidPlacement(8, 8, 5), isTrue); // different row/col/box
    });

    test('isComplete returns false when board has empty cells', () {
      final board = SudokuBoard.empty();
      expect(board.isComplete(), isFalse);
    });

    test('isComplete returns true when all cells filled', () {
      final board = SudokuBoard.empty();
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          board.setCellValue(r, c, ((r + c) % 9) + 1);
        }
      }
      expect(board.isComplete(), isTrue);
    });

    test('hasConflicts detects invalid state', () {
      final board = SudokuBoard.empty();
      board.setCellValue(0, 0, 5);
      board.setCellValue(0, 1, 5); // duplicate in row
      expect(board.hasConflicts(), isTrue);
    });

    test('updateConflicts marks conflicting cells', () {
      final board = SudokuBoard.empty();
      board.setCellValue(0, 0, 5);
      board.setCellValue(0, 1, 5);
      board.updateConflicts();
      expect(board.getCell(0, 0).isConflicting, isTrue);
      expect(board.getCell(0, 1).isConflicting, isTrue);
      expect(board.getCell(1, 0).isConflicting, isFalse); // unaffected
    });

    test('copy produces independent board', () {
      final board = SudokuBoard.empty();
      board.setCellValue(2, 2, 8);

      final copy = board.copy();
      expect(copy.getCell(2, 2).value, 8);

      board.setCellValue(2, 2, 3);
      expect(copy.getCell(2, 2).value,
          8); // original modification doesn't affect copy
    });

    test('toValueGrid returns correct values', () {
      final board = SudokuBoard.empty();
      board.setCellValue(0, 0, 1);
      board.setCellValue(4, 7, 9);

      final grid = board.toValueGrid();
      expect(grid[0][0], 1);
      expect(grid[4][7], 9);
      expect(grid[8][8], 0);
    });

    test('JSON roundtrip', () {
      final board = SudokuBoard.empty();
      board.setCellValue(1, 2, 7);
      board.getCell(1, 2).notes = {4, 5};
      board.setCellValue(3, 4, 9);
      board.getCell(3, 4).isGiven = true;

      final json = board.toJson();
      final restored = SudokuBoard.fromJson(json);

      expect(restored.getCell(1, 2).value, 7);
      expect(restored.getCell(1, 2).notes, {4, 5});
      expect(restored.getCell(1, 2).isGiven, isFalse);
      expect(restored.getCell(3, 4).value, 9);
      expect(restored.getCell(3, 4).isGiven, isTrue);
    });

    test('fromJson handles empty board', () {
      final boardEmpty = SudokuBoard.empty();
      final json = boardEmpty.toJson();
      final restored = SudokuBoard.fromJson(json);

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(restored.getCell(r, c).value, 0);
        }
      }
    });
  });
}
