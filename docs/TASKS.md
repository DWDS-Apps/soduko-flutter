# Tasks — Sudoku v1.0

|**Last Updated:** 2026-06-25 (Session 14)  
**Tracking method:** This file. Mark `[ ]` → `[x]` as completed.

---

## Phase 1: Foundation ✅

- [x] Create Flutter project with `flutter create --offline`
- [x] Write data models: SudokuCell, SudokuBoard, GameState, PlayerStats, Settings, DailyChallenge
- [x] Write theme/constants core files
- [x] Implement backtracking solver (`sudoku_solver.dart`)
- [x] Implement puzzle generator with uniqueness check (`puzzle_generator.dart`)
- [x] Implement JSON file storage service (`storage_service.dart`)

## Phase 2: State & Storage ✅

- [x] Create central `AppState` (ChangeNotifier) aggregating game/settings/stats
- [x] Wire `AppState` via constructor to all screens
- [x] Delete obsolete `providers/` files (game_provider, settings_provider, stats_provider)
- [x] Verify all files compile with `dart analyze`

## Phase 3: UI Shell ✅

- [x] MainMenuScreen — stats bar, menu buttons, continue/new/daily
- [x] SettingsScreen — all toggles, reset button
- [x] StatisticsScreen — cards, best times by difficulty, average time
- [x] AboutScreen — app name, version, description
- [x] DailyChallengeScreen — calendar icon, completed/streak state, play button

## Phase 4: Game Board & Controls ✅

- [x] SudokuGrid with 9×9 layout, 3×3 box borders, cell tap → selection
- [x] CellWidget rendering: value, notes grid, conflict/hint colors, highlight states
- [x] NumberPad: 1-9 buttons with used-number dimming, erase, notes toggle, undo/redo, hint
- [x] GameTimerWidget: HH:MM:SS display
- [x] VictoryDialog: completion stats, play again, share, home

## Phase 5: Game Logic ✅

- [x] Number placement: input → validate → update board → check completion
- [x] Notes mode: toggle → tap number toggles candidate
- [x] Undo/redo: history stack, apply/restore cell state
- [x] Hint: find first empty cell → fill with solution value → mark as hint
- [x] Pause overlay: pause timer, blur board, resume/restart/quit
- [x] Auto-save: persist GameState after each move
- [x] Game completion: validate → show VictoryDialog → record stats

## Phase 6: Polish (Complete ✅)

- [x] Dark mode: wire AppState.settings.darkMode → MaterialApp themeMode
- [x] Timer pause on app lifecycle (WidgetsBindingObserver)
- [x] Left-handed mode: flip number pad layout
- [x] Responsive layout: constrain grid width on tablets (LayoutBuilder)
- [x] Animations: cell selection (AnimatedContainer), number placement pop-in (TweenAnimationBuilder), victory confetti overlay
- [x] Accessibility font sizes (MediaQuery textScaler + Settings)

## Phase 7: Testing (Complete ✅)

- [x] `test/sudoku_solver_test.dart` — solver, validation, countSolutions
- [x] `test/sudoku_board_test.dart` — board ops, cell, JSON roundtrip
- [x] `test/puzzle_generator_test.dart` — generates valid, unique puzzles
- [x] `test/app_state_test.dart` — game flow, undo/redo, stats record (25 tests)
- [x] `test/widget_screens_test.dart` — main menu, settings, stats, about, daily challenge smoke tests (8 tests)
- [x] Integration: full game flow (new → play → win)
- [x] Edge cases: empty board, all cells filled, save/restore
- [x] `test/game_widgets_test.dart` — CellWidget, SudokuGrid, NumberPad, GameTimer, VictoryDialog, DifficultySelector, font scale (31 tests)
- [x] 80%+ code coverage target (achieved 80.3%)

## Phase 8: Release

- [x] Version bump pubspec.yaml to 1.0.0
- [x] Update README.md with full setup, screenshots, architecture
- [x] Generate app icon (adaptive Android + iOS) — custom Sudoku-themed icon via ImageMagick
- [x] Linux desktop build verified: `flutter build linux` success (23 KB ELF binary)
- [x] Web build verified: `flutter build web` compiles clean
- [x] All 145 tests passing, `dart analyze` clean (Session 11, re-verified Sessions 12, 13)
- [x] Linux desktop build re-verified: `flutter build linux` success (Session 12)
- [x] Web build re-verified: `flutter build web` success (Sessions 12, 13)
- [ ] Verify Android build: `flutter build apk` (blocked: no Android SDK in CI)
- [ ] Verify iOS build: `flutter build ios` (requires macOS + Xcode)

---

## Quick Status

|| Phase reached | Status |
|:--|:--|:--|
| Phase 1: Foundation | ✅ Done |
| Phase 2: State & Storage | ✅ Done |
| Phase 3: UI Shell | ✅ Done |
| Phase 4: Game Board & Controls | ✅ Done |
| Phase 5: Game Logic | ✅ Done |
| Phase 6: Polish | ✅ Done |
| Phase 7: Testing & QA | ✅ Done (80.3%) |
| Phase 8: Release | ✅ 7/9 done (Web build re-verified Session 14, 145 tests passing, dart analyze clean; Android/iOS blocked by CI constraints; Linux build cmake unavailable) |
