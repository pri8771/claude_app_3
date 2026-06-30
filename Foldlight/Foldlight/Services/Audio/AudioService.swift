//
//  AudioService.swift
//  Foldlight
//
//  STUB SERVICE — intentionally a safe placeholder for the Phase 1 foundation.
//
//  The Technical PRD calls for ASMR-quality fold sounds and background music
//  (§ Design Philosophy, E010 asset production). No audio assets exist yet, so
//  this service configures the audio session correctly and exposes the API the
//  game will call, but routing real samples is deferred to a later phase.
//
//  The stub is clearly isolated behind the `AudioPlaying` protocol and never
//  performs unsafe work: calls are no-ops (optionally logged) when disabled or
//  when no asset is wired up.
//

import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

/// Semantic sound effects the game can request.
enum SoundEffect: String, Sendable {
    case fold
    case invalidFold
    case combine
    case win
    case tap
}

/// Plays sound effects and background music, gated by user preference.
@MainActor
protocol AudioPlaying: AnyObject {
    var soundEffectsEnabled: Bool { get set }
    var musicEnabled: Bool { get set }
    func prepare()
    func play(_ effect: SoundEffect)
    func startMusic()
    func stopMusic()
}

/// Default audio service. Configures `AVAudioSession`, preloads the bundled
/// sound effects into small player pools (so rapid folds overlap cleanly), and
/// loops the ambient music track. All calls are safe no-ops when disabled or
/// when an asset is missing — playback never crashes the game.
@MainActor
final class AudioService: AudioPlaying {
    var soundEffectsEnabled: Bool
    var musicEnabled: Bool {
        didSet {
            guard musicEnabled != oldValue else { return }
            if musicEnabled { startMusic() } else { stopMusic() }
        }
    }

    private var isPrepared = false

    #if canImport(AVFoundation)
    /// A tiny round-robin pool per effect so overlapping plays don't cut off.
    private var pools: [SoundEffect: [AVAudioPlayer]] = [:]
    private var poolCursor: [SoundEffect: Int] = [:]
    private var musicPlayer: AVAudioPlayer?
    #endif

    init(soundEffectsEnabled: Bool = true, musicEnabled: Bool = true) {
        self.soundEffectsEnabled = soundEffectsEnabled
        self.musicEnabled = musicEnabled
    }

    /// Configure the audio session, preload assets, and start music if enabled.
    /// Uses `.ambient` so the game mixes with other audio and respects the silent
    /// switch (Bug Tracker RISK-010 mitigation).
    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true
        #if canImport(AVFoundation) && !os(macOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif
        #if canImport(AVFoundation)
        preloadEffects()
        loadMusic()
        if musicEnabled { startMusic() }
        #endif
    }

    func play(_ effect: SoundEffect) {
        guard soundEffectsEnabled else { return }
        #if canImport(AVFoundation)
        guard let pool = pools[effect], !pool.isEmpty else { return }
        let index = (poolCursor[effect] ?? 0) % pool.count
        poolCursor[effect] = index + 1
        let player = pool[index]
        player.currentTime = 0
        player.play()
        #endif
    }

    func startMusic() {
        guard musicEnabled, isPrepared else { return }
        #if canImport(AVFoundation)
        guard let music = musicPlayer else { return }
        if !music.isPlaying { music.play() }
        #endif
    }

    func stopMusic() {
        #if canImport(AVFoundation)
        musicPlayer?.pause()
        #endif
    }

    // MARK: - Loading

    #if canImport(AVFoundation)
    private func preloadEffects() {
        let poolSizes: [SoundEffect: Int] = [.fold: 3, .invalidFold: 2, .combine: 2, .win: 1, .tap: 2]
        for effect in [SoundEffect.fold, .invalidFold, .combine, .win, .tap] {
            guard let url = assetURL(named: effect.rawValue) else { continue }
            let count = poolSizes[effect] ?? 1
            var players: [AVAudioPlayer] = []
            for _ in 0..<count {
                if let player = try? AVAudioPlayer(contentsOf: url) {
                    player.volume = effect == .win ? 0.8 : 0.55
                    player.prepareToPlay()
                    players.append(player)
                }
            }
            if !players.isEmpty { pools[effect] = players }
        }
    }

    private func loadMusic() {
        guard let url = assetURL(named: "ambient") else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.numberOfLoops = -1
        player.volume = 0.30
        player.prepareToPlay()
        musicPlayer = player
    }

    /// Look up a bundled `.wav`, tolerating either a flattened layout or an
    /// `Audio/` subdirectory.
    private func assetURL(named name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "wav")
            ?? Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Audio")
    }
    #endif
}
