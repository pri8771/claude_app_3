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
