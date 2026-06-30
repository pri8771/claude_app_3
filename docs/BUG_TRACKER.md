# Bug Tracker — Foldlight

> _Updated 2026-06-30 to match the shipped product and launch scope. See [../LAUNCH_READINESS.md](../LAUNCH_READINESS.md)._
>
> **Reconciliation notes:** Repo is `pri8771/foldlight` (`claude_app_3` is legacy). There are no code bugs because there is no code yet (pre-build / docs-only). The launch-blocking and non-blocking issue triage for v1 lives in **LAUNCH_READINESS.md §7** (e.g. no app exists, stale repo identity, the AdMob-vs-offline monetization contradiction, three incompatible IAP catalogs). Several "Pre-Development Known Risks" below reference deferred subsystems (procedural generator, StoreKit, Game Center, biome atlases) that are **out of v1 scope** — keep them as design notes, not active v1 bugs.

**Game:** Foldlight — Folding Light Puzzle
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

---

*Bugs should be filed immediately when discovered. Never ship with known P0 or P1 bugs.*
*Last updated: 2026-06-27*
