class SudokuSolver {
  /// Check if [value] can be placed at (row, col) in [grid].
  static bool isValid(List<List<int>> grid, int row, int col, int value) {
    for (int c = 0; c < 9; c++) {
      if (c != col && grid[row][c] == value) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (r != row && grid[r][col] == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row && c != col && grid[r][c] == value) return false;
      }
    }
    return true;
  }

  /// Solve the puzzle using backtracking. Returns true if solved.
  static bool solve(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int value = 1; value <= 9; value++) {
            if (isValid(grid, row, col, value)) {
              grid[row][col] = value;
              if (solve(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Count solutions (up to [limit]) to check uniqueness.
  static int countSolutions(List<List<int>> grid, {int limit = 2}) {
    int count = 0;
    _countSolutions(grid, limit, () {
      count++;
    });
    return count;
  }

  static void _countSolutions(
      List<List<int>> grid, int limit, void Function() found) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int value = 1; value <= 9; value++) {
            if (isValid(grid, row, col, value)) {
              grid[row][col] = value;
              _countSolutions(grid, limit, found);
              grid[row][col] = 0;
              if (_solutionCount >= limit) return;
            }
          }
          return;
        }
      }
    }
    // Found a solution
    _solutionCount++;
    found();
  }

  /// Get a hint: find the first empty cell and return the correct value.
  static Map<int, int>? getHint(
      List<List<int>> board, List<List<int>> solution) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          return {r * 9 + c: solution[r][c]};
        }
      }
    }
    return null;
  }
}

// Track solutions across recursive calls
int _solutionCount = 0;
