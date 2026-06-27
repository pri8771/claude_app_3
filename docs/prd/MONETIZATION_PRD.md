# Monetization Plan PRD — Foldlight: Infinite Folding Puzzle

**Document Version:** 1.0.0
**Created:** 2026-06-27
**Status:** Draft
**Owner:** Product / Business Lead

---

## 1. Philosophy

Foldlight monetizes through **player delight, not player frustration.**

We never block progress behind paywalls. We never create artificial scarcity. We make players *want* to spend because the game earns their trust first. This approach builds higher lifetime value, better reviews, and organic word-of-mouth.

**Core principles:**
- All puzzles are completable without spending money
- Hints are convenience, not requirements
- Cosmetics enhance aesthetics, not gameplay
- No energy systems, no timers, no artificial waiting
- No loot boxes or gambling mechanics

---

## 2. Revenue Streams

### 2.1 Consumable IAP — Hints

Hints show the player the next optimal fold. They do not solve the puzzle — they point in the right direction.

| Product | Price | Unit Value | Notes |
|---------|-------|-----------|-------|
| Hint Pack (10) | $0.99 | $0.099/hint | Entry-level purchase |
| Hint Pack (50) | $3.99 | $0.079/hint | Best per-unit value |
| Hint Pack (200) | $12.99 | $0.065/hint | Whale-tier option |

**Free hint allocation:**
- 3 free hints at first install (tutorial gift)
- 1 free hint per day (ad-free option in settings)
- 1 free hint per 5-day daily puzzle streak bonus

### 2.2 Non-Consumable IAP — No Ads

| Product | Price | Description |
|---------|-------|-------------|
| No Ads | $2.99 | Permanently removes all optional reward ads |

Note: Ads are only reward-based (player-initiated). There are no interstitial or banner ads. The "No Ads" purchase is primarily for players who don't want any ad prompts.

### 2.3 Non-Consumable IAP — Starter Bundle

| Product | Price | Value |
|---------|-------|-------|
| Starter Bundle | $4.99 | No Ads ($2.99) + 30 hints ($2.97) + Crystal Cave skin ($1.99) = $7.95 value |

Best first-purchase offer. Shown prominently at level 5 completion (first natural monetization moment).

### 2.4 Non-Consumable IAP — Cosmetic Board Skins

Board skins change the visual theme of the entire puzzle board — tile art, background, particle effects, animations.

| Product | Price | Theme |
|---------|-------|-------|
| Crystal Cave Skin | $1.99 | Glowing crystals, deep blue |
| Stardust Skin | $1.99 | Stars, constellations, gold |
| Shadow Realm Skin | $1.99 | Dark, mystery, purple mist |
| Glass Forest Skin | $1.99 | Green glass, nature, light |
| Fire Fjord Skin | $2.99 | Volcanic, dramatic, red/orange |
| Void Archive Skin | $2.99 | Cosmic, minimalist, deep space |

Skin bundles (3-pack) at $4.99 introduced in v1.1.

### 2.5 Auto-Renewing Subscription — Challenge Pass

| Product | Price | Value |
|---------|-------|-------|
| Challenge Pass (Monthly) | $2.99/month | 5 exclusive weekly challenges, 20 bonus hints/month, early biome access, exclusive "Pass Holder" board skin |
| Challenge Pass (Annual) | $19.99/year | Same as monthly + 2 months free |

**Note:** Challenge Pass is soft-launched in v1.1 (not v1.0). Building the subscriber base after establishing organic retention.

---

## 3. Rewarded Ads Strategy

Ads are entirely optional and player-initiated. They are offered as rewards, never interruptions.

| Ad Placement | Reward | Trigger |
|-------------|--------|---------|
| After level fail | Retry with 1 hint revealed | Player taps "Need a hint?" |
| Daily bonus | Double Light Fragments for current session | Daily login screen |
| Extra undo | +5 undos for current puzzle | Player exhausts undo limit |

**Ad frequency cap:** Max 3 rewarded ads per day per player.

**Ad SDK:** AdMob (Google) — privacy manifest compliant, IDFA-optional. When No Ads is purchased, all ad placements are hidden.

---

## 4. Monetization Funnel

### Stage 1: Hook (Sessions 1–3)
Goal: Get the player addicted before asking for money.
- No monetization prompts in first 3 sessions
- Gift 3 free hints on install
- Show beautiful world restoration progress

### Stage 2: First Ask (Level 5–10)
Goal: Convert engaged players.
- Show Starter Bundle offer after Level 5 completion (one-time prompt)
- Offer rewarded ad for bonus fragments after Level 7
- Surface hint purchase naturally when player first gets stuck

### Stage 3: Engagement (Ongoing)
Goal: Retain and upsell.
- Daily puzzle streak bonuses drive daily return
- New skin drops (seasonal / biome unlocks) create purchase events
- Challenge Pass introduced at 30-day engagement

### Stage 4: Deep Players (Month 2+)
Goal: Maximize LTV of engaged users.
- Whale-tier hint pack ($12.99)
- Skin bundles
- Annual Challenge Pass

---

## 5. Price Testing Plan

We will A/B test the following in the first 90 days post-launch:

| Variable | Test A | Test B |
|----------|--------|--------|
| Starter Bundle price | $4.99 | $3.99 |
| Hint Pack 10 price | $0.99 | $1.49 |
| No Ads price | $2.99 | $1.99 |
| First ask timing | Level 5 | Level 8 |

Testing via StoreKit 2 offer codes and App Store product price tiers.

---

## 6. Revenue Projections (12-Month Conservative Model)

**Assumptions:**
- 50,000 downloads in Year 1 (organic + ASO)
- 40% Day-1 retention, 20% Day-7 retention
- 3% conversion rate to any purchase
- Average purchase value $3.50
- 5% DAU watches rewarded ad per day at $0.02 eCPM per impression

| Month | Downloads | DAU | IAP Rev | Ad Rev | Total |
|-------|----------|-----|---------|--------|-------|
| 1 | 15,000 | 2,000 | $1,575 | $200 | $1,775 |
| 2 | 8,000 | 3,200 | $2,520 | $320 | $2,840 |
| 3 | 6,000 | 3,800 | $2,989 | $380 | $3,369 |
| 6 | 4,000 | 4,200 | $3,307 | $420 | $3,727 |
| 12 | 3,000 | 3,800 | $2,989 | $380 | $3,369 |
| **Total** | **~50,000** | | **~$31,000** | **~$3,900** | **~$34,900** |

**Upside scenario** (viral moment, featured by Apple): 5x multiplier = ~$175,000 Year 1.

---

## 7. KPIs & Tracking

| KPI | Target | Tracking Method |
|-----|--------|----------------|
| ARPU (Average Revenue Per User) | > $0.70 | Revenue / Downloads |
| ARPPU (Average Revenue Per Paying User) | > $4.50 | Revenue / Payers |
| Conversion Rate | > 3% | Payers / DAU at 30 days |
| Day-7 Retention | > 20% | Local analytics |
| Day-30 Retention | > 10% | Local analytics |
| IAP Revenue Mix | IAP > 80% of revenue | StoreKit reports |
| Subscription Take Rate | > 1% of DAU by Month 3 | StoreKit reports |

---

## 8. App Store Optimization for Monetization

- App Store screenshots showcase premium skin themes (drives cosmetic sales)
- Description highlights "no energy system, no pay-to-win"
- Feature: Free to Play with Optional Cosmetics
- Review prompt triggered after daily puzzle streak day 3 (high satisfaction moment)

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-06-27 | Business Lead | Initial draft |
