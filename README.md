# 🌟 Foldlight — Infinite Folding Puzzle Game

**Repository:** `claude_app_3`  
**Platform:** iOS 17+  
**Engine:** Swift 5.9 | SwiftUI + SpriteKit  
**Status:** Pre-Development | Planning Phase  
**Version:** 0.1.0-alpha  

---

## 🎮 Game Overview

**Foldlight** is a relaxing, procedurally infinite puzzle game where players fold a magical glass-paper board to overlap tiles, bend light, reveal hidden paths, and restore a broken world — one fold at a time.

> *"Fold the board. Bend the rules. Rebuild a broken world."*

---

## 🎯 Core Mechanic

The board is made of foldable magical tiles. Instead of matching, swapping, or sorting, the player **folds sections of the board** over other sections. When tiles overlap, they combine and transform:

| Tile A | Tile B | Result |
|--------|--------|--------|
| Light | Mirror | Beam changes direction |
| Seed | Water | Plant bridge grows |
| Fire | Ice | Steam cloud appears |
| Key | Lock | Door opens |
| Empty | Shadow | Hidden path revealed |
| Broken Path | Matching Path | Path repaired |

The goal: guide a beam of light from its source to the goal crystal — but the only way to solve the puzzle is by **folding the board itself into new arrangements**.

---

## 📁 Repository Structure

```
claude_app_3/
├── README.md                    # This file
├── docs/
│   ├── prd/
│   │   ├── TECHNICAL_PRD.md
│   │   ├── NON_TECHNICAL_PRD.md
│   │   ├── BUSINESS_PLAN_PRD.md
│   │   ├── MONETIZATION_PRD.md
│   │   ├── PRIVATE_BETA_PRD.md
│   │   ├── PUBLIC_BETA_PRD.md
│   │   ├── GO_TO_MARKET_PRD.md
│   │   ├── MARKETING_PLAN_PRD.md
│   │   └── INVESTOR_DECK_PRD.md
│   ├── PROJECT_TRACKER.md
│   ├── BUG_TRACKER.md
│   ├── PROMPT_LOG.md
│   ├── ARCHITECTURE.md
│   └── DESIGN_SYSTEM.md
├── Foldlight/                   # Xcode project (Swift source)
│   ├── App/
│   ├── Game/
│   ├── UI/
│   ├── Data/
│   └── Resources/
└── FoldlightTests/
```

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

## 💰 Monetization (IAP via StoreKit 2)

- 🎨 **Cosmetic Board Skins** — different visual themes per biome
- 💡 **Hint Packs** — optional convenience, never required
- 🌍 **Biome Unlock Bundles** — early access to world areas
- 🚫 **No Ads purchase** — premium one-time unlock
- 🏆 **Challenge Pass** — optional seasonal content
- ❌ **No pay-to-win** — all puzzles solvable without IAP

---

## 🗺️ Development Roadmap

| Phase | Description | Target |
|-------|-------------|--------|
| Phase 0 | Documentation & Planning | Week 1-2 |
| Phase 1 | Core Engine (fold system, tile overlap) | Week 3-6 |
| Phase 2 | Procedural Level Generator | Week 7-9 |
| Phase 3 | Meta-Progression & World Restoration | Week 10-12 |
| Phase 4 | Art, Animations & Polish | Week 13-16 |
| Phase 5 | Monetization & StoreKit | Week 17-18 |
| Phase 6 | Private Beta | Week 19-20 |
| Phase 7 | Public Beta | Week 21-22 |
| Phase 8 | App Store Launch | Week 23-24 |

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
