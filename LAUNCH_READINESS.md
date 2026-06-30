# Foldlight — Launch Readiness (v1)

> _Authored 2026-06-30. This is the canonical launch-scope artifact for Foldlight and the authoritative build-to spec. Where it conflicts with older docs, this document wins; the older docs have been reconciled against it (see PROJECT_DOCUMENTATION.md and README.md)._

**Foldlight** is a relaxing, single-player iOS puzzle game whose one mechanic is _folding the board_: the player draws a fold line across a grid of tiles, one half flips onto the other (like folding paper), overlapping tiles combine, and the goal is to route a beam of light from a light source to a goal crystal. The hook is that you do not move pieces inside a fixed board — you change the shape of the board itself, which is legible in a few seconds of silent video and is the game's free-marketing property. It targets premium-puzzle players (the Monument Valley / The Room / Threes! audience) who want a genuinely new mechanic in short, calm sessions.

**Implementation maturity: PRE-BUILD / DOCS-ONLY.** This is the single most important fact for any reader. The repository (`pri8771/foldlight`, default branch `main`) contains **14 Markdown documents and zero lines of source code**. There is no Xcode project, no Swift Package, no `Foldlight/` source tree, no `FoldlightTests/`, no `Info.plist`, no `PrivacyInfo.xcprivacy`, no `.storekit` config, and no CI. Every framework, model, and feature named in the docs is _planned, not built_. `docs/PROJECT_TRACKER.md` confirms only EPIC E001 (documentation) is complete and Xcode initialization (E002) is "Not Started." `docs/BUG_TRACKER.md` has no real bugs because development has not begun. The README and trackers also still call the repo `claude_app_3`, an inherited stale name. Consequently, the MVP scope below is a **build target**, not an inventory of working features, and every feature's status is honestly **Not built** unless stated otherwise.

This document deliberately narrows the sprawling documented vision (10 biomes, procedurally infinite generation, world-restoration meta-progression, StoreKit 2 with 8+ SKUs, AdMob rewarded ads, Game Center with 200 achievements, subscriptions) down to **one proven mechanic and a small hand-authored level set**, per the product conversation in `Foldlight.md`. Everything else is explicitly deferred to §3.

---

## 1. PRD / Launch Scope

### Problem & insight
The mobile puzzle category is enormous but mechanically stagnant: match-3, color/water sort, block-blast, and screw-jam all work by _moving or clearing pieces inside a fixed board_. Premium-puzzle players (the people who buy every Apple-featured $2–5 puzzle game day one) chronically run out of genuinely new mechanics. The insight: a mechanic that transforms the board itself ("fold the board") is (a) novel, (b) explainable without words, and (c) inherently shareable as short silent video — which is the cheapest possible acquisition channel for a premium indie puzzle game.

The honest counter-insight, surfaced in `Foldlight.md`: the documented _differentiator_ ("procedurally infinite") is also the single least-proven and hardest-to-build part. "Is folding fun for five minutes?" is unvalidated and must be proven on hand-authored levels before any generator, content, or monetization work is justified.

### Target user
- **Primary (first user):** the _premium-puzzle tastemaker_ — buys Apple-featured premium puzzle games day one, finishes them quickly, and posts a short clip of the prettiest mechanic to TikTok/Reddit. Sharpest pain ("I've played everything"), cheapest acquisition (the fold _is_ the clip). This is narrower than the docs' stated "adults 22–45 casual" audience, and deliberately so for v1.
- **Secondary:** casual relax-before-bed / commute puzzle players who enjoyed Monument Valley, Alto's Odyssey, The Room; want something beautiful and calm, not stressful.
- **Tertiary:** puzzle enthusiasts active in r/puzzlegames who want a fresh mechanic to dissect.

### Value proposition (one sentence)
A calm, beautiful iOS puzzle where you fold the board itself to bend light to its goal — a mechanic you have not played before.

### Positioning / category & one-sentence pitch
Category: premium single-player spatial/logic puzzle (offline, no energy timers). Pitch: _"Fold the board. Bend the light. Solve the level."_

### Platform & tech baseline (planned — none implemented yet)
- **iOS 17.0+**, iPhone, portrait. (iPad/macOS deferred.)
- **Swift 5.9+, Xcode 16+.**
- **SwiftUI** for the app shell, menus, HUD, settings.
- **SpriteKit** for the board render + fold/beam animation (deferred until the engine is proven headless — see §8).
- **Pure-Swift engine core** (`FoldlightCore`-equivalent): the board model, fold transform, overlap resolution, beam solver, and win check, with **zero UIKit/SwiftUI/SpriteKit imports**, validated entirely with `swift test`. This headless-first split is the conversation's explicit direction and the v1 architectural commitment.
- **Persistence:** Codable + file storage (or `UserDefaults` for flags) for local progress. SwiftData is documented but is **not** required for v1 and is deferred — Codable is the smaller, safer choice for a level-completion record.
- **No third-party dependencies. No network calls. 100% offline.**

### Business model (only what v1 supports)
**v1 ships with NO monetization.** No StoreKit, no IAP, no ads, no subscription. The repo's monetization docs are internally contradictory (see §3 and §7-R1) and, more importantly, monetizing an unproven mechanic is premature. v1's only job is to prove the fold loop is fun. Pricing/IAP decisions are deferred until after a fun-validation pass. If a model is later chosen, the conversation and docs favor **premium-feeling, player-first**: optional cosmetic board skins and convenience hint packs, never pay-to-win, never energy timers.

### North-star / success signals (local-only, privacy-respecting)
Because v1 is offline with no analytics SDK, success is measured by manual playtest and (later) a local-only debug event log — never server telemetry.
- **North-star (fun gate, from `Foldlight.md`):** _After ~5 minutes, does a first-time player voluntarily replay a level to find a cleaner fold?_ If no, stop before building content.
- Tutorial/first-5-levels completion in playtest (target: most testers finish all 5 unaided).
- "Fold mechanic intuitive" rated ≥ 3.5/5 by playtesters (mirrors `PRIVATE_BETA_PRD` exit bar).
- Qualitative: at least one tester produces a shareable "aha" fold clip.

---

## 2. MVP Feature List (with acceptance criteria)

Scope philosophy: the MVP is the smallest thing that proves the fold-and-solve loop is fun on hand-authored content, runnable end-to-end on device, with no generator, no monetization, no meta-progression. Features are ordered by build dependency. **All statuses are "Not built"** because the repo is docs-only; status reflects build reality, not ambition.

### F1. Board & tile model (pure Swift) — Status: **Not built**
The immutable, value-type data model for a rectangular puzzle: grid of tiles, each tile with a type and the cell coordinate; a `Board` value type with width/height and tile lookup; serialization for loading bundled levels.
- **MVP tile types (frozen — 5):** `lightSource`, `goalCrystal`, `path`, `mirror`, `blocker`. (The docs variously list 7, 8, or 15 types; v1 freezes the **minimum set that can express "route a beam to a goal via folds"**. Water/seed/fire/ice/key/lock/shadow/monster/cage are deferred to §3.)
- Acceptance criteria:
  - Given a bundled level JSON, When the model loads it, Then a `Board` is produced with exactly the specified tiles at the specified coordinates, and round-trips (encode→decode) to an identical board.
  - Given any board, When a coordinate outside bounds is queried, Then the API returns a safe empty/absent result and never crashes or force-unwraps.
  - `Board` is a `struct` (value semantics); copying a board and mutating the copy does not mutate the original (verified by test).
  - Exactly one `lightSource` and at least one `goalCrystal` per valid level (validated on load; invalid levels rejected with a typed error, not a crash).

### F2. Fold transform — Status: **Not built**
Apply a single fold along a horizontal or vertical fold line: one region mirror-folds onto the other, source-region tiles are removed, coordinates are mirror-transformed, and overlaps are recorded for F3 to resolve.
- **MVP fold axes (frozen):** horizontal (fold a row boundary) and vertical (fold a column boundary), in all four directions (top↓, bottom↑, left→, right←). **Diagonal folds are deferred** (TECHNICAL_PRD already marks them "future").
- Acceptance criteria:
  - Given a board and a legal fold line, When the fold is applied, Then every source tile lands at its correct mirror-transformed destination coordinate (verified against hand-computed expected coordinates in tests).
  - Given an illegal fold (line outside board, or producing a zero-size region), When the fold is attempted, Then it is rejected via a typed result and the board is unchanged.
  - A fold is a pure function `(Board, FoldLine) -> FoldResult` with no side effects outside its return value.
  - Folding never produces overlapping tiles at the same coordinate without those overlaps being reported to F3.

### F3. Overlap / combination resolution — Status: **Not built**
When two tiles land on the same cell after a fold, resolve them deterministically per a small, frozen combination matrix.
- **MVP combination rules (frozen, symmetric A+B = B+A):**
  - `lightSource` + `mirror` → reflecting cell (beam turns 90°).
  - `path` + `path` → connected path (traversable).
  - `lightSource`/`path` over `blocker` → illegal/blocked overlap (fold is rejected or the cell stays blocked — pick one rule and test it; v1 rule: such a fold is **illegal**).
  - any tile + `goalCrystal` → goal preserved (goal is never destroyed by an overlap).
  - same type onto same type (other than path) → tile preserved (idempotent), no crash.
- Acceptance criteria:
  - Given two overlapping tiles, When resolved, Then the result matches the frozen matrix exactly and is independent of A/B order (symmetry test).
  - Given an overlap not in the matrix, When resolved, Then a documented default applies (keep target tile) and no crash occurs.
  - Resolution is deterministic: same inputs always produce the same board (replay test).

### F4. Light-beam solver & win detection — Status: **Not built**
Trace the beam from the light source through path/reflecting cells, stopping at blockers, and report whether it reaches the goal crystal.
- Acceptance criteria:
  - Given a solved board, When the beam is traced, Then it reaches the goal crystal and `isSolved == true`.
  - Given an unsolved/blocked board, When traced, Then `isSolved == false` and a beam-segment list is returned for later rendering.
  - Given a mirror/reflecting cell, When the beam enters, Then it exits at the correct 90° direction (per-orientation test).
  - **Loop safety:** the tracer terminates within a hard step cap (≤ 100 steps per TECHNICAL_PRD §3.4) on any board, including adversarial mirror loops; verified by a deliberately-looping test fixture.

### F5. Undo / reset — Status: **Not built**
Unlimited-within-cap undo of folds and a full reset to the level's initial state.
- Acceptance criteria:
  - Given a sequence of folds, When undo is invoked, Then the board returns to the exact previous state (deep-equality test), repeatedly, back to the initial board.
  - Given any state, When reset is invoked, Then the board equals the level's loaded initial board.
  - Undo history is bounded (≤ 20 snapshots per TECHNICAL_PRD §3.5) and never grows unbounded.
  - `canUndo` is false at the initial state and true after any applied fold.

### F6. Hand-authored level set (5 teaching levels) — Status: **Not built**
Five bundled, hand-designed levels (JSON), each isolating exactly one idea, per the conversation's "teach, not pad" cut.
- **Level 1:** a single valid fold reaches the goal (proves the core fold is satisfying in isolation).
- **Level 2:** an overlap/combine (e.g. `path`+`path`) is required to connect the route.
- **Level 3:** a beam must reflect through a folded-in mirror to bend toward the goal.
- **Level 4:** requires more than one fold in sequence (multi-fold).
- **Level 5:** is unsolvable without a specific fold _order_ (proves ordering matters).
- Acceptance criteria:
  - Each of the 5 levels is solvable by the engine via a known fold sequence (a test asserts each ships with at least one valid solution and that the engine reaches `isSolved` when that sequence is applied).
  - Each level loads from bundled JSON without runtime errors.
  - No level is trivially solvable by an empty fold sequence (each requires ≥ 1 fold).
  - Level 5 has at least one fold ordering that fails and one that succeeds (ordering-sensitivity test).

### F7. Playable board UI (SpriteKit) — Status: **Not built**
The on-device playable screen: render the board, recognize a fold gesture, show a fold preview, apply the fold, show overlaps/beam, and detect/display the win.
- Acceptance criteria:
  - Given a loaded level on device/simulator, When the player drags to define a fold line, Then a preview shows the destination region before release.
  - When the player completes the gesture, Then the fold is applied via F2–F4 and the board updates; an illegal fold shows clear, non-annoying feedback and no state change.
  - Undo and Reset buttons invoke F5 and update the view.
  - When the beam reaches the goal, Then a win state is shown (animation acceptable as a stub in first slice).
  - No gameplay logic lives in the rendering layer (engine/UI separation verified by the engine compiling and testing with zero SpriteKit import).

### F8. App shell, navigation & local progress — Status: **Not built**
A minimal SwiftUI shell: Home → Level Select (the 5 levels) → Play → Win/Complete → back; a Settings screen; and Codable persistence of which levels are completed.
- Acceptance criteria:
  - The app launches to a Home screen and navigates Home → Level Select → Play → Complete without a crash.
  - Completing a level persists its completion; relaunching the app shows that level as completed.
  - Settings exposes at least: sound toggle, haptics toggle, reduced-motion toggle, and a reset-progress action; toggles persist across relaunch.
  - Save/load is a real implementation (not a stub) and round-trips progress (test).

### F9. Onboarding / first-run teaching — Status: **Not built**
A lightweight first-run that teaches the fold gesture and the goal (light→crystal) through Level 1, without text walls.
- Acceptance criteria:
  - On first launch, the player is guided to perform their first fold via an on-board prompt (gesture coach), not a paragraph of instructions.
  - The fold→combine→beam→win causal chain is demonstrated within the first level.
  - Onboarding can be skipped/replayed and its "seen" flag persists.

### F10. Accessibility & feel baseline — Status: **Not built**
The minimum accessibility and game-feel hooks that a premium puzzle game must ship with.
- Acceptance criteria:
  - Every interactive tile/control exposes a VoiceOver `accessibilityLabel`.
  - Reduced Motion replaces the fold animation with a crossfade (no large motion).
  - Haptic feedback fires on fold, invalid fold, undo, and win (respecting the haptics toggle).
  - Dynamic Type: all on-screen text scales with the system setting.

---

## 3. Out of Scope (v1 non-goals)

Everything below is documented somewhere in the repo but is **explicitly excluded from v1**. The unifying rule: nothing that depends on the fold mechanic being fun ships before the fold mechanic is proven fun.

- **Procedural / infinite level generation** (TECHNICAL_PRD §4, PROMPT_LOG FOLDLIGHT-PROMPT-004, tracker E005). Deferred to a _disposable throwaway spike_ run only after the 5 hand levels pass the fun test, per `Foldlight.md`. A generator that emits puzzles you cannot yet validate as solvable is untestable; it needs a solver/validator for hand levels first.
- **Daily puzzle (seeded-by-date)** — depends on the generator; deferred.
- **10 biomes / world themes** (crystalCave … luminousDesert). v1 ships one neutral visual theme.
- **World-restoration meta-progression, Light Fragments currency, stars** (PROMPT_LOG FOLDLIGHT-PROMPT-005). Deferred; v1 progress is just "level completed."
- **All monetization:** StoreKit 2, IAP, the (mutually contradictory) SKU catalogs, subscriptions / Challenge Pass, **and AdMob rewarded ads**. v1 has none. (The AdMob plan in MONETIZATION_PRD also directly conflicts with the "zero third-party deps / zero network" guarantees in TECHNICAL_PRD — see §7-R1.)
- **Game Center / GameKit:** leaderboards and the 200-achievement plan (tracker E009, INVESTOR_DECK). Deferred (TECHNICAL_PRD itself defers GameKit to ≥ v1.1/v1.2).
- **Extended tile set & combinations** beyond the 5 MVP types: water/seed/fire/ice/key/lock/shadow/monster/cage and their combos. Deferred until the 5-type beam loop is proven.
- **Diagonal folds** (TECHNICAL_PRD §3.2 "future").
- **SwiftData persistence, cloud/iCloud sync, cross-device save.** v1 is local Codable only.
- **Large level libraries** (the "30", "100", "50–500 per biome" counts scattered across betas/investor docs). v1 is exactly 5 teaching levels.
- **Analytics beyond a local debug-only event log.** No third-party analytics SDK, ever, in v1.
- **iPad / macOS Catalyst, landscape.** iPhone portrait only.
- **Hint engine / solver-as-a-product** (TECHNICAL_PRD §4 hint system, tracker T004-06). A solver may exist internally to validate levels, but a player-facing hint feature (and any hint monetization) is deferred.

---

## 4. User Flows

These are the v1 flows to build. Screen names map to the F8/F7 screens above. (None exist in code yet — they are the target.)

### 4.1 First run / onboarding (F9)
1. App launches to **Home** for the first time; "seen onboarding" flag is false.
2. Tapping **Play** (or auto-routing) opens **Level 1** in the **Play** screen with a gesture coach.
3. The coach prompts a single drag to define a fold line; the destination region previews.
4. Player releases; the fold applies, tiles combine, the beam traces and reaches the goal.
5. **Win** state shows; the onboarding flag is set; player returns to **Level Select**.

### 4.2 Core loop (F1–F8)
1. From **Level Select**, the player picks a level (1–5).
2. **Play** screen renders the board (F7).
3. Player drags to define a fold line → preview shown.
4. On release, the engine applies the fold (F2), resolves overlaps (F3), re-traces the beam (F4), and the view updates.
5. Player may tap **Undo** (F5) or **Reset** (F5) freely.
6. When the beam reaches the goal (F4 win), the **Complete** screen shows; completion persists (F8).
7. Player returns to **Level Select**; the completed level is marked done.

### 4.3 Settings / accessibility (F8, F10)
1. From **Home**, open **Settings**.
2. Toggle sound, haptics, reduced motion; trigger reset-progress (with confirm).
3. Changes persist across relaunch (F8 acceptance).

### 4.4 Share / export
**Not in v1.** No screenshot/clip-export feature ships in v1; the "shareable fold clip" is captured by the player via the iOS system screen recorder, not an in-app feature. (Listed here only to state it is intentionally absent.)

---

## 5. Acceptance Criteria Summary

| ID | Feature | Launch pass/fail gate | Status |
|----|---------|------------------------|--------|
| F1 | Board & tile model | Levels load to correct boards; encode/decode round-trips; value semantics; no force-unwrap | Not built |
| F2 | Fold transform | Legal folds map coordinates correctly; illegal folds rejected; pure function | Not built |
| F3 | Overlap resolution | Frozen matrix applied deterministically & symmetrically; safe default for unknown overlaps | Not built |
| F4 | Beam solver & win | Beam reaches goal on solved boards; reflects correctly; terminates within step cap on loops | Not built |
| F5 | Undo / reset | Undo restores exact prior state; reset restores initial; bounded history | Not built |
| F6 | 5 teaching levels | Each engine-solvable, each isolates one idea, level 5 is order-sensitive | Not built |
| F7 | Playable UI | On-device fold gesture + preview + apply + win; engine/UI separation | Not built |
| F8 | Shell & progress | Home→Select→Play→Complete no crash; completion persists across relaunch | Not built |
| F9 | Onboarding | First fold taught via gesture coach; flag persists | Not built |
| F10 | Accessibility/feel | VoiceOver labels, reduced motion crossfade, haptics, Dynamic Type | Not built |

**Launch gate (all must hold):** F1–F8 fully built with passing tests; F9–F10 built; the engine compiles and tests with zero SpriteKit/SwiftUI import; the fun-validation north-star (§1) passes a manual playtest. Until then the recommended status is **Planning** (docs/scope only; no app code).

---

## 6. Known Limitations

- **Nothing is implemented.** All of §2 is a build target; "Known Limitations" here are forward-looking design constraints, not observed defects.
- **The fold mechanic's fun is unproven.** The core product risk is whether folding is satisfying after five minutes. No human has played it. This is acknowledged repeatedly in `Foldlight.md` and is the gating uncertainty.
- **The frozen 5-tile MVP set is a deliberate narrowing.** It can express "fold to route light to a goal," but it does _not_ deliver the richer combinations (bridges, gates, steam, captures) the marketing docs promise. Those are deferred, so v1 will look mechanically thinner than the PRDs imply.
- **No procedural content.** v1 has exactly 5 levels and ~10–20 minutes of content. It is a _proof_, not a retainable product; retention metrics in the betas/business docs are not achievable from v1 content alone.
- **Beam solver is approximate by design** (raycast with a hard step cap). Exotic mirror geometries are capped, not exhaustively simulated; this is a correctness/perf trade-off, not a bug.
- **Persistence is minimal (Codable/file).** No migration story, no cloud sync, no multi-device — by choice for v1. A future SwiftData migration is non-trivial and deferred.
- **Performance/feel targets (60/120fps, <2s launch) are unverified** because there is no build to profile.
- **Docs remain internally contradictory** outside the items reconciled in this pass: IAP catalogs, level counts, app name/subtitle, and Game Center timing differ across PRDs. v1 sidesteps these by shipping none of those features, but they must be reconciled before any monetized release (see §7).

---

## 7. Bug & Risk Triage

There are **no code bugs** because there is no code. The "launch-blocking" list below is therefore composed of (a) the absence of all build work, (b) concrete doc/spec contradictions that would mislead an implementer or fail App Store review if shipped as written, and (c) product/safety/privacy risks. IDs prefixed `BLK` (blocking) and `NB` (non-blocking).

### Launch-blocking (must fix before TestFlight / App Store)

- **BLK-1 — No application exists.** _Where:_ entire repo (no Xcode project, no Swift, no tests). _Why blocking:_ there is nothing to submit; F1–F10 must be built and tested. This is the master blocker.
- **BLK-2 — Stale repo identity (`claude_app_3`).** _Where:_ `README.md` line 3, `docs/PROJECT_TRACKER.md`, `docs/BUG_TRACKER.md`, `docs/PROMPT_LOG.md` headers. _Why blocking:_ the docs name the wrong repo and describe directories (`Foldlight/`, `FoldlightTests/`, `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md`) as if they exist; an implementer or reviewer will be misled about current state. Reconciled in this pass (README + PROJECT_DOCUMENTATION updated); trackers still carry the legacy name and should be corrected as build begins.
- **BLK-3 — Monetization model contradicts the privacy/offline guarantee.** _Where:_ `docs/prd/MONETIZATION_PRD.md` §2.3/§3 (AdMob/Google rewarded ads, IDFA-optional) vs `docs/prd/TECHNICAL_PRD.md` §1.2/§12/§13/§14 ("0 network calls during gameplay," "zero third-party dependencies," "no PII"). _Why blocking:_ shipping AdMob would require a network connection, a third-party SDK, a tracking-domain entry, and a `PrivacyInfo.xcprivacy` declaring data collection — directly breaking the privacy posture the app is pitched on and risking App Store privacy-label rejection. v1 resolves it by shipping **no ads and no IAP**; before any monetized release this conflict must be explicitly resolved (recommended: no ads; cosmetic IAP only).
- **BLK-4 — Three incompatible IAP catalogs.** _Where:_ `TECHNICAL_PRD.md` §7.1 (`com.foldlight.noads`, `.starterbundle`, `.hints.10/.50`, `.skin.*`, `.challengepass.s1`) vs `PROMPT_LOG.md`/`PROJECT_TRACKER.md` (`.lux_pack_v1`, `.crystal_pack_v1`, `.world_bundle_forest`, `.hints_5/20`, `.pass_monthly`, `.infinite_unlock`) vs `INVESTOR_DECK_PRD.md` slide 6 (Lux/Crystal/World/Hint/Pass). _Why blocking (for any monetized build):_ product IDs are permanent in App Store Connect; shipping mismatched/placeholder IDs is unrecoverable. v1 ships no IAP, so this is deferred — but it must be frozen to one catalog before monetization.
- **BLK-5 — No privacy/compliance artifacts.** _Where:_ no `PrivacyInfo.xcprivacy`, no privacy policy, no age rating decided. _Why blocking:_ App Store submission requires a privacy manifest and (since the app is offline with no data collection) a "Data Not Collected" label; these must exist and match reality before review. (Easy once built, but absent today.)
- **BLK-6 — Core mechanic fun is unvalidated.** _Where:_ product-level (`Foldlight.md` north-star). _Why blocking:_ per the agreed kill-criterion, content/monetization/marketing must not proceed if a first-time player does not voluntarily replay to find a cleaner fold. Launching a polished-but-unfun mechanic wastes the one-shot launch moment. Gate launch on the §1 fun test.
- **BLK-7 — Frozen rules contract must be locked before code.** _Where:_ tile set (5 vs 7 vs 8 vs 15 across README/TECHNICAL_PRD/PROMPT_LOG), combination matrix, fold axes, beam/loop rules, undo model. _Why blocking:_ the conversation's explicit sequencing is "design mechanics before code"; building SpriteKit before the matrix is frozen hard-codes a guess. This document freezes the v1 contract (§2 F1–F5); it must be honored, not re-litigated mid-build.

### Non-blocking (ship-with / fix later)

- **NB-1 — Level-count inconsistency** (5 vs 20 vs 30 vs 100 across `Foldlight.md`, `PRIVATE_BETA_PRD`, `PUBLIC_BETA_PRD`). _Defer:_ v1 is unambiguously 5 (§2 F6); the larger counts belong to post-validation content phases.
- **NB-2 — App name/subtitle inconsistency** ("Foldlight — Infinite Puzzle" / "Foldlight: Spatial Puzzle" / differing subtitles across GTM and Marketing PRDs). _Defer:_ ASO metadata, finalized at store-submission time.
- **NB-3 — Game Center timing inconsistency** (TECHNICAL_PRD defers GameKit to v1.2 but its appendix says v1.1; tracker E009 plans 200 achievements as if MVP). _Defer:_ all Game Center is out of v1 scope (§3); reconcile when/if it's scheduled.
- **NB-4 — Diagonal fold ambiguity** (README/tracker imply it; TECHNICAL_PRD marks "future"). _Defer:_ v1 excludes diagonal folds (§3); resolve when designing v2 axes.
- **NB-5 — SwiftData vs Codable persistence** (TECHNICAL_PRD/PROMPT_LOG assume SwiftData; v1 chooses Codable). _Defer:_ Codable is sufficient and smaller for 5 levels; revisit if cloud sync/large libraries are ever scoped.
- **NB-6 — Risk register in `BUG_TRACKER.md` references unbuilt subsystems** (generator infinite-loop, StoreKit idempotency, biome atlas memory, Game Center offline queueing). _Defer:_ valid future risks but tied to deferred features; keep as design notes, not active bugs.
- **NB-7 — Aspirational financials/marketing budgets** ($120K marketing, $400K seed ask, 500K downloads) far exceed the self-funded, AI-built reality stated in BUSINESS_PLAN_PRD ($800 total cost). _Defer:_ harmless for the build; flag before any external use of the investor deck.

---

## 8. Production-Readiness Assessment

### Current estimated readiness: **8%**
Justification: the product concept, target user, and a coherent (now-reconciled) mechanics contract are well-defined — that is real, reusable planning value, and it is most of what exists. But **0% of the application is built**: no project, no engine, no UI, no tests, no store/privacy artifacts. Documentation completeness is high; implementation completeness is zero. An 8% figure credits the clarified scope and frozen rules contract (which de-risk the first code PR) while honestly reflecting that every shippable surface is absent. Status: **Planning**.

### Concrete remaining work to reach 80–90% production-ready (ordered checklist)
1. **Freeze the mechanics contract** (this doc) and correct stale repo identity in README + PROJECT_DOCUMENTATION (done in this pass); propagate the `foldlight` name into the trackers.
2. **Create the Xcode project / Swift package** targeting iOS 17, with a **pure-Swift engine module** that imports no UI framework. (PROMPT_LOG FOLDLIGHT-PROMPT-001/002 are the build prompts; honor §2's frozen 5-tile scope, not the 7/8-tile prompts.)
3. **Build F1 (board/tile model)** with Codable load + value semantics; unit-test round-trip and bounds safety.
4. **Build F2 (fold transform)** as a pure function; unit-test coordinate mapping and illegal-fold rejection.
5. **Build F3 (overlap matrix)**; unit-test determinism + symmetry + safe default.
6. **Build F4 (beam solver + win)**; unit-test reflection, blocked beams, and **loop termination under the step cap**.
7. **Build F5 (undo/reset)**; unit-test exact state restoration and bounded history.
8. **Author F6 (5 teaching levels)** as bundled JSON; add a test asserting each is engine-solvable and level 5 is order-sensitive. _(Engine is now headless-complete and fully testable — this is the fun-validation gate.)_
9. **Run the fun test** (§1 north-star) on the headless engine via a debug harness or first rough UI. If it fails, stop and redesign the mechanic — do not proceed to polish.
10. **Build F7 (SpriteKit board UI)**: render, fold gesture + preview, apply, beam/win display; keep all logic in the engine.
11. **Build F8 (SwiftUI shell + Codable progress)**: Home→Select→Play→Complete→Settings; persist completion; test save/load round-trip.
12. **Build F9 (onboarding gesture coach)** and **F10 (VoiceOver labels, reduced-motion crossfade, haptics, Dynamic Type)**.
13. **Add app icon + launch screen; write `PrivacyInfo.xcprivacy` ("Data Not Collected"); set age rating 4+; write a short privacy policy.**
14. **Stand up CI** (build + `swift test`) and a manual on-device QA pass across at least one A14-class and one ProMotion device for the feel/perf targets.
15. **TestFlight internal build**; collect playtest data against the §1 success signals; only then decide whether to scope content/monetization (the deferred §3 items) for a later version.

Reaching the end of step 12 with green tests and a passing fun test puts the app at roughly **80–85%** of a v1 launch (steps 13–15 close the remaining store/privacy/QA gap).

### Test coverage summary
- **Currently tested:** nothing — there are no tests and no test target in the repo.
- **Planned coverage (the bar this doc sets):** the engine (F1–F5) must be covered by `swift test` with high coverage (TECHNICAL_PRD §10 asks for ≥ 85–90% on core/engine; v1 should hit that on the engine because it is pure and small). Required engine tests: board load/round-trip, fold coordinate mapping, illegal-fold rejection, overlap matrix determinism + symmetry, beam reflection/blocking, beam loop-cap termination, undo/reset exactness, and per-level solvability for all 5 levels (F6).
- **Lighter coverage (acceptable for v1):** UI (F7/F8/F9) via a few smoke/XCUITests for the Home→Play→Complete path and save/load persistence; full UI-test breadth is out of scope for v1.

---

## 9. Launch Checklist

App Store / privacy / safety / content items specific to Foldlight. None are satisfied yet (pre-build); this is the gate list.

- [ ] **Buildable app**: Xcode project compiles; `swift test` green on the engine; runs on device (closes BLK-1).
- [ ] **Repo identity corrected**: no remaining `claude_app_3` references in shipped docs/metadata (BLK-2; README + PROJECT_DOCUMENTATION done, trackers pending).
- [ ] **`PrivacyInfo.xcprivacy` present and accurate**: declares **no data collection / no tracking** (matches offline, no-analytics, no-ads v1) (BLK-5).
- [ ] **App Store privacy label = "Data Not Collected"**, consistent with the manifest and with shipping zero third-party SDKs (BLK-3 resolved by shipping no ads).
- [ ] **No third-party dependencies / no network calls** in the build — verified, not just documented (closes the AdMob contradiction for v1).
- [ ] **Age rating 4+** (no objectionable content; calm puzzle) set in App Store Connect (matches PUBLIC_BETA_PRD).
- [ ] **No StoreKit/IAP in v1**: confirm no `.storekit` config and no purchase code ship; defer the IAP-catalog freeze (BLK-4) to a later monetized version.
- [ ] **Content sign-off**: the 5 levels are solvable and free of placeholder art/strings; no lorem-ipsum or debug-only UI in the shipped build.
- [ ] **Accessibility pass (F10)**: VoiceOver labels on all controls, Reduced Motion path, Dynamic Type, one-thumb reachable gestures — minimum bar before TestFlight.
- [ ] **Haptics/feel**: CoreHaptics fires on fold/invalid/undo/win, respects the settings toggle and silent switch (AVAudioSession `.ambient`).
- [ ] **Fun-validation gate passed** (§1 north-star) before committing to launch marketing (BLK-6).
- [ ] **App icon + launch screen** present at required sizes.
- [ ] **Privacy policy URL** live (even a minimal "we collect nothing" policy) for the App Store listing.
- [ ] **Crash-free smoke pass**: Home→Select→Play→Undo→Reset→Complete→Settings with no crash on a clean install and on relaunch (progress persists).
- [ ] **ASO metadata finalized**: single app name + subtitle chosen (resolves NB-2) with screenshots that show the _real_ v1 (5 levels, one theme), not the unbuilt 10-biome vision.
