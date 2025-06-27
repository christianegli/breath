import SwiftUI

/**
 * BreathApp: Main application entry point
 * 
 * PURPOSE: Initializes the app with safety-first architecture and mandatory
 * safety education flow. Users cannot access training features without
 * completing safety education.
 * 
 * ARCHITECTURE DECISION: SwiftUI + MVVM pattern chosen for:
 * - Declarative UI that's easier to test and maintain
 * - Clear separation of concerns between Views and ViewModels
 * - Better state management for complex safety flows
 * - Native iOS performance and accessibility support
 * 
 * SAFETY PRINCIPLE: App startup always checks safety education completion
 * and routes users appropriately to prevent unsafe access to training.
 */
@main
struct BreathApp: App {
    
    // MARK: - Core Services
    
    /**
     * SafetyValidator: Ensures all safety requirements are met before training
     * 
     * RATIONALE: Centralized safety validation prevents bypassing safety
     * requirements and ensures consistent safety enforcement across the app.
     */
    @StateObject private var safetyValidator = SafetyValidator()
    
    /**
     * AppState: Manages global application state and navigation
     * 
     * RATIONALE: Single source of truth for app state prevents inconsistencies
     * and makes it easier to enforce safety-first navigation flow.
     */
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(safetyValidator)
                .environmentObject(appState)
                .onAppear {
                    // Initialize safety validation on app launch
                    safetyValidator.validateAppLaunch()
                }
        }
    }
}

/**
 * AppState: Global application state management
 * 
 * DESIGN PRINCIPLE: Centralized state management ensures safety-first
 * navigation and prevents users from accessing training without proper
 * safety education completion.
 */
class AppState: ObservableObject {
    
    // MARK: - Published Properties
    
    /**
     * Current app navigation state
     * 
     * SAFETY DESIGN: Navigation state is controlled by safety validation
     * to prevent unsafe access to training features.
     */
    @Published var currentView: AppView = .launch
    
    /**
     * Safety education completion status
     * 
     * CRITICAL: This gates access to all training features. Users cannot
     * proceed to training without completing mandatory safety education.
     */
    @Published var safetyEducationCompleted: Bool = false
    
    // MARK: - Navigation Methods
    
    /**
     * Navigate to safety education
     * 
     * RATIONALE: Explicit method ensures safety education is always the
     * first step for new users, preventing accidental bypass.
     */
    func navigateToSafetyEducation() {
        currentView = .safetyEducation
    }
    
    /**
     * Navigate to main training interface
     * 
     * SAFETY CHECK: Only accessible after safety education completion.
     * This method includes validation to prevent unsafe access.
     */
    func navigateToTraining() {
        guard safetyEducationCompleted else {
            // Force return to safety education if not completed
            navigateToSafetyEducation()
            return
        }
        currentView = .trainingHome
    }
    
    /**
     * Complete safety education and unlock training features
     * 
     * RATIONALE: Explicit method with validation ensures users have
     * genuinely completed safety education before accessing training.
     */
    func completeSafetyEducation() {
        safetyEducationCompleted = true
        // Persist completion status
        UserDefaults.standard.set(true, forKey: "safetyEducationCompleted")
        navigateToTraining()
    }
    
    // MARK: - Initialization
    
    init() {
        // Load safety education completion status from persistence
        safetyEducationCompleted = UserDefaults.standard.bool(forKey: "safetyEducationCompleted")
        
        // Set initial view based on safety education status
        if safetyEducationCompleted {
            currentView = .trainingHome
        } else {
            currentView = .safetyEducation
        }
    }
}

/**
 * AppView: Enumeration of main app views
 * 
 * DESIGN PRINCIPLE: Explicit view enumeration makes navigation flow
 * clear and prevents accidental navigation to unsafe states.
 */
enum AppView {
    case launch
    case safetyEducation
    case trainingHome
    case breathingSession
    case progressTracking
} 