import 'dart:async';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/game_timer.dart';
import '../widgets/victory_dialog.dart';
import '../models/game_state.dart';
import '../core/constants.dart';

class GameScreen extends StatefulWidget {
  final AppState state;
  const GameScreen({super.key, required this.state});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  bool _showPauseOverlay = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onChanged);
    WidgetsBinding.instance.addObserver(this);
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.state.removeListener(_onChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      widget.state.pauseGame();
      _timer?.cancel();
      _timer = null;
    } else if (lifecycle == AppLifecycleState.resumed) {
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    final gs = widget.state.gameState;
    if (gs != null && gs.status == GameStatus.playing && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        widget.state.tick();
      });
    }
  }

  void _onChanged() {
    final gs = widget.state.gameState;
    if (gs == null || gs.status != GameStatus.playing) {
      _timer?.cancel();
      _timer = null;
    } else {
      _startTimerIfNeeded();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.state;
    final isDark = appState.settings.darkMode;
    final state = appState.gameState;

    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Game')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == GameStatus.won) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => VictoryDialog(
              state: state,
              elapsedSeconds: appState.elapsedSeconds,
              isNewBest: true,
              onPlayAgain: () {
                Navigator.of(context).pop();
              },
              onShare: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share coming soon!')),
                );
              },
              onHome: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          );
        }
      });
    }

    // Build the game view inside a Stack for pause overlay
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text(state.difficulty.label, style: const TextStyle(fontSize: 14)),
          if (appState.settings.showTimer)
            GameTimerWidget(seconds: appState.elapsedSeconds, running: state.status == GameStatus.playing),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () { appState.pauseGame(); setState(() => _showPauseOverlay = true); },
        ),
        actions: [
          if (state.mistakes > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text('✕ ${state.mistakes}',
                style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600))),
            ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'restart') _confirmRestart();
              if (v == 'pause') { appState.pauseGame(); setState(() => _showPauseOverlay = true); }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'restart', child: Text('Restart')),
              const PopupMenuItem(value: 'pause', child: Text('Pause')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Hints: ${state.hintsUsed}/${AppConstants.maxHints}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text('Mistakes: ${state.mistakes}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxGridWidth = constraints.maxWidth > 600
                          ? 480.0
                          : constraints.maxWidth;
                      return SizedBox(
                        width: maxGridWidth,
                        child: SudokuGrid(appState: appState, isDarkMode: isDark),
                      );
                    },
                  ),
                ),
              ),
            ),
            NumberPad(appState: appState, isDarkMode: isDark, leftHanded: appState.settings.leftHandedMode),
          ]),
          if (_showPauseOverlay) _pauseOverlay(appState),
        ],
      ),
    );
  }

  Widget _pauseOverlay(AppState appState) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text('Paused', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Time: ${appState.elapsedSeconds ~/ 60}:${(appState.elapsedSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () { appState.resumeGame(); setState(() => _showPauseOverlay = false); },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _confirmRestart,
              child: const Text('Restart', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quit Game', style: TextStyle(color: Colors.white70))),
          ],
        ),
      ),
    );
  }

  void _confirmRestart() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Puzzle'),
        content: const Text('All progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(ctx); _showPauseOverlay = false; widget.state.restartPuzzle(); }, child: const Text('Restart')),
        ],
      ),
    );
  }
}
