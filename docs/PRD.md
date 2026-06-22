# Product Requirements Document — Sudoku

**Status:** Draft  
**Version:** 1.0  
**Last Updated:** 2026-06-22  

---

## 1. Overview

A production-quality Sudoku mobile game built with Flutter, targeting iOS and Android. Fully offline, optimized for mobile devices, with a clean Material 3 design and smooth animations.

---

## 2. Goals

- Deliver a polished, playable Sudoku game ready for App Store and Google Play submission
- Implement all core features defined in the spec: difficulty levels, hints, notes, undo/redo, auto-save, daily challenges, statistics
- Achieve 60 FPS performance and minimal widget rebuilds
- Ensure single-solution puzzles via backtracking solver + uniqueness check
- Provide a responsive layout across phones and tablets

---

## 3. Non-Goals

- No cloud sync, leaderboards, or multiplayer (reserved for future)
- No ad monetization or IAP in v1
- No sound effects library (stub only — real audio hooks added later)
- No shared/team puzzle database

---

## 4. User Personas

| Persona | Needs |
|---|---|
| Casual player | Easy puzzles, quick session, minimal friction |
| Enthusiast | Medium/Hard, hints only when stuck, note-taking |
| Expert | Expert difficulty, no hints, fastest completion times |
| Daily player | One puzzle per day, streak tracking, competition with self |

---

## 5. Feature Requirements

### 5.1 Main Menu
| ID | Requirement | Priority |
|---|---|---|
| MM-1 | Show Continue Game button if saved game exists | P0 |
| MM-2 | New Game button → difficulty selector bottom sheet | P0 |
| MM-3 | Statistics screen with win/loss/streaks/times | P0 |
| MM-4 | Settings screen with all toggles | P0 |
| MM-5 | Daily Challenge entry point | P1 |
| MM-6 | About screen with version info | P2 |
| MM-7 | Display mini stat bar (won, streak, best time) | P1 |

### 5.2 Difficulty Levels
| ID | Requirement | Priority |
|---|---|---|
| DL-1 | Easy: 38 starting clues | P0 |
| DL-2 | Medium: 32 clues | P0 |
| DL-3 | Hard: 26 clues | P0 |
| DL-4 | Expert: 22 clues | P0 |

### 5.3 Game Board
| ID | Requirement | Priority |
|---|---|---|
| GB-1 | 9×9 grid with 3×3 box highlighting | P0 |
| GB-2 | Tap cell to select, highlight row/col/box | P0 |
| GB-3 | Highlight cells with same value | P1 |
| GB-4 | Show conflicts in red | P0 |
| GB-5 | Pencil-mark notes mode | P0 |
| GB-6 | Erase cell contents | P0 |

### 5.4 Number Pad
| ID | Requirement | Priority |
|---|---|---|
| NP-1 | Numbers 1–9 with used-number dimming | P0 |
| NP-2 | Eraser button | P0 |
| NP-3 | Notes mode toggle | P0 |
| NP-4 | Hint button (limited) | P1 |
| NP-5 | Undo / Redo | P0 |

### 5.5 Game Features
| ID | Requirement | Priority |
|---|---|---|
| GF-1 | Undo/redo with full history | P0 |
| GF-2 | Pause/resume | P0 |
| GF-3 | Auto-save on every move | P0 |
| GF-4 | Restart puzzle (new same difficulty) | P0 |
| GF-5 | Game timer (pauses on bg) | P0 |

### 5.6 Hint System
| ID | Requirement | Priority |
|---|---|---|
| HS-1 | Reveal one correct cell value | P0 |
| HS-2 | Max 3 hints per game | P0 |
| HS-3 | Mark hinted cells visually (green) | P2 |

### 5.7 Puzzle Generator
| ID | Requirement | Priority |
|---|---|---|
| PG-1 | Backtracking solver | P0 |
| PG-2 | Generate valid complete grid | P0 |
| PG-3 | Remove cells while ensuring unique solution | P0 |
| PG-4 | Seeded generator for daily puzzles | P1 |

### 5.8 Validation & Victory
| ID | Requirement | Priority |
|---|---|---|
| VV-1 | Detect rule violations (row/col/box) | P0 |
| VV-2 | Validate puzzle completion | P0 |
| VV-3 | Victory dialog with time/hints/mistakes/difficulty | P0 |

### 5.9 Settings
| ID | Requirement | Priority |
|---|---|---|
| ST-1 | Dark mode toggle | P0 |
| ST-2 | Sound effects toggle (stub) | P1 |
| ST-3 | Vibration toggle (stub) | P2 |
| ST-4 | Highlight duplicates toggle | P1 |
| ST-5 | Auto-check mistakes toggle | P1 |
| ST-6 | Timer visibility toggle | P1 |
| ST-7 | Left-handed mode toggle | P2 |

### 5.10 Persistence
| ID | Requirement | Priority |
|---|---|---|
| PS-1 | Save current game (board, timer, notes) | P0 |
| PS-2 | Save/load statistics | P0 |
| PS-3 | Save/load settings | P0 |
| PS-4 | Save daily challenge progress | P1 |
| PS-5 | Auto-restore on app reopen | P0 |

---

## 6. Architecture

```
lib/
├── app_state.dart         # Central state (ChangeNotifier)
├── main.dart              # Entry point
├── core/                  # Constants, enums
├── models/                # Data models
├── services/              # Solver, generator, storage
├── screens/               # 6 screen widgets
├── widgets/               # Reusable components
└── themes/                # Light/dark theme definitions
```

State management: Single `ChangeNotifier` (`AppState`) passed via constructor. No external packages.

Storage: JSON files via `dart:io` (`File.writeAsString`).

---

## 7. Performance Targets

- 60 FPS animations during cell selection and number placement
- Puzzle generation < 500ms for Easy, < 2s for Expert
- Minimal widget rebuilds via `ListenableBuilder` granularity
- App size target: < 30MB (no native images/assets)

---

## 8. Future Enhancements

- Cloud sync (Firebase)
- Achievements (Google Play / Game Center)
- Leaderboards
- Multiplayer races (same puzzle, timed)
- Ad monetization (rewarded hints)
- In-app purchases (theme packs, hint packs)
- Sound effects library
- Accessibility improvements
- Tablet-optimized layout

---

## 9. Glossary

| Term | Definition |
|---|---|
| Cell | Single square on the 9×9 grid |
| Given | Pre-filled clue cell (cannot be edited) |
| Notes/Pencil marks | Candidate numbers a user has flagged for a cell |
| Conflict | Two or more cells in same row/col/box with same value |
| Backtracking | Recursive algorithm that tries+backtracks to solve |
| Uniqueness | Property that a puzzle has exactly one solution |
