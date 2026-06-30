# Foldlight — Project Documentation

> _Updated 2026-06-30 to match the shipped product and launch scope. See [../LAUNCH_READINESS.md](../LAUNCH_READINESS.md)._

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

**Implementation state (2026-06-30): pre-build / docs-only.** There is no Xcode project, no Swift source, and no tests in this repo yet. The repo is named `pri8771/foldlight` (older docs say `claude_app_3`). The canonical, build-to spec is `LAUNCH_READINESS.md` at the repo root; where this file and the PRDs differ from it, that document wins. The sections below describe the long-term product; the **v1 launch scope is deliberately narrower** (see §01).

## 00. Executive Summary
Foldlight is an iOS puzzle game whose one mechanic is folding the board: the player folds a grid of tiles so halves overlap and combine, in order to route a beam of light to a goal crystal. It is for puzzle players who like elegant mechanics, beautiful visuals, and short, calm sessions. The product's hook is that you change the shape of the board itself, which is legible in a few seconds of silent video. The end-state product includes fold gestures, tile rules, beam routing, tutorial levels, local progress, QA, and a TestFlight path — but v1 ships only enough to prove the fold loop is fun.

## 01. Product
**v1 frozen scope (the build target):** the fold mechanic with **five tile types** (`lightSource`, `goalCrystal`, `path`, `mirror`, `blocker`), a small symmetric overlap matrix, horizontal/vertical folds, a beam solver + win check, undo/reset, **five hand-authored teaching levels**, a minimal SwiftUI+SpriteKit shell, onboarding, local Codable progress, and basic accessibility. **Out of v1:** procedural/infinite generation, daily seed, 10 biomes, world-restoration meta-progression, all monetization (StoreKit/IAP/ads/subscription), Game Center, and the extended tile set. See LAUNCH_READINESS.md §2 (in scope) and §3 (out of scope).

## 02. Design
Magical glass-paper look, glowing beams, soft biomes, tactile haptics, and calming premium visuals.

## 03. Frontend Technical
SwiftUI shell with a SpriteKit puzzle scene. **Core principle:** the game logic (Board, Tile, FoldAction/FoldLine, OverlapMatrix, BeamPath/BeamSolver, Level, Progress) lives in a **pure-Swift engine module with zero UIKit/SwiftUI/SpriteKit imports**, validated headless with `swift test` _before_ any rendering work. SpriteKit is for rendering and animation only. v1 persistence is **Codable + file storage / UserDefaults** (SwiftData is deferred, not used in v1).

## 04. Backend Technical
No backend, ever, in v1. 100% offline, no network calls during gameplay, no third-party SDKs. Future services (daily puzzle sync, cloud save, remote level packs) are deferred and would require revisiting the privacy posture.

## 05. Business
**v1 has no monetization.** The long-term model is player-first: optional cosmetic board skins and convenience hint packs, no pay-to-win, no energy timers, no gambling. Monetization is decided only after the core mechanic is validated as fun. Note: the older `MONETIZATION_PRD.md` proposes Google AdMob rewarded ads — this conflicts with the offline / zero-third-party / no-data-collected guarantees and is **not** adopted; the recommended resolution is no ads, cosmetic IAP only (LAUNCH_READINESS.md §7 BLK-3/BLK-4).

## 06. Marketing
Positioning: fold the board, bend the rules, restore the light. Channels: satisfying fold clips, puzzle communities, App Store pitch.

## 07. User Acquisition
Beta with puzzle fans, cozy game players, and iOS testers. Metrics: tutorial completion, puzzle completion, hint use, retention, share/save rate.

## 08. Execution
Plan: resolve repo mismatch, build board model, implement fold transform, tile rules, beam routing, vertical slice, local progress, QA.

## 09. QA
Test fold cases, tile overlaps, beam routing, unsolvable states, undo/reset, progress, and performance.

## 10. Legal / Compliance
Keep v1 local if possible. Disclose data handling and purchase behavior if monetization or analytics are added.

## 11. Operations
Release process: vertical slice, internal QA, puzzle beta, TestFlight. Post-launch: daily puzzle, biomes, cosmetics.
