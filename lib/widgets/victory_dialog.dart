import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../themes/app_theme.dart';
import 'confetti_overlay.dart';

class VictoryDialog extends StatelessWidget {
  final GameState state;
  final int elapsedSeconds;
  final bool isNewBest;
  final VoidCallback onPlayAgain;
  final VoidCallback onShare;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.state,
    required this.elapsedSeconds,
    required this.isNewBest,
    required this.onPlayAgain,
    required this.onShare,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = elapsedSeconds ~/ 60;
    final secs = elapsedSeconds % 60;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          // Confetti behind the dialog content
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              child: ConfettiOverlay(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade700,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 56,
                    color: AppTheme.victoryGold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Puzzle Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isNewBest) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.victoryGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW BEST!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _StatRow(
                  icon: Icons.timer,
                  label: 'Time',
                  value:
                      '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.lightbulb_outline,
                  label: 'Hints',
                  value: '${state.hintsUsed}',
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.sports_esports,
                  label: 'Difficulty',
                  value: state.difficulty.label,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  icon: Icons.cancel_outlined,
                  label: 'Mistakes',
                  value: '${state.mistakes}',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onHome,
                        icon: const Icon(Icons.home, size: 18),
                        label: const Text('Home'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayAgain,
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
