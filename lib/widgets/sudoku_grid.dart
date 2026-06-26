import 'package:flutter/material.dart';
import '../app_state.dart';
import '../themes/app_theme.dart';
import 'cell_widget.dart';

class SudokuGrid extends StatelessWidget {
  final AppState appState;
  final bool isDarkMode;

  const SudokuGrid({
    super.key,
    required this.appState,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final state = appState.gameState;
    if (state == null) return const SizedBox();

    final board = state.board;
    final highlightedCells = appState.getHighlightedCells();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.boardBackgroundDark
              : AppTheme.boardBackground,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final cell = board.getCell(row, col);
            final cellIndex = row * 9 + col;

            final isSelected =
                row == appState.selectedRow && col == appState.selectedCol;
            final isHighlighted = highlightedCells.contains(cellIndex);
            final showSameValue =
                appState.getSameNumberCells(cell.value).contains(cellIndex);

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: col % 3 == 2
                        ? (isDarkMode
                            ? AppTheme.boxBorderDark
                            : AppTheme.boxBorder)
                        : (isDarkMode
                            ? AppTheme.cellBorderDark
                            : AppTheme.cellBorder),
                    width: col % 3 == 2 ? 2 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: row % 3 == 2
                        ? (isDarkMode
                            ? AppTheme.boxBorderDark
                            : AppTheme.boxBorder)
                        : (isDarkMode
                            ? AppTheme.cellBorderDark
                            : AppTheme.cellBorder),
                    width: row % 3 == 2 ? 2 : 0.5,
                  ),
                  left: col == 0
                      ? BorderSide(
                          color: isDarkMode
                              ? AppTheme.boxBorderDark
                              : AppTheme.boxBorder,
                          width: 2)
                      : BorderSide.none,
                  top: row == 0
                      ? BorderSide(
                          color: isDarkMode
                              ? AppTheme.boxBorderDark
                              : AppTheme.boxBorder,
                          width: 2)
                      : BorderSide.none,
                ),
              ),
              child: GestureDetector(
                onTap: () => appState.selectCell(row, col),
                child: CellWidget(
                  value: cell.value,
                  isGiven: cell.isGiven,
                  isSelected: isSelected,
                  isHighlighted: isHighlighted,
                  isConflict: cell.isConflicting,
                  isHint: cell.isHint,
                  showSameValue: showSameValue && !isSelected,
                  notes: cell.notes,
                  isDarkMode: isDarkMode,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
