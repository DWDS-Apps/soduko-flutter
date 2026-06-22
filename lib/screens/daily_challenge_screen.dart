import 'package:flutter/material.dart';
import '../app_state.dart';
import '../core/constants.dart';
import '../themes/app_theme.dart';
import 'game_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  final AppState state;
  const DailyChallengeScreen({super.key, required this.state});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _loading = true;
  bool _completed = false;
  int _bestTime = 0;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
    _checkDailyProgress();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  Future<void> _checkDailyProgress() async {
    final storage = widget.state.storage;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final challenge = await storage.loadDailyChallenge(todayStart);

    if (mounted) {
      setState(() {
        _completed = challenge?.completed ?? false;
        _bestTime = challenge?.bestTimeSeconds ?? 0;
        _loading = false;
      });
    }
  }

  void _startDaily() {
    widget.state.startNewGame(Difficulty.medium);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameScreen(state: widget.state)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${DateTime.now().day}',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                          Text(_monthName(DateTime.now().month),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text("Today's Challenge",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text('One puzzle per day. Same puzzle for everyone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 32),

                    if (_completed)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20)),
                        child: Column(children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 12),
                          const Text('Completed!', style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          Text('Time: ${_bestTime ~/ 60}:${(_bestTime % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16)),
                        ]),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text('Streak: ${widget.state.stats.currentStreak}',
                              style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _startDaily,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play Daily Challenge', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text('Next challenge in ${24 - DateTime.now().hour}h',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}
