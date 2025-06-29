import SwiftUI

/**
 * SafetyEducationNavigationView: Navigation controls for safety education flow
 * 
 * PURPOSE: Provides consistent navigation controls throughout the safety
 * education process. Ensures users can move through steps safely while
 * preventing skipping of critical safety information.
 * 
 * RATIONALE: Controlled navigation prevents users from bypassing important
 * safety content while still allowing review of previous steps.
 */
struct SafetyEducationNavigationView: View {
    let currentStep: SafetyEducationStep
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: (() -> Void)?
    
    private var isFirstStep: Bool {
        currentStep == .ageVerification
    }
    
    private var isLastStep: Bool {
        currentStep == .completion
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            // MARK: - Back Button
            if !isFirstStep {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Placeholder to maintain layout
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 80, height: 44)
            }
            
            Spacer()
            
            // MARK: - Skip Button (if allowed)
            if let onSkip = onSkip {
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // MARK: - Next/Continue Button
            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text(nextButtonText)
                        .font(.system(size: 16, weight: .semibold))
                    
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .foregroundColor(canProceed ? .white : .gray)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(canProceed ? Color.blue : Color(.systemGray4))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canProceed)
            .animation(.easeInOut(duration: 0.2), value: canProceed)
        }
    }
    
    private var nextButtonText: String {
        switch currentStep {
        case .completion:
            return "Finish"
        case .safetyQuiz:
            return "Submit Quiz"
        default:
            return "Continue"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // First step
        SafetyEducationNavigationView(
            currentStep: .ageVerification,
            canProceed: false,
            onBack: {},
            onNext: {},
            onSkip: nil
        )
        
        // Middle step - can proceed
        SafetyEducationNavigationView(
            currentStep: .safetyBasics,
            canProceed: true,
            onBack: {},
            onNext: {},
            onSkip: nil
        )
        
        // Middle step - cannot proceed
        SafetyEducationNavigationView(
            currentStep: .medicalDisclaimer,
            canProceed: false,
            onBack: {},
            onNext: {},
            onSkip: nil
        )
        
        // Quiz step
        SafetyEducationNavigationView(
            currentStep: .safetyQuiz,
            canProceed: true,
            onBack: {},
            onNext: {},
            onSkip: nil
        )
        
        // Final step
        SafetyEducationNavigationView(
            currentStep: .completion,
            canProceed: true,
            onBack: {},
            onNext: {},
            onSkip: nil
        )
    }
    .padding()
} 