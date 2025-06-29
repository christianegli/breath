import SwiftUI

/**
 * AgeVerificationStepView: Age verification for safety compliance
 * 
 * PURPOSE: Ensures users meet minimum age requirements for breath training.
 * Provides appropriate guidance for minors who require adult supervision.
 * 
 * SAFETY RATIONALE: Minors may not understand the risks of breath training
 * or may not recognize warning signs. Adult supervision is required for
 * users under 18, with absolute minimum age of 13.
 * 
 * ARCHITECTURE DECISION: Clear, simple interface that cannot be bypassed
 * without proper age verification. Provides educational content about
 * supervision requirements.
 */
struct AgeVerificationStepView: View {
    @Binding var userAge: String
    let onNext: () -> Void
    
    @State private var showingAgeWarning = false
    @State private var ageValidationMessage = ""
    
    private var isValidAge: Bool {
        guard let age = Int(userAge), age >= 13 else { return false }
        return true
    }
    
    private var requiresSupervision: Bool {
        guard let age = Int(userAge) else { return false }
        return age >= 13 && age < 18
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Header
            VStack(spacing: 16) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Age Verification")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text("We need to verify your age to ensure safe breath training practices.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // MARK: - Age Input
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Age")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your age", text: $userAge)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .onChange(of: userAge) { _, newValue in
                            validateAge(newValue)
                        }
                }
                
                // Age validation feedback
                if !ageValidationMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: isValidAge ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(isValidAge ? .green : .red)
                        
                        Text(ageValidationMessage)
                            .font(.caption)
                            .foregroundColor(isValidAge ? .green : .red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background((isValidAge ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // MARK: - Age Requirements Information
            VStack(spacing: 16) {
                Text("Age Requirements")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    AgeRequirementRow(
                        icon: "xmark.circle.fill",
                        iconColor: .red,
                        title: "Under 13 years",
                        description: "Not permitted to use breath training features"
                    )
                    
                    AgeRequirementRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        title: "13-17 years",
                        description: "Requires adult supervision and parental consent"
                    )
                    
                    AgeRequirementRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        title: "18+ years",
                        description: "Can practice independently with proper safety education"
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // MARK: - Supervision Notice (for minors)
            if requiresSupervision {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.orange)
                        Text("Adult Supervision Required")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text("As a minor, you must have an adult present during all breath training sessions. The supervising adult should also complete this safety education.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Please ensure a responsible adult is available before proceeding.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            
            // MARK: - Safety Notice
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                    Text("Why Age Verification Matters")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text("Breath training can have powerful physiological effects. Age verification ensures users have the maturity to understand safety instructions and recognize warning signs.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Spacer(minLength: 20)
        }
        .padding()
    }
    
    private func validateAge(_ ageString: String) {
        guard !ageString.isEmpty else {
            ageValidationMessage = ""
            return
        }
        
        guard let age = Int(ageString) else {
            ageValidationMessage = "Please enter a valid age"
            return
        }
        
        if age < 13 {
            ageValidationMessage = "You must be at least 13 years old to use this app"
        } else if age >= 13 && age < 18 {
            ageValidationMessage = "Adult supervision required for minors"
        } else if age >= 18 && age <= 120 {
            ageValidationMessage = "Age verified - you can practice independently"
        } else {
            ageValidationMessage = "Please enter a realistic age"
        }
    }
}

/**
 * AgeRequirementRow: Individual age requirement display component
 */
struct AgeRequirementRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        AgeVerificationStepView(
            userAge: .constant("16"),
            onNext: {}
        )
    }
} 