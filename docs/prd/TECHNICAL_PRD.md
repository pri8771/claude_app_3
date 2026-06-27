# Technical PRD — Foldlight: Infinite Folding Puzzle

**Document Version:** 1.0.0
**Created:** 2026-06-27
**Last Updated:** 2026-06-27
**Status:** Draft
**Owner:** Engineering Lead
**Reviewers:** Product, Design, QA

---

## 1. Executive Summary

### 1.1 Product

**Foldlight** is a procedurally infinite puzzle game for iOS built with Swift 5.9 using SwiftUI and SpriteKit. Players fold sections of a magical tile board to create overlapping combinations that guide light to its goal. The game runs entirely offline with no server dependency.

### 1.2 Technical Goals

- 60 FPS gameplay on iPhone 12 and above; 30 FPS minimum on iPhone XS
- Cold launch < 2 seconds on iPhone 14
- < 50MB initial download
- 0 network calls during gameplay (fully offline)
- Clean Architecture with testable business logic isolated from UI
- MVVM with Combine/async-await for reactive state

### 1.3 Non-Goals (v1.0)

- Multiplayer or Game Center leaderboards (deferred to v1.2)
- Cloud sync / iCloud backup (deferred to v1.3)
- macOS Catalyst / iPad-only features (deferred)
- Server-side level generation (explicitly excluded — all local)

---

## 2. System Architecture

### 2.1 Layered Architecture

The system follows a strict 4-layer Clean Architecture pattern:

**Presentation Layer:** SwiftUI Views + ViewModels (MVVM)
**Domain Layer:** Use Cases, Game Logic, Business Rules
**Data Layer:** Repositories, SwiftData, UserDefaults, JSON
**Infrastructure Layer:** SpriteKit, StoreKit 2, GameKit, HapticEngine

### 2.2 Module Breakdown

| Module | Responsibility |
|--------|---------------|
| FoldlightCore | Pure Swift game logic — zero UIKit/SwiftUI dependencies |
| FoldlightUI | SwiftUI views, navigation, design system |
| FoldlightGame | SpriteKit scene management, rendering, animations |
| FoldlightData | SwiftData models, repositories, persistence |
| FoldlightStore | StoreKit 2 purchase management |
| FoldlightAnalytics | Event tracking, no external SDK required |
| FoldlightGenerator | Procedural level generation algorithms |

**Dependency Rule:** No module may import a module above it in the hierarchy. FoldlightCore has zero external dependencies.

---

## 3. Core Game Engine

### 3.1 Board Representation

The game board is an N×N grid of Tile objects. Standard board sizes: 4×4, 5×5, 6×6, 7×7, 8×8.

Tile types: empty, lightSource, goalCrystal, path, mirror, blocker, seed, water, fire, ice, key, lock, shadow, monster, cage

Each Tile has: id (UUID), type (TileType), orientation (0/90/180/270°), layer (0=base, 1+=folded), isRevealed, metadata

### 3.2 Fold System

A fold is defined by a fold axis — a line dividing the board into two regions. One region folds onto the other.

Fold Axes: horizontal(row), vertical(col), diagonal (future)
Fold Directions: topOntoBottom, bottomOntoTop, leftOntoRight, rightOntoLeft

**Fold Resolution Algorithm:**
1. Identify source region (tiles being folded)
2. Identify target region (tiles being folded onto)
3. For each tile in source: calculate mirror-transform position in target, resolve overlap
4. Remove source region tiles
5. Recalculate board bounds
6. Trigger light beam recalculation

### 3.3 Tile Overlap Resolution Rules

| Tile A | Tile B | Result |
|--------|--------|--------|
| Light Source | Mirror | Redirected Beam |
| Seed | Water | Plant Bridge |
| Fire | Ice | Steam Cloud (blocker) |
| Key | Lock | Open Gate |
| Empty | Shadow | Revealed Hidden Tile |
| Path | Path | Repaired Route |
| Monster | Cage | Captured Monster |

All rules are symmetric (A+B = B+A).

### 3.4 Light Beam Solver

After each fold, beam recalculated via raycasting:
- Traces from LightSource
- Follows path tiles
- Reflects off mirror tiles (orientation-dependent)
- Blocked by blockers/steam
- Succeeds when beam reaches GoalCrystal
- Returns [BeamSegment] array for rendering
- Loop detection: max 100 steps

### 3.5 Undo/Reset System

- Max undo history: 20 states (Board snapshots)
- canUndo computed property
- reset() returns initial board state
- Board stored as value type (struct) — copy-on-write semantics ensure safe snapshots

---

## 4. Procedural Level Generator

### 4.1 Reverse-Construction Algorithm

Generates guaranteed-solvable levels by working backwards from a known solution:

1. CREATE solved board (LightSource → valid path → GoalCrystal)
2. APPLY N reverse folds (unfold the solved state)
3. Validate unique solvability (max 50 retries per config)
4. ADD difficulty elements (blockers, mirrors, shadows, multi-step combos)
5. VALIDATE: confirm solution exists, no shorter path exists
6. SCORE difficulty: D = (folds × 2) + (tileTypes × 1.5) + (boardSize × 0.5) + (decoyFolds × 1)
7. RETURN Level with embedded solution for hint system

### 4.2 Level Configuration

- Board size: 4–8
- Required folds: 1–6
- Tile type count: 2–8
- Decoy folds: 0–3
- Allow diagonal folds: false for beginner
- Seeded RNG for daily puzzle reproducibility

### 4.3 Daily Puzzle System

Seed = hash(currentDate.ISO8601String) → deterministic level per calendar day. No server required. Stored locally: completion status, best time, star count.

### 4.4 Biome Themes (10 total)

crystalCave, glassForest, starMap, shadowRealm, moonGarden, fireFjord, ancientLibrary, voidArchive, sunkenAtoll, luminousDesert

---

## 5. Data Models (SwiftData)

### 5.1 PlayerProgress (singleton)

Fields: totalLevelsCompleted, totalStarsEarned, lightFragments, currentBiome, unlockedBiomes, dailyPuzzleStreak, lastPlayedDate, totalPlayTime, settings, ownedCosmetics, worldRestorationState

### 5.2 LevelRecord

Fields: levelID, isCompleted, starsEarned (1–3), bestMoveCount, completionDate, hintsUsed

### 5.3 WorldRestorationState

Fields: islandProgress [0.0–1.0], constellationsRestored, creaturesCollected, memoryCardsUnlocked, sanctuaryDecorations

---

## 6. Persistence Layer

### 6.1 SwiftData Schema

- PlayerProgress (singleton)
- LevelRecord (one per level)
- DailyRecord (one per calendar day)
- PurchaseRecord (mirrors StoreKit transaction history)

### 6.2 UserDefaults (lightweight)

App launch count, first launch flag, current tutorial step, haptic/sound preferences

### 6.3 Bundled JSON Assets

levels/handcrafted/ (curated onboarding), levels/templates/ (generator templates), themes/biomes.json, store/products.json, localization/en.lproj/

### 6.4 Data Migration

SwiftData VersionedSchema for all migrations. Additive-only in v1.x. Destructive migrations require user confirmation.

---

## 7. Monetization & StoreKit 2

### 7.1 IAP Product Catalog (v1.0)

| Product ID | Type | Price | Description |
|-----------|------|-------|-------------|
| com.foldlight.noads | Non-consumable | $2.99 | Remove all ads |
| com.foldlight.starterbundle | Non-consumable | $4.99 | No Ads + 30 hints + skin |
| com.foldlight.hints.10 | Consumable | $0.99 | 10 hints |
| com.foldlight.hints.50 | Consumable | $3.99 | 50 hints |
| com.foldlight.skin.crystalcave | Non-consumable | $1.99 | Crystal Cave theme |
| com.foldlight.skin.stardust | Non-consumable | $1.99 | Stardust theme |
| com.foldlight.skin.shadowrealm | Non-consumable | $1.99 | Shadow Realm theme |
| com.foldlight.challengepass.s1 | Auto-Renewing Sub | $2.99/mo | Season 1 pass |

### 7.2 StoreKit 2 Architecture

StoreManager (ObservableObject): loads products on init, handles purchase flow, verifies via Transaction.currentEntitlements (on-device, no server). Purchased product IDs stored in SwiftData PurchaseRecord, cross-referenced with StoreKit entitlements on launch.

---

## 8. Performance Requirements

| Device | Target FPS | Min FPS |
|--------|-----------|---------|
| iPhone 15 Pro | 120 (ProMotion) | 60 |
| iPhone 14/15 | 60 | 60 |
| iPhone 12/13 | 60 | 60 |
| iPhone XS/11 | 60 | 30 |

Memory Budget: Total < 150MB, Texture Atlas per biome < 20MB, Loaded level < 2MB

Load Targets: Cold launch < 2.0s, Level load < 0.5s, Fold animation < 300ms, Level generation < 200ms

Optimizations: SKTextureAtlas (batched draw calls), Metal backend, background Task for generation, lazy biome asset loading, ASTC texture compression

---

## 9. Accessibility

- VoiceOver: all tiles have accessibilityLabel + accessibilityHint
- Dynamic Type: all text scales with system font size
- Reduced Motion: fold animations replaced with crossfade
- High Contrast: alternative high-contrast tile set
- Color Blind Support: shape + pattern differentiation (not color alone)
- One-Handed Play: all gestures achievable with one thumb

---

## 10. Testing Strategy

**Coverage Requirements:** Domain/Core 90%, Game Engine 85%, Level Generator 80%, Data Layer 80%, UI 60%, Overall 80%

**Test Types:**
- Unit: TileOverlapResolverTests, FoldSystemTests, LightBeamSolverTests, LevelGeneratorTests, StoreManagerTests
- Integration: complete puzzle solve flow, 365-day daily puzzle generation, save/load round-trip, StoreKit sandbox
- UI (XCUITest): tutorial flow, puzzle solve, store purchase, accessibility VoiceOver
- Performance: fold animation 60fps benchmark, generation time < 200ms

---

## 11. CI/CD (Xcode Cloud)

- feature/* → Build + Unit Tests + SwiftLint
- develop → Full test suite + Archive + TestFlight (Internal)
- main → Full test suite + Archive + TestFlight (External beta)
- Tag v*.*.* → App Store submission

**Quality Gates:** SwiftLint zero warnings on main, SwiftFormat enforced, 80% test coverage minimum, no force-unwraps (!), no TODO/FIXME in PRs to main

---

## 12. Security

- SwiftData stores use NSFileProtectionComplete
- No PII collected or stored
- StoreKit 2 on-device validation only
- No network calls in gameplay
- Basic jailbreak detection (analytics event only, no feature blocking)
- Anti-cheat: progress in SwiftData (not UserDefaults), fragment counts validated against completion records

---

## 13. Analytics (Local Only)

No third-party SDKs. Events written to local JSON log (debug builds only).

Key events: level_start, level_complete (with folds_used, optimal_folds, time_ms, stars, hints_used), level_fail, fold_performed, hint_used, daily_puzzle_complete, purchase_initiated/complete/failed, app_foreground/background

---

## 14. Dependencies

**First-Party Apple Only:**
- SwiftUI (UI)
- SpriteKit (2D rendering)
- StoreKit 2 (IAP)
- GameKit (Achievements v1.1)
- SwiftData (Persistence)
- CoreHaptics (Haptic feedback)
- AVFoundation (Audio)
- Combine (Reactive bindings)

**Third-Party: None** — intentionally zero third-party dependencies for security, size, and privacy.

**Minimum Target:** iOS 17.0, Xcode 16.0+, Swift 5.9+

---

## Appendix A: Error Handling

All game-critical operations use Result<T, GameError>. No silent failures. Crash reporting via MetricKit only.

## Appendix B: Localization

v1.0: English only. String(localized:) throughout for v1.1 expansion (ES, FR, DE, JA, KO, ZH).

## Appendix C: Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-06-27 | Engineering Lead | Initial draft |
