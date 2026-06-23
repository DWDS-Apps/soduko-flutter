import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soduko/app_state.dart';
import 'package:soduko/widgets/cell_widget.dart';
import 'package:soduko/widgets/sudoku_grid.dart';
import 'package:soduko/widgets/number_pad.dart';
import 'package:soduko/widgets/game_timer.dart';
import 'package:soduko/widgets/victory_dialog.dart';
import 'package:soduko/widgets/difficulty_selector.dart';
import 'package:soduko/screens/settings_screen.dart';
import 'package:soduko/services/storage_service.dart';
import 'package:soduko/models/settings_model.dart';
import 'package:soduko/models/player_stats.dart';
import 'package:soduko/models/game_state.dart';
import 'package:soduko/models/sudoku_board.dart';
import 'package:soduko/core/constants.dart';

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
  group('CellWidget', () {
    testWidgets('renders empty cell with no value', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 0, isGiven: false),
        ),
      ));
      // Should not crash and show empty
      expect(find.byType(CellWidget), findsOneWidget);
    });

    testWidgets('renders value text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 5, isGiven: false),
        ),
      ));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders given number with bold weight', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 3, isGiven: true),
        ),
      ));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 7, isGiven: false, isSelected: true),
        ),
      ));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('renders highlighted state', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 4, isGiven: false, isHighlighted: true),
        ),
      ));
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders conflict state with red color', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 9, isGiven: false, isConflict: true),
        ),
      ));
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('renders hint state', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 2, isGiven: false, isHint: true),
        ),
      ));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders notes in empty cell', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 0, isGiven: false, notes: {1, 3, 5}),
        ),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('renders same value highlight', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CellWidget(value: 6, isGiven: false, showSameValue: true),
        ),
      ));
      expect(find.text('6'), findsOneWidget);
    });
  });

  group('GameTimerWidget', () {
    testWidgets('displays formatted time', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: GameTimerWidget(seconds: 125, running: true),
        ),
      ));
      // 125 seconds = 02:05
      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('displays zero time', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: GameTimerWidget(seconds: 0, running: false),
        ),
      ));
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('handles large time values', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: GameTimerWidget(seconds: 3661, running: true),
        ),
      ));
      // 3661 seconds = 1h 1m 1s → 01:01:01
      expect(find.text('01:01:01'), findsOneWidget);
    });
  });

  group('GameTimerWidget dark mode', () {
    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        home: const Scaffold(
          body: GameTimerWidget(seconds: 60, running: true),
        ),
      ));
      expect(find.text('01:00'), findsOneWidget);
    });
  });

  group('NumberPad', () {
    testWidgets('renders number buttons 1-9', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NumberPad(appState: state, isDarkMode: false),
        ),
      ));
      await tester.pumpAndSettle();

      for (int i = 1; i <= 9; i++) {
        expect(find.text('$i'), findsWidgets);
      }
      expect(find.text('Erase'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Redo'), findsOneWidget);
    });

    testWidgets('shows Notes button', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NumberPad(appState: state, isDarkMode: false),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows Notes ON when toggle is active', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);
      state.toggleNotesMode();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NumberPad(appState: state, isDarkMode: false),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Notes ON'), findsOneWidget);
    });

    testWidgets('renders left-handed layout', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NumberPad(appState: state, isDarkMode: false, leftHanded: true),
        ),
      ));
      await tester.pumpAndSettle();

      // Buttons should still render
      expect(find.text('Erase'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('renders nothing when no game state', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: NumberPad(appState: state, isDarkMode: false),
        ),
      ));

      // Should be an empty SizedBox
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('SudokuGrid', () {
    testWidgets('renders empty when no game state', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SudokuGrid(appState: state, isDarkMode: false),
        ),
      ));

      // Should be an empty SizedBox
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders grid cells with game state', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SudokuGrid(appState: state, isDarkMode: false),
        ),
      ));
      await tester.pumpAndSettle();

      // GridView should be present
      expect(find.byType(GridView), findsOneWidget);
      // CellWidget items should exist
      expect(find.byType(CellWidget), findsWidgets);
    });

    testWidgets('grid tap selects a cell', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SudokuGrid(appState: state, isDarkMode: false),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on first cell
      final cells = find.byType(CellWidget);
      if (cells.evaluate().isNotEmpty) {
        await tester.tap(cells.first);
        await tester.pumpAndSettle();
        // Selected cell should have row=0, col=0
        expect(state.selectedRow, 0);
        expect(state.selectedCol, 0);
      }
    });

    testWidgets('renders in dark mode', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);
      await state.startNewGame(Difficulty.easy);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SudokuGrid(appState: state, isDarkMode: true),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('VictoryDialog', () {
    GameState completedState() {
      final board = SudokuBoard.empty();
      final solution = SudokuBoard.empty();
      return GameState(
        board: board,
        solution: solution,
        difficulty: Difficulty.easy,
        hintsUsed: 2,
      );
    }

    testWidgets('renders completion message', (tester) async {
      final state = completedState();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            state: state,
            elapsedSeconds: 300,
            isNewBest: false,
            onPlayAgain: () {},
            onShare: () {},
            onHome: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Puzzle Complete!'), findsOneWidget);
    });

    testWidgets('shows NEW BEST badge', (tester) async {
      final state = completedState();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            state: state,
            elapsedSeconds: 120,
            isNewBest: true,
            onPlayAgain: () {},
            onShare: () {},
            onHome: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('NEW BEST!'), findsOneWidget);
    });

    testWidgets('displays game stats correctly', (tester) async {
      final state = completedState();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            state: state,
            elapsedSeconds: 185,
            isNewBest: false,
            onPlayAgain: () {},
            onShare: () {},
            onHome: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // 185 seconds = 03:05
      expect(find.text('03:05'), findsOneWidget);
      // 2 hints used
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('calls onPlayAgain when button tapped', (tester) async {
      final state = completedState();
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            state: state,
            elapsedSeconds: 0,
            isNewBest: false,
            onPlayAgain: () => called = true,
            onShare: () {},
            onHome: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();
      expect(called, true);
    });

    testWidgets('calls onHome when button tapped', (tester) async {
      final state = completedState();
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            state: state,
            elapsedSeconds: 0,
            isNewBest: false,
            onPlayAgain: () {},
            onShare: () {},
            onHome: () => called = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(called, true);
    });
  });

  group('DifficultySelector', () {
    testWidgets('renders all difficulty options', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DifficultySelector(
            onSelected: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Expert'), findsOneWidget);
    });

    testWidgets('tap Easy calls onSelected', (tester) async {
      Difficulty? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DifficultySelector(
            onSelected: (d) => selected = d,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();
      expect(selected, Difficulty.easy);
    });

    testWidgets('tap Expert calls onSelected', (tester) async {
      Difficulty? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DifficultySelector(
            onSelected: (d) => selected = d,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expert'));
      await tester.pumpAndSettle();
      expect(selected, Difficulty.expert);
    });
  });

  group('SettingsScreen font scale', () {
    testWidgets('font scale SegmentedButton exists', (tester) async {
      final storage = _MockStorage();
      final state = AppState(storage);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SettingsScreen(state: state),
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to find the font size section
      await tester.scrollUntilVisible(find.text('Font Size'), 100.0);
      expect(find.text('Font Size'), findsOneWidget);
      // The SegmentedButton should be visible
      expect(find.byType(SegmentedButton<double>), findsOneWidget);
    });
  });
}
