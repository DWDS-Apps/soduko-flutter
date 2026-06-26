import 'sudoku_cell.dart';
import '../core/constants.dart';

class SudokuBoard {
  final List<List<SudokuCell>> cells;

  SudokuBoard(this.cells);

  factory SudokuBoard.empty() {
    return SudokuBoard(
      List.generate(
        AppConstants.gridSize,
        (row) => List.generate(
          AppConstants.gridSize,
          (col) => SudokuCell(row: row, col: col),
        ),
      ),
    );
  }

  factory SudokuBoard.fromGrid(List<List<int>> grid) {
    return SudokuBoard(
      List.generate(
        AppConstants.gridSize,
        (row) => List.generate(
          AppConstants.gridSize,
          (col) => SudokuCell(
            row: row,
            col: col,
            value: grid[row][col],
            isGiven: grid[row][col] != 0,
          ),
        ),
      ),
    );
  }

  SudokuCell getCell(int row, int col) => cells[row][col];

  void setCellValue(int row, int col, int value) {
    cells[row][col].value = value;
    cells[row][col].notes.clear();
    cells[row][col].isHint = false;
  }

  void toggleNote(int row, int col, int number) {
    final cell = cells[row][col];
    if (cell.notes.contains(number)) {
      cell.notes.remove(number);
    } else {
      cell.notes.add(number);
    }
  }

  void clearCell(int row, int col) {
    final cell = cells[row][col];
    if (!cell.isGiven) {
      cell.value = 0;
      cell.notes.clear();
      cell.isConflicting = false;
      cell.isHint = false;
    }
  }

  bool isValidPlacement(int row, int col, int value) {
    for (int c = 0; c < AppConstants.gridSize; c++) {
      if (c != col && cells[row][c].value == value) return false;
    }
    for (int r = 0; r < AppConstants.gridSize; r++) {
      if (r != row && cells[r][col].value == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row && c != col && cells[r][c].value == value) {
          return false;
        }
      }
    }
    return true;
  }

  bool isComplete() {
    for (int r = 0; r < AppConstants.gridSize; r++) {
      for (int c = 0; c < AppConstants.gridSize; c++) {
        if (cells[r][c].isEmpty) return false;
      }
    }
    return true;
  }

  bool hasConflicts() {
    for (int r = 0; r < AppConstants.gridSize; r++) {
      for (int c = 0; c < AppConstants.gridSize; c++) {
        if (!cells[r][c].isEmpty &&
            !isValidPlacement(r, c, cells[r][c].value)) {
          return true;
        }
      }
    }
    return false;
  }

  void updateConflicts() {
    for (int r = 0; r < AppConstants.gridSize; r++) {
      for (int c = 0; c < AppConstants.gridSize; c++) {
        cells[r][c].isConflicting = false;
      }
    }
    for (int r = 0; r < AppConstants.gridSize; r++) {
      for (int c = 0; c < AppConstants.gridSize; c++) {
        if (!cells[r][c].isEmpty &&
            !isValidPlacement(r, c, cells[r][c].value)) {
          cells[r][c].isConflicting = true;
        }
      }
    }
  }

  SudokuBoard copy() {
    return SudokuBoard(
      cells.map((row) => row.map((cell) => cell.copy()).toList()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cells': cells
            .map((row) => row.map((cell) => cell.toJson()).toList())
            .toList(),
      };

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final cellsList = (json['cells'] as List<dynamic>)
        .map((row) => (row as List<dynamic>)
            .map((cell) => SudokuCell.fromJson(cell as Map<String, dynamic>))
            .toList())
        .toList();
    return SudokuBoard(cellsList);
  }

  List<List<int>> toValueGrid() {
    return cells.map((row) => row.map((cell) => cell.value).toList()).toList();
  }
}
