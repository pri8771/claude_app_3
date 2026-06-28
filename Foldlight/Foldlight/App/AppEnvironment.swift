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

    // MARK: Level generation
    let generator: PuzzleGenerator
    let dailyService: DailyPuzzleService
    let levelRepository: LevelRepository

    // MARK: Published state
    @Published private(set) var profile: PlayerProfile
    @Published private(set) var settings: GameSettings
    @Published private(set) var isReady = false
    /// The puzzle source the Play screen should load next.
    @Published var pendingGameRequest: GameRequest = .infinite(.easy)

    init(
        preferences: PreferencesStore,
        saveService: SaveService,
        haptics: Haptics,
        audio: AudioPlaying,
        analytics: AnalyticsTracking,
        generator: PuzzleGenerator,
        dailyService: DailyPuzzleService,
        levelRepository: LevelRepository
    ) {
        self.preferences = preferences
        self.saveService = saveService
        self.haptics = haptics
        self.audio = audio
        self.analytics = analytics
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
        applySettingsToServices()

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

    private func applySettingsToServices() {
        haptics.isEnabled = settings.hapticsEnabled
        audio.soundEffectsEnabled = settings.soundEffectsEnabled
        audio.musicEnabled = settings.musicEnabled
    }
}
