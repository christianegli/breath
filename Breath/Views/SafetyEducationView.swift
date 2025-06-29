import SwiftUI

/**
 * SafetyEducationView: Comprehensive mandatory safety education interface
 * 
 * PURPOSE: This view implements the complete safety education flow that users
 * must complete before accessing any breath training features. It ensures users
 * understand critical safety principles, dangerous techniques to avoid, and
 * proper emergency protocols.
 * 
 * SAFETY RATIONALE: This is literally a life-saving interface. Many breath
 * training techniques can be dangerous if done incorrectly. The Wim Hof Method,
 * in particular, has been linked to drowning deaths when combined with breath
 * holding. This education prevents such tragedies.
 * 
 * ARCHITECTURE DECISION: Multi-step wizard design ensures users cannot skip
 * critical safety information. Each step must be completed in sequence with
 * validation to prevent rushed completion.
 */
struct SafetyEducationView: View {
    
    /**
     * Safety validator for tracking completion
     * RATIONALE: Environment object ensures consistent safety state management
     */
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    /**
     * Current step in safety education flow
     * RATIONALE: Tracks progress through mandatory safety steps
     */
    @State private var currentStep: SafetyEducationStep = .ageVerification
    
    /**
     * User's age input for verification
     * RATIONALE: Age restrictions prevent minors from unsupervised breath training
     */
    @State private var userAge: String = ""
    
    /**
     * Medical disclaimer acceptance tracking
     * RATIONALE: Ensures users acknowledge medical risks and contraindications
     */
    @State private var medicalDisclaimerAccepted: Bool = false
    @State private var medicalDisclaimerScrolled: Bool = false
    
    /**
     * Safety education progress tracking
     * RATIONALE: Ensures users read and understand each safety section
     */
    @State private var safetyBasicsCompleted: Bool = false
    @State private var dangerousTechniquesCompleted: Bool = false
    @State private var properTechniquesCompleted: Bool = false
    @State private var emergencyProtocolsCompleted: Bool = false
    
    /**
     * Safety quiz state
     * RATIONALE: Validates understanding of critical safety concepts
     */
    @State private var quizAnswers: [Int] = Array(repeating: -1, count: SafetyQuizQuestion.allQuestions.count)
    @State private var quizCompleted: Bool = false
    @State private var quizScore: Double = 0.0
    
    /**
     * Animation and UI state
     * RATIONALE: Smooth transitions enhance user experience during education
     */
    @State private var showingCompletionCelebration: Bool = false
    @State private var animateProgress: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // MARK: - Progress Header
                SafetyEducationProgressView(
                    currentStep: currentStep,
                    totalSteps: SafetyEducationStep.allCases.count,
                    animate: animateProgress
                )
                .padding(.horizontal)
                .padding(.top)
                
                // MARK: - Step Content
                ScrollView {
                    VStack(spacing: 24) {
                        
                        switch currentStep {
                        case .ageVerification:
                            AgeVerificationStepView(
                                userAge: $userAge,
                                onNext: proceedToNextStep
                            )
                            
                        case .medicalDisclaimer:
                            MedicalDisclaimerStepView(
                                accepted: $medicalDisclaimerAccepted,
                                scrolled: $medicalDisclaimerScrolled,
                                onNext: proceedToNextStep
                            )
                            
                        case .safetyBasics:
                            SafetyBasicsStepView(
                                completed: $safetyBasicsCompleted,
                                onNext: proceedToNextStep
                            )
                            
                        case .dangerousTechniques:
                            DangerousTechniquesStepView(
                                completed: $dangerousTechniquesCompleted,
                                onNext: proceedToNextStep
                            )
                            
                        case .properTechniques:
                            ProperTechniquesStepView(
                                completed: $properTechniquesCompleted,
                                onNext: proceedToNextStep
                            )
                            
                        case .emergencyProtocols:
                            EmergencyProtocolsStepView(
                                completed: $emergencyProtocolsCompleted,
                                onNext: proceedToNextStep
                            )
                            
                        case .safetyQuiz:
                            SafetyQuizStepView(
                                answers: $quizAnswers,
                                completed: $quizCompleted,
                                score: $quizScore,
                                onNext: proceedToNextStep
                            )
                            
                        case .completion:
                            SafetyEducationCompletionView(
                                score: quizScore,
                                showCelebration: $showingCompletionCelebration,
                                onFinish: completeSafetyEducation
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for navigation buttons
                }
                
                Spacer()
                
                // MARK: - Navigation Footer
                SafetyEducationNavigationView(
                    currentStep: currentStep,
                    canProceed: canProceedFromCurrentStep(),
                    onBack: goToPreviousStep,
                    onNext: proceedToNextStep,
                    onSkip: nil // No skipping allowed in safety education
                )
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            }
            .navigationTitle("Safety Education")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Emergency Info") {
                        // Show emergency contact information
                    }
                    .foregroundColor(.red)
                    .font(.caption.weight(.semibold))
                }
            }
        }
        .onAppear {
            startSafetyEducation()
        }
    }
    
    // MARK: - Navigation Logic
    
    /**
     * Proceeds to the next step in safety education
     * RATIONALE: Validates current step completion before advancing
     */
    private func proceedToNextStep() {
        guard canProceedFromCurrentStep() else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if let nextStep = currentStep.next() {
                currentStep = nextStep
                animateProgress.toggle()
            }
        }
    }
    
    /**
     * Returns to the previous step
     * RATIONALE: Allows users to review previous safety information
     */
    private func goToPreviousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let previousStep = currentStep.previous() {
                currentStep = previousStep
                animateProgress.toggle()
            }
        }
    }
    
    /**
     * Validates if user can proceed from current step
     * RATIONALE: Ensures all safety requirements are met before advancing
     */
    private func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case .ageVerification:
            guard let age = Int(userAge), age >= 13 else { return false }
            return true
            
        case .medicalDisclaimer:
            return medicalDisclaimerAccepted && medicalDisclaimerScrolled
            
        case .safetyBasics:
            return safetyBasicsCompleted
            
        case .dangerousTechniques:
            return dangerousTechniquesCompleted
            
        case .properTechniques:
            return properTechniquesCompleted
            
        case .emergencyProtocols:
            return emergencyProtocolsCompleted
            
        case .safetyQuiz:
            return quizCompleted && quizScore >= 0.8 // 80% passing grade
            
        case .completion:
            return true
        }
    }
    
    /**
     * Initializes safety education session
     * RATIONALE: Sets up tracking and validation for education completion
     */
    private func startSafetyEducation() {
        // Reset all state to ensure clean education session
        currentStep = .ageVerification
        userAge = ""
        medicalDisclaimerAccepted = false
        medicalDisclaimerScrolled = false
        safetyBasicsCompleted = false
        dangerousTechniquesCompleted = false
        properTechniquesCompleted = false
        emergencyProtocolsCompleted = false
        quizAnswers = Array(repeating: -1, count: SafetyQuizQuestion.allQuestions.count)
        quizCompleted = false
        quizScore = 0.0
        showingCompletionCelebration = false
    }
    
    /**
     * Completes safety education and updates validator
     * RATIONALE: Marks safety education as complete and grants training access
     */
    private func completeSafetyEducation() {
        let ageInt = Int(userAge) ?? 0
        safetyValidator.completeSafetyEducation(
            age: ageInt,
            quizScore: quizScore
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingCompletionCelebration = true
        }
        
        // Auto-dismiss after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Navigation will be handled by ContentView based on safety validation state
        }
    }
}

// MARK: - Safety Education Steps Enum

/**
 * SafetyEducationStep: Defines the sequence of mandatory safety education steps
 * 
 * RATIONALE: Ensures consistent flow through all critical safety topics.
 * Order is carefully designed to build understanding progressively.
 */
enum SafetyEducationStep: CaseIterable {
    case ageVerification
    case medicalDisclaimer
    case safetyBasics
    case dangerousTechniques
    case properTechniques
    case emergencyProtocols
    case safetyQuiz
    case completion
    
    func next() -> SafetyEducationStep? {
        let allCases = SafetyEducationStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex + 1 < allCases.count else { return nil }
        return allCases[currentIndex + 1]
    }
    
    func previous() -> SafetyEducationStep? {
        let allCases = SafetyEducationStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else { return nil }
        return allCases[currentIndex - 1]
    }
    
    var title: String {
        switch self {
        case .ageVerification: return "Age Verification"
        case .medicalDisclaimer: return "Medical Disclaimer"
        case .safetyBasics: return "Safety Basics"
        case .dangerousTechniques: return "Dangerous Techniques"
        case .properTechniques: return "Safe Techniques"
        case .emergencyProtocols: return "Emergency Protocols"
        case .safetyQuiz: return "Safety Quiz"
        case .completion: return "Completion"
        }
    }
    
    var stepNumber: Int {
        return SafetyEducationStep.allCases.firstIndex(of: self)! + 1
    }
}

// MARK: - Preview

#Preview {
    SafetyEducationView()
        .environmentObject(SafetyValidator())
} 