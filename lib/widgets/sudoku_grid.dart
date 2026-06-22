import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../themes/app_theme.dart';
import 'cell_widget.dart';

class SudokuGrid extends StatelessWidget {
  final GameProvider gameProvider;
  final bool isDarkMode;

  const SudokuGrid({
    super.key,
    required this.gameProvider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final state = gameProvider.gameState;
    if (state == null) return const SizedBox();

    final board = state.board;
    final selectedValue = gameProvider.selectedRow >= 0
        ? board.getCell(gameProvider.selectedRow, gameProvider.selectedCol).value
        : 0;

    final highlightedCells = gameProvider.getHighlightedCells();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.boardBackgroundDark : AppTheme.boardBackground,
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
                row == gameProvider.selectedRow && col == gameProvider.selectedCol;
            final isHighlighted = highlightedCells.contains(cellIndex);
            final showSameValue = gameProvider
                .getSameNumberCells(cell.value)
                .contains(cellIndex);

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: col % 3 == 2
                        ? (isDarkMode ? AppTheme.boxBorderDark : AppTheme.boxBorder)
                        : (isDarkMode ? AppTheme.cellBorderDark : AppTheme.cellBorder),
                    width: col % 3 == 2 ? 2 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: row % 3 == 2
                        ? (isDarkMode ? AppTheme.boxBorderDark : AppTheme.boxBorder)
                        : (isDarkMode ? AppTheme.cellBorderDark : AppTheme.cellBorder),
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
                onTap: () => gameProvider.selectCell(row, col),
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
