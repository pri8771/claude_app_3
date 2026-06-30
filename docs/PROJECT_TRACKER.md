# Project Tracker — Foldlight

> _Updated 2026-06-30 to match the shipped product and launch scope. See [../LAUNCH_READINESS.md](../LAUNCH_READINESS.md)._
>
> **Reconciliation notes:** The repo is `pri8771/foldlight` (the `claude_app_3` name is legacy). Implementation state is **pre-build / docs-only** — only EPIC E001 (documentation) is complete; nothing in E002+ is built. The epic plan below is the _full long-term vision_; the **v1 launch scope is much narrower** (engine + 5 levels + minimal shell, no generator/monetization/Game Center). For v1, treat E004 (Fold Engine) and a 5-level subset as the priority, build the engine headless and test-first, and **defer E005 generator, E008 monetization, E009 Game Center, and the 10-biome content in E006/E007/E010** until the fold mechanic is validated as fun. Source of truth for v1 scope and sequencing: LAUNCH_READINESS.md §2/§3/§8.

**Game:** Foldlight — Folding Light Puzzle
**Platform:** iOS 17.0+
**Stack (v1):** Swift / SwiftUI / SpriteKit / Codable (SwiftData & StoreKit 2 deferred)
**Last Updated:** 2026-06-30

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 📅 | Not Started |
| 🔄 | In Progress |
| ✅ | Complete |
| ⏸ | Deferred |
| ⚠️ | Blocked |

**Story Points:** 1 = 0.5 day, 2 = 1 day, 3 = 1.5 days, 5 = 2.5 days, 8 = 4 days, 13 = 6.5 days

---

## EPIC E001: Project Setup & Documentation

**Goal:** Establish repo, architecture, and all planning documents
**Status:** ✅ Complete
**Est SP:** 21 | **Actual SP:** 24

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T001-01 | Create GitHub repo (claude_app_3) | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | None |
| T001-02 | Create README.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-01 |
| T001-03 | Write Technical PRD | ✅ | 3 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-01 |
| T001-04 | Write Non-Technical PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-05 | Write Business Plan PRD | ✅ | 3 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-04 |
| T001-06 | Write Monetization PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-05 |
| T001-07 | Write Private Beta PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-04 |
| T001-08 | Write Public Beta PRD | ✅ | 2 | 2 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-07 |
| T001-09 | Write Go-to-Market PRD | ✅ | 2 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-06 |
| T001-10 | Write Marketing Plan PRD | ✅ | 2 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-09 |
| T001-11 | Write Investor Deck PRD | ✅ | 3 | 3 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-05 |
| T001-12 | Create PROJECT_TRACKER.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-13 | Create BUG_TRACKER.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |
| T001-14 | Create PROMPT_LOG.md | ✅ | 1 | 1 | 2026-06-27 | 2026-06-27 | 2026-06-27 | 2026-06-27 | T001-03 |

---

## EPIC E002: Xcode Project Initialization

**Goal:** Set up Xcode project with proper architecture skeleton
**Status:** 📅 Not Started
**Est SP:** 13 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T002-01 | Create Xcode project (FoldlightApp) | 📅 | 1 | — | 2026-07-01 | 2026-07-01 | — | — | E001 |
| T002-02 | Set deployment target: iOS 17.0 | 📅 | 1 | — | 2026-07-01 | 2026-07-01 | — | — | T002-01 |
| T002-03 | Configure app icon + launch screen | 📅 | 2 | — | 2026-07-01 | 2026-07-01 | — | — | T002-01 |
| T002-04 | Set up Clean Architecture folder structure | 📅 | 2 | — | 2026-07-01 | 2026-07-02 | — | — | T002-01 |
| T002-05 | Configure SwiftData container (AppDatabase) | 📅 | 3 | — | 2026-07-02 | 2026-07-02 | — | — | T002-04 |
| T002-06 | Set up StoreKit 2 configuration file | 📅 | 2 | — | 2026-07-02 | 2026-07-02 | — | — | T002-04 |
| T002-07 | Implement AppCoordinator navigation | 📅 | 2 | — | 2026-07-02 | 2026-07-03 | — | — | T002-04 |

---

## EPIC E003: Data Models & Core Domain

**Goal:** Define all SwiftData models and core domain entities
**Status:** 📅 Not Started
**Est SP:** 21 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T003-01 | Define TileType enum (7 types) | 📅 | 1 | — | 2026-07-03 | 2026-07-03 | — | — | T002-04 |
| T003-02 | Define CombinationResult enum | 📅 | 1 | — | 2026-07-03 | 2026-07-03 | — | — | T003-01 |
| T003-03 | Define FoldAxis enum (H/V/D) | 📅 | 1 | — | 2026-07-03 | 2026-07-03 | — | — | T002-04 |
| T003-04 | Implement Board model (grid + fold history) | 📅 | 3 | — | 2026-07-03 | 2026-07-04 | — | — | T003-01 |
| T003-05 | Implement Tile model (type, position, state) | 📅 | 2 | — | 2026-07-04 | 2026-07-04 | — | — | T003-01 |
| T003-06 | Implement Puzzle model (board + metadata) | 📅 | 3 | — | 2026-07-04 | 2026-07-05 | — | — | T003-04 |
| T003-07 | Implement PlayerProgress SwiftData model | 📅 | 3 | — | 2026-07-05 | 2026-07-05 | — | — | T002-05 |
| T003-08 | Implement Biome + World models | 📅 | 2 | — | 2026-07-05 | 2026-07-06 | — | — | T003-06 |
| T003-09 | Implement CosmeticInventory model | 📅 | 2 | — | 2026-07-06 | 2026-07-06 | — | — | T003-07 |
| T003-10 | Write unit tests for all models | 📅 | 3 | — | 2026-07-06 | 2026-07-07 | — | — | T003-09 |

---

## EPIC E004: Core Fold Engine

**Goal:** Implement the spatial folding mechanic with all tile combinations
**Status:** 📅 Not Started
**Est SP:** 34 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T004-01 | Implement FoldEngine.fold(axis:position:) | 📅 | 5 | — | 2026-07-07 | 2026-07-09 | — | — | E003 |
| T004-02 | Implement FoldEngine.unfold() | 📅 | 3 | — | 2026-07-09 | 2026-07-10 | — | — | T004-01 |
| T004-03 | Implement tile combination resolution logic | 📅 | 8 | — | 2026-07-10 | 2026-07-14 | — | — | T004-01 |
| T004-04 | Implement light beam propagation algorithm | 📅 | 5 | — | 2026-07-14 | 2026-07-16 | — | — | T004-03 |
| T004-05 | Implement win condition detection | 📅 | 2 | — | 2026-07-16 | 2026-07-16 | — | — | T004-04 |
| T004-06 | Implement hint engine (next best fold) | 📅 | 5 | — | 2026-07-17 | 2026-07-19 | — | — | T004-03 |
| T004-07 | Write unit tests for fold engine | 📅 | 6 | — | 2026-07-19 | 2026-07-21 | — | — | T004-06 |

---

## EPIC E005: Procedural Puzzle Generator

**Goal:** Build reverse-construction puzzle generator
**Status:** 📅 Not Started
**Est SP:** 26 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T005-01 | Implement solved board factory | 📅 | 3 | — | 2026-07-21 | 2026-07-22 | — | — | E004 |
| T005-02 | Implement reverse fold scrambler | 📅 | 5 | — | 2026-07-22 | 2026-07-24 | — | — | T005-01 |
| T005-03 | Implement difficulty classifier | 📅 | 5 | — | 2026-07-24 | 2026-07-26 | — | — | T005-02 |
| T005-04 | Implement puzzle uniqueness validator | 📅 | 3 | — | 2026-07-26 | 2026-07-27 | — | — | T005-02 |
| T005-05 | Implement DifficultyProgression curve | 📅 | 3 | — | 2026-07-27 | 2026-07-28 | — | — | T005-03 |
| T005-06 | Build batch generation pipeline (async) | 📅 | 5 | — | 2026-07-28 | 2026-07-30 | — | — | T005-04 |
| T005-07 | Write unit tests for generator | 📅 | 2 | — | 2026-07-30 | 2026-07-31 | — | — | T005-06 |

---

## EPIC E006: SpriteKit Game Scene

**Goal:** Build the visual puzzle board with animations
**Status:** 📅 Not Started
**Est SP:** 55 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T006-01 | Set up SpriteKit GameScene with SKCamera | 📅 | 3 | — | 2026-08-01 | 2026-08-02 | — | — | E004 |
| T006-02 | Implement BoardNode (tile grid rendering) | 📅 | 5 | — | 2026-08-02 | 2026-08-04 | — | — | T006-01 |
| T006-03 | Implement TileNode with 7 tile designs | 📅 | 8 | — | 2026-08-04 | 2026-08-08 | — | — | T006-02 |
| T006-04 | Implement swipe/tap gesture recognition | 📅 | 3 | — | 2026-08-08 | 2026-08-09 | — | — | T006-01 |
| T006-05 | Implement fold animation (paper-fold physics) | 📅 | 8 | — | 2026-08-09 | 2026-08-13 | — | — | T006-03 |
| T006-06 | Implement light beam particle animation | 📅 | 5 | — | 2026-08-13 | 2026-08-15 | — | — | T006-03 |
| T006-07 | Implement tile combination visual effects | 📅 | 5 | — | 2026-08-15 | 2026-08-17 | — | — | T006-05 |
| T006-08 | Implement win celebration animation | 📅 | 3 | — | 2026-08-17 | 2026-08-18 | — | — | T006-07 |
| T006-09 | Implement camera zoom/pan for large boards | 📅 | 3 | — | 2026-08-18 | 2026-08-19 | — | — | T006-01 |
| T006-10 | Implement undo/redo visual feedback | 📅 | 2 | — | 2026-08-19 | 2026-08-20 | — | — | T006-05 |
| T006-11 | Implement hint visual overlay | 📅 | 3 | — | 2026-08-20 | 2026-08-21 | — | — | T006-04 |
| T006-12 | Audio: fold ASMR sounds + music integration | 📅 | 5 | — | 2026-08-21 | 2026-08-23 | — | — | T006-05 |
| T006-13 | 60fps/120fps performance optimization | 📅 | 2 | — | 2026-08-23 | 2026-08-24 | — | — | T006-09 |

---

## EPIC E007: SwiftUI UI Layer

**Goal:** Build all app screens (non-game) in SwiftUI
**Status:** 📅 Not Started
**Est SP:** 40 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T007-01 | Main Menu / Home Screen | 📅 | 3 | — | 2026-08-24 | 2026-08-25 | — | — | E006 |
| T007-02 | World Map Screen (10 biomes) | 📅 | 5 | — | 2026-08-25 | 2026-08-27 | — | — | T007-01 |
| T007-03 | Level Select Screen (per biome) | 📅 | 3 | — | 2026-08-27 | 2026-08-28 | — | — | T007-02 |
| T007-04 | Puzzle HUD (moves, timer, hints) | 📅 | 3 | — | 2026-08-28 | 2026-08-29 | — | — | E006 |
| T007-05 | Cosmetic Shop screen | 📅 | 5 | — | 2026-08-29 | 2026-08-31 | — | — | E008 |
| T007-06 | Settings screen | 📅 | 2 | — | 2026-08-31 | 2026-09-01 | — | — | T007-01 |
| T007-07 | Achievement screen | 📅 | 5 | — | 2026-09-01 | 2026-09-03 | — | — | T007-02 |
| T007-08 | Daily Challenge screen | 📅 | 3 | — | 2026-09-03 | 2026-09-04 | — | — | T007-03 |
| T007-09 | Onboarding / Tutorial flow | 📅 | 5 | — | 2026-09-04 | 2026-09-06 | — | — | T007-01 |
| T007-10 | World restoration cutscene (per biome) | 📅 | 5 | — | 2026-09-06 | 2026-09-08 | — | — | T007-02 |
| T007-11 | Leaderboard screen (Game Center) | 📅 | 2 | — | 2026-09-08 | 2026-09-09 | — | — | T007-07 |

---

## EPIC E008: Monetization (StoreKit 2)

**Goal:** Implement all IAP products and purchase flows
**Status:** 📅 Not Started
**Est SP:** 21 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T008-01 | Define StoreKit product IDs (all SKUs) | 📅 | 1 | — | 2026-09-09 | 2026-09-09 | — | — | E002 |
| T008-02 | Implement PurchaseManager (StoreKit 2) | 📅 | 5 | — | 2026-09-09 | 2026-09-11 | — | — | T008-01 |
| T008-03 | Implement product fetch + caching | 📅 | 2 | — | 2026-09-11 | 2026-09-11 | — | — | T008-02 |
| T008-04 | Implement purchase flow (async/await) | 📅 | 3 | — | 2026-09-11 | 2026-09-12 | — | — | T008-02 |
| T008-05 | Implement restore purchases | 📅 | 2 | — | 2026-09-12 | 2026-09-12 | — | — | T008-04 |
| T008-06 | Implement subscription management | 📅 | 3 | — | 2026-09-13 | 2026-09-14 | — | — | T008-04 |
| T008-07 | Entitlement persistence (SwiftData) | 📅 | 2 | — | 2026-09-14 | 2026-09-14 | — | — | T008-05 |
| T008-08 | Write IAP unit tests | 📅 | 3 | — | 2026-09-14 | 2026-09-15 | — | — | T008-07 |

---

## EPIC E009: Game Center Integration

**Goal:** Leaderboards, achievements, multiplayer readiness
**Status:** 📅 Not Started
**Est SP:** 13 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T009-01 | Configure Game Center in App Store Connect | 📅 | 1 | — | 2026-09-15 | 2026-09-15 | — | — | E002 |
| T009-02 | Implement GameCenterManager | 📅 | 3 | — | 2026-09-15 | 2026-09-16 | — | — | T009-01 |
| T009-03 | Implement 200 achievements | 📅 | 5 | — | 2026-09-16 | 2026-09-18 | — | — | T009-02 |
| T009-04 | Implement leaderboards (daily, all-time) | 📅 | 2 | — | 2026-09-18 | 2026-09-19 | — | — | T009-02 |
| T009-05 | Test Game Center sandbox | 📅 | 2 | — | 2026-09-19 | 2026-09-19 | — | — | T009-04 |

---

## EPIC E010: Asset Production

**Goal:** Create all visual and audio assets
**Status:** 📅 Not Started
**Est SP:** 55 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T010-01 | App icon (all required sizes) | 📅 | 2 | — | 2026-07-01 | 2026-07-02 | — | — | E002 |
| T010-02 | 7 tile type art (base + variants) | 📅 | 8 | — | 2026-07-07 | 2026-07-11 | — | — | T003-01 |
| T010-03 | 10 biome background themes | 📅 | 13 | — | 2026-07-14 | 2026-07-22 | — | — | T003-08 |
| T010-04 | Board fold animations (Lottie/SpriteKit) | 📅 | 13 | — | 2026-07-22 | 2026-07-30 | — | — | T010-02 |
| T010-05 | Light beam particle FX | 📅 | 5 | — | 2026-08-01 | 2026-08-03 | — | — | T010-04 |
| T010-06 | UI component assets (buttons, icons) | 📅 | 5 | — | 2026-08-03 | 2026-08-05 | — | — | E002 |
| T010-07 | ASMR sound effects (fold, click, win) | 📅 | 5 | — | 2026-08-01 | 2026-08-03 | — | — | T004-01 |
| T010-08 | Background music (2 tracks min) | 📅 | 4 | — | 2026-08-05 | 2026-08-07 | — | — | None |

---

## EPIC E011: QA & Testing

**Goal:** Comprehensive testing before each beta phase
**Status:** 📅 Not Started
**Est SP:** 34 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T011-01 | Unit test coverage ≥ 80% | 📅 | 8 | — | 2026-09-20 | 2026-09-24 | — | — | E009 |
| T011-02 | UI tests (XCTest) for critical flows | 📅 | 5 | — | 2026-09-24 | 2026-09-26 | — | — | E007 |
| T011-03 | Performance testing (Instruments) | 📅 | 5 | — | 2026-09-26 | 2026-09-28 | — | — | E006 |
| T011-04 | Memory leak audit | 📅 | 3 | — | 2026-09-28 | 2026-09-29 | — | — | T011-03 |
| T011-05 | IAP sandbox testing (all SKUs) | 📅 | 3 | — | 2026-09-29 | 2026-09-30 | — | — | E008 |
| T011-06 | Accessibility audit (VoiceOver) | 📅 | 3 | — | 2026-09-30 | 2026-10-01 | — | — | E007 |
| T011-07 | Device matrix testing (iPhone 12–16) | 📅 | 5 | — | 2026-10-01 | 2026-10-03 | — | — | E007 |
| T011-08 | Crash-free rate target: ≥ 99.5% | 📅 | 2 | — | 2026-10-03 | 2026-10-04 | — | — | T011-07 |

---

## EPIC E012: Beta & Launch

**Goal:** Execute private beta → public beta → App Store launch
**Status:** 📅 Not Started
**Est SP:** 21 | **Actual SP:** —

| Task ID | Task | Status | Est SP | Act SP | Est Start | Est End | Act Start | Act End | Dependencies |
|---------|------|--------|--------|--------|-----------|---------|-----------|---------|--------------|
| T012-01 | TestFlight private beta (500 users) | 📅 | 3 | — | 2026-10-15 | 2026-11-15 | — | — | E011 |
| T012-02 | Beta feedback integration | 📅 | 8 | — | 2026-11-01 | 2026-11-30 | — | — | T012-01 |
| T012-03 | Public beta (5,000 users) | 📅 | 3 | — | 2026-12-01 | 2026-12-31 | — | — | T012-02 |
| T012-04 | App Store submission prep | 📅 | 3 | — | 2027-01-01 | 2027-01-07 | — | — | T012-03 |
| T012-05 | App Store review process | 📅 | 1 | — | 2027-01-08 | 2027-01-14 | — | — | T012-04 |
| T012-06 | Launch day execution | 📅 | 3 | — | 2027-01-15 | 2027-01-15 | — | — | T012-05 |

---

## Summary Dashboard

| Epic | Name | Total Est SP | Status | Est Start | Est End |
|------|------|-------------|--------|-----------|---------|
| E001 | Project Setup & Docs | 21 | ✅ | 2026-06-27 | 2026-06-27 |
| E002 | Xcode Initialization | 13 | 📅 | 2026-07-01 | 2026-07-03 |
| E003 | Data Models | 21 | 📅 | 2026-07-03 | 2026-07-07 |
| E004 | Fold Engine | 34 | 📅 | 2026-07-07 | 2026-07-21 |
| E005 | Puzzle Generator | 26 | 📅 | 2026-07-21 | 2026-07-31 |
| E006 | SpriteKit Scene | 55 | 📅 | 2026-08-01 | 2026-08-24 |
| E007 | SwiftUI Screens | 40 | 📅 | 2026-08-24 | 2026-09-09 |
| E008 | Monetization (StoreKit 2) | 21 | 📅 | 2026-09-09 | 2026-09-15 |
| E009 | Game Center | 13 | 📅 | 2026-09-15 | 2026-09-19 |
| E010 | Asset Production | 55 | 📅 | 2026-07-01 | 2026-08-07 |
| E011 | QA & Testing | 34 | 📅 | 2026-09-20 | 2026-10-04 |
| E012 | Beta & Launch | 21 | 📅 | 2026-10-15 | 2027-01-15 |
| **TOTAL** | | **354** | | **2026-06-27** | **2027-01-15** |

---

## Velocity Tracking

| Sprint | Start | End | Planned SP | Actual SP | Notes |
|--------|-------|-----|-----------|----------|-------|
| Sprint 0 | 2026-06-27 | 2026-06-27 | 21 | 24 | Documentation sprint (E001) |

---

*Last updated: 2026-06-27*
