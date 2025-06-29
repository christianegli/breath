import SwiftUI

/**
 * ContentView: Main application interface with safety-first navigation
 * 
 * RATIONALE: Acts as the primary navigation controller that routes users
 * through mandatory safety education before allowing access to breath
 * training features. Implements safety-first architecture principles.
 * 
 * ARCHITECTURE DECISION: Uses SafetyValidator to determine appropriate
 * view routing. No training features are accessible without completed
 * safety validation. Clear visual feedback guides users through safety requirements.
 * 
 * SAFETY DESIGN: Fail-safe routing ensures users cannot bypass safety
 * education through navigation manipulation. All paths lead through safety validation.
 */
struct ContentView: View {
    
    /**
     * Safety validator for routing and access control
     * 
     * SAFETY PRINCIPLE: Environment object ensures consistent safety
     * validation across all views and prevents bypassing safety requirements.
     */
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        NavigationView {
            Group {
                // Route based on safety validation status
                switch safetyValidator.currentStatus {
                case .approved:
                    // Safety requirements met - show training interface
                    TrainingApprovedView()
                    
                case .safetyEducationRequired, .safetyEducationExpired:
                    // Safety education needed
                    SafetyEducationRequiredView()
                    
                case .ageRestriction:
                    // Age verification needed
                    AgeVerificationView()
                    
                case .medicalRestriction:
                    // Medical disclaimer needed
                    MedicalDisclaimerView()
                    
                case .parentalSupervisionRequired:
                    // Emergency contact needed for minors
                    ParentalSupervisionView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Safety Routing Views

/**
 * TrainingApprovedView: Main training interface for validated users
 * 
 * SAFETY VALIDATION: Only accessible after complete safety validation.
 * Provides access to all breath training features with continued safety monitoring.
 */
struct TrainingApprovedView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        VStack(spacing: 30) {
            
            // MARK: - Safety Status Header
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Safety Validated")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Button("Safety Info") {
                    // Show safety status details
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // MARK: - App Header
            VStack(spacing: 10) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Breath Training")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Safe, guided breath training for improved performance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // MARK: - Training Options
            VStack(spacing: 20) {
                
                NavigationLink(destination: Text("Quick Training Session").navigationTitle("Quick Training")) {
                    TrainingOptionCard(
                        icon: "timer",
                        title: "Quick Session",
                        description: "5-minute guided breathing session",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: Text("Training Programs").navigationTitle("Programs")) {
                    TrainingOptionCard(
                        icon: "calendar",
                        title: "Training Programs",
                        description: "Structured programs for skill development",
                        color: .green
                    )
                }
                
                NavigationLink(destination: Text("Progress Tracking").navigationTitle("Progress")) {
                    TrainingOptionCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress Tracking",
                        description: "Monitor your improvement over time",
                        color: .orange
                    )
                }
                
                NavigationLink(destination: Text("Breathing Techniques").navigationTitle("Techniques")) {
                    TrainingOptionCard(
                        icon: "waveform.path.ecg",
                        title: "Breathing Techniques",
                        description: "Learn safe and effective techniques",
                        color: .purple
                    )
                }
            }
            
            Spacer()
            
            // MARK: - Safety Reminder
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("Safety First")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                Text("Always listen to your body. Stop immediately if you feel dizzy, uncomfortable, or unwell.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
    }
}

/**
 * SafetyEducationRequiredView: Guides users to safety education
 * 
 * SAFETY PRINCIPLE: Clear explanation of why safety education is mandatory
 * and how it protects the user. No bypass options available.
 */
struct SafetyEducationRequiredView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        VStack(spacing: 30) {
            
            // MARK: - Safety Education Header
            VStack(spacing: 15) {
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("Safety Education Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Your safety is our top priority. Complete the safety education to access breath training features.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // MARK: - Why Safety Education Matters
            VStack(alignment: .leading, spacing: 15) {
                Text("Why Safety Education is Essential:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                SafetyPointView(
                    icon: "exclamationmark.triangle.fill",
                    title: "Prevent Dangerous Techniques",
                    description: "Learn why certain popular breathing methods can be life-threatening"
                )
                
                SafetyPointView(
                    icon: "heart.fill",
                    title: "Understand Your Limits",
                    description: "Recognize warning signs and know when to stop safely"
                )
                
                SafetyPointView(
                    icon: "person.2.fill",
                    title: "Emergency Preparedness",
                    description: "Know what to do if something goes wrong during training"
                )
                
                SafetyPointView(
                    icon: "checkmark.circle.fill",
                    title: "Proper Techniques",
                    description: "Master safe, effective breathing methods that actually work"
                )
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            // MARK: - Start Safety Education Button
            NavigationLink(destination: Text("Safety Education Module").navigationTitle("Safety Education")) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    
                    Text("Start Safety Education")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
            
            Text("Takes about 10-15 minutes • Required only once")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/**
 * AgeVerificationView: Age verification for safety compliance
 * 
 * SAFETY REQUIREMENT: Ensures users meet minimum age requirements
 * and triggers appropriate safety measures for different age groups.
 */
struct AgeVerificationView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    @State private var ageText: String = ""
    @State private var showingError: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Age Verification")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Please confirm your age to ensure appropriate safety measures")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("Enter your age:")
                    .font(.headline)
                
                TextField("Age", text: $ageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                
                Button("Verify Age") {
                    verifyAge()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(ageText.isEmpty)
            }
            
            if showingError {
                Text("Minimum age 13 required for breath training")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            Text("Breath training requires maturity to understand and follow safety instructions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private func verifyAge() {
        guard let age = Int(ageText), age >= 13 else {
            showingError = true
            return
        }
        
        showingError = false
        safetyValidator.setUserAge(age)
    }
}

/**
 * MedicalDisclaimerView: Medical disclaimer acceptance
 * 
 * LEGAL SAFETY: Ensures users acknowledge medical risks and contraindications
 * before accessing breath training features.
 */
struct MedicalDisclaimerView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 15) {
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("Medical Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("Important Medical Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Breath training involves controlled breathing exercises that may affect your cardiovascular and nervous systems. Please read carefully:")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("⚠️ Do NOT use this app if you have:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Heart conditions or cardiovascular disease")
                        Text("• Respiratory conditions (asthma, COPD, etc.)")
                        Text("• Pregnancy")
                        Text("• Seizure disorders or epilepsy")
                        Text("• Recent surgery or injuries")
                        Text("• Any condition affecting breathing or circulation")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    
                    Text("⚠️ Consult your doctor before using this app if you have any medical conditions or concerns.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
            }
            
            Button("I Understand and Accept") {
                safetyValidator.acceptMedicalDisclaimer()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding()
    }
}

/**
 * ParentalSupervisionView: Emergency contact for minors
 * 
 * SAFETY REQUIREMENT: Ensures emergency response capability for users under 18.
 */
struct ParentalSupervisionView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 15) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Parental Awareness Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("As a minor, we require parental awareness and emergency contact information for your safety")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("Please ensure:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("A parent or guardian knows you're using this app")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Someone is available in case of emergency")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("You have emergency contact information ready")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("I Confirm Parental Awareness") {
                safetyValidator.setEmergencyContact(provided: true)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Supporting Views

/**
 * TrainingOptionCard: Reusable card for training options
 */
struct TrainingOptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

/**
 * SafetyPointView: Reusable view for safety education points
 */
struct SafetyPointView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SafetyValidator())
    }
} 