# Bug Tracker — Foldlight (claude_app_3)

**Game:** Foldlight — Spatial Puzzle
**Platform:** iOS 17.0+
**Last Updated:** 2026-06-30

---

## Legend

| Field | Values |
|-------|--------|
| **Status** | 🔴 Open / 🟡 In Progress / 🟢 Closed / ⚫ Deferred / 🔵 Cannot Reproduce |
| **Severity** | P0 (Critical/Crash) / P1 (Major) / P2 (Minor) / P3 (Cosmetic) |
| **Type** | Crash / Logic / UI / Performance / IAP / Data / Audio |

---

## Active Bugs

*No active bugs yet — development not started.*

---

## Closed Bugs

| Bug ID | Title | Severity | Type | Status | Reported Date | Reported By | Device / OS | Steps to Reproduce | Expected | Actual | Root Cause | Fix Description | Fixed Date | Fixed By | PR/Commit |
|--------|-------|----------|------|--------|---------------|-------------|-------------|-------------------|----------|--------|-----------|-----------------|-----------|---------|----------|
| BUG-000 | Template Row | P2 | Logic | 🟢 Closed | 2026-06-27 | System | iPhone 15 / iOS 17.5 | 1. Open app 2. Do X 3. Observe | Expected result | Actual result | Root cause explanation | Fix description | 2026-06-27 | Team | abc1234 |

---

## Pre-Development Known Risks (Tracked as Potential Bugs)

| Risk ID | Area | Description | Likelihood | Mitigation |
|---------|------|-------------|-----------|-----------|
| RISK-001 | Fold Engine | Board state corruption if fold applied during animation | Medium | Lock board state during animation transition |
| RISK-002 | Fold Engine | Infinite loop in reverse-construction generator | Low | Add iteration cap + fallback to pre-validated puzzles |
| RISK-003 | SpriteKit | Memory spike when loading large biome atlas | Medium | Use on-demand asset loading + texture atlas paging |
| RISK-004 | StoreKit 2 | Transaction not finalized if app crashes mid-purchase | Low | Always check unfinished transactions on app launch |
| RISK-005 | SwiftData | Migration failure on model version change | Medium | Strict versioned migration plan before any model changes |
| RISK-006 | Performance | 60fps drop on older devices (iPhone 12) during fold animation | Medium | Reduce particle count + use lower-res textures on A14 and below |
| RISK-007 | Game Center | Leaderboard submission failure during offline play | High | Queue failed submissions, retry on next connection |
| RISK-008 | IAP | Duplicate purchase charged if network timeout | Low | StoreKit 2 handles idempotency, but verify with sandbox testing |
| RISK-009 | Puzzle Gen | Difficulty curve not matching intended progression | Medium | Playtest each biome independently, adjust classifier thresholds |
| RISK-010 | Audio | ASMR sounds not playing when device on silent | Low | Use AVAudioSession with .ambient category to bypass silent mode |

---

## Bug Filing Template

When filing a new bug, copy this template:

```markdown
### BUG-[XXX]: [Short Title]

**Severity:** P0/P1/P2/P3
**Type:** Crash/Logic/UI/Performance/IAP/Data/Audio
**Status:** 🔴 Open
**Reported:** YYYY-MM-DD
**Reported By:** [Name/Role]
**Device:** [Model] / iOS [version]
**App Version:** [version]
**Build:** [build number]

#### Steps to Reproduce
1. 
2. 
3. 

#### Expected Behavior


#### Actual Behavior


#### Frequency
[ ] Always [ ] Sometimes (___%) [ ] Rare [ ] Cannot Reproduce

#### Attachments
- Screenshots:
- Video:
- Crash log:
- Console output:

#### Notes

```

---

## Bug Statistics

| Metric | Value |
|--------|-------|
| Total Bugs Filed | 0 |
| Open (🔴) | 0 |
| In Progress (🟡) | 0 |
| Closed (🟢) | 0 |
| Deferred (⚫) | 0 |
| Cannot Reproduce (🔵) | 0 |
| P0 Crashes | 0 |
| P1 Major | 0 |
| P2 Minor | 0 |
| P3 Cosmetic | 0 |

---

## Bug History Log

| Date | Action | Bug ID | Notes |
|------|--------|--------|-------|
| 2026-06-27 | Created bug tracker | — | Initial setup |
| 2026-06-28 | Foundation implemented (FOLDLIGHT-PROMPT-001) | — | App shell, navigation, services, persistence, design system + unit tests added. No defects found during implementation review. |
| 2026-06-28 | Core fold engine implemented (FOLDLIGHT-PROMPT-002) | — | Board/fold/combination/beam models + solver + undo/reset + 6 test files. No defects found; engine is Foundation-only and deterministic. |
| 2026-06-28 | Playable SpriteKit board implemented (FOLDLIGHT-PROMPT-003) | — | GameScene/TileNode renderer, drag-to-fold + preview, beam draw, win animation, HUD, gesture interpreter + tests. Engine/UI separation preserved. No defects found. |
| 2026-06-28 | Board animation upgrade (FOLDLIGHT-PROMPT-003 expanded) | — | BoardScene + GameView, 0.3s paper-fold, combination FX, 1.5s win + glow, animated undo, green/red feedback, debug coord labels. |
| 2026-06-28 | Procedural level system implemented (FOLDLIGHT-PROMPT-004) | — | Seeded generator (constructive, verified solvable), validator, daily puzzle, level repository + prefetch, Infinite/Daily wiring, 4 test files. Removed hardcoded sample from production. No defects found. |
| 2026-06-30 | Vertical-slice completion loop implemented (FOLDLIGHT-PROMPT-005) | — | First-run onboarding, 5 guided levels, reward/star/fragment loop, hint credits, restoration unlock/select, StoreKit manager/shop, app icon metadata, and 14 additional tests. Full simulator suite: 99 passing. |

---

## Known Limitations (Foundation Phase — not defects)

These are intentional, documented gaps from the Phase 1 foundation, tracked so they
are not mistaken for bugs. None are P0/P1.

| Ref | Area | Limitation | Planned Resolution |
|-----|------|-----------|--------------------|
| LIM-001 | Build verification | Foundation was authored in a Linux container without Xcode; the iOS build & `swift test` were not executed in-session. | Run `xcodebuild`/tests on a macOS host (first task of next phase). |
| LIM-002 | Persistence | MVP uses Codable file storage + UserDefaults instead of SwiftData (per Phase 1 prompt). | Swap behind `SaveService` protocol in a later phase (tracker T002-05). |
| LIM-003 | Audio | `AudioService` is a documented stub (configures the session, no samples). | Wire ASMR/music assets in E010. |
| LIM-004 | App icon | Generated master icon is wired into required slots, but final marketing-grade art direction is not complete. | Replace with final E010 artwork before TestFlight marketing/screenshots. |
| LIM-005 | Play screen | Playable SpriteKit board has animated folds/FX and hints, but tiles still use glyph placeholders rather than bespoke art. | Produce tile art and biome skins in E010. |
| LIM-006 | StoreKit | StoreKit 2 manager/shop code exists, but sandbox checkout depends on App Store Connect products or a local StoreKit configuration. | Configure products and run sandbox purchase/restore QA before beta. |
| LIM-007 | Geometric unfold | `FoldEngine.unfold()` (reverse-construction primitive) is deferred; undo uses board snapshots instead. | Add for the procedural generator (Phase 4). |

---

*Bugs should be filed immediately when discovered. Never ship with known P0 or P1 bugs.*
*Last updated: 2026-06-30*
