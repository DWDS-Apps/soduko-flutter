# Roadmap — Sudoku v1.0

**Last Updated:** 2026-06-22  
**Target Release:** v1.0.0  

---

## Phases

### Phase 1 — Foundation (Complete ✓)
- [x] Flutter project scaffolding
- [x] Data models (SudokuCell, SudokuBoard, GameState, PlayerStats, Settings, DailyChallenge)
- [x] Core constants and theme definitions
- [x] Backtracking solver with uniqueness check
- [x] Puzzle generator (any difficulty, daily seeded)

### Phase 2 — State & Storage (In Progress)
- [x] Central AppState (ChangeNotifier)
- [x] JSON file storage service
- [ ] Wire AppState to all screens/widgets (remove provider stubs)
- [ ] Delete obsolete provider files

### Phase 3 — UI Shell
- [ ] Main Menu screen with navigation
- [ ] Settings screen with all toggles
- [ ] Statistics screen
- [ ] About screen
- [ ] Daily Challenge screen

### Phase 4 — Game Board & Controls
- [ ] SudokuGrid widget with cell selection/highlighting
- [ ] CellWidget with value/notes/conflict rendering
- [ ] NumberPad with 1-9, erase, notes, undo/redo, hint
- [ ] Game timer widget
- [ ] Victory dialog

### Phase 5 — Game Logic
- [ ] Number placement with validation
- [ ] Notes/pencil marks
- [ ] Undo/redo history
- [ ] Hint system (max 3)
- [ ] Pause/resume overlay
- [ ] Auto-save on every move
- [ ] Game completion flow

### Phase 6 — Polish
- [ ] Dark mode support
- [ ] Responsive layout (phones + tablets)
- [ ] Left-handed mode
- [ ] Timer pause on app background
- [ ] Animations (cell selection, placement, victory)
- [ ] Accessibility font sizes

### Phase 7 — Testing & QA
- [ ] Unit tests: solver, generator, board validation
- [ ] Widget tests: each screen's baseline state
- [ ] Integration: full game flow (new → play → win)
- [ ] Edge cases: empty board, all cells filled, save/restore
- [ ] 80%+ code coverage target

### Phase 8 — Release
- [ ] App icon and assets
- [ ] Android build verification
- [ ] iOS build verification
- [ ] README with setup instructions
- [ ] Version bump to 1.0.0

---

## Milestones

| Milestone | Date | Status |
|---|---|---|
| M1: Architecture & Models | 2026-06-22 | ✅ Done |
| M2: State & Services | 2026-06-22 | 🔶 In Progress |
| M3: All Screens Built | TBD | ⬜ |
| M4: Game Board Playable | TBD | ⬜ |
| M5: Full Game Loop | TBD | ⬜ |
| M6: Tests Pass | TBD | ⬜ |
| M7: v1.0 Release | TBD | ⬜ |
