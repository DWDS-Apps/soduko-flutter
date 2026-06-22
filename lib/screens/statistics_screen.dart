import 'package:flutter/material.dart';
import '../app_state.dart';
import '../core/constants.dart';

class StatisticsScreen extends StatelessWidget {
  final AppState state;
  const StatisticsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final s = state.stats;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.sports_esports, label: 'Played', value: '${s.gamesPlayed}', color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.emoji_events, label: 'Won', value: '${s.gamesWon}', color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.pie_chart, label: 'Win %', value: '${s.winPercentage.toStringAsFixed(0)}%', color: Colors.purple)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '${s.currentStreak}', color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.trending_up, label: 'Longest', value: '${s.longestStreak}', color: Colors.red)),
              ]),
              const SizedBox(height: 24),
              Text('Best Times', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              ...Difficulty.values.map((d) => _DifficultyStatsRow(
                difficulty: d, bestTime: s.getBestTime(d), gamesCount: s.getGamesForDifficulty(d))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.access_time, color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Average Time', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(_formatTime(s.averageTime.toInt()), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Total Hints', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('${s.totalHintsUsed}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ]),
    );
  }
}

class _DifficultyStatsRow extends StatelessWidget {
  final Difficulty difficulty; final int bestTime; final int gamesCount;
  const _DifficultyStatsRow({required this.difficulty, required this.bestTime, required this.gamesCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(difficulty.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(bestTime > 0 ? '${bestTime ~/ 60}:${(bestTime % 60).toString().padLeft(2, '0')}' : '--:--',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('$gamesCount games', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }
}
