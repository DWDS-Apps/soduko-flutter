# Tasks — Sudoku v1.0

**Last Updated:** 2026-06-22  
**Tracking method:** This file. Mark `[ ]` → `[x]` as completed.

---

## Phase 1: Foundation ✅

- [x] Create Flutter project with `flutter create --offline`
- [x] Write data models: SudokuCell, SudokuBoard, GameState, PlayerStats, Settings, DailyChallenge
- [x] Write theme/constants core files
- [x] Implement backtracking solver (`sudoku_solver.dart`)
- [x] Implement puzzle generator with uniqueness check (`puzzle_generator.dart`)
- [x] Implement JSON file storage service (`storage_service.dart`)

## Phase 2: State & Storage

- [x] Create central `AppState` (ChangeNotifier) aggregating game/settings/stats
- [x] Wire `AppState` via constructor to all screens
- [x] Delete obsolete `providers/` files (game_provider, settings_provider, stats_provider)
- [ ] Remove unused `dart:convert` imports from model files (cosmetic)
- [ ] Verify all files compile with `dart analyze`

## Phase 3: UI Shell

- [x] MainMenuScreen — stats bar, menu buttons, continue/new/daily
- [x] SettingsScreen — all toggles, reset button
- [x] StatisticsScreen — cards, best times by difficulty, average time
- [x] AboutScreen — app name, version, description
- [x] DailyChallengeScreen — calendar icon, completed/streak state, play button

### Phase 3 Fixes (current)
- [ ] Rewrite `sudoku_grid.dart` to accept `AppState` param instead of `GameProvider`
- [ ] Rewrite `number_pad.dart` to accept `AppState` param instead of `GameProvider`
- [ ] Rewrite `daily_challenge_screen.dart` to accept `AppState` param instead of `context.read`
- [ ] Update `difficulty_selector.dart` to accept `AppState` param

## Phase 4: Game Board & Controls

- [ ] SudokuGrid with 9×9 layout, 3×3 box borders, cell tap → selection
- [ ] CellWidget rendering: value, notes grid, conflict/hint colors, highlight states
- [ ] NumberPad: 1-9 buttons with used-number dimming, erase, notes toggle, undo/redo, hint
- [ ] GameTimerWidget: HH:MM:SS display
- [ ] VictoryDialog: completion stats, play again, share, home

## Phase 5: Game Logic

- [ ] Number placement: input → validate → update board → check completion
- [ ] Notes mode: toggle → tap number toggles candidate
- [ ] Undo/redo: history stack, apply/restore cell state
- [ ] Hint: find first empty cell → fill with solution value → mark as hint
- [ ] Pause overlay: pause timer, blur board, resume/restart/quit
- [ ] Auto-save: persist GameState after each move
- [ ] Game completion: validate → show VictoryDialog → record stats

## Phase 6: Polish

- [ ] Dark mode: wire AppState.settings.darkMode → MaterialApp themeMode
- [ ] Left-handed mode: flip number pad layout
- [ ] Timer pause on app lifecycle (WidgetsBindingObserver)
- [ ] Animations: hero-like cell transition, victory confetti stub
- [ ] Responsive: constrain grid width on tablets

## Phase 7: Testing

- [ ] `test/sudoku_solver_test.dart` — solver, validation, countSolutions
- [ ] `test/sudoku_board_test.dart` — board ops, cell, JSON roundtrip
- [ ] `test/puzzle_generator_test.dart` — generates valid, unique puzzles
- [ ] `test/app_state_test.dart` — game flow, undo/redo, stats record
- [ ] `test/widget_screens_test.dart` — main menu, game screen smoke tests

## Phase 8: Release

- [ ] Generate app icon (adaptive Android + iOS)
- [ ] Verify Android build: `flutter build apk`
- [ ] Verify iOS build: `flutter build ios` (requires macOS + Xcode)
- [ ] Update README.md with full setup, screenshots, architecture
- [ ] Version bump pubspec.yaml to 1.0.0

---

## Quick Status

| Area | Progress |
|---|---|
| Data models | ✅ 100% |
| Solver/Generator | ✅ 100% |
| Storage | ✅ 100% |
| AppState (central) | ✅ 100% |
| Screens (stubs) | ✅ 100% |
| Widgets (need AppState wiring) | 🔶 60% |
| Remove provider deps | ⬜ 0% |
| Compiles clean | ⬜ 0% |
| Tests | 🔶 30% |
| Polish | ⬜ 0% |
