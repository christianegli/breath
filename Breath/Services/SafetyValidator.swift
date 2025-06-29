import Foundation
import SwiftUI

/**
 * SafetyValidator: Comprehensive safety validation service
 * 
 * PURPOSE: This is the cornerstone of our safety-first architecture. It ensures
 * users cannot access training features without proper safety education and
 * continuously validates safety compliance throughout the app experience.
 * 
 * CRITICAL SAFETY PRINCIPLE: This service acts as a gatekeeper that prevents
 * unsafe access to breath training features. All training functionality must
 * pass through safety validation to prevent potential harm.
 * 
 * ARCHITECTURE DECISION: Centralized validation prevents bypassing safety
 * requirements through direct navigation or state manipulation. Fail-safe
 * design ensures uncertainty always denies access.
 */
class SafetyValidator: ObservableObject {
    
    // MARK: - Published Properties
    
    /**
     * Current safety validation status
     * 
     * SAFETY DESIGN: Published property ensures UI automatically updates
     * when safety status changes, preventing stale safety states.
     */
    @Published var currentStatus: SafetyValidationResult = .safetyEducationRequired
    
    /**
     * Safety education completion status
     * 
     * CRITICAL: This is the primary gate for training access. Users cannot
     * proceed without completing comprehensive safety education.
     */
    @Published var safetyEducationCompleted: Bool = false
    
    /**
     * Safety education completion date
     * 
     * RATIONALE: Safety education expires after 90 days to ensure users
     * maintain current safety knowledge as techniques evolve.
     */
    @Published var safetyEducationDate: Date?
    
    /**
     * User age verification status
     * 
     * SAFETY REQUIREMENT: Minimum age 13 for breath training, with parental
     * supervision recommended for users under 18.
     */
    @Published var ageVerified: Bool = false
    @Published var userAge: Int?
    
    /**
     * Medical disclaimer acceptance
     * 
     * LEGAL SAFETY: Users must explicitly acknowledge medical risks and
     * confirm they have no contraindications before training.
     */
    @Published var medicalDisclaimerAccepted: Bool = false
    
    /**
     * Emergency contact information
     * 
     * SAFETY FEATURE: Required for users under 18 or those with medical
     * conditions to ensure emergency response capability.
     */
    @Published var emergencyContactProvided: Bool = false
    
    // MARK: - Constants
    
    /**
     * Safety education validity period (90 days)
     * 
     * RATIONALE: Regular re-education ensures users maintain current safety
     * knowledge as research and best practices evolve.
     */
    private let safetyEducationValidityPeriod: TimeInterval = 90 * 24 * 60 * 60
    
    /**
     * Minimum age for breath training
     * 
     * SAFETY STANDARD: Based on physiological development and ability to
     * understand and follow safety instructions.
     */
    private let minimumAge: Int = 13
    
    /**
     * Age requiring parental supervision
     * 
     * SAFETY GUIDELINE: Users under 18 should have parental awareness
     * and emergency contact information.
     */
    private let parentalSupervisionAge: Int = 18
    
    // MARK: - Initialization
    
    init() {
        loadSafetyStatus()
        validateCurrentStatus()
    }
    
    // MARK: - Core Validation Methods
    
    /**
     * Primary validation method for training access
     * 
     * SAFETY DESIGN: This is the main gatekeeper method that determines
     * whether a user can access breath training features. All training
     * components must call this before allowing access.
     * 
     * FAIL-SAFE PRINCIPLE: Any uncertainty or missing requirement results
     * in denial of access. Better to be overly cautious than risk harm.
     */
    func validateUserCanTrain() -> SafetyValidationResult {
        // Age verification check
        guard ageVerified, let age = userAge, age >= minimumAge else {
            currentStatus = .ageRestriction
            return .ageRestriction
        }
        
        // Medical disclaimer check
        guard medicalDisclaimerAccepted else {
            currentStatus = .medicalRestriction
            return .medicalRestriction
        }
        
        // Emergency contact check for minors
        if age < parentalSupervisionAge && !emergencyContactProvided {
            currentStatus = .parentalSupervisionRequired
            return .parentalSupervisionRequired
        }
        
        // Safety education completion check
        guard safetyEducationCompleted else {
            currentStatus = .safetyEducationRequired
            return .safetyEducationRequired
        }
        
        // Safety education validity check
        guard isSafetyEducationValid() else {
            currentStatus = .safetyEducationExpired
            return .safetyEducationExpired
        }
        
        // All checks passed
        currentStatus = .approved
        return .approved
    }
    
    /**
     * Validate safety education currency
     * 
     * SAFETY PRINCIPLE: Safety knowledge must be current to ensure users
     * are aware of latest research and best practices.
     */
    private func isSafetyEducationValid() -> Bool {
        guard let completionDate = safetyEducationDate else { return false }
        let timeElapsed = Date().timeIntervalSince(completionDate)
        return timeElapsed <= safetyEducationValidityPeriod
    }
    
    /**
     * Validate session parameters for safety compliance
     * 
     * CRITICAL SAFETY: Enforces hard-coded safety limits that cannot be
     * bypassed. These limits are based on medical research and safety guidelines.
     */
    func validateSessionParameters(holdDuration: TimeInterval, restDuration: TimeInterval, rounds: Int) -> SessionValidationResult {
        // Hard-coded safety limits based on experience level
        let maxHoldDuration: TimeInterval
        let minRestDuration: TimeInterval
        let maxRounds: Int
        
        // Determine limits based on user experience (simplified for MVP)
        if let age = userAge, age < 16 {
            // Stricter limits for younger users
            maxHoldDuration = 15.0
            minRestDuration = 30.0
            maxRounds = 3
        } else {
            // Standard safety limits
            maxHoldDuration = 120.0  // 2 minutes maximum
            minRestDuration = 15.0   // 15 seconds minimum rest
            maxRounds = 10           // Maximum 10 rounds
        }
        
        // Validate hold duration
        if holdDuration > maxHoldDuration {
            return .holdDurationTooLong(maximum: maxHoldDuration)
        }
        
        // Validate rest duration
        if restDuration < minRestDuration {
            return .restDurationTooShort(minimum: minRestDuration)
        }
        
        // Validate round count
        if rounds > maxRounds {
            return .tooManyRounds(maximum: maxRounds)
        }
        
        // Additional safety checks
        if holdDuration < 5.0 {
            return .holdDurationTooShort
        }
        
        return .approved
    }
    
    // MARK: - Safety Education Methods
    
    /**
     * Mark safety education as completed
     * 
     * SAFETY VALIDATION: Only called after user successfully completes
     * comprehensive safety education including quiz with 80% passing score.
     */
    func completeSafetyEducation() {
        safetyEducationCompleted = true
        safetyEducationDate = Date()
        saveSafetyStatus()
        validateCurrentStatus()
        
        // Log safety education completion for audit trail
        print("🛡️ Safety education completed at \(Date())")
    }
    
    /**
     * Reset safety education (for re-validation)
     * 
     * SAFETY FEATURE: Allows users to retake safety education when
     * expired or when they want to refresh their knowledge.
     */
    func resetSafetyEducation() {
        safetyEducationCompleted = false
        safetyEducationDate = nil
        saveSafetyStatus()
        validateCurrentStatus()
    }
    
    // MARK: - User Information Methods
    
    /**
     * Set user age with validation
     * 
     * SAFETY VALIDATION: Ensures age meets minimum requirements and
     * triggers appropriate safety measures for different age groups.
     */
    func setUserAge(_ age: Int) {
        guard age >= minimumAge && age <= 120 else {
            print("⚠️ Invalid age provided: \(age)")
            return
        }
        
        userAge = age
        ageVerified = true
        
        // Require emergency contact for minors
        if age < parentalSupervisionAge {
            emergencyContactProvided = false
        }
        
        saveSafetyStatus()
        validateCurrentStatus()
    }
    
    /**
     * Accept medical disclaimer
     * 
     * LEGAL SAFETY: Records user acknowledgment of medical risks and
     * contraindications associated with breath training.
     */
    func acceptMedicalDisclaimer() {
        medicalDisclaimerAccepted = true
        saveSafetyStatus()
        validateCurrentStatus()
    }
    
    /**
     * Set emergency contact information
     * 
     * SAFETY REQUIREMENT: Ensures emergency response capability,
     * especially important for minors and users with medical conditions.
     */
    func setEmergencyContact(provided: Bool) {
        emergencyContactProvided = provided
        saveSafetyStatus()
        validateCurrentStatus()
    }
    
    // MARK: - Emergency Methods
    
    /**
     * Emergency stop validation
     * 
     * CRITICAL SAFETY: Always allows immediate session termination
     * regardless of other states. Safety override for emergency situations.
     */
    func validateEmergencyStop() -> Bool {
        // Emergency stop is ALWAYS allowed - no conditions
        return true
    }
    
    /**
     * Check if user needs immediate medical attention
     * 
     * SAFETY ASSESSMENT: Evaluates user-reported symptoms or conditions
     * that might require immediate medical intervention.
     */
    func requiresImmediateMedicalAttention(symptoms: [String]) -> Bool {
        let emergencySymptoms = [
            "chest pain",
            "severe dizziness",
            "fainting",
            "difficulty breathing",
            "heart palpitations",
            "severe nausea"
        ]
        
        return symptoms.contains { symptom in
            emergencySymptoms.contains(symptom.lowercased())
        }
    }
    
    // MARK: - Persistence Methods
    
    /**
     * Load safety status from persistent storage
     * 
     * RATIONALE: Maintains safety validation across app sessions
     * to prevent users from bypassing completed safety education.
     */
    private func loadSafetyStatus() {
        let defaults = UserDefaults.standard
        
        safetyEducationCompleted = defaults.bool(forKey: "safetyEducationCompleted")
        ageVerified = defaults.bool(forKey: "ageVerified")
        medicalDisclaimerAccepted = defaults.bool(forKey: "medicalDisclaimerAccepted")
        emergencyContactProvided = defaults.bool(forKey: "emergencyContactProvided")
        
        if let ageValue = defaults.object(forKey: "userAge") as? Int {
            userAge = ageValue
        }
        
        if let dateValue = defaults.object(forKey: "safetyEducationDate") as? Date {
            safetyEducationDate = dateValue
        }
    }
    
    /**
     * Save safety status to persistent storage
     * 
     * RATIONALE: Persists safety validation state to prevent loss
     * of completed safety education and maintain consistent safety enforcement.
     */
    private func saveSafetyStatus() {
        let defaults = UserDefaults.standard
        
        defaults.set(safetyEducationCompleted, forKey: "safetyEducationCompleted")
        defaults.set(ageVerified, forKey: "ageVerified")
        defaults.set(medicalDisclaimerAccepted, forKey: "medicalDisclaimerAccepted")
        defaults.set(emergencyContactProvided, forKey: "emergencyContactProvided")
        defaults.set(userAge, forKey: "userAge")
        defaults.set(safetyEducationDate, forKey: "safetyEducationDate")
    }
    
    /**
     * Update current validation status
     * 
     * SAFETY DESIGN: Ensures UI reflects current safety state and
     * triggers appropriate user guidance or restrictions.
     */
    private func validateCurrentStatus() {
        currentStatus = validateUserCanTrain()
    }
    
    // MARK: - App Launch Validation
    
    /**
     * Validate app launch safety requirements
     * 
     * STARTUP SAFETY: Ensures app starts in a safe state and guides
     * users through required safety steps before accessing training.
     */
    func validateAppLaunch() {
        validateCurrentStatus()
        
        // Log safety status for debugging
        print("🛡️ Safety Validation Status: \(currentStatus)")
        print("🛡️ Safety Education: \(safetyEducationCompleted)")
        print("🛡️ Age Verified: \(ageVerified)")
        print("🛡️ Medical Disclaimer: \(medicalDisclaimerAccepted)")
    }
}

// MARK: - Safety Validation Results

/**
 * SafetyValidationResult: Enumeration of possible safety validation outcomes
 * 
 * DESIGN PRINCIPLE: Explicit enumeration of all possible safety states
 * ensures comprehensive handling and prevents undefined safety conditions.
 */
enum SafetyValidationResult {
    case approved
    case safetyEducationRequired
    case safetyEducationExpired
    case ageRestriction
    case medicalRestriction
    case parentalSupervisionRequired
    
    /**
     * User-friendly description of validation result
     * 
     * RATIONALE: Provides clear guidance to users about what steps
     * they need to take to meet safety requirements.
     */
    var description: String {
        switch self {
        case .approved:
            return "Safety requirements met. Training access approved."
        case .safetyEducationRequired:
            return "Safety education required before training access."
        case .safetyEducationExpired:
            return "Safety education has expired. Please complete refresher course."
        case .ageRestriction:
            return "Age verification required. Minimum age 13 for breath training."
        case .medicalRestriction:
            return "Medical disclaimer acceptance required before training."
        case .parentalSupervisionRequired:
            return "Emergency contact required for users under 18."
        }
    }
}

/**
 * SessionValidationResult: Enumeration of session parameter validation outcomes
 * 
 * SAFETY DESIGN: Specific validation results for training session parameters
 * ensure users cannot configure unsafe training sessions.
 */
enum SessionValidationResult {
    case approved
    case holdDurationTooLong(maximum: TimeInterval)
    case holdDurationTooShort
    case restDurationTooShort(minimum: TimeInterval)
    case tooManyRounds(maximum: Int)
    
    /**
     * User-friendly description of session validation result
     * 
     * RATIONALE: Provides specific guidance about safe parameter ranges
     * and helps users understand safety limitations.
     */
    var description: String {
        switch self {
        case .approved:
            return "Session parameters approved for safe training."
        case .holdDurationTooLong(let maximum):
            return "Hold duration too long. Maximum safe duration: \(Int(maximum)) seconds."
        case .holdDurationTooShort:
            return "Hold duration too short. Minimum recommended: 5 seconds."
        case .restDurationTooShort(let minimum):
            return "Rest duration too short. Minimum safe rest: \(Int(minimum)) seconds."
        case .tooManyRounds(let maximum):
            return "Too many rounds. Maximum safe rounds: \(maximum)."
        }
    }
} 