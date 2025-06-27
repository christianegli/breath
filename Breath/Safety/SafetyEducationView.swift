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

// MARK: - Placeholder Step Views (To be implemented in next tasks)

struct AgeVerificationStepView: View {
    @Binding var userAge: String
    
    var body: some View {
        Text("Age Verification Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct MedicalDisclaimerStepView: View {
    @Binding var accepted: Bool
    
    var body: some View {
        Text("Medical Disclaimer Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct SafetyBasicsStepView: View {
    var body: some View {
        Text("Safety Basics Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct DangerousTechniquesStepView: View {
    var body: some View {
        Text("Dangerous Techniques Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct ProperTechniquesStepView: View {
    var body: some View {
        Text("Proper Techniques Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct EmergencyProtocolsStepView: View {
    var body: some View {
        Text("Emergency Protocols Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct SafetyQuizStepView: View {
    @Binding var answers: [SafetyQuizAnswer]
    
    var body: some View {
        Text("Safety Quiz Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct CompletionStepView: View {
    var body: some View {
        Text("Completion Step - To be implemented")
            .foregroundColor(.secondary)
    }
}

struct NavigationControlsView: View {
    @Binding var currentStep: SafetyEducationStep
    @Binding var userAge: String
    @Binding var medicalDisclaimerAccepted: Bool
    @Binding var quizAnswers: [SafetyQuizAnswer]
    let educationStartTime: Date
    let onCompletion: () -> Void
    
    var body: some View {
        HStack {
            if currentStep != .welcome {
                Button("Previous") {
                    currentStep = currentStep.previous()
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(currentStep == .completion ? "Complete" : "Next") {
                if currentStep == .completion {
                    onCompletion()
                } else {
                    currentStep = currentStep.next()
                }
            }
            .foregroundColor(.blue)
            .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - Supporting Types

/**
 * SafetyEducationStep: Enumeration of education steps
 */
enum SafetyEducationStep: CaseIterable {
    case welcome
    case ageVerification
    case medicalDisclaimer
    case safetyBasics
    case dangerousTechniques
    case properTechniques
    case emergencyProtocols
    case quiz
    case completion
    
    var progress: Double {
        let currentIndex = Double(SafetyEducationStep.allCases.firstIndex(of: self) ?? 0)
        let totalSteps = Double(SafetyEducationStep.allCases.count - 1)
        return currentIndex / totalSteps
    }
    
    func next() -> SafetyEducationStep {
        let allCases = SafetyEducationStep.allCases
        let currentIndex = allCases.firstIndex(of: self) ?? 0
        let nextIndex = min(currentIndex + 1, allCases.count - 1)
        return allCases[nextIndex]
    }
    
    func previous() -> SafetyEducationStep {
        let allCases = SafetyEducationStep.allCases
        let currentIndex = allCases.firstIndex(of: self) ?? 0
        let previousIndex = max(currentIndex - 1, 0)
        return allCases[previousIndex]
    }
}

/**
 * SafetyQuizAnswer: Structure for quiz answer validation
 */
struct SafetyQuizAnswer {
    let questionId: String
    let selectedAnswer: String
    let correctAnswer: String
    
    var isCorrect: Bool {
        return selectedAnswer == correctAnswer
    }
}

#Preview {
    SafetyEducationView()
        .environmentObject(AppState())
        .environmentObject(SafetyValidator())
} 