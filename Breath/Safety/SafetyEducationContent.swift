import SwiftUI

/**
 * SafetyEducationContent: Comprehensive safety education step implementations
 * 
 * PURPOSE: Provides detailed, engaging safety education content that users
 * must complete before accessing training features. Each step is designed
 * to educate users about specific safety aspects of breath training.
 * 
 * SAFETY CRITICAL: This content forms the foundation of user safety knowledge.
 * All information must be accurate, comprehensive, and clearly communicated.
 */

// MARK: - Age Verification Step

/**
 * AgeVerificationStepView: Age verification and parental controls
 * 
 * SAFETY REQUIREMENT: Age verification ensures appropriate safety measures
 * and determines if parental supervision is required.
 */
struct AgeVerificationStepView: View {
    @Binding var userAge: String
    @State private var showParentalGuidance: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Age Verification")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We need to verify your age to provide appropriate safety guidance and training programs.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Age input
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your age:")
                        .font(.headline)
                    
                    TextField("Age", text: $userAge)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                }
                
                // Age-based guidance
                if let age = Int(userAge), !userAge.isEmpty {
                    AgeGuidanceView(age: age)
                }
            }
            
            // Safety information
            VStack(spacing: 12) {
                SafetyInfoCard(
                    icon: "exclamationmark.shield",
                    title: "Why Age Verification?",
                    description: "Different age groups require different safety protocols and supervision levels.",
                    color: .orange
                )
                
                SafetyInfoCard(
                    icon: "person.2",
                    title: "Parental Supervision",
                    description: "Users under 18 should practice under adult supervision.",
                    color: .blue
                )
            }
        }
        .alert("Parental Guidance Required", isPresented: $showParentalGuidance) {
            Button("I Understand") { }
        } message: {
            Text("Users under 18 should have parental supervision when practicing breathing exercises. Please ensure an adult is present during training sessions.")
        }
    }
}

/**
 * AgeGuidanceView: Age-specific guidance and requirements
 */
struct AgeGuidanceView: View {
    let age: Int
    
    var body: some View {
        VStack(spacing: 12) {
            if age < 13 {
                AgeGuidanceCard(
                    title: "Parental Supervision Required",
                    message: "Users under 13 require constant adult supervision during all breathing exercises.",
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )
            } else if age < 18 {
                AgeGuidanceCard(
                    title: "Adult Supervision Recommended",
                    message: "We recommend adult supervision during breathing exercises for users under 18.",
                    color: .orange,
                    icon: "person.2.fill"
                )
            } else {
                AgeGuidanceCard(
                    title: "Independent Training Approved",
                    message: "You can practice independently, but always follow safety guidelines.",
                    color: .green,
                    icon: "checkmark.shield.fill"
                )
            }
        }
    }
}

/**
 * AgeGuidanceCard: Individual age guidance display
 */
struct AgeGuidanceCard: View {
    let title: String
    let message: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Medical Disclaimer Step

/**
 * MedicalDisclaimerStepView: Medical disclaimers and health warnings
 * 
 * LEGAL REQUIREMENT: Comprehensive medical disclaimers for legal compliance
 * and user safety awareness.
 */
struct MedicalDisclaimerStepView: View {
    @Binding var accepted: Bool
    @State private var hasReadDisclaimer: Bool = false
    @State private var scrolledToBottom: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "cross.case")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Medical Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Please read and understand these important medical disclaimers before proceeding.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Disclaimer content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    DisclaimerSection(
                        title: "⚠️ Medical Consultation Required",
                        content: """
                        Consult your healthcare provider before starting any breathing exercise program, especially if you have:
                        
                        • Heart conditions or cardiovascular disease
                        • Respiratory conditions (asthma, COPD, etc.)
                        • Blood pressure disorders
                        • Anxiety or panic disorders
                        • Pregnancy
                        • Any chronic medical conditions
                        • History of fainting or seizures
                        """
                    )
                    
                    DisclaimerSection(
                        title: "🚫 Contraindications",
                        content: """
                        Do NOT use this app if you have:
                        
                        • Severe heart conditions
                        • Uncontrolled high blood pressure
                        • Recent surgery or injury
                        • Active respiratory infections
                        • Severe mental health conditions
                        • Are under the influence of substances
                        
                        When in doubt, consult a medical professional.
                        """
                    )
                    
                    DisclaimerSection(
                        title: "⚡ Emergency Warning Signs",
                        content: """
                        STOP IMMEDIATELY and seek medical attention if you experience:
                        
                        • Chest pain or discomfort
                        • Severe dizziness or fainting
                        • Difficulty breathing normally
                        • Rapid or irregular heartbeat
                        • Nausea or vomiting
                        • Severe anxiety or panic
                        • Any unusual symptoms
                        """
                    )
                    
                    DisclaimerSection(
                        title: "📋 Legal Disclaimer",
                        content: """
                        This app is for educational and wellness purposes only. It is not intended to diagnose, treat, cure, or prevent any medical condition.
                        
                        • Use at your own risk
                        • Results may vary between individuals
                        • No medical supervision is provided
                        • Always prioritize your safety and well-being
                        • The developers assume no liability for any adverse effects
                        """
                    )
                    
                    // Scroll detection view
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            scrolledToBottom = true
                        }
                }
                .padding()
            }
            .frame(maxHeight: 300)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Acceptance checkbox
            VStack(spacing: 16) {
                Button(action: {
                    if scrolledToBottom {
                        accepted.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: accepted ? "checkmark.square.fill" : "square")
                            .foregroundColor(accepted ? .green : .gray)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I have read and understand the medical disclaimers")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("I accept full responsibility for my safety")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .disabled(!scrolledToBottom)
                
                if !scrolledToBottom {
                    Text("Please scroll to the bottom to enable acceptance")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

/**
 * DisclaimerSection: Individual disclaimer section
 */
struct DisclaimerSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

// MARK: - Safety Basics Step

/**
 * SafetyBasicsStepView: Fundamental safety principles
 * 
 * PURPOSE: Educates users about basic safety principles that apply
 * to all breathing exercises and training sessions.
 */
struct SafetyBasicsStepView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Safety Basics")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Learn the fundamental safety principles that will keep you safe during all breathing exercises.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Safety principles
            VStack(spacing: 16) {
                
                SafetyPrincipleCard(
                    icon: "location.fill",
                    iconColor: .green,
                    title: "Safe Environment Only",
                    description: "Always practice in a safe, comfortable location:",
                    details: [
                        "Sitting or lying down securely",
                        "Away from water (pools, bathtubs, etc.)",
                        "In a quiet, distraction-free space",
                        "With someone nearby if possible"
                    ]
                )
                
                SafetyPrincipleCard(
                    icon: "ear.fill",
                    iconColor: .blue,
                    title: "Listen to Your Body",
                    description: "Your body knows best - always pay attention:",
                    details: [
                        "Stop if you feel dizzy or uncomfortable",
                        "Never push beyond your comfort zone",
                        "Respect your natural limits",
                        "Take breaks when needed"
                    ]
                )
                
                SafetyPrincipleCard(
                    icon: "clock.fill",
                    iconColor: .orange,
                    title: "Start Slowly",
                    description: "Gradual progression prevents injury:",
                    details: [
                        "Begin with short, easy exercises",
                        "Increase difficulty gradually over weeks",
                        "Never rush your development",
                        "Consistency beats intensity"
                    ]
                )
                
                SafetyPrincipleCard(
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .red,
                    title: "Emergency Preparedness",
                    description: "Always be prepared for emergencies:",
                    details: [
                        "Know when to stop immediately",
                        "Have emergency contacts accessible",
                        "Practice with supervision when possible",
                        "Trust your instincts about safety"
                    ]
                )
            }
        }
    }
}

/**
 * SafetyPrincipleCard: Individual safety principle display
 */
struct SafetyPrincipleCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let details: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                ForEach(details, id: \.self) { detail in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(iconColor)
                            .font(.caption)
                        
                        Text(detail)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

/**
 * SafetyInfoCard: Reusable safety information card
 */
struct SafetyInfoCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 