import SwiftUI

/**
 * BreathApp: Main application entry point
 * 
 * RATIONALE: Simple SwiftUI app structure chosen for MVP to get basic functionality working.
 * We'll add the comprehensive safety system in the next iteration.
 * 
 * ARCHITECTURE DECISION: Starting with minimal viable structure to test project setup,
 * then will incrementally add the full safety-first architecture we designed.
 */
@main
struct BreathApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 