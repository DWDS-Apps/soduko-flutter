# Sudoku v1.0.0

A production-quality Sudoku game built with Flutter. Features four difficulty levels, pencil marks, hints, undo/redo, dark mode, daily challenges, and full statistics tracking.

## Features

- **🎮 Four Difficulty Levels** — Easy (38 clues), Medium (32), Hard (26), Expert (22)
- **✏️ Pencil Marks** — Toggle notes mode to mark candidates in cells
- **↩️ Undo/Redo** — Full move history with undo and redo
- **💡 Hint System** — Up to 3 hints per game; auto-fills a correct cell
- **⏱️ Game Timer** — Tracks elapsed time per puzzle; pauses on background
- **📊 Statistics** — Per-difficulty tracking: games played, won, best time, average time, streaks
- **🌙 Dark Mode** — Full dark theme support with toggle in settings
- **📅 Daily Challenges** — Seeded puzzle that changes daily with completion tracking
- **👈 Left-Handed Mode** — Flips the number pad layout
- **📱 Responsive Layout** — Grid constrained on tablets for comfortable play
- **♿ Accessibility** — Adjustable font scaling (0.85×, 1.0×, 1.15×)
- **💾 Auto-Save** — Game state saved after every move; resume on return
- **🎉 Victory Animations** — Confetti overlay on puzzle completion

## Screenshots

| Main Menu | Game Board | Statistics |
|:---:|:---:|:---:|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

## Architecture

This app uses **no external state management packages**. State is managed by a central `AppState` class (a `ChangeNotifier`) that is passed via constructor to every screen and widget.

```
lib/
├── main.dart                    # App entry point, MaterialApp setup
├── app_state.dart               # Central ChangeNotifier (game + settings + stats)
├── core/
│   └── constants.dart           # App constants, Difficulty enum
├── models/
│   ├── sudoku_cell.dart         # Single cell model (value, notes, state flags)
│   ├── sudoku_board.dart        # 9×9 board model with JSON serialization
│   ├── game_state.dart          # Current game snapshot (board, timer, hints used)
│   ├── player_stats.dart        # Per-difficulty and aggregate statistics
│   ├── settings_model.dart      # User preferences (dark mode, font scale, etc.)
│   └── ...
├── services/
│   ├── sudoku_solver.dart       # Backtracking solver, validation, uniqueness check
│   ├── puzzle_generator.dart    # Puzzle generation (seeded, any difficulty)
│   └── storage_service.dart     # JSON file persistence via dart:io
├── screens/
│   ├── main_menu_screen.dart    # Home screen with continue/new/daily
│   ├── game_screen.dart         # Game board with controls
│   ├── settings_screen.dart     # Preferences screen
│   ├── statistics_screen.dart   # Stats dashboard
│   ├── daily_challenge_screen.dart # Daily puzzle screen
│   └── about_screen.dart        # App info
├── widgets/
│   ├── sudoku_grid.dart         # 9×9 puzzle grid with 3×3 boxes
│   ├── cell_widget.dart         # Individual cell rendering
│   ├── number_pad.dart          # Input: 1-9, erase, notes, undo/redo, hint
│   ├── game_timer.dart          # Elapsed time display
│   ├── victory_dialog.dart      # Completion modal
│   ├── confetti_overlay.dart    # Victory animation
│   └── difficulty_selector.dart # Difficulty picker
└── themes/
    └── app_theme.dart           # Light & dark theme definitions
```

### State Management

- **`AppState`** extends `ChangeNotifier` and aggregates all application state
- Screens and widgets receive `AppState` via constructor parameter
- Reactive updates use `ListenableBuilder` (no `context.read`/`context.watch`)
- `StorageService` persists game state, settings, and stats as JSON files

## Getting Started

### Prerequisites

- Flutter SDK 3.27+ (Dart 3.6+)
- Android SDK (for Android builds) or Xcode (for iOS builds)

### Build & Run

```bash
# Clone the repository
git clone <repo-url>
cd soduko-flutter

# Get dependencies (offline-compatible)
flutter pub get

# Run in debug mode
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS, requires macOS + Xcode)
flutter build ios
```

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/sudoku_solver_test.dart
flutter test test/app_state_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Coverage

| Area | Tests | Status |
|:---|:---:|:---:|
| Solver & Validation | 10+ | ✅ |
| Board Operations | 10+ | ✅ |
| Puzzle Generator | 5+ | ✅ |
| AppState (game flow, undo/redo, stats) | 25 | ✅ |
| Widget Screens (main menu, settings, stats, about, daily) | 8 | ✅ |
| Game Widgets (CellWidget, Grid, NumberPad, Timer, Victory) | 31 | ✅ |
| Integration (full game flow) | 5+ | ✅ |
| **Total Coverage** | **80.3%** | ✅ |

## Version History

| Date | Version | Notes |
|:---|:---:|:---:|
| 2026-06-23 | 1.0.0 | Initial release |

## License

MIT
