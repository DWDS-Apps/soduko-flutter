import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../themes/app_theme.dart';

class NumberPad extends StatelessWidget {
  final GameProvider gameProvider;
  final bool isDarkMode;

  const NumberPad({
    super.key,
    required this.gameProvider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final state = gameProvider.gameState;
    if (state == null) return const SizedBox();

    final usedNumbers = <int>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final v = state.board.getCell(r, c).value;
        if (v != 0) usedNumbers.add(v);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (index) {
              final number = index + 1;
              final isUsed = usedNumbers.contains(number);
              final isSelectedNumber = gameProvider.selectedRow >= 0 &&
                  gameProvider
                          .gameState!
                          .board
                          .getCell(gameProvider.selectedRow,
                              gameProvider.selectedCol)
                          .value ==
                      number;

              return _NumberButton(
                number: number,
                isUsed: isUsed,
                isSelectedNumber: isSelectedNumber,
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.inputNumber(number),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.undo,
                label: 'Undo',
                enabled: gameProvider.gameState?.canUndo ?? false,
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.undo(),
              ),
              _ActionButton(
                icon: Icons.auto_fix_high,
                label: 'Hint',
                enabled: (gameProvider.gameState?.hintsUsed ?? 0) < 3,
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.useHint(),
              ),
              _ActionButton(
                icon: gameProvider.notesMode
                    ? Icons.edit_note
                    : Icons.edit_off,
                label: gameProvider.notesMode ? 'Notes ON' : 'Notes',
                isActive: gameProvider.notesMode,
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.toggleNotesMode(),
              ),
              _ActionButton(
                icon: Icons.backspace,
                label: 'Erase',
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.eraseCell(),
              ),
              _ActionButton(
                icon: Icons.redo,
                label: 'Redo',
                enabled: gameProvider.gameState?.canRedo ?? false,
                isDarkMode: isDarkMode,
                onTap: () => gameProvider.redo(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final bool isUsed;
  final bool isSelectedNumber;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.isUsed,
    required this.isSelectedNumber,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 44,
        decoration: BoxDecoration(
          color: isSelectedNumber
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: isUsed
                    ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                    : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isActive;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.isActive = false,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.primaryColor
        : enabled
            ? (isDarkMode ? Colors.white70 : Colors.black54)
            : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
