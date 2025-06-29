import SwiftUI

/**
 * BreathApp: Main application entry point with safety-first architecture
 * 
 * RATIONALE: Integrates comprehensive SafetyValidator to ensure all users
 * complete mandatory safety education before accessing breath training features.
 * This safety-first approach prioritizes user wellbeing over feature access.
 * 
 * ARCHITECTURE DECISION: SafetyValidator is created at app level and passed
 * as environment object to ensure consistent safety validation throughout
 * the entire app lifecycle. No training features can be accessed without
 * proper safety validation.
 * 
 * CRITICAL SAFETY PRINCIPLE: The app starts in a safe state and guides users
 * through required safety steps before allowing any breath training access.
 */
@main
struct BreathApp: App {
    
    /**
     * Safety validator instance for app-wide safety enforcement
     * 
     * SAFETY DESIGN: Created at app launch to ensure safety validation
     * is available throughout the app lifecycle. StateObject ensures
     * the validator persists across view updates.
     */
    @StateObject private var safetyValidator = SafetyValidator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(safetyValidator)
                .onAppear {
                    // Validate safety requirements on app launch
                    safetyValidator.validateAppLaunch()
                }
        }
    }
} 