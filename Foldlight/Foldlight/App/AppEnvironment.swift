//
//  AppEnvironment.swift
//  Foldlight
//
//  Lightweight dependency container + observable app state. Holds the single
//  instances of every service and the live, published player/settings state.
//  Injected into the SwiftUI environment so views and view models resolve their
//  dependencies from one place (Clean Architecture composition root).
//

import Foundation
import Combine

/// Composition root: owns services and publishes app-wide state.
@MainActor
final class AppEnvironment: ObservableObject {
    // MARK: Services
    let preferences: PreferencesStore
    let saveService: SaveService
    let haptics: Haptics
    let audio: AudioPlaying
    let analytics: AnalyticsTracking
    let storeManager: StoreManager

    // MARK: Level generation
    let generator: PuzzleGenerator
    let dailyService: DailyPuzzleService
    let levelRepository: LevelRepository

    // MARK: Published state
    @Published private(set) var profile: PlayerProfile
    @Published private(set) var settings: GameSettings
    @Published private(set) var isReady = false
    @Published private(set) var hasCompletedOnboarding = false
    /// The puzzle source the Play screen should load next.
    @Published var pendingGameRequest: GameRequest = .infinite

    init(
        preferences: PreferencesStore,
        saveService: SaveService,
        haptics: Haptics,
        audio: AudioPlaying,
        analytics: AnalyticsTracking,
        storeManager: StoreManager,
        generator: PuzzleGenerator,
        dailyService: DailyPuzzleService,
        levelRepository: LevelRepository
    ) {
        self.preferences = preferences
        self.saveService = saveService
        self.haptics = haptics
        self.audio = audio
        self.analytics = analytics
        self.storeManager = storeManager
        self.generator = generator
        self.dailyService = dailyService
        self.levelRepository = levelRepository
        self.settings = preferences.loadSettings()
        self.profile = .new
    }

    /// Production composition root wiring concrete services together.
    static func live() -> AppEnvironment {
        let preferences = PreferencesStore()
        let settings = preferences.loadSettings()
        let generator = PuzzleGenerator()
        let baseSeed = UInt64(bitPattern: Int64(preferences.launchCount)) &* 0x9E37_79B9_7F4A_7C15 &+ 0xF01D
        return AppEnvironment(
            preferences: preferences,
            saveService: FileSaveService(),
            haptics: HapticsService(isEnabled: settings.hapticsEnabled),
            audio: AudioService(
                soundEffectsEnabled: settings.soundEffectsEnabled,
                musicEnabled: settings.musicEnabled
            ),
            analytics: AnalyticsService(),
            storeManager: StoreManager(),
            generator: generator,
            dailyService: DailyPuzzleService(generator: generator),
            levelRepository: LevelRepository(generator: generator, baseSeed: baseSeed)
        )
    }

    // MARK: - Lifecycle

    /// Load persisted state and prepare services. Safe to call once on launch.
    /// Never crashes: a corrupt/missing profile falls back to a fresh one.
    func bootstrap() async {
        preferences.recordLaunch()
        audio.prepare()
        storeManager.start()
        applySettingsToServices()
        hasCompletedOnboarding = preferences.hasCompletedFirstLaunch

        do {
            if let saved = try await saveService.load(PlayerProfile.self, for: .playerProfile) {
                profile = saved
            } else {
                profile = .new
                try await saveService.save(profile, for: .playerProfile)
            }
        } catch {
            // Corrupt or unreadable save: start clean rather than crash.
            profile = .new
        }

        await analytics.track(.appLaunched)
        await storeManager.refresh()
        isReady = true
    }

    // MARK: - Mutations

    /// Update settings, persist them, and propagate to live services.
    func updateSettings(_ newValue: GameSettings) {
        settings = newValue
        preferences.save(newValue)
        applySettingsToServices()
    }

    /// Replace the profile and persist it durably.
    func updateProfile(_ newValue: PlayerProfile) async {
        profile = newValue
        try? await saveService.save(newValue, for: .playerProfile)
    }

    /// Mark the first-run flow complete.
    func completeOnboarding() {
        preferences.hasCompletedFirstLaunch = true
        hasCompletedOnboarding = true
        haptics.play(.selection)
    }

    /// Record a solved puzzle: award fragments/stars, advance the daily streak,
    /// persist, and return a summary for the level-complete screen. This is the
    /// single place the reward loop closes — see `Progression`.
    @discardableResult
    func recordCompletion(
        moveCount: Int,
        parFolds: Int?,
        difficulty: Difficulty,
        isDaily: Bool,
        puzzleID: String? = nil,
        rewardsRepeatable: Bool = true,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async -> CompletionSummary {
        let todayKey = isDaily ? DayKey.string(for: now, calendar: calendar) : nil
        let isConsecutive = DayKey.isConsecutive(previous: profile.lastDailyCompletedDay, today: now, calendar: calendar)
        let outcome = Progression.record(
            moveCount: moveCount,
            parFolds: parFolds,
            difficulty: difficulty,
            isDaily: isDaily,
            todayKey: todayKey,
            isConsecutiveDay: isConsecutive,
            puzzleID: puzzleID,
            rewardsRepeatable: rewardsRepeatable,
            into: profile
        )
        profile = outcome.profile
        try? await saveService.save(profile, for: .playerProfile)
        return outcome.summary
    }

    /// Spend Light Fragments to unlock a biome (World Restoration). Returns
    /// `true` on success; `false` if the biome is already unlocked or the player
    /// cannot afford it. Persists on success.
    @discardableResult
    func unlockBiome(_ biome: BiomeID, cost: Int) async -> Bool {
        guard !profile.unlockedBiomes.contains(biome), profile.lightFragments >= cost else { return false }
        var updated = profile
        updated.lightFragments -= cost
        updated.unlockedBiomes.insert(biome)
        updated.currentBiome = biome
        profile = updated
        try? await saveService.save(profile, for: .playerProfile)
        await analytics.track(AnalyticsEvent("biome_unlocked", parameters: ["biome": biome.rawValue, "cost": "\(cost)"]))
        return true
    }

    /// Select an already-restored biome as the active visual/world theme.
    func selectBiome(_ biome: BiomeID) async {
        guard profile.unlockedBiomes.contains(biome), profile.currentBiome != biome else { return }
        var updated = profile
        updated.currentBiome = biome
        profile = updated
        try? await saveService.save(updated, for: .playerProfile)
        await analytics.track(AnalyticsEvent("biome_selected", parameters: ["biome": biome.rawValue]))
    }

    /// Apply local entitlements after StoreKit verifies a purchase.
    func fulfill(_ productID: StoreProductID) async {
        var updated = profile
        updated.hintCredits += productID.grantedHintCredits
        if !productID.isConsumable {
            updated.ownedProductIDs.insert(productID.rawValue)
        }
        profile = updated
        try? await saveService.save(updated, for: .playerProfile)
        await analytics.track(AnalyticsEvent("purchase_fulfilled", parameters: ["product": productID.rawValue]))
    }

    /// Spend one hint credit. Returns false when the player is out of hints.
    @discardableResult
    func consumeHintCredit() async -> Bool {
        guard profile.hintCredits > 0 else { return false }
        var updated = profile
        updated.hintCredits -= 1
        profile = updated
        try? await saveService.save(updated, for: .playerProfile)
        return true
    }

    /// Restore a clean local profile while keeping user preferences.
    func resetProgress() async {
        profile = .new
        try? await saveService.save(profile, for: .playerProfile)
        haptics.play(.selection)
        await analytics.track(AnalyticsEvent("progress_reset"))
    }

    private func applySettingsToServices() {
        haptics.isEnabled = settings.hapticsEnabled
        audio.soundEffectsEnabled = settings.soundEffectsEnabled
        audio.musicEnabled = settings.musicEnabled
    }
}
