import SwiftUI

/**
 * TrainingHomeView: Main training interface after safety education completion
 * 
 * PURPOSE: Provides the main training dashboard where users can access
 * different breathing exercises, view progress, and manage their training.
 * Only accessible after completing mandatory safety education.
 * 
 * SAFETY DESIGN: All training options include built-in safety validation
 * and enforce appropriate limits based on user experience level.
 * 
 * ARCHITECTURE: Central hub that routes to specific training modules
 * while maintaining safety oversight and progress tracking.
 */
struct TrainingHomeView: View {
    
    // MARK: - Environment Objects
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    // MARK: - State Properties
    
    /**
     * User's current training level
     * 
     * RATIONALE: Determines available training programs and safety limits
     * to ensure appropriate progression and risk management.
     */
    @State private var userLevel: UserLevel = .beginner
    
    /**
     * Show safety reminder alert
     * 
     * SAFETY DESIGN: Periodic safety reminders to maintain safety awareness
     * even after education completion.
     */
    @State private var showSafetyReminder: Bool = false
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Welcome header with safety status
                    WelcomeHeaderView(userLevel: userLevel)
                    
                    // Safety status indicator
                    SafetyStatusView()
                    
                    // Quick training options
                    QuickTrainingSection()
                    
                    // Structured programs
                    StructuredProgramsSection(userLevel: userLevel)
                    
                    // Progress overview
                    ProgressOverviewSection()
                    
                    // Safety and settings
                    SafetyAndSettingsSection()
                }
                .padding()
            }
            .navigationTitle("Breath Training")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSafetyReminder = true }) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .alert("Safety Reminder", isPresented: $showSafetyReminder) {
            Button("OK") { }
        } message: {
            Text("Always practice in a safe environment. Never practice breath holding in or near water. Stop immediately if you feel dizzy or uncomfortable.")
        }
        .onAppear {
            validateSafetyStatus()
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * Validate safety status and redirect if necessary
     * 
     * SAFETY CHECK: Continuous validation ensures users cannot access
     * training if safety requirements are no longer met.
     */
    private func validateSafetyStatus() {
        let validationResult = safetyValidator.validateUserCanTrain()
        
        if validationResult != .approved {
            // Safety validation failed, redirect to safety education
            appState.navigateToSafetyEducation()
        }
    }
}

// MARK: - Section Views

/**
 * WelcomeHeaderView: Personalized welcome with safety messaging
 */
struct WelcomeHeaderView: View {
    let userLevel: UserLevel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Level: \(userLevel.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "lungs.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            // Daily safety reminder
            HStack(spacing: 12) {
                Image(systemName: "shield.fill")
                    .foregroundColor(.green)
                
                Text("Remember: Safety first, progress second")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

/**
 * SafetyStatusView: Current safety validation status
 */
struct SafetyStatusView: View {
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Safety Status")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                SafetyStatusRow(
                    title: "Safety Education",
                    status: safetyValidator.safetyEducationCompleted ? "Complete" : "Required",
                    isValid: safetyValidator.safetyEducationCompleted
                )
                
                SafetyStatusRow(
                    title: "Medical Disclaimer",
                    status: safetyValidator.medicalDisclaimerAccepted ? "Accepted" : "Required",
                    isValid: safetyValidator.medicalDisclaimerAccepted
                )
                
                SafetyStatusRow(
                    title: "Age Verification",
                    status: safetyValidator.ageVerified ? "Verified" : "Required",
                    isValid: safetyValidator.ageVerified
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/**
 * SafetyStatusRow: Individual safety status item
 */
struct SafetyStatusRow: View {
    let title: String
    let status: String
    let isValid: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(status)
                .font(.body)
                .foregroundColor(isValid ? .green : .red)
        }
    }
}

/**
 * QuickTrainingSection: Quick access to basic training exercises
 */
struct QuickTrainingSection: View {
    @State private var showingBreathingTechniques = false
    @State private var showingBreathingSession = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Training")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                QuickTrainingCard(
                    title: "Learn Techniques",
                    subtitle: "Master breathing basics",
                    icon: "lungs.fill",
                    color: .blue
                ) {
                    showingBreathingTechniques = true
                }
                
                QuickTrainingCard(
                    title: "Start Training",
                    subtitle: "Begin breath hold session",
                    icon: "play.circle.fill",
                    color: .green
                ) {
                    showingBreathingSession = true
                }
            }
        }
        .sheet(isPresented: $showingBreathingTechniques) {
            BreathingTechniquesView()
        }
        .sheet(isPresented: $showingBreathingSession) {
            BreathingSessionView()
        }
    }
}

/**
 * QuickTrainingCard: Individual training exercise card
 */
struct QuickTrainingCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/**
 * StructuredProgramsSection: Comprehensive training programs
 */
struct StructuredProgramsSection: View {
    let userLevel: UserLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Programs")
                .font(.headline)
            
            VStack(spacing: 12) {
                ProgramCard(
                    title: "Beginner Foundation",
                    description: "4-week program for breathing basics",
                    duration: "4 weeks",
                    difficulty: "Beginner",
                    isLocked: userLevel.rawValue < UserLevel.beginner.rawValue
                )
                
                ProgramCard(
                    title: "Intermediate Development",
                    description: "Advanced techniques and longer holds",
                    duration: "6 weeks",
                    difficulty: "Intermediate",
                    isLocked: userLevel.rawValue < UserLevel.intermediate.rawValue
                )
                
                ProgramCard(
                    title: "Advanced Mastery",
                    description: "Expert-level breath control training",
                    duration: "8 weeks",
                    difficulty: "Advanced",
                    isLocked: userLevel.rawValue < UserLevel.advanced.rawValue
                )
            }
        }
    }
}

/**
 * ProgramCard: Individual training program card
 */
struct ProgramCard: View {
    let title: String
    let description: String
    let duration: String
    let difficulty: String
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isLocked ? .secondary : .primary)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if !isLocked {
                Button("Start") {
                    // Navigate to program
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isLocked ? 0.6 : 1.0)
    }
}

/**
 * ProgressOverviewSection: Quick progress overview
 */
struct ProgressOverviewSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.headline)
            
            Button(action: {
                // Navigate to detailed progress
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("View Detailed Progress")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("Track your improvement and consistency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

/**
 * SafetyAndSettingsSection: Safety and app settings
 */
struct SafetyAndSettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Safety & Settings")
                .font(.headline)
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Review Safety Education",
                    subtitle: "Refresh your safety knowledge",
                    icon: "shield.checkered",
                    color: .green
                ) {
                    // Navigate to safety education review
                }
                
                SettingsRow(
                    title: "Emergency Contacts",
                    subtitle: "Set up emergency information",
                    icon: "phone.fill",
                    color: .red
                ) {
                    // Navigate to emergency contacts
                }
                
                SettingsRow(
                    title: "App Settings",
                    subtitle: "Customize your experience",
                    icon: "gear",
                    color: .blue
                ) {
                    // Navigate to app settings
                }
            }
        }
    }
}

/**
 * SettingsRow: Individual settings row
 */
struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions

extension UserLevel {
    var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
}

#Preview {
    TrainingHomeView()
        .environmentObject(AppState())
        .environmentObject(SafetyValidator())
} 
} 