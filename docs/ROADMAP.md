# Roadmap — Sudoku v1.0

|**Last Updated:** 2026-06-25 (Session 12)  
**Target Release:** v1.0.0  

---

## Phases

### Phase 1 — Foundation (Complete ✓)
- [x] Flutter project scaffolding
- [x] Data models (SudokuCell, SudokuBoard, GameState, PlayerStats, Settings, DailyChallenge)
- [x] Core constants and theme definitions
- [x] Backtracking solver with uniqueness check
- [x] Puzzle generator (any difficulty, daily seeded)

### Phase 2 — State & Storage (Complete ✓)
- [x] Central AppState (ChangeNotifier)
- [x] JSON file storage service
- [x] Wire AppState to all screens/widgets (remove provider stubs)
- [x] Delete obsolete provider files

### Phase 3 — UI Shell (Complete ✓)
- [x] Main Menu screen with navigation
- [x] Settings screen with all toggles
- [x] Statistics screen
- [x] About screen
- [x] Daily Challenge screen

### Phase 4 — Game Board & Controls (Complete ✓)
- [x] SudokuGrid widget with cell selection/highlighting
- [x] CellWidget with value/notes/conflict rendering
- [x] NumberPad with 1-9, erase, notes, undo/redo, hint
- [x] Game timer widget
- [x] Victory dialog

### Phase 5 — Game Logic (Complete ✓)
- [x] Number placement with validation
- [x] Notes/pencil marks
- [x] Undo/redo history
- [x] Hint system (max 3)
- [x] Pause/resume overlay
- [x] Auto-save on every move
- [x] Game completion flow

### Phase 6 — Polish (Complete ✓)
- [x] Dark mode support
- [x] Timer pause on app background
- [x] Left-handed mode (flip number pad layout)
- [x] Responsive layout (constrain grid on tablets)
- [x] Animations (cell selection, placement, victory)
- [x] Accessibility font sizes (MediaQuery textScaler + Settings)

### Phase 7 — Testing & QA (Complete ✓)
- [x] Unit tests: solver, generator, board validation
- [x] AppState unit tests: game flow, undo/redo, stats, settings
- [x] Widget sanity tests: main menu, settings, stats, about, daily challenge
- [x] Integration: full game flow (new → play → win)
- [x] Edge cases: empty board, all cells filled, save/restore
- [x] 80%+ code coverage target

### Phase 8 — Release (Complete ✓)
- [x] App icon and assets
- [x] README with setup instructions
- [x] Version bump to 1.0.0
- [x] Linux desktop build verified (`flutter build linux` — 23 KB ELF)
- [x] Web build verified (`flutter build web` — compiles clean)
- [x] All 145 tests passing, `dart analyze` clean (Session 11)
- [ ] Android build verification (blocked: no Android SDK in CI)
- [ ] iOS build verification (requires macOS + Xcode)

---

## Milestones

||| Milestone | Date | Status |
|---|---|---|---|---|
||| M1: Architecture & Models | 2026-06-22 | ✅ Done |
||| M2: State & Services | 2026-06-22 | ✅ Done |
||| M3: All Screens Built | 2026-06-22 | ✅ Done |
||| M4: Game Board Playable | 2026-06-22 | ✅ Done |
||| M5: Full Game Loop | 2026-06-23 | ✅ Done |
||| M6: Left-Handed + Responsive + Tests | 2026-06-23 | ✅ Done |
||| M7: Integration + Edge Case + Animations + 80% Coverage | 2026-06-23 | ✅ Done |
||| M8: v1.0 Release | 2026-06-25 | ✅ Done (Linux + Web builds re-verified Session 12; APK/iOS blocked — no Android SDK/macOS in CI) |
