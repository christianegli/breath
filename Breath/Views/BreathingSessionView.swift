import SwiftUI

/**
 * BreathingSessionView: Main breath training session interface
 * 
 * PURPOSE: Provides guided breath-holding training sessions with comprehensive
 * safety validation, real-time monitoring, and emergency stop functionality.
 * This is the core training interface where users practice breath holds.
 * 
 * SAFETY DESIGN: Every aspect prioritizes user safety with hard-coded limits,
 * continuous monitoring, mandatory rest periods, and immediate emergency stops.
 */
struct BreathingSessionView: View {
    
    // MARK: - Dependencies
    
    @StateObject private var trainingEngine = TrainingEngine()
    @StateObject private var audioController = AudioController()
    @StateObject private var dataStore = DataStore()
    @EnvironmentObject private var safetyValidator: SafetyValidator
    
    // MARK: - State
    
    @State private var selectedProgram: TrainingProgram?
    @State private var currentSession: TrainingSession?
    @State private var sessionState: SessionState = .setup
    @State private var showingProgramSelection = true
    @State private var showingEmergencyStop = false
    @State private var showingSessionComplete = false
    @State private var emergencyStopReason: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                if showingProgramSelection {
                    programSelectionView
                } else {
                    sessionView
                }
            }
            .navigationTitle("Breath Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if sessionState == .setup {
                        Button("Close") { dismiss() }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if sessionState != .setup {
                        Button("Emergency Stop") {
                            emergencyStop(reason: "User requested emergency stop")
                        }
             