import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/difficulty_selector.dart';
import '../core/constants.dart';
import '../themes/app_theme.dart';
import 'game_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'daily_challenge_screen.dart';
import 'about_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final AppState state;
  const MainMenuScreen({super.key, required this.state});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
    widget.state.checkSavedGame();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  void _showDifficultySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DifficultySelector(
        onSelected: (d) => _startNewGame(d),
      ),
    );
  }

  Future<void> _startNewGame(Difficulty d) async {
    await widget.state.startNewGame(d);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen(state: widget.state)),
      );
    }
  }

  Future<void> _continueGame() async {
    await widget.state.loadSavedGame();
    if (mounted && widget.state.gameState != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen(state: widget.state)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.state.stats;
    final hasSave = widget.state.hasSavedGame;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(Icons.grid_on,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(AppConstants.appName,
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MiniStat(
                            icon: Icons.emoji_events,
                            value: '${stats.gamesWon}',
                            label: 'Won'),
                        Container(
                            width: 1, height: 30, color: Colors.grey.shade300),
                        _MiniStat(
                            icon: Icons.local_fire_department,
                            value: '${stats.currentStreak}',
                            label: 'Streak'),
                        Container(
                            width: 1, height: 30, color: Colors.grey.shade300),
                        _MiniStat(
                            icon: Icons.timer,
                            value: stats.bestTimes.values.isNotEmpty
                                ? '${stats.bestTimes.values.reduce((a, b) => a < b ? a : b) ~/ 60}m'
                                : '--',
                            label: 'Best'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (hasSave) ...[
                    _MenuButton(
                        icon: Icons.play_arrow,
                        label: 'Continue Game',
                        color: AppTheme.primaryColor,
                        onTap: _continueGame),
                    const SizedBox(height: 12),
                  ],
                  _MenuButton(
                      icon: Icons.add_circle_outline,
                      label: 'New Game',
                      color: Colors.orange,
                      onTap: _showDifficultySelector),
                  const SizedBox(height: 12),
                  _MenuButton(
                      icon: Icons.bar_chart,
                      label: 'Statistics',
                      color: Colors.purple,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              StatisticsScreen(state: widget.state)))),
                  const SizedBox(height: 12),
                  _MenuButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.grey,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              SettingsScreen(state: widget.state)))),
                  const SizedBox(height: 12),
                  _MenuButton(
                      icon: Icons.calendar_today,
                      label: 'Daily Challenge',
                      color: Colors.teal,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              DailyChallengeScreen(state: widget.state)))),
                  const SizedBox(height: 12),
                  _MenuButton(
                      icon: Icons.info_outline,
                      label: 'About',
                      color: Colors.blueGrey,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AboutScreen()))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]);
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 16),
              Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ]),
          ),
        ),
      ),
    );
  }
}
