import SwiftUI

/**
 * ContentView: Main navigation controller for the app
 * 
 * PURPOSE: Handles top-level navigation and ensures safety-first routing.
 * This view acts as the navigation coordinator, ensuring users cannot
 * access training features without completing mandatory safety education.
 * 
 * SAFETY PRINCIPLE: All navigation decisions are based on safety validation
 * status. Users are automatically routed to safety education if not completed.
 * 
 * ARCHITECTURE: Uses SwiftUI's declarative navigation with state-driven
 * view selection for predictable and testable navigation flow.
 */
struct ContentView: View {
    
    // MARK: - Environment Objects
    
    /**
     * Global app state management
     * 
     * RATIONALE: Centralized state ensures consistent navigation behavior
     * and prevents bypassing safety requirements.
     */
    @EnvironmentObject var appState: AppState
    
    /**
     * Safety validation service
     * 
     * RATIONALE: Continuous safety validation ensures users cannot access
     * unsafe features even if they attempt to bypass normal navigation.
     */
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            Group {
                // Route to appropriate view based on app state and safety validation
                switch appState.currentView {
                case .launch:
                    LaunchView()
                case .safetyEducation:
                    SafetyEducationView()
                case .trainingHome:
                    TrainingHomeView()
                case .breathingSession:
                    BreathingSessionView()
                case .progressTracking:
                    ProgressTrackingView()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            validateAndRoute()
        }
        .onChange(of: appState.safetyEducationCompleted) { _ in
            validateAndRoute()
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * Validate safety requirements and route appropriately
     * 
     * SAFETY DESIGN: This method ensures users are always routed to the
     * appropriate view based on their safety education status. It prevents
     * unsafe access by continuously validating requirements.
     * 
     * RATIONALE: Centralized routing logic makes it impossible to bypass
     * safety requirements through direct navigation or state manipulation.
     */
    private func validateAndRoute() {
        let validationResult = safetyValidator.validateUserCanTrain()
        
        switch validationResult {
        case .safetyEducationRequired:
            appState.navigateToSafetyEducation()
        case .approved:
            // User can access training features
            if appState.currentView == .launch {
                appState.navigateToTraining()
            }
        case .medicalRestriction:
            // Route to medical disclaimer and restrictions
            appState.navigateToSafetyEducation()
        case .ageRestriction:
            // Route to age verification and parental controls
            appState.navigateToSafetyEducation()
        }
    }
}

/**
 * LaunchView: Initial app launch screen
 * 
 * PURPOSE: Provides a brief launch experience while the app performs
 * safety validation and determines the appropriate initial view.
 * 
 * DESIGN: Minimal, clean interface with app branding and safety messaging.
 */
struct LaunchView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            
            // App Logo and Branding
            VStack(spacing: 16) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Breath")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Safe Breath Training")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Safety-First Messaging
            VStack(spacing: 12) {
                Text("Safety First")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Your safety is our top priority. We'll guide you through proper breathing techniques with comprehensive safety education.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Loading Indicator
            ProgressView()
                .scaleEffect(1.2)
                .padding(.top)
        }
        .padding()
        .onAppear {
            // Simulate brief launch delay for safety validation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if appState.safetyEducationCompleted {
                    appState.navigateToTraining()
                } else {
                    appState.navigateToSafetyEducation()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(SafetyValidator())
} 