# Roadmap — Sudoku v1.0

**Last Updated:** 2026-06-23  
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

### Phase 6 — Polish (In Progress)
- [x] Dark mode support
- [x] Timer pause on app background
- [x] Left-handed mode (flip number pad layout)
- [x] Responsive layout (constrain grid on tablets)
- [ ] Animations (cell selection, placement, victory)
- [ ] Accessibility font sizes

### Phase 7 — Testing & QA (In Progress)
- [x] Unit tests: solver, generator, board validation
- [x] AppState unit tests: game flow, undo/redo, stats, settings
- [x] Widget sanity tests: main menu, settings, stats, about, daily challenge
- [x] Integration: full game flow (new → play → win)
- [x] Edge cases: empty board, all cells filled, save/restore
- [ ] 80%+ code coverage target

### Phase 8 — Release
- [ ] App icon and assets
- [ ] Android build verification
- [ ] iOS build verification
- [ ] README with setup instructions
- [ ] Version bump to 1.0.0

---

## Milestones

|| Milestone | Date | Status |
|---|---|---|---|
|| M1: Architecture & Models | 2026-06-22 | ✅ Done |
|| M2: State & Services | 2026-06-22 | ✅ Done |
|| M3: All Screens Built | 2026-06-22 | ✅ Done |
|| M4: Game Board Playable | 2026-06-22 | ✅ Done |
|| M5: Full Game Loop | 2026-06-23 | ✅ Done |
||| M6: Left-Handed + Responsive + Tests | 2026-06-23 | ✅ Done |
||| M7: Integration + Edge Case Tests | 2026-06-23 | ✅ Done |
||| M8: v1.0 Release | TBD | ⬜ |
