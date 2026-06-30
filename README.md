# 🌟 Foldlight — Folding Light Puzzle Game

> _Updated 2026-06-30 to match the shipped product and launch scope. See [LAUNCH_READINESS.md](LAUNCH_READINESS.md)._

**Repository:** `pri8771/foldlight`
**Platform:** iOS 17+
**Engine:** Swift 5.9 | SwiftUI + SpriteKit (planned)
**Status:** Pre-build / Docs-only — Planning Phase
**Version:** 0.0.0 (no app code yet)

> **Current implementation state (2026-06-30):** This repository is **documentation only**. There is **no Xcode project, no Swift source, and no tests** yet — the `Foldlight/` and `FoldlightTests/` directories described below are the _planned_ structure, not present files. The canonical, build-to spec for v1 is **[LAUNCH_READINESS.md](LAUNCH_READINESS.md)**, which deliberately narrows the broad vision below to **one proven fold-and-solve mechanic plus 5 hand-authored levels** (no procedural generation, no monetization, no Game Center in v1). Treat the marketing-scale sections (10 biomes, infinite generation, full IAP catalog) as long-term vision, not v1 scope.

---

## 🎮 Game Overview

**Foldlight** is a relaxing, procedurally infinite puzzle game where players fold a magical glass-paper board to overlap tiles, bend light, reveal hidden paths, and restore a broken world — one fold at a time.

> *"Fold the board. Bend the rules. Rebuild a broken world."*

---

## 🎯 Core Mechanic

The board is made of foldable magical tiles. Instead of matching, swapping, or sorting, the player **folds sections of the board** over other sections. When tiles overlap, they combine and transform.

**v1 frozen mechanic (the only set v1 builds — see LAUNCH_READINESS.md §2):** five tile types — `lightSource`, `goalCrystal`, `path`, `mirror`, `blocker` — and a small symmetric combination matrix:

| Tile A | Tile B | Result |
|--------|--------|--------|
| Light Source | Mirror | Beam turns 90° (reflecting cell) |
| Path | Path | Connected, traversable path |
| Light/Path | Blocker | Illegal/blocked overlap (fold rejected) |
| Any | Goal Crystal | Goal preserved |

**Long-term vision (deferred, not v1):** richer combinations — Seed+Water (bridge), Fire+Ice (steam), Key+Lock (gate), Empty+Shadow (revealed path), Monster+Cage (capture) — are documented in the PRDs but are out of v1 scope.

The goal: guide a beam of light from its source to the goal crystal — but the only way to solve the puzzle is by **folding the board itself into new arrangements**.

---

## 📁 Repository Structure

**Present today (docs only):**

```
foldlight/
├── README.md                    # This file
├── LAUNCH_READINESS.md          # Canonical v1 build-to spec (read this)
└── docs/
    ├── prd/
    │   ├── TECHNICAL_PRD.md
    │   ├── NON_TECHNICAL_PRD.md
    │   ├── BUSINESS_PLAN_PRD.md
    │   ├── MONETIZATION_PRD.md
    │   ├── PRIVATE_BETA_PRD.md
    │   ├── PUBLIC_BETA_PRD.md
    │   ├── GO_TO_MARKET_PRD.md
    │   ├── MARKETING_PLAN_PRD.md
    │   └── INVESTOR_DECK_PRD.md
    ├── PROJECT_DOCUMENTATION.md
    ├── PROJECT_TRACKER.md
    ├── BUG_TRACKER.md
    └── PROMPT_LOG.md
```

**Planned (not yet created)** — the v1 build target adds a pure-Swift, UI-free engine module plus a thin SwiftUI/SpriteKit shell:

```
Foldlight/                   # Xcode project (Swift source) — NOT PRESENT YET
├── App/                     # SwiftUI app shell, navigation
├── Engine/                  # Pure Swift: Board, Fold, OverlapMatrix, BeamSolver (no UI imports)
├── Game/                    # SpriteKit board renderer + gestures
├── Data/                    # Codable level loading + local progress
└── Resources/               # 5 bundled levels (JSON), assets
FoldlightTests/              # swift test target for the Engine — NOT PRESENT YET
```

> Note: `docs/ARCHITECTURE.md` and `docs/DESIGN_SYSTEM.md` are referenced in older drafts but do **not** exist yet; the engine/UI architecture is specified in LAUNCH_READINESS.md §1 and §8.

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Game Engine | SpriteKit |
| Persistence | SwiftData / UserDefaults |
| Purchases | StoreKit 2 |
| Achievements | GameKit |
| Architecture | MVVM + Clean Architecture |
| Testing | XCTest + Swift Testing |
| CI/CD | Xcode Cloud |

---

## 🎨 Design Philosophy

- **Modern & Premium** — feels like a AAA mobile title from a large studio
- **Cozy & Magical** — stained glass, soft glowing night palette, impossible geometry
- **Satisfying Feedback** — every fold has weight, particle effects, haptics
- **Accessibility First** — supports Dynamic Type, VoiceOver, reduced motion

---

## 💰 Monetization (deferred — NOT in v1)

> **v1 ships with no monetization** — no StoreKit, no IAP, no ads, no subscription. The list below is long-term vision. Note: older monetization docs are internally contradictory (e.g. `MONETIZATION_PRD.md` plans Google AdMob rewarded ads, which conflicts with this project's "zero third-party dependencies / no network calls / no data collected" guarantees in `TECHNICAL_PRD.md`). The recommended resolution is **no ads; cosmetic IAP only**, decided after the core mechanic is proven fun. See LAUNCH_READINESS.md §3 and §7 (BLK-3, BLK-4).

- 🎨 **Cosmetic Board Skins** — different visual themes (post-v1)
- 💡 **Hint Packs** — optional convenience, never required (post-v1)
- 🚫 **No Ads / premium unlock** — only relevant if ads are ever added (currently: no ads)
- ❌ **No pay-to-win, no energy timers, no gambling** — all puzzles solvable without spending

---

## 🗺️ Development Roadmap

**v1 (current target) — prove the mechanic, then stop:** build a pure-Swift fold/overlap/beam engine (test-first, no SpriteKit), 5 hand-authored teaching levels, a minimal SwiftUI+SpriteKit playable shell, undo/reset, onboarding, and basic accessibility. **Then gate everything else on a fun test** (does a first-time player voluntarily replay to find a cleaner fold?). See LAUNCH_READINESS.md §2 and §8.

| Phase | Description | Scope |
|-------|-------------|-------|
| Phase 0 | Documentation & Planning | Done |
| Phase 1 | **v1:** Headless engine (fold, overlap, beam, win, undo) + 5 levels + tests | Current |
| Phase 2 | **v1:** Playable SpriteKit board UI + SwiftUI shell + local progress + onboarding + a11y | Current |
| Phase 3 | **Gate:** fun validation on the 5 levels | Decision point |
| Phase 4 | Procedural generator _spike_ (disposable; only if fun test passes) | Deferred |
| Phase 5 | Meta-progression, biomes, content scale-up | Deferred |
| Phase 6 | Monetization decision (cosmetic IAP only; no ads) | Deferred |
| Phase 7 | Private → Public Beta (TestFlight) | Deferred |
| Phase 8 | App Store Launch | Deferred |

---

## 📚 Documentation

All project documentation lives in `/docs/prd/`. See individual PRD files for detailed specifications.

---

## 🤝 Collaboration

This game is being developed in collaboration with:
- **Claude (Anthropic)** — primary development, design, architecture
- **ChatGPT (OpenAI)** — concept development, planning, prompt generation

---

## ⚖️ License

Proprietary — All rights reserved © 2026 pri8771
