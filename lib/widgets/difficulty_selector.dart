import 'package:flutter/material.dart';
import '../core/constants.dart';

class DifficultySelector extends StatelessWidget {
  final void Function(Difficulty) onSelected;

  const DifficultySelector({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Select Difficulty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...Difficulty.values.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DifficultyCard(
                  difficulty: d,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(d);
                  },
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final VoidCallback onTap;

  const _DifficultyCard({required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Material(
      color: colors.first,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(_getIcon(), color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${difficulty.startingClues} clues',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getColors() {
    switch (difficulty) {
      case Difficulty.easy:
        return [Colors.green.shade600, Colors.green.shade400];
      case Difficulty.medium:
        return [Colors.orange.shade700, Colors.orange.shade500];
      case Difficulty.hard:
        return [Colors.red.shade700, Colors.red.shade500];
      case Difficulty.expert:
        return [Colors.purple.shade800, Colors.purple.shade600];
    }
  }

  IconData _getIcon() {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_dissatisfied;
      case Difficulty.expert:
        return Icons.psychology;
    }
  }
}
