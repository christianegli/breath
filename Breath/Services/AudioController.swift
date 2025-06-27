import Foundation
import AVFoundation
import SwiftUI

/**
 * AudioController: Manages audio guidance and cues for breath training
 * 
 * PURPOSE: Provides audio guidance for breathing techniques, session timing,
 * and safety alerts. Uses system sounds and speech synthesis to guide users
 * through training sessions safely.
 * 
 * SAFETY FEATURES: Includes emergency stop functionality and clear audio
 * cues for safety events. All audio is designed to enhance safety rather
 * than distract from it.
 */
@MainActor
class AudioController: ObservableObject {
    
    // MARK: - Published State
    
    @Published var isPlayingGuidance: Bool = false
    @Published var currentGuidanceType: GuidanceType = .none
    @Published var audioEnabled: Bool = true
    @Published var guidanceVolume: Float = 0.7
    @Published var useVoiceGuidance: Bool = true
    @Published var useSoundEffects: Bool = true
    
    // MARK: - Private Properties
    
    private var audioEngine: AVAudioEngine?
    private var speechSynthesizer: AVSpeechSynthesizer?
    private var guidanceTimer: Timer?
    private var currentPhaseTimer: Timer?
    private var audioSession: AVAudioSession
    
    // Audio players for different sound types
    private var breathInPlayer: AVAudioPlayer?
    private var breathOutPlayer: AVAudioPlayer?
    private var holdStartPlayer: AVAudioPlayer?
    private var holdEndPlayer: AVAudioPlayer?
    private var warningPlayer: AVAudioPlayer?
    private var emergencyPlayer: AVAudioPlayer?
    
    // MARK: - Initialization
    
    init() {
        self.audioSession = AVAudioSession.sharedInstance()
        
        setupAudioSession()
        setupAudioPlayers()
        setupSpeechSynthesizer()
    }
    
    // MARK: - Audio Session Setup
    
    /**
     * Configure audio session for breath training
     * 
     * RATIONALE: Configures audio session to work well with other apps
     * and ensure audio continues during device lock for safety.
     */
    private func setupAudioSession() {
        
        do {
            // Set category to allow audio during lock screen (safety critical)
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    /**
     * Setup audio players for different sound effects
     */
    private func setupAudioPlayers() {
        
        // Create simple system sounds for breathing cues
        // In a full implementation, these would load from app bundle
        
        // For now, we'll use system sounds via AudioServicesPlaySystemSound
        // This is safer than trying to load audio files that don't exist
    }
    
    /**
     * Setup speech synthesizer for voice guidance
     */
    private func setupSpeechSynthesizer() {
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer?.delegate = self
    }
    
    // MARK: - Training Phase Audio Guidance
    
    /**
     * Start preparation phase audio guidance
     * 
     * PURPOSE: Guides user through relaxation breathing before breath holds
     */
    func startPreparationGuidance(duration: TimeInterval) async {
        
        guard audioEnabled else { return }
        
        currentGuidanceType = .preparation
        isPlayingGuidance = true
        
        // Start with welcome message
        if useVoiceGuidance {
            await speakText("Beginning preparation phase. Focus on relaxing and breathing naturally.")
        }
        
        // Start breathing guidance rhythm
        startBreathingRhythm(type: .preparation, duration: duration)
    }
    
    /**
     * Start breath hold phase audio guidance
     * 
     * SAFETY: Provides clear start/end cues and safety reminders
     */
    func startBreathHoldGuidance(duration: TimeInterval) async {
        
        guard audioEnabled else { return }
        
        currentGuidanceType = .breathHold
        isPlayingGuidance = true
        
        // Clear start cue
        if useSoundEffects {
            playSystemSound(.breathHoldStart)
        }
        
        if useVoiceGuidance {
            await speakText("Take a deep breath and hold. Stay calm and relaxed.")
        }
        
        // Schedule end warning and completion cues
        scheduleBreathHoldCues(duration: duration)
    }
    
    /**
     * Start recovery phase audio guidance
     * 
     * PURPOSE: Guides user through recovery breathing after breath hold
     */
    func startRecoveryGuidance(duration: TimeInterval) async {
        
        guard audioEnabled else { return }
        
        currentGuidanceType = .recovery
        isPlayingGuidance = true
        
        // Recovery start cue
        if useSoundEffects {
            playSystemSound(.breathHoldEnd)
        }
        
        if useVoiceGuidance {
            await speakText("Good job. Now breathe normally and recover.")
        }
        
        // Start recovery breathing rhythm
        startBreathingRhythm(type: .recovery, duration: duration)
    }
    
    // MARK: - Breathing Rhythm Guidance
    
    /**
     * Start breathing rhythm guidance
     * 
     * PURPOSE: Provides audio cues for breathing patterns during different phases
     */
    private func startBreathingRhythm(type: GuidanceType, duration: TimeInterval) {
        
        let breathingPattern = getBreathingPattern(for: type)
        let cycleDuration = breathingPattern.totalDuration
        let cycleCount = Int(duration / cycleDuration)
        
        var currentCycle = 0
        
        guidanceTimer = Timer.scheduledTimer(withTimeInterval: cycleDuration, repeats: true) { [weak self] _ in
            
            guard let self = self else { return }
            
            currentCycle += 1
            
            if currentCycle >= cycleCount {
                self.guidanceTimer?.invalidate()
                self.guidanceTimer = nil
                return
            }
            
            // Start next breathing cycle
            Task { @MainActor in
                await self.playBreathingCycle(pattern: breathingPattern)
            }
        }
        
        // Start first cycle immediately
        Task { @MainActor in
            await playBreathingCycle(pattern: breathingPattern)
        }
    }
    
    /**
     * Play a single breathing cycle
     */
    private func playBreathingCycle(pattern: BreathingRhythm) async {
        
        // Inhale phase
        if useVoiceGuidance {
            await speakText("Breathe in")
        }
        if useSoundEffects {
            playSystemSound(.breathIn)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(pattern.inhaleDuration * 1_000_000_000))
        
        // Hold phase (if applicable)
        if pattern.holdDuration > 0 {
            if useVoiceGuidance {
                await speakText("Hold")
            }
            
            try? await Task.sleep(nanoseconds: UInt64(pattern.holdDuration * 1_000_000_000))
        }
        
        // Exhale phase
        if useVoiceGuidance {
            await speakText("Breathe out")
        }
        if useSoundEffects {
            playSystemSound(.breathOut)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(pattern.exhaleDuration * 1_000_000_000))
        
        // Pause phase (if applicable)
        if pattern.pauseDuration > 0 {
            try? await Task.sleep(nanoseconds: UInt64(pattern.pauseDuration * 1_000_000_000))
        }
    }
    
    /**
     * Schedule breath hold audio cues
     * 
     * SAFETY: Provides warnings before hold completion to prevent overexertion
     */
    private func scheduleBreathHoldCues(duration: TimeInterval) {
        
        // Schedule warning at 80% of duration
        let warningTime = duration * 0.8
        
        DispatchQueue.main.asyncAfter(deadline: .now() + warningTime) { [weak self] in
            
            guard let self = self, self.currentGuidanceType == .breathHold else { return }
            
            if self.useSoundEffects {
                self.playSystemSound(.warning)
            }
            
            if self.useVoiceGuidance {
                Task { @MainActor in
                    await self.speakText("Almost done")
                }
            }
        }
        
        // Schedule completion cue
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            
            guard let self = self, self.currentGuidanceType == .breathHold else { return }
            
            if self.useSoundEffects {
                self.playSystemSound(.breathHoldEnd)
            }
            
            if self.useVoiceGuidance {
                Task { @MainActor in
                    await self.speakText("Release and breathe")
                }
            }
        }
    }
    
    // MARK: - Audio Control Methods
    
    /**
     * Stop all audio guidance
     */
    func stopAllAudio() async {
        
        isPlayingGuidance = false
        currentGuidanceType = .none
        
        // Stop timers
        guidanceTimer?.invalidate()
        guidanceTimer = nil
        
        currentPhaseTimer?.invalidate()
        currentPhaseTimer = nil
        
        // Stop speech synthesis
        speechSynthesizer?.stopSpeaking(at: .immediate)
        
        // Stop any playing audio
        breathInPlayer?.stop()
        breathOutPlayer?.stop()
        holdStartPlayer?.stop()
        holdEndPlayer?.stop()
    }
    
    /**
     * Emergency stop all audio immediately
     * 
     * SAFETY CRITICAL: Immediate audio stop for emergency situations
     */
    func emergencyStop() async {
        
        await stopAllAudio()
        
        // Play emergency stop sound if enabled
        if useSoundEffects {
            playSystemSound(.emergency)
        }
        
        if useVoiceGuidance {
            await speakText("Session stopped. Breathe normally.")
        }
    }
    
    /**
     * Play safety warning audio
     */
    func playSafetyWarning(_ message: String) async {
        
        if useSoundEffects {
            playSystemSound(.warning)
        }
        
        if useVoiceGuidance {
            await speakText("Safety alert: \(message)")
        }
    }
    
    // MARK: - Speech Synthesis
    
    /**
     * Speak text using speech synthesizer
     */
    private func speakText(_ text: String) async {
        
        guard useVoiceGuidance, let synthesizer = speechSynthesizer else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5 // Slower rate for clarity
        utterance.volume = guidanceVolume
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
        
        // Wait for speech to complete
        while synthesizer.isSpeaking {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
    
    // MARK: - System Sound Effects
    
    /**
     * Play system sound for audio cue
     * 
     * RATIONALE: Uses system sounds to avoid loading audio files and
     * ensure compatibility across all devices.
     */
    private func playSystemSound(_ soundType: SystemSoundType) {
        
        guard useSoundEffects else { return }
        
        let soundID: SystemSoundID
        
        switch soundType {
        case .breathIn:
            soundID = 1104 // SMS received tone (gentle)
        case .breathOut:
            soundID = 1105 // SMS sent tone (gentle)
        case .breathHoldStart:
            soundID = 1016 // Camera shutter (clear start)
        case .breathHoldEnd:
            soundID = 1111 // Unlock sound (completion)
        case .warning:
            soundID = 1006 // Tock sound (attention)
        case .emergency:
            soundID = 1005 // New voicemail (urgent)
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - Breathing Pattern Definitions
    
    /**
     * Get breathing pattern for guidance type
     */
    private func getBreathingPattern(for type: GuidanceType) -> BreathingRhythm {
        
        switch type {
        case .preparation:
            // Box breathing pattern for preparation
            return BreathingRhythm(
                inhaleDuration: 4.0,
                holdDuration: 4.0,
                exhaleDuration: 4.0,
                pauseDuration: 4.0
            )
            
        case .recovery:
            // Natural breathing pattern for recovery
            return BreathingRhythm(
                inhaleDuration: 3.0,
                holdDuration: 0.0,
                exhaleDuration: 5.0,
                pauseDuration: 1.0
            )
            
        case .breathHold, .none:
            // No pattern for breath hold or none
            return BreathingRhythm(
                inhaleDuration: 0.0,
                holdDuration: 0.0,
                exhaleDuration: 0.0,
                pauseDuration: 0.0
            )
        }
    }
    
    // MARK: - Settings Management
    
    /**
     * Update audio settings
     */
    func updateAudioSettings(
        enabled: Bool,
        volume: Float,
        voiceGuidance: Bool,
        soundEffects: Bool
    ) {
        audioEnabled = enabled
        guidanceVolume = volume
        useVoiceGuidance = voiceGuidance
        useSoundEffects = soundEffects
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Speech completion handling if needed
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // Speech cancellation handling if needed
    }
}

// MARK: - Supporting Types

/**
 * GuidanceType: Types of audio guidance
 */
enum GuidanceType {
    case none
    case preparation
    case breathHold
    case recovery
}

/**
 * SystemSoundType: Types of system sounds used
 */
enum SystemSoundType {
    case breathIn
    case breathOut
    case breathHoldStart
    case breathHoldEnd
    case warning
    case emergency
}

/**
 * BreathingRhythm: Defines timing for breathing patterns
 */
struct BreathingRhythm {
    let inhaleDuration: TimeInterval
    let holdDuration: TimeInterval
    let exhaleDuration: TimeInterval
    let pauseDuration: TimeInterval
    
    var totalDuration: TimeInterval {
        return inhaleDuration + holdDuration + exhaleDuration + pauseDuration
    }
} 