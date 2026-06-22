import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CellWidget extends StatelessWidget {
  final int value;
  final bool isGiven;
  final bool isSelected;
  final bool isHighlighted;
  final bool isConflict;
  final bool isHint;
  final bool showSameValue;
  final Set<int> notes;
  final bool isDarkMode;

  const CellWidget({
    super.key,
    required this.value,
    required this.isGiven,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isConflict = false,
    this.isHint = false,
    this.showSameValue = false,
    this.notes = const {},
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;

    if (isSelected) {
      bgColor = isDarkMode ? AppTheme.selectedCellDark : AppTheme.selectedCell;
    } else if (isHighlighted) {
      bgColor = isDarkMode ? AppTheme.highlightedCellDark : AppTheme.highlightedCell;
    } else if (showSameValue && value != 0) {
      bgColor = isDarkMode ? AppTheme.highlightedCellDark : AppTheme.highlightedCell;
    }

    Color textColor;
    if (isConflict) {
      textColor = AppTheme.conflictColor;
    } else if (isHint) {
      textColor = AppTheme.hintColor;
    } else if (isGiven) {
      textColor = isDarkMode ? AppTheme.givenNumberDark : AppTheme.givenNumber;
    } else if (value != 0) {
      textColor = isDarkMode ? AppTheme.userNumberDark : AppTheme.userNumber;
    } else {
      textColor = Colors.transparent;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: Colors.transparent,
          width: 0.5,
        ),
      ),
      child: value != 0
          ? Center(
              child: FittedBox(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: isGiven ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            )
          : _buildNotes(),
    );
  }

  Widget _buildNotes() {
    if (notes.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: List.generate(9, (index) {
          final num = index + 1;
          return Center(
            child: notes.contains(num)
                ? Text(
                    '$num',
                    style: TextStyle(
                      fontSize: 8,
                      color: isDarkMode ? AppTheme.noteTextDark : AppTheme.noteText,
                    ),
                  )
                : const SizedBox(),
          );
        }),
      ),
    );
  }
}
