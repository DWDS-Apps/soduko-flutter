import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/app_state.dart';
import 'package:soduko/screens/main_menu_screen.dart';
import 'package:soduko/screens/settings_screen.dart';
import 'package:soduko/screens/statistics_screen.dart';
import 'package:soduko/screens/about_screen.dart';
import 'package:soduko/screens/daily_challenge_screen.dart';
import 'package:soduko/services/storage_service.dart';
import 'package:soduko/models/settings_model.dart';
import 'package:soduko/models/player_stats.dart';
import 'package:soduko/models/game_state.dart';

/// In-memory storage for widget tests.
class _MockStorage implements StorageService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> hasSavedGame() async => false;

  @override
  Future<void> saveGame(GameState state) async {}

  @override
  Future<GameState?> loadGame() async => null;

  @override
  Future<void> deleteSave() async {}

  @override
  Future<PlayerStats> loadStats() async => PlayerStats();

  @override
  Future<void> saveStats(PlayerStats stats) async {}

  @override
  Future<SettingsModel> loadSettings() async => SettingsModel();

  @override
  Future<void> saveSettings(SettingsModel settings) async {}

  @override
  Future<void> saveDailyChallenge(DailyChallenge challenge) async {}

  @override
  Future<DailyChallenge?> loadDailyChallenge(DateTime date) async => null;
}

void main() {
  group('AboutScreen', () {
    testWidgets('renders app name and version', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sudoku'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });
  });

  group('MainMenuScreen', () {
    testWidgets('renders title and buttons', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: MainMenuScreen(state: state),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sudoku'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Daily Challenge'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('hides Continue Game when no saved game', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: MainMenuScreen(state: state),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Continue Game'), findsNothing);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders appearance section', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(state: state),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('renders gameplay and display sections', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(state: state),
      ));
      await tester.pumpAndSettle();

      // Scroll to find items lower in the list
      await tester.scrollUntilVisible(find.text('Left-Handed Mode'), 100.0);
      expect(find.text('Left-Handed Mode'), findsOneWidget);

      // Scroll further to reach "Reset to Defaults"
      await tester.scrollUntilVisible(find.text('Reset to Defaults'), 100.0);
      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('dark mode switch is present', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(state: state),
      ));
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
      expect(state.settings.darkMode, false);
    });
  });

  group('StatisticsScreen', () {
    testWidgets('renders basic stats', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(state: state),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Played'), findsOneWidget);
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Best Times'), findsOneWidget);
    });

    testWidgets('renders average time section', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: StatisticsScreen(state: state),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Average Time'), 100.0);
      expect(find.text('Average Time'), findsOneWidget);
      expect(find.text('Total Hints'), findsOneWidget);
    });
  });

  group('DailyChallengeScreen', () {
    testWidgets('renders content after loading', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: DailyChallengeScreen(state: state),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text("Today's Challenge"), findsOneWidget);
      expect(find.text('Play Daily Challenge'), findsOneWidget);
    });
  });
}
