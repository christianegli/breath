import Foundation
import SwiftUI

/**
 * SafetyValidator: Core safety validation and enforcement service
 * 
 * PURPOSE: Centralized safety validation that ensures users cannot access
 * breath training features without proper safety education and validation.
 * This service acts as the primary safety gatekeeper for the entire app.
 * 
 * DESIGN PRINCIPLE: Fail-safe design where any uncertainty results in
 * denying access to training features. Safety validation is mandatory
 * and cannot be bypassed.
 * 
 * ARCHITECTURE DECISION: ObservableObject pattern chosen to provide
 * reactive safety validation across the entire app with automatic UI updates.
 */
class SafetyValidator: ObservableObject {
    
    // MARK: - Published Properties
    
    /**
     * Current safety validation status
     * 
     * RATIONALE: Published property ensures UI automatically updates when
     * safety status changes, preventing stale safety states.
     */
    @Published var currentValidationStatus: SafetyValidationResult = .safetyEducationRequired
    
    /**
     * Safety education completion tracking
     * 
     * CRITICAL: This property gates access to all training features.
     * Must be validated through proper safety education completion.
     */
    @Published var safetyEducationCompleted: Bool = false
    
    /**
     * Medical disclaimer acceptance status
     * 
     * LEGAL REQUIREMENT: Users must explicitly acknowledge medical
     * disclaimers before accessing any training features.
     */
    @Published var medicalDisclaimerAccepted: Bool = false
    
    /**
     * Age verification status
     * 
     * SAFETY REQUIREMENT: Age verification ensures appropriate safety
     * measures and parental controls for younger users.
     */
    @Published var ageVerified: Bool = false
    
    // MARK: - Private Properties
    
    /**
     * Minimum age for independent app usage
     * 
     * RATIONALE: Based on safety research, users under 13 require
     * additional supervision and modified training protocols.
     */
    private let minimumAge: Int = 13
    
    /**
     * Safety education completion timestamp
     * 
     * PURPOSE: Tracks when safety education was completed to enforce
     * periodic re-validation of safety knowledge.
     */
    private var safetyEducationCompletionDate: Date?
    
    /**
     * Safety education validity period (days)
     * 
     * RATIONALE: Safety knowledge should be refreshed periodically
     * to ensure users maintain awareness of safety requirements.
     */
    private let safetyEducationValidityDays: Int = 90
    
    // MARK: - Initialization
    
    init() {
        loadSafetyStatus()
        validateCurrentStatus()
    }
    
    // MARK: - Public Validation Methods
    
    /**
     * Validate if user can access training features
     * 
     * SAFETY DESIGN: Comprehensive validation that checks all safety
     * requirements before allowing access to training features.
     * 
     * FAIL-SAFE PRINCIPLE: Any failed validation results in denying
     * access and routing user to appropriate safety education.
     * 
     * @return SafetyValidationResult indicating current validation status
     */
    func validateUserCanTrain() -> SafetyValidationResult {
        
        // Check age verification
        guard ageVerified else {
            currentValidationStatus = .ageRestriction
            return .ageRestriction
        }
        
        // Check medical disclaimer acceptance
        guard medicalDisclaimerAccepted else {
            currentValidationStatus = .medicalRestriction
            return .medicalRestriction
        }
        
        // Check safety education completion
        guard safetyEducationCompleted else {
            currentValidationStatus = .safetyEducationRequired
            return .safetyEducationRequired
        }
        
        // Check safety education validity (not expired)
        guard isSafetyEducationValid() else {
            currentValidationStatus = .safetyEducationRequired
            return .safetyEducationRequired
        }
        
        // All validations passed
        currentValidationStatus = .approved
        return .approved
    }
    
    /**
     * Validate session parameters for safety compliance
     * 
     * PURPOSE: Ensures training session parameters are within safe limits
     * and appropriate for the user's experience level.
     * 
     * @param params: Session parameters to validate
     * @return Bool indicating if parameters are safe
     */
    func validateSessionParameters(_ params: SessionParameters) -> Bool {
        
        // Validate maximum hold time limits
        guard params.maxHoldTime <= SafetyLimits.maxHoldTimeForLevel(params.userLevel) else {
            return false
        }
        
        // Validate minimum rest periods
        guard params.restPeriod >= SafetyLimits.minRestPeriodForHoldTime(params.maxHoldTime) else {
            return false
        }
        
        // Validate session duration limits
        guard params.totalSessionTime <= SafetyLimits.maxSessionDuration else {
            return false
        }
        
        // Validate daily training limits
        guard !hasExceededDailyTrainingLimit() else {
            return false
        }
        
        return true
    }
    
    /**
     * Validate app launch safety requirements
     * 
     * PURPOSE: Performs comprehensive safety validation on app launch
     * to ensure proper safety state initialization.
     */
    func validateAppLaunch() {
        loadSafetyStatus()
        validateCurrentStatus()
    }
    
    /**
     * Record safety education completion
     * 
     * CRITICAL: This method officially records safety education completion
     * and enables access to training features. Includes validation to ensure
     * education was genuinely completed.
     * 
     * @param educationScore: Score from safety education quiz
     * @param completionTime: Time taken to complete education
     */
    func recordSafetyEducationCompletion(educationScore: Double, completionTime: TimeInterval) {
        
        // Validate education completion requirements
        guard educationScore >= SafetyLimits.minSafetyEducationScore else {
            // Score too low, education not completed
            return
        }
        
        guard completionTime >= SafetyLimits.minSafetyEducationTime else {
            // Completed too quickly, likely not read properly
            return
        }
        
        // Record completion
        safetyEducationCompleted = true
        safetyEducationCompletionDate = Date()
        
        // Persist to storage
        saveSafetyStatus()
        
        // Re-validate status
        validateCurrentStatus()
    }
    
    /**
     * Record medical disclaimer acceptance
     * 
     * LEGAL REQUIREMENT: Explicit acceptance of medical disclaimers
     * with timestamp for legal compliance.
     */
    func recordMedicalDisclaimerAcceptance() {
        medicalDisclaimerAccepted = true
        UserDefaults.standard.set(true, forKey: "medicalDisclaimerAccepted")
        UserDefaults.standard.set(Date(), forKey: "medicalDisclaimerAcceptanceDate")
        validateCurrentStatus()
    }
    
    /**
     * Record age verification
     * 
     * SAFETY REQUIREMENT: Age verification with appropriate safety
     * measures for different age groups.
     * 
     * @param age: User's age for verification
     */
    func recordAgeVerification(age: Int) {
        guard age >= minimumAge else {
            // Age too low, require parental supervision
            ageVerified = false
            return
        }
        
        ageVerified = true
        UserDefaults.standard.set(true, forKey: "ageVerified")
        UserDefaults.standard.set(age, forKey: "userAge")
        validateCurrentStatus()
    }
    
    // MARK: - Private Methods
    
    /**
     * Check if safety education is still valid (not expired)
     * 
     * RATIONALE: Safety knowledge should be refreshed periodically
     * to ensure users maintain current safety awareness.
     */
    private func isSafetyEducationValid() -> Bool {
        guard let completionDate = safetyEducationCompletionDate else {
            return false
        }
        
        let daysSinceCompletion = Calendar.current.dateComponents([.day], from: completionDate, to: Date()).day ?? 0
        return daysSinceCompletion <= safetyEducationValidityDays
    }
    
    /**
     * Check if user has exceeded daily training limits
     * 
     * SAFETY DESIGN: Prevents overtraining which can lead to fatigue
     * and increased risk of accidents or injury.
     */
    private func hasExceededDailyTrainingLimit() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let todaysTrainingTime = getTotalTrainingTimeForDate(today)
        return todaysTrainingTime >= SafetyLimits.maxDailyTrainingTime
    }
    
    /**
     * Get total training time for a specific date
     * 
     * PURPOSE: Tracks daily training time to enforce safety limits
     * and prevent overtraining.
     */
    private func getTotalTrainingTimeForDate(_ date: Date) -> TimeInterval {
        // Implementation would query CoreData for training sessions on date
        // For now, return 0 (will be implemented with progress tracking)
        return 0
    }
    
    /**
     * Load safety status from persistent storage
     * 
     * PURPOSE: Restore safety validation state from previous app sessions
     * to maintain consistent safety enforcement.
     */
    private func loadSafetyStatus() {
        safetyEducationCompleted = UserDefaults.standard.bool(forKey: "safetyEducationCompleted")
        medicalDisclaimerAccepted = UserDefaults.standard.bool(forKey: "medicalDisclaimerAccepted")
        ageVerified = UserDefaults.standard.bool(forKey: "ageVerified")
        
        if let completionDate = UserDefaults.standard.object(forKey: "safetyEducationCompletionDate") as? Date {
            safetyEducationCompletionDate = completionDate
        }
    }
    
    /**
     * Save safety status to persistent storage
     * 
     * PURPOSE: Persist safety validation state to maintain consistency
     * across app sessions and prevent repeated safety education.
     */
    private func saveSafetyStatus() {
        UserDefaults.standard.set(safetyEducationCompleted, forKey: "safetyEducationCompleted")
        UserDefaults.standard.set(medicalDisclaimerAccepted, forKey: "medicalDisclaimerAccepted")
        UserDefaults.standard.set(ageVerified, forKey: "ageVerified")
        
        if let completionDate = safetyEducationCompletionDate {
            UserDefaults.standard.set(completionDate, forKey: "safetyEducationCompletionDate")
        }
    }
    
    /**
     * Validate current safety status and update published properties
     * 
     * PURPOSE: Ensures published properties reflect current validation
     * state and trigger appropriate UI updates.
     */
    private func validateCurrentStatus() {
        let _ = validateUserCanTrain()
    }
}

// MARK: - Supporting Types

/**
 * SafetyValidationResult: Enumeration of possible validation outcomes
 * 
 * DESIGN PRINCIPLE: Explicit enumeration of all possible validation
 * states enables clear handling of each safety scenario.
 */
enum SafetyValidationResult {
    case approved                    // User can access training features
    case safetyEducationRequired     // Must complete safety education
    case medicalRestriction          // Medical disclaimer not accepted
    case ageRestriction             // Age verification required
}

/**
 * SessionParameters: Parameters for a training session
 * 
 * PURPOSE: Encapsulates all session parameters that require safety
 * validation before allowing session to proceed.
 */
struct SessionParameters {
    let maxHoldTime: TimeInterval
    let restPeriod: TimeInterval
    let totalSessionTime: TimeInterval
    let userLevel: UserLevel
}

/**
 * UserLevel: User experience level for safety limit determination
 * 
 * RATIONALE: Different experience levels have different safety limits
 * to ensure appropriate progression and risk management.
 */
enum UserLevel: Int, CaseIterable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
}

/**
 * SafetyLimits: Hard-coded safety limits and thresholds
 * 
 * CRITICAL: These limits are based on safety research and must not
 * be exceeded under any circumstances. They provide the foundation
 * for all safety validation in the app.
 */
struct SafetyLimits {
    
    // Education requirements
    static let minSafetyEducationScore: Double = 0.8  // 80% minimum score
    static let minSafetyEducationTime: TimeInterval = 300  // 5 minutes minimum
    
    // Training limits by level
    static func maxHoldTimeForLevel(_ level: UserLevel) -> TimeInterval {
        switch level {
        case .beginner: return 30      // 30 seconds max for beginners
        case .intermediate: return 60   // 1 minute max for intermediate
        case .advanced: return 120     // 2 minutes max for advanced
        }
    }
    
    // Rest period requirements
    static func minRestPeriodForHoldTime(_ holdTime: TimeInterval) -> TimeInterval {
        return holdTime * 2  // Rest period must be at least 2x hold time
    }
    
    // Session limits
    static let maxSessionDuration: TimeInterval = 1800  // 30 minutes max session
    static let maxDailyTrainingTime: TimeInterval = 3600  // 1 hour max daily
} 