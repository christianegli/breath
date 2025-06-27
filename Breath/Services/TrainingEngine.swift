import Foundation
import SwiftUI
import Combine

/**
 * TrainingEngine: Core training session management and execution service
 * 
 * PURPOSE: Manages all aspects of breath training sessions including timing,
 * safety validation, progress tracking, and user guidance. This is the central
 * orchestrator for all training activities.
 * 
 * SAFETY CRITICAL: Enforces hard-coded safety limits and validates user
 * eligibility before allowing training sessions. All training must go through
 * this service to ensure safety compliance.
 * 
 * ARCHITECTURE: Observable class that coordinates between SafetyValidator,
 * ProgressCalculator, and AudioController to provide safe training experiences.
 */
@MainActor
class TrainingEngine: ObservableObject {
    
    // MARK: - Dependencies
    
    private let safetyValidator: SafetyValidator
    private let progressCalculator: ProgressCalculator
    private let audioController: AudioController
    
    // MARK: - Published State
    
    /**
     * Current training session state
     * 
     * RATIONALE: Published state allows UI to reactively update based on
     * training progress and safety validations.
     */
    @Published var currentSession: TrainingSession?
    @Published var sessionState: TrainingSessionState = .idle
    @Published var currentPhase: TrainingPhase = .preparation
    @Published var timeRemaining: TimeInterval = 0
    @Published var safetyStatus: TrainingSafetyStatus = .safe
    
    /**
     * Training program state
     */
    @Published var availablePrograms: [TrainingProgram] = []
    @Published var currentProgram: TrainingProgram?
    @Published var programProgress: TrainingProgramProgress?
    
    /**
     * Safety and validation state
     */
    @Published var canStartTraining: Bool = false
    @Published var safetyMessage: String = ""
    @Published var lastSafetyCheck: Date = Date()
    
    // MARK: - Private State
    
    private var sessionTimer: Timer?
    private var phaseStartTime: Date?
    private var totalSessionTime: TimeInterval = 0
    private var breathHoldCount: Int = 0
    private var currentBreathHoldTime: TimeInterval = 0
    
    // MARK: - Safety Limits (Hard-coded for safety)
    
    /**
     * Maximum breath hold times by experience level
     * 
     * SAFETY CRITICAL: These limits cannot be exceeded regardless of user
     * settings or requests. They are based on safety research and prevent
     * dangerous training practices.
     */
    private enum SafetyLimits {
        static let beginnerMaxHold: TimeInterval = 30.0      // 30 seconds
        static let intermediateMaxHold: TimeInterval = 60.0   // 1 minute
        static let advancedMaxHold: TimeInterval = 120.0     // 2 minutes
        
        static let minimumRestRatio: Double = 2.0            // Rest = 2x hold time
        static let maxSessionDuration: TimeInterval = 1800.0 // 30 minutes
        static let maxBreathHoldsPerSession: Int = 10        // Maximum holds per session
        static let mandatoryRestBetweenSessions: TimeInterval = 3600.0 // 1 hour
    }
    
    // MARK: - Initialization
    
    /**
     * Initialize TrainingEngine with required dependencies
     * 
     * RATIONALE: Dependency injection allows for proper testing and ensures
     * all safety validations are performed through the SafetyValidator.
     */
    init(
        safetyValidator: SafetyValidator,
        progressCalculator: ProgressCalculator,
        audioController: AudioController
    ) {
        self.safetyValidator = safetyValidator
        self.progressCalculator = progressCalculator
        self.audioController = audioController
        
        // Initialize available training programs
        self.availablePrograms = TrainingProgram.defaultPrograms
        
        // Perform initial safety validation
        validateTrainingEligibility()
    }
    
    // MARK: - Public Training Methods
    
    /**
     * Start a new training session
     * 
     * SAFETY VALIDATION: Performs comprehensive safety checks before allowing
     * any training session to begin. This is the primary safety gate.
     */
    func startTrainingSession(program: TrainingProgram) async throws {
        
        // Critical safety validation
        let safetyValidation = safetyValidator.validateUserCanTrain()
        guard safetyValidation == .approved else {
            throw TrainingError.safetyValidationFailed(safetyValidation.denialReason ?? "Safety validation failed")
        }
        
        // Check for recent sessions (mandatory rest period)
        if let lastSession = progressCalculator.getLastSession(),
           Date().timeIntervalSince(lastSession.endTime) < SafetyLimits.mandatoryRestBetweenSessions {
            throw TrainingError.insufficientRest("You must wait at least 1 hour between training sessions")
        }
        
        // Validate program safety for user level
        guard validateProgramSafety(program: program) else {
            throw TrainingError.programTooAdvanced("This program exceeds your current safety level")
        }
        
        // Create new session
        let session = TrainingSession(
            id: UUID(),
            program: program,
            startTime: Date(),
            userExperienceLevel: safetyValidator.getUserExperienceLevel()
        )
        
        // Initialize session state
        self.currentSession = session
        self.currentProgram = program
        self.sessionState = .active
        self.currentPhase = .preparation
        self.breathHoldCount = 0
        self.totalSessionTime = 0
        self.phaseStartTime = Date()
        
        // Start with preparation phase
        try await startPreparationPhase()
        
        // Record session start
        progressCalculator.recordSessionStart(session)
        
        // Update safety status
        updateSafetyStatus()
    }
    
    /**
     * Stop current training session
     * 
     * SAFETY: Always allows immediate session termination for safety.
     */
    func stopTrainingSession() async {
        
        guard let session = currentSession else { return }
        
        // Stop any running timers
        sessionTimer?.invalidate()
        sessionTimer = nil
        
        // Stop audio cues
        await audioController.stopAllAudio()
        
        // Complete the session record
        let completedSession = TrainingSessionResult(
            session: session,
            endTime: Date(),
            totalDuration: totalSessionTime,
            breathHoldsCompleted: breathHoldCount,
            averageHoldTime: calculateAverageHoldTime(),
            safetyCompliance: calculateSafetyCompliance(),
            completionReason: .userStopped
        )
        
        // Record session completion
        progressCalculator.recordSessionCompletion(completedSession)
        
        // Reset state
        resetSessionState()
        
        // Update safety status
        updateSafetyStatus()
    }
    
    /**
     * Emergency stop - immediate termination for safety
     * 
     * SAFETY CRITICAL: This method provides immediate session termination
     * in case of emergency or safety concerns.
     */
    func emergencyStop() async {
        
        // Immediate stop of all activities
        sessionTimer?.invalidate()
        sessionTimer = nil
        
        await audioController.emergencyStop()
        
        // Record emergency stop if session was active
        if let session = currentSession {
            let emergencyResult = TrainingSessionResult(
                session: session,
                endTime: Date(),
                totalDuration: totalSessionTime,
                breathHoldsCompleted: breathHoldCount,
                averageHoldTime: calculateAverageHoldTime(),
                safetyCompliance: .emergencyStop,
                completionReason: .emergencyStop
            )
            
            progressCalculator.recordSessionCompletion(emergencyResult)
        }
        
        // Reset all state
        resetSessionState()
        
        // Update safety status
        safetyStatus = .emergencyStop
        safetyMessage = "Emergency stop activated. Please ensure you are safe before continuing."
    }
    
    // MARK: - Training Phase Management
    
    /**
     * Start preparation phase
     * 
     * PURPOSE: Preparation phase allows users to relax and prepare for
     * breath holds using safe breathing techniques.
     */
    private func startPreparationPhase() async throws {
        
        guard let program = currentProgram else {
            throw TrainingError.invalidState("No program selected")
        }
        
        currentPhase = .preparation
        timeRemaining = program.preparationDuration
        phaseStartTime = Date()
        
        // Start preparation breathing guidance
        await audioController.startPreparationGuidance(duration: program.preparationDuration)
        
        // Start phase timer
        startPhaseTimer()
    }
    
    /**
     * Start breath hold phase
     * 
     * SAFETY: Validates hold duration against safety limits before starting.
     */
    private func startBreathHoldPhase() async throws {
        
        guard let program = currentProgram,
              let session = currentSession else {
            throw TrainingError.invalidState("Invalid session state")
        }
        
        // Calculate target hold time for this round
        let targetHoldTime = calculateTargetHoldTime(program: program, round: breathHoldCount)
        
        // SAFETY: Enforce maximum hold time based on user experience
        let maxAllowedHold = getMaxAllowedHoldTime(for: session.userExperienceLevel)
        let safeHoldTime = min(targetHoldTime, maxAllowedHold)
        
        if safeHoldTime < targetHoldTime {
            safetyMessage = "Hold time limited to \(Int(safeHoldTime))s for your safety level"
        }
        
        currentPhase = .breathHold
        timeRemaining = safeHoldTime
        currentBreathHoldTime = safeHoldTime
        phaseStartTime = Date()
        
        // Start breath hold guidance
        await audioController.startBreathHoldGuidance(duration: safeHoldTime)
        
        // Start phase timer
        startPhaseTimer()
        
        // Increment breath hold count
        breathHoldCount += 1
    }
    
    /**
     * Start recovery phase
     * 
     * SAFETY: Enforces minimum rest period based on hold duration.
     */
    private func startRecoveryPhase() async throws {
        
        // Calculate required rest time (minimum 2x hold time)
        let requiredRestTime = currentBreathHoldTime * SafetyLimits.minimumRestRatio
        
        currentPhase = .recovery
        timeRemaining = requiredRestTime
        phaseStartTime = Date()
        
        // Start recovery breathing guidance
        await audioController.startRecoveryGuidance(duration: requiredRestTime)
        
        // Start phase timer
        startPhaseTimer()
    }
    
    // MARK: - Timer Management
    
    /**
     * Start phase timer for current training phase
     */
    private func startPhaseTimer() {
        
        sessionTimer?.invalidate()
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updatePhaseTimer()
            }
        }
    }
    
    /**
     * Update phase timer and handle phase transitions
     */
    private func updatePhaseTimer() async {
        
        guard let phaseStartTime = phaseStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(phaseStartTime)
        let remaining = max(0, timeRemaining - elapsed)
        
        self.timeRemaining = remaining
        self.totalSessionTime += 0.1
        
        // Check for phase completion
        if remaining <= 0 {
            await handlePhaseCompletion()
        }
        
        // Continuous safety monitoring
        updateSafetyStatus()
        
        // Check for session limits
        checkSessionLimits()
    }
    
    /**
     * Handle completion of current phase
     */
    private func handlePhaseCompletion() async {
        
        sessionTimer?.invalidate()
        sessionTimer = nil
        
        do {
            switch currentPhase {
            case .preparation:
                try await startBreathHoldPhase()
                
            case .breathHold:
                try await startRecoveryPhase()
                
            case .recovery:
                // Check if session should continue
                if shouldContinueSession() {
                    try await startBreathHoldPhase()
                } else {
                    await completeSession()
                }
            }
        } catch {
            await emergencyStop()
            safetyMessage = "Session stopped due to error: \(error.localizedDescription)"
        }
    }
    
    /**
     * Complete current training session
     */
    private func completeSession() async {
        
        guard let session = currentSession else { return }
        
        // Stop all audio
        await audioController.stopAllAudio()
        
        // Create completion result
        let completedSession = TrainingSessionResult(
            session: session,
            endTime: Date(),
            totalDuration: totalSessionTime,
            breathHoldsCompleted: breathHoldCount,
            averageHoldTime: calculateAverageHoldTime(),
            safetyCompliance: .fullCompliance,
            completionReason: .completed
        )
        
        // Record completion
        progressCalculator.recordSessionCompletion(completedSession)
        
        // Reset state
        resetSessionState()
        
        // Update safety status
        updateSafetyStatus()
    }
    
    // MARK: - Safety Validation Methods
    
    /**
     * Validate training eligibility
     */
    private func validateTrainingEligibility() {
        
        let validation = safetyValidator.validateUserCanTrain()
        canStartTraining = (validation == .approved)
        
        switch validation {
        case .approved:
            safetyMessage = "Ready for training"
            safetyStatus = .safe
            
        case .denied(let reason):
            safetyMessage = reason
            safetyStatus = .blocked
            
        case .requiresEducation:
            safetyMessage = "Complete safety education to access training"
            safetyStatus = .blocked
            
        case .requiresRest:
            safetyMessage = "Mandatory rest period required"
            safetyStatus = .blocked
        }
        
        lastSafetyCheck = Date()
    }
    
    /**
     * Validate program safety for user
     */
    private func validateProgramSafety(program: TrainingProgram) -> Bool {
        
        let userLevel = safetyValidator.getUserExperienceLevel()
        let maxAllowedHold = getMaxAllowedHoldTime(for: userLevel)
        
        // Check if program's maximum hold time exceeds user's safety limit
        return program.maxHoldTime <= maxAllowedHold
    }
    
    /**
     * Get maximum allowed hold time for experience level
     */
    private func getMaxAllowedHoldTime(for level: UserExperienceLevel) -> TimeInterval {
        switch level {
        case .beginner:
            return SafetyLimits.beginnerMaxHold
        case .intermediate:
            return SafetyLimits.intermediateMaxHold
        case .advanced:
            return SafetyLimits.advancedMaxHold
        }
    }
    
    /**
     * Update safety status during training
     */
    private func updateSafetyStatus() {
        
        // Check if safety validation is still current
        if Date().timeIntervalSince(lastSafetyCheck) > 300 { // 5 minutes
            validateTrainingEligibility()
        }
        
        // Monitor session duration
        if totalSessionTime > SafetyLimits.maxSessionDuration {
            safetyStatus = .warning
            safetyMessage = "Session approaching maximum duration limit"
        }
        
        // Monitor breath hold count
        if breathHoldCount > SafetyLimits.maxBreathHoldsPerSession {
            safetyStatus = .warning
            safetyMessage = "Maximum breath holds per session reached"
        }
    }
    
    /**
     * Check session limits and enforce safety
     */
    private func checkSessionLimits() {
        
        // Enforce maximum session duration
        if totalSessionTime >= SafetyLimits.maxSessionDuration {
            Task {
                await emergencyStop()
                safetyMessage = "Session stopped: Maximum duration reached for safety"
            }
        }
        
        // Enforce maximum breath holds per session
        if breathHoldCount >= SafetyLimits.maxBreathHoldsPerSession {
            Task {
                await completeSession()
                safetyMessage = "Session completed: Maximum breath holds reached"
            }
        }
    }
    
    // MARK: - Calculation Methods
    
    /**
     * Calculate target hold time for current round
     */
    private func calculateTargetHoldTime(program: TrainingProgram, round: Int) -> TimeInterval {
        
        // Use program's progression algorithm
        return program.calculateHoldTime(forRound: round)
    }
    
    /**
     * Calculate average hold time for session
     */
    private func calculateAverageHoldTime() -> TimeInterval {
        
        guard breathHoldCount > 0 else { return 0 }
        
        // This would be calculated from actual recorded hold times
        // For now, return estimated based on current session
        return currentBreathHoldTime
    }
    
    /**
     * Calculate safety compliance score
     */
    private func calculateSafetyCompliance() -> SafetyCompliance {
        
        // Check various safety factors
        let hasExceededLimits = breathHoldCount > SafetyLimits.maxBreathHoldsPerSession ||
                               totalSessionTime > SafetyLimits.maxSessionDuration
        
        if hasExceededLimits {
            return .limitsExceeded
        }
        
        return .fullCompliance
    }
    
    /**
     * Determine if session should continue
     */
    private func shouldContinueSession() -> Bool {
        
        guard let program = currentProgram else { return false }
        
        // Check program completion
        if breathHoldCount >= program.targetBreathHolds {
            return false
        }
        
        // Check safety limits
        if breathHoldCount >= SafetyLimits.maxBreathHoldsPerSession {
            return false
        }
        
        if totalSessionTime >= SafetyLimits.maxSessionDuration {
            return false
        }
        
        return true
    }
    
    /**
     * Reset session state
     */
    private func resetSessionState() {
        
        currentSession = nil
        sessionState = .idle
        currentPhase = .preparation
        timeRemaining = 0
        breathHoldCount = 0
        currentBreathHoldTime = 0
        totalSessionTime = 0
        phaseStartTime = nil
        
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
}

// MARK: - Supporting Types

/**
 * TrainingSessionState: Current state of training session
 */
enum TrainingSessionState {
    case idle
    case active
    case paused
    case completed
}

/**
 * TrainingPhase: Current phase within a training session
 */
enum TrainingPhase {
    case preparation
    case breathHold
    case recovery
}

/**
 * TrainingSafetyStatus: Safety status during training
 */
enum TrainingSafetyStatus {
    case safe
    case warning
    case blocked
    case emergencyStop
}

/**
 * TrainingError: Training-specific errors
 */
enum TrainingError: LocalizedError {
    case safetyValidationFailed(String)
    case insufficientRest(String)
    case programTooAdvanced(String)
    case invalidState(String)
    case sessionLimitReached(String)
    
    var errorDescription: String? {
        switch self {
        case .safetyValidationFailed(let message),
             .insufficientRest(let message),
             .programTooAdvanced(let message),
             .invalidState(let message),
             .sessionLimitReached(let message):
            return message
        }
    }
}

/**
 * SafetyCompliance: Safety compliance level for session
 */
enum SafetyCompliance {
    case fullCompliance
    case minorViolations
    case limitsExceeded
    case emergencyStop
}

/**
 * SessionCompletionReason: Reason for session completion
 */
enum SessionCompletionReason {
    case completed
    case userStopped
    case emergencyStop
    case safetyLimitReached
} 