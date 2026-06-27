# Prompt Log — Foldlight (claude_app_3)

**Game:** Foldlight — Spatial Puzzle
**Platform:** iOS 17.0+
**Purpose:** Complete record of all prompts used to plan, design, and implement Foldlight
**Last Updated:** 2026-06-27

---

## Legend

| Field | Description |
|-------|-------------|
| **PROMPT-ID** | Sequential prompt identifier |
| **Phase** | Planning / Architecture / Implementation / Testing / QA |
| **Tool** | ChatGPT / Claude Code / Claude (Browser) |
| **Epic** | Related epic from PROJECT_TRACKER.md |
| **Status** | ✅ Used / 🔄 Active / 📅 Queued |

---

## Phase 0: Ideation & Concept (ChatGPT Collaboration)

### PROMPT-001
**Date:** 2026-06-27
**Phase:** Ideation
**Tool:** ChatGPT (Browser)
**Epic:** E001
**Status:** ✅ Used

**Prompt:**
> "I have two GitHub repos: claude_app_3 and codex_app_3. I want to build two unique iOS games from 0 to production. One should be a puzzle game, one an idle game. They must: run locally without cloud, be written in Swift using Apple guidelines, be monetizable via microtransactions, be fairly complex with progression, feel like they were made by a large studio, have potential for near-infinite levels, and be fun and addicting. Can you help me brainstorm unique concepts for each?"

**Response Summary:** ChatGPT proposed multiple concepts. After iteration, agreed on:
- claude_app_3: FOLDLIGHT (spatial folding puzzle)
- codex_app_3: MOONLOOM: IDLE DREAM FACTORY (idle dream production game)

**Outcome:** Both game concepts finalized and approved.

---

### PROMPT-002
**Date:** 2026-06-27
**Phase:** Ideation
**Tool:** ChatGPT (Browser)
**Epic:** E001
**Status:** ✅ Used

**Prompt:**
> "Let's focus on Foldlight. Can you help me develop the full game concept? I need: the core mechanic, all tile types and their combinations, the meta-progression system, the world structure (biomes), the monetization hooks, and the technical stack. Make it detailed enough to start building."

**Response Summary:** ChatGPT detailed:
- Core fold mechanic: fold glass-paper board to overlap tiles
- 7 tile combination types defined
- 10-biome world restoration meta-progression
- Light Fragment collection system
- StoreKit 2 cosmetic monetization
- SwiftUI + SpriteKit + SwiftData tech stack

**Outcome:** Full Foldlight game design specification created.

---

## Phase 1: Architecture Planning (Claude Code)

### PROMPT-003
**Date:** 2026-07-01 (Planned)
**Phase:** Architecture
**Tool:** Claude Code (Instance 1)
**Epic:** E002, E003
**Status:** 📅 Queued

**Prompt:**
> "You are the lead iOS architect for Foldlight, a spatial folding puzzle game for iOS 17+. The tech stack is: Swift 5.9, SwiftUI, SpriteKit, SwiftData, StoreKit 2, Game Center. No third-party dependencies allowed.
>
> Core mechanics:
> - Players fold a grid-based board along horizontal, vertical, or diagonal axes
> - When two tiles overlap after a fold, they combine according to 7 combination rules
> - The goal is to guide a LightSource beam to reach a GoalCrystal
> - Players have unlimited undos
> - Puzzles are either handcrafted (story) or procedurally generated (infinite mode)
>
> Please create a complete Xcode project architecture plan including:
> 1. Full folder structure (Clean Architecture + MVVM)
> 2. All Swift files needed with their responsibilities
> 3. Data models (SwiftData schemas)
> 4. Key protocols and interfaces
> 5. Module dependency graph
> 6. Estimated file count and complexity
>
> Format your response as a detailed architectural specification that I can review with stakeholders."

**Expected Output:** Complete Xcode project skeleton plan
**Planned For:** Sprint 1, Week 1

---

### PROMPT-004
**Date:** 2026-07-01 (Planned)
**Phase:** Architecture
**Tool:** ChatGPT (Browser)
**Epic:** E002
**Status:** 📅 Queued

**Prompt:**
> "Here is the architecture plan from our iOS architect for Foldlight: [PASTE CLAUDE CODE OUTPUT FROM PROMPT-003]. Please review it for: completeness, any missing components, potential architectural pitfalls, scalability concerns, and whether it follows Apple's best practices for iOS 17+. Suggest any improvements."

**Expected Output:** Architecture review with suggested improvements
**Planned For:** Sprint 1, Week 1

---

## Phase 2: Core Implementation Prompts (Claude Code)

### PROMPT-005
**Date:** 2026-07-01 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E002
**Status:** 📅 Queued

**Prompt:**
> "Create the Xcode project for Foldlight with the following setup:
> - App name: Foldlight
> - Bundle ID: com.[team].foldlight
> - Deployment target: iOS 17.0
> - Swift version: 5.9
> - Frameworks: SwiftUI, SpriteKit, SwiftData, StoreKit, GameKit
> - Architecture: Clean Architecture + MVVM
>
> Create the complete folder structure:
> ```
> Foldlight/
> ├── App/
> │   ├── FoldlightApp.swift
> │   └── AppDelegate.swift
> ├── Core/
> │   ├── Domain/
> │   │   ├── Models/
> │   │   ├── UseCases/
> │   │   └── Repositories/
> │   ├── Data/
> │   │   ├── Persistence/
> │   │   └── Repositories/
> │   └── Presentation/
> │       ├── ViewModels/
> │       └── Views/
> ├── Features/
> │   ├── Game/
> │   ├── WorldMap/
> │   ├── Shop/
> │   └── Settings/
> ├── Services/
> │   ├── StoreKit/
> │   ├── GameCenter/
> │   └── Audio/
> └── Resources/
>     ├── Assets.xcassets
>     └── Sounds/
> ```
>
> Create stub files for each component. Each file should have the correct Swift boilerplate, import statements, and TODO comments describing what needs to be implemented. Do not implement logic yet — just the scaffolding."

**Expected Output:** Complete Xcode project with folder structure and stub files
**Planned For:** Sprint 1, Day 1

---

### PROMPT-006
**Date:** 2026-07-03 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E003
**Status:** 📅 Queued

**Prompt:**
> "Implement all SwiftData models for Foldlight. Requirements:
>
> 1. TileType enum: LightSource, Mirror, GoalCrystal, Path, Water, Shadow, Cage — each with associated color and description
> 2. CombinationResult enum: all valid combinations (Light+Mirror=RedirectedBeam, etc.)
> 3. FoldAxis enum: horizontal(row:), vertical(column:), diagonal(direction:)
> 4. Tile @Model: position (row, col), type, isRevealed, isCombined, combinationResult
> 5. Board @Model: width, height, tiles, foldHistory, isSolved
> 6. Puzzle @Model: id, biomeID, difficulty, board, lightFragmentReward, par (optimal folds)
> 7. PlayerProgress @Model: completedPuzzles, collectedFragments, unlockedBiomes, cosmetics
> 8. Biome @Model: id, name, theme, puzzles, restorationProgress
>
> Constraints:
> - Use SwiftData @Model macros properly
> - All types must be Sendable where appropriate
> - No force unwraps
> - Use @MainActor on UI-touching code
> - async/await over callbacks
> - Include full documentation comments
>
> Implement the full models with all properties, relationships, and computed properties."

**Expected Output:** Complete Swift file with all data models
**Planned For:** Sprint 1, Days 3-4

---

### PROMPT-007
**Date:** 2026-07-07 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E004
**Status:** 📅 Queued

**Prompt:**
> "Implement the FoldEngine for Foldlight. This is the core game mechanic.
>
> ```swift
> // FoldEngine responsibilities:
> // 1. Apply a fold to a Board along an axis
> // 2. Determine which tiles overlap after the fold
> // 3. Resolve tile combinations based on CombinationMatrix
> // 4. Update board state
> // 5. Support undo (unfold to previous state)
> // 6. Detect win condition (LightSource beam reaches GoalCrystal)
> ```
>
> Combination rules:
> - LightSource + Mirror = RedirectedBeam (beam turns 90 degrees)
> - LightSource + Path = LitPath (lights up the path)
> - Mirror + Mirror = CrossBeam (beam goes both directions)
> - Seed + Water = PlantBridge (creates traversable bridge)
> - Fire + Ice = SteamCloud (blocks adjacent tiles briefly)
> - Key + Lock = OpenGate (removes gate tile from board)
> - Empty + Shadow = RevealedPath (reveals hidden tile)
> - Monster + Cage = CapturedMonster (removes monster from board)
>
> Implement:
> - FoldEngine actor (thread-safe)
> - fold(board: Board, axis: FoldAxis) -> FoldResult
> - unfold(board: Board) -> Board
> - resolveCombinations(overlapping: [(Tile, Tile)]) -> [CombinationResult]
> - propagateLightBeam(from: Tile, on: Board) -> [Position]
> - checkWinCondition(board: Board) -> Bool
>
> All functions must be pure (no side effects outside of returned value).
> Include comprehensive unit tests."

**Expected Output:** FoldEngine.swift + FoldEngineTests.swift
**Planned For:** Sprint 2, Week 1

---

### PROMPT-008
**Date:** 2026-07-21 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E005
**Status:** 📅 Queued

**Prompt:**
> "Implement the PuzzleGenerator for Foldlight using reverse-construction methodology.
>
> Algorithm:
> 1. Start with a solved board (LightSource beam already reaches GoalCrystal)
> 2. Apply N random reverse folds to 'unsolve' it (where N = difficulty level)
> 3. Validate the puzzle has exactly one solution
> 4. Classify difficulty: Easy (≤3 folds), Medium (4-6 folds), Hard (7-9 folds), Expert (10+)
>
> Requirements:
> - async/await based (runs in background)
> - Generates batches of 50 puzzles for a given difficulty
> - Validates uniqueness (no duplicate puzzles per biome)
> - Stores generated puzzles in SwiftData
> - DifficultyProgression: difficulty increases smoothly per biome
> - Must generate a valid puzzle within 500ms (performance requirement)
>
> Implement:
> - PuzzleGenerator actor
> - generatePuzzle(biome: Biome, targetDifficulty: Difficulty) async -> Puzzle
> - generateBatch(count: Int, biome: Biome) async -> [Puzzle]
> - validateSolvability(_ puzzle: Puzzle) -> Bool
> - classifyDifficulty(_ puzzle: Puzzle) -> Difficulty
>
> Include unit tests covering edge cases."

**Expected Output:** PuzzleGenerator.swift + PuzzleGeneratorTests.swift
**Planned For:** Sprint 3, Week 1

---

### PROMPT-009
**Date:** 2026-08-01 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E006
**Status:** 📅 Queued

**Prompt:**
> "Implement the SpriteKit GameScene for Foldlight. This is the main puzzle-playing screen.
>
> Requirements:
> - GameScene: SKScene subclass
> - BoardNode: SKNode that renders the game board
> - TileNode: SKSpriteNode for each tile type (7 types, 3 states each)
> - FoldAnimator: handles the paper-fold animation (SKAction sequence)
> - LightBeamEmitter: SKEmitterNode for the light beam particle effect
> - GestureHandler: processes swipe gestures → fold commands
>
> Animation specs:
> - Fold animation: 0.3s ease-in-out, paper folding physics feel
> - Tile combination: particle burst + color flash (0.2s)
> - Win animation: light beam explosion + world glow (1.5s)
> - ASMR-quality: satisfying, not jarring
>
> Performance:
> - 60fps on iPhone 12 (A14 Bionic)
> - 120fps on ProMotion devices
> - Max 200 active nodes at any time
> - Texture atlas for all tile sprites
>
> Integrate with FoldEngine via GameViewModel (MVVM pattern).
> SwiftUI wrapper: GameView wraps the SKView."

**Expected Output:** GameScene.swift, BoardNode.swift, TileNode.swift, FoldAnimator.swift, GameView.swift
**Planned For:** Sprint 4, Week 1

---

### PROMPT-010
**Date:** 2026-09-09 (Planned)
**Phase:** Implementation
**Tool:** Claude Code (Instance 1)
**Epic:** E008
**Status:** 📅 Queued

**Prompt:**
> "Implement the complete StoreKit 2 monetization system for Foldlight.
>
> Product catalog:
> | Product ID | Type | Price | Description |
> |------------|------|-------|-------------|
> | com.foldlight.lux_pack_v1 | Non-consumable | $2.99 | Crystalline board skin |
> | com.foldlight.crystal_pack_v1 | Non-consumable | $1.99 | Stained glass tile theme |
> | com.foldlight.world_bundle_forest | Non-consumable | $4.99 | Enchanted Forest biome + cosmetics |
> | com.foldlight.hints_5 | Consumable | $0.99 | 5 hints |
> | com.foldlight.hints_20 | Consumable | $2.99 | 20 hints |
> | com.foldlight.pass_monthly | Auto-renewable | $4.99/mo | Foldlight Pass: unlimited hints + exclusive cosmetics |
> | com.foldlight.infinite_unlock | Non-consumable | $7.99 | Removes hint limits forever |
>
> Implement:
> - PurchaseManager (ObservableObject) using StoreKit 2 async API
> - Fetch and cache products on app launch
> - purchase(_ product: Product) async throws -> Transaction
> - restorePurchases() async
> - checkEntitlement(for productID: String) async -> Bool
> - subscriptionStatus() async -> Product.SubscriptionInfo.Status?
> - Persist entitlements in SwiftData (CosmeticInventory model)
> - Handle all Transaction states: .purchased, .pending, .failed, .cancelled
> - Process unfinished transactions on app launch
>
> Constraints:
> - No force unwraps
> - Full async/await
> - Thread-safe (actor-based where appropriate)
> - Testable with StoreKit Testing configuration
>
> Include StoreKit configuration file and unit tests."

**Expected Output:** PurchaseManager.swift, Foldlight.storekit, PurchaseManagerTests.swift
**Planned For:** Sprint 5, Week 1

---

## Prompt Statistics

| Phase | Total Prompts | Used | Queued |
|-------|--------------|------|--------|
| Phase 0: Ideation | 2 | 2 | 0 |
| Phase 1: Architecture | 2 | 0 | 2 |
| Phase 2: Implementation | 6 | 0 | 6 |
| Phase 3: Testing | 0 | 0 | 0 |
| Phase 4: Beta | 0 | 0 | 0 |
| **Total** | **10** | **2** | **8** |

---

## Adding New Prompts

When adding prompts:
1. Use sequential PROMPT-XXX IDs
2. Always include: date, phase, tool, epic, status
3. Write the full prompt text (copy-paste what was actually sent)
4. Record the expected output and actual outcome
5. Mark status as ✅ once used and response captured

---

*This log is the single source of truth for all AI prompts used in this project.*
*Last updated: 2026-06-27*


---

## Phase 1: Claude Code Implementation (ChatGPT-Generated Prompts)

**Date Generated:** 2026-06-27
**Source:** ChatGPT (iOS Game Ideas Collaboration chat)
**Status:** All queued for Claude Code execution

---

### UNIVERSAL-PROMPT: Claude Code Rule Prompt
**Date:** 2026-06-27 | **Phase:** Setup | **Tool:** Claude Code | **Status:** 📅 Queued

**Paste this FIRST in Claude Code before starting implementation:**

```
You are working inside this GitHub repo. This project already has complete documentation: 9 PRDs, a project tracker, a bug tracker, and a prompt log.

Your job is to implement the app from the documentation, not redesign it.

Rules:
1. Read the local documentation before coding.
2. Treat the PRDs as the source of truth.
3. If a decision is already specified in the docs, follow it.
4. If a detail is missing, make the smallest production-quality decision that is consistent with the docs.
5. Do not ask me for clarification unless implementation is truly blocked.
6. Do not delete or rewrite the PRDs.
7. Keep the project tracker updated as work is completed.
8. Keep the bug tracker updated with discovered issues, fixed issues, and remaining issues.
9. Append each major implementation prompt and outcome to the prompt log.
10. Prioritize compiling, testable, production-oriented Swift code over mockups.
11. Avoid placeholder-only features. If something is stubbed, it must be clearly isolated, documented, and safe.
12. After each implementation phase, run the available build/tests or explain exactly why they could not be run.
13. Keep changes scoped to the current phase.
14. Prefer simple, maintainable architecture over clever abstractions.
15. Do not claim something is done unless it is implemented and verified.

Start by scanning the repo and summarizing:
- the app name
- target platform
- key docs found
- current implementation state
- highest-priority next implementation step

Then proceed with the requested phase.
```

---

### FOLDLIGHT-PROMPT-001: Project Intake and Foundation
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E002 | **Status:** 📅 Queued

```
Implement Phase 1 for Foldlight.

Before coding:
1. Read all local PRDs and planning docs.
2. Read the project tracker, bug tracker, and prompt log.
3. Identify the intended app architecture, platform target, gameplay requirements, progression requirements, and MVP scope.
4. Inspect the current codebase and determine whether an iOS project already exists.

Implementation goal:
Create or complete the production foundation for the Foldlight iOS app.

Expected result:
A compiling iOS app with a clean SwiftUI app shell, navigation structure, shared architecture, and placeholder screens wired for the major game areas.

Implement:
- App entry point
- Main navigation flow
- Home screen
- Puzzle play screen placeholder
- Daily puzzle entry point
- Infinite mode entry point
- World restoration/meta-progression entry point
- Settings screen
- Save/load service foundation
- Lightweight dependency container or app state model
- Shared design tokens where appropriate
- Basic haptics service
- Basic audio service stub
- Basic analytics/event logging stub
- Model folders/files organized for future gameplay implementation

Technical requirements:
- Use SwiftUI for app shell. Use SpriteKit only where gameplay rendering requires it.
- Keep the code modular. No large gameplay logic in views.
- Add unit-testable services where possible.
- Use local persistence appropriate for MVP (Codable + file storage or UserDefaults).
- No force unwraps. Clean Architecture + MVVM. async/await. @MainActor on ViewModels. Sendable conformance. iOS 17.0 minimum. No third-party dependencies.

Acceptance criteria:
- App builds successfully.
- User can navigate between Home, Play, Daily, Infinite, Restoration, and Settings.
- Save/load service has a real implementation.
- No hard crashes on launch or navigation.
- Project tracker updated. Bug tracker updated. Prompt log updated.
```

---

### FOLDLIGHT-PROMPT-002: Core Puzzle Engine
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E004 | **Status:** 📅 Queued

```
Implement Phase 2 for Foldlight: the core puzzle engine.

Before coding:
1. Re-read the gameplay, folding, tile, procedural generation, and MVP PRDs.
2. Inspect the current foundation from Phase 1.
3. Do not redesign the mechanic. Implement the documented Foldlight rules.

Implementation goal:
Build a deterministic, testable puzzle engine independent of UI.

Implement core models:
- Board, BoardCoordinate, Tile, TileType
- TileLayer or overlap representation
- FoldDirection, FoldLine/FoldRegion/FoldAction
- PuzzleState, PuzzleGoal, PuzzleResult
- MoveHistory / Undo state

Implement mechanics:
- Represent a rectangular puzzle board
- Support tile placement and lookup
- Support legal fold detection
- Apply a fold action to a region of the board
- Correctly map source coordinates to destination coordinates
- Support overlapping tiles
- Resolve tile combinations using documented rules:
  * light source + goal crystal = win
  * path + path = connected path
  * light + mirror = reflected beam (90 degrees)
  * light + shadow = revealed path
  * key + lock = opened gate
  * seed + water = grown bridge
  * fire + ice = steam blocker
  * monster + cage = captured monster
- Support reset and undo
- Support serialization/deserialization

Implement light/beam simulation:
- Trace beam from source
- Respect blockers
- Reflect from mirrors
- Detect goal completion
- Prevent infinite loops safely
- Return rich result for UI animation

Testing:
Add unit tests for:
- board initialization, coordinate mapping
- legal and illegal folds, fold application
- tile overlap behavior, tile combination behavior
- undo/reset
- light reaches goal, light blocked, mirror reflection
- deterministic replay of fold actions

Acceptance criteria:
- Puzzle engine compiles independently of UI.
- Unit tests pass.
- A simple hardcoded puzzle can be solved through engine calls.
- Engine has no SpriteKit or SwiftUI dependency.
- Project tracker, bug tracker, and prompt log updated.
```

---

### FOLDLIGHT-PROMPT-003: Playable Puzzle Board UI
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E006 | **Status:** 📅 Queued

```
Implement Phase 3 for Foldlight: playable puzzle board UI.

Before coding:
1. Read the UI/UX, gameplay, tutorial, and visual PRDs.
2. Inspect the puzzle engine from Phase 2.
3. Preserve engine/UI separation.

Implementation goal:
Turn the puzzle engine into an actual playable board screen.

Implement:
- SpriteKit-based board renderer
- Visual rendering for all MVP tile types (7 tile types, each with 3 visual states)
- Board grid rendering
- Fold gesture input (swipe/tap to select fold line)
- Fold preview before release (show destination region)
- Legal/illegal fold feedback
- Apply fold on gesture completion
- Undo button, Reset button
- Goal/completion detection
- Win animation (light beam explosion + world glow)
- Haptics for fold, invalid fold, undo, and completion
- Sound hooks (ASMR fold sounds)
- Debug level loader for hardcoded test puzzle
- UI state for move count and puzzle status
- Safe layout for iPhone portrait mode
- 60fps on iPhone 12+, 120fps on ProMotion

Important:
The folding interaction must feel like the core game. Player should:
- Understand what region is being folded
- See where it will land (fold preview)
- See tile overlaps or transformations
- See invalid folds clearly but not annoyingly

Acceptance criteria:
- User can open Play screen and solve at least one hardcoded puzzle.
- Fold gestures work on device/simulator.
- Undo and reset work. Completion is detected and shown.
- No gameplay logic is trapped inside the rendering layer.
- App builds. Tests still pass. Trackers updated.
```

---

### FOLDLIGHT-PROMPT-004: Procedural Level Generation
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E005 | **Status:** 📅 Queued

```
Implement Phase 4 for Foldlight: procedural solvable level generation.

Before coding:
1. Read all procedural generation, infinite mode, daily puzzle, difficulty, and validation PRDs.
2. Inspect the existing puzzle engine and playable UI.
3. The generator must create solvable levels and must be deterministic from a seed.

Implementation goal:
Build the MVP procedural puzzle generator for Foldlight.

Implement:
- Seeded random number generator
- PuzzleGenerationConfig
- PuzzleGenerator (async, background generation)
- PuzzleValidator
- Difficulty scoring model
- GeneratedPuzzle metadata

Generation approach (reverse-construction):
1. Start with a solved board (LightSource beam already reaches GoalCrystal)
2. Apply N random valid reverse folds to 'unsolve' it (N = difficulty level)
3. Validate puzzle has at least one solution
4. Classify difficulty: Easy (≤3 folds), Medium (4-6), Hard (7-9), Expert (10+)
5. Reject boring/impossible/degenerate puzzles

Integrate:
- Infinite mode requests generated level by difficulty/seed
- Daily puzzle uses deterministic date-based seed (same puzzle for same date)
- Generated puzzle loads into existing play UI

Testing:
Add tests for:
- deterministic generation from same seed
- generated puzzle validity
- daily seed stability across dates
- difficulty config boundaries
- failed candidate rejection
- validator correctness

Performance requirement: Generate valid puzzle within 500ms

Acceptance criteria:
- Infinite mode produces playable generated puzzles.
- Daily puzzle produces same puzzle for same date seed.
- Generated puzzles validated before shown.
- App builds. Tests pass. Trackers updated.
```

---

### FOLDLIGHT-PROMPT-005: Meta-Progression and World Restoration
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E007 | **Status:** 📅 Queued

```
Implement Phase 5 for Foldlight: meta-progression and world restoration.

Before coding:
1. Read the progression, world restoration, economy, retention, and save-system PRDs.
2. Inspect current gameplay completion flow and persistence layer.

Implementation goal:
Add the progression loop that connects solved puzzles to restoring the Foldlight world.

Implement:
- PlayerProgress model (SwiftData @Model)
- Light Fragments currency
- Puzzle completion rewards (difficulty-scaled)
- RestorationNode model for each of 10 biomes
- World Restoration screen (world map with 10 biomes)
- Spend Light Fragments to restore world nodes
- Permanent unlock state persistence
- Completion summary screen after puzzle solve
- Streak/daily reward support
- Biome unlock gates

Economy values (from docs):
- Easy puzzle: 5-10 Light Fragments
- Medium: 15-25 Light Fragments
- Hard: 35-50 Light Fragments
- Expert: 75-100 Light Fragments
- Daily challenge: 2x reward

Integrate:
- Solving puzzle grants rewards (persisted)
- Restoration purchases persist
- Restoration unlocks affect available biomes/generator configs
- UI communicates next goal clearly

Acceptance criteria:
- Player can solve puzzle, earn Light Fragments, spend in restoration.
- Progress persists across app relaunch.
- Restoration screen is functional (not static mockup).
- Economy values come from central config.
- App builds. Tests pass. Trackers updated.
```

---

### FOLDLIGHT-PROMPT-006: Tutorial, Hints, and Polish
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E007 | **Status:** 📅 Queued

```
Implement Phase 6 for Foldlight: onboarding, hints, and gameplay polish.

Implement:
- First-run onboarding flow (3-5 tutorial puzzles)
- Tutorial puzzle sequence using controlled handcrafted puzzles
- Step-by-step instruction overlays explaining fold mechanic
- Gesture teaching for folding interaction
- Explanation of all 7 tile combination types
- Explanation of light/goal behavior
- Hint system (next best fold, from solver)
- Hint UI and hint consumption tracking
- Move feedback improvements
- Better completion screen (world restoration reveal)
- Improved invalid action feedback
- Accessibility labels for all interactive elements
- Reduced motion support
- Sound/haptics settings toggles
- Visual polish: board, tile states, fold preview, completion animation

Acceptance criteria:
- New player can learn core mechanic without external docs.
- Tutorial puzzles are playable and complete.
- Hint system works for generated/handcrafted puzzles.
- Settings toggles work and persist.
- App builds. Tests pass. Trackers updated.
```

---

### FOLDLIGHT-PROMPT-007: Production Readiness
**Date:** 2026-06-27 | **Phase:** Implementation | **Tool:** Claude Code | **Epic:** E011 | **Status:** 📅 Queued

```
Implement Phase 7 for Foldlight: production readiness.

Implement or finalize:
- App icon and launch screen
- Error-safe persistence with versioned save data
- StoreKit 2 configuration (cosmetics: board skins, tile themes)
- Product IDs: com.foldlight.lux_pack_v1 ($2.99), com.foldlight.crystal_pack_v1 ($1.99), com.foldlight.hints_5 ($0.99), com.foldlight.pass_monthly ($4.99/mo), com.foldlight.infinite_unlock ($7.99)
- PurchaseManager implementation (StoreKit 2 async)
- Game Center achievements (200 achievements)
- Leaderboards (daily, all-time)
- Analytics event tracking
- Performance cleanup (60fps sustained, <80MB RAM)
- Device size checks (iPhone 12-16 matrix)
- Accessibility pass (VoiceOver support)
- Remove dead code and debug-only UI
- Ensure all config values are centralized
- README run instructions

Verification flow:
Home → Tutorial → Puzzle → Complete → Rewards → Restoration → Infinite → Daily → Settings → Shop → Purchase

Acceptance criteria:
- App builds cleanly. Tests pass.
- MVP user flow works end-to-end.
- StoreKit 2 sandbox flows verified.
- Project tracker, bug tracker, prompt log all updated with final audit.
```

---

### FOLDLIGHT-AUDIT: Final Repo Completion Audit
**Date:** 2026-06-27 | **Phase:** QA | **Tool:** Claude Code | **Status:** 📅 Queued

```
Perform a full implementation audit for this repo.

Tasks:
1. Read all PRDs.
2. Read the project tracker.
3. Read the bug tracker.
4. Read the prompt log.
5. Inspect the current codebase.
6. Compare implemented features against documented MVP requirements.
7. Build the app.
8. Run the test suite.
9. Identify missing, incomplete, broken, or placeholder-only features.
10. Fix any small or moderate issues you can safely fix now.
11. Do not start major redesigns.
12. Update the project tracker, bug tracker, and prompt log.

Return:
- Build result
- Test result
- MVP completeness percentage estimate
- Features fully implemented
- Features partially implemented
- Known bugs
- Risks before App Store submission
- Recommended next implementation prompt, if any
```

---

## Prompt Statistics (Updated)

| Phase | Total | Used | Queued |
|-------|-------|------|--------|
| Ideation (ChatGPT) | 2 | 2 | 0 |
| Architecture (ChatGPT) | 2 | 0 | 2 |
| Claude Code Universal | 1 | 0 | 1 |
| Claude Code Implementation | 7 | 0 | 7 |
| Claude Code Audit | 1 | 0 | 1 |
| **Total** | **13** | **2** | **11** |

---

*Last updated: 2026-06-27 — ChatGPT implementation prompts added*
