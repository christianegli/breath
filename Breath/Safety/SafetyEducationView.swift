import SwiftUI

/**
 * SafetyEducationView: Mandatory safety education interface
 * 
 * PURPOSE: Provides comprehensive safety education that users MUST complete
 * before accessing any training features. This is the primary safety gatekeeper
 * that ensures users understand proper breathing techniques and safety protocols.
 * 
 * DESIGN PRINCIPLE: Education-first approach where users cannot bypass or
 * skip safety education. The interface is designed to be engaging and thorough
 * while maintaining strict completion requirements.
 * 
 * SAFETY CRITICAL: This view determines whether users can access training
 * features. All validation must be rigorous and cannot be circumvented.
 */
struct SafetyEducationView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    // MARK: - State Properties
    
    /**
     * Current education step/page
     * 
     * RATIONALE: Step-by-step progression ensures users read all safety
     * information before proceeding to quiz validation.
     */
    @State private var currentStep: SafetyEducationStep = .welcome
    
    /**
     * Education start time for completion validation
     * 
     * PURPOSE: Tracks time spent on education to prevent users from
     * rushing through safety content without reading.
     */
    @State private var educationStartTime: Date = Date()
    
    /**
     * Quiz answers for validation
     * 
     * CRITICAL: Quiz validation ensures users have understood key
     * safety concepts before accessing training features.
     */
    @State private var quizAnswers: [SafetyQuizAnswer] = []
    
    /**
     * Age verification input
     * 
     * SAFETY REQUIREMENT: Age verification for appropriate safety
     * measures and parental controls.
     */
    @State private var userAge: String = ""
    
    /**
     * Medical disclaimer acceptance
     * 
     * LEGAL REQUIREMENT: Explicit acceptance of medical disclaimers
     * for legal compliance and user safety awareness.
     */
    @State private var medicalDisclaimerAccepted: Bool = false
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Progress indicator
            ProgressIndicatorView(currentStep: currentStep)
            
            // Main content area
            ScrollView {
                VStack(spacing: 24) {
                    
                    switch currentStep {
                    case .welcome:
                        WelcomeStepView()
                    case .ageVerification:
                        AgeVerificationStepView(userAge: $userAge)
                    case .medicalDisclaimer:
                        MedicalDisclaimerStepView(accepted: $medicalDisclaimerAccepted)
                    case .safetyBasics:
                        SafetyBasicsStepView()
                    case .dangerousTechniques:
                        DangerousTechniquesStepView()
                    case .properTechniques:
                        ProperTechniquesStepView()
                    case .emergencyProtocols:
                        EmergencyProtocolsStepView()
                    case .quiz:
                        SafetyQuizStepView(answers: $quizAnswers)
                    case .completion:
                        CompletionStepView()
                    }
                }
                .padding()
            }
            
            // Navigation controls
            NavigationControlsView(
                currentStep: $currentStep,
                userAge: $userAge,
                medicalDisclaimerAccepted: $medicalDisclaimerAccepted,
                quizAnswers: $quizAnswers,
                educationStartTime: educationStartTime,
                onCompletion: completeEducation
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            educationStartTime = Date()
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * Complete safety education and validate requirements
     * 
     * CRITICAL: This method performs final validation of all safety
     * education requirements before granting access to training features.
     */
    private func completeEducation() {
        
        // Calculate education completion time
        let completionTime = Date().timeIntervalSince(educationStartTime)
        
        // Calculate quiz score
        let quizScore = calculateQuizScore()
        
        // Validate age
        if let age = Int(userAge) {
            safetyValidator.recordAgeVerification(age: age)
        }
        
        // Record medical disclaimer acceptance
        if medicalDisclaimerAccepted {
            safetyValidator.recordMedicalDisclaimerAcceptance()
        }
        
        // Record safety education completion with validation
        safetyValidator.recordSafetyEducationCompletion(
            educationScore: quizScore,
            completionTime: completionTime
        )
        
        // Navigate to training if all validations passed
        if safetyValidator.validateUserCanTrain() == .approved {
            appState.completeSafetyEducation()
        }
    }
    
    /**
     * Calculate quiz score from user answers
     * 
     * RATIONALE: Quiz scoring validates user understanding of critical
     * safety concepts before allowing access to training features.
     */
    private func calculateQuizScore() -> Double {
        guard !quizAnswers.isEmpty else { return 0.0 }
        
        let correctAnswers = quizAnswers.filter { $0.isCorrect }.count
        return Double(correctAnswers) / Double(quizAnswers.count)
    }
}

// MARK: - Supporting Views

/**
 * ProgressIndicatorView: Shows education progress
 */
struct ProgressIndicatorView: View {
    let currentStep: SafetyEducationStep
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: currentStep.progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            Text("Safety Education Progress")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
}

/**
 * WelcomeStepView: Introduction to safety education
 */
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Welcome to Breath Safety Education")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Before you begin training, we need to ensure you understand proper breathing techniques and safety protocols.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                SafetyPointView(
                    icon: "exclamationmark.triangle.fill",
                    text: "Safety education is mandatory and cannot be skipped",
                    color: .red
                )
                
                SafetyPointView(
                    icon: "clock.fill",
                    text: "Take your time to read and understand each section",
                    color: .orange
                )
                
                SafetyPointView(
                    icon: "checkmark.seal.fill",
                    text: "You must pass a safety quiz to access training",
                    color: .blue
                )
            }
        }
    }
}

/**
 * SafetyPointView: Reusable safety point display
 */
struct SafetyPointView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Step Views Implementation Note
// The detailed step view implementations are in separate files:
// - AgeVerificationStepView: SafetyEducationContent.swift
// - MedicalDisclaimerStepView: SafetyEducationContent.swift  
// - SafetyBasicsStepView: SafetyEducationContent.swift
// - DangerousTechniquesStepView: DangerousTechniquesView.swift
// - ProperTechniquesStepView: ProperTechniquesView.swift
// - EmergencyProtocolsStepView: EmergencyProtocolsView.swift
// - SafetyQuizStepView: SafetyQuizView.swift

struct CompletionStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // Success header
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Safety Education Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Congratulations! You have successfully completed the comprehensive safety education program.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Achievement summary
            VStack(spacing: 16) {
                Text("🎓 What You've Accomplished")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    CompletionAchievement(
                        icon: "person.badge.shield.checkmark",
                        title: "Age Verification",
                        description: "Confirmed appropriate safety protocols for your age group"
                    )
                    
                    CompletionAchievement(
                        icon: "cross.case.fill",
                        title: "Medical Awareness",
                        description: "Understood medical disclaimers and health considerations"
                    )
                    
                    CompletionAchievement(
                        icon: "shield.lefthalf.filled.badge.checkmark",
                        title: "Safety Fundamentals",
                        description: "Learned essential safety principles for breath training"
                    )
                    
                    CompletionAchievement(
                        icon: "exclamationmark.triangle.fill",
                        title: "Dangerous Techniques",
                        description: "Identified and committed to avoid dangerous practices"
                    )
                    
                    CompletionAchievement(
                        icon: "lungs.fill",
                        title: "Proper Techniques",
                        description: "Learned safe, scientifically-validated breathing methods"
                    )
                    
                    CompletionAchievement(
                        icon: "cross.case.circle.fill",
                        title: "Emergency Protocols",
                        description: "Prepared for emergency recognition and response"
                    )
                    
                    CompletionAchievement(
                        icon: "brain.head.profile",
                        title: "Knowledge Validation",
                        description: "Passed comprehensive safety quiz with 80%+ score"
                    )
                }
            }
            
            // Safety commitment reminder
            VStack(spacing: 12) {
                Text("🤝 Your Safety Commitment")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                VStack(spacing: 8) {
                    Text("By completing this education, you have committed to:")
                        .font(.body)