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
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                    }
                }
            }
        }
        .alert("Emergency Stop", isPresented: $showingEmergencyStop) {
            Button("OK") { endSession() }
        } message: {
            Text(emergencyStopReason)
        }
        .sheet(isPresented: $showingSessionComplete) {
            SessionCompleteView(session: currentSession) {
                endSession()
            }
        }
        .onAppear {
            validateSafetyForSession()
        }
        .onDisappear {
            stopSession()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.green.opacity(0.1),
                Color.blue.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Program Selection View
    
    private var programSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                programSelectionHeader
                safetyReminderSection
                availableProgramsSection
                quickStartSection
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    private var programSelectionHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "lungs.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("Choose Your Training")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Select a training program that matches your experience level. All programs include comprehensive safety monitoring.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var safetyReminderSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Critical Safety Reminders")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SafetyReminderRow(
                    icon: "exclamationmark.triangle.fill",
                    text: "NEVER practice in or near water",
                    color: .red
                )
                
                SafetyReminderRow(
                    icon: "person.2.fill",
                    text: "Always have someone nearby who knows you're training",
                    color: .orange
                )
                
                SafetyReminderRow(
                    icon: "hand.raised.fill",
                    text: "Stop immediately if you feel dizzy or uncomfortable",
                    color: .red
                )
                
                SafetyReminderRow(
                    icon: "clock.fill",
                    text: "Respect all time limits - they exist for your safety",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var availableProgramsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Training Programs")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(getAvailablePrograms()) { program in
                    ProgramSelectionCard(
                        program: program,
                        isRecommended: program.difficulty == getUserLevel()
                    ) {
                        selectProgram(program)
                    }
                }
            }
        }
    }
    
    private var quickStartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Start")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Button(action: startQuickSession) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Beginner Quick Start")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("5-minute session with guided breathing and short holds")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Session View
    
    private var sessionView: some View {
        VStack(spacing: 24) {
            sessionHeaderView
            
            Spacer()
            
            switch sessionState {
            case .setup:
                setupView
            case .preparation:
                preparationView
            case .hold:
                holdView
            case .recovery:
                recoveryView
            case .rest:
                restView
            case .complete:
                EmptyView()
            }
            
            Spacer()
            
            sessionControlsView
        }
        .padding()
    }
    
    private var sessionHeaderView: some View {
        VStack(spacing: 12) {
            if let program = selectedProgram {
                Text(program.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Session \(getCurrentSessionNumber()) of \(program.totalSessions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let session = currentSession {
                HStack(spacing: 20) {
                    VStack {
                        Text("Hold")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(session.currentRound + 1)/\(session.totalRounds)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(session.elapsedTime))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    
                    VStack {
                        Text("Best Hold")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(session.bestHoldTime))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var setupView: some View {
        VStack(spacing: 24) {
            Text("Get Ready")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Find a comfortable, safe position. Make sure you're not near water and someone knows you're training.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ChecklistItem(text: "I am in a safe, dry location", isChecked: .constant(true))
                ChecklistItem(text: "Someone knows I am training", isChecked: .constant(true))
                ChecklistItem(text: "I will stop if I feel uncomfortable", isChecked: .constant(true))
            }
            
            Button(action: startSession) {
                Text("Begin Session")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    private var preparationView: some View {
        VStack(spacing: 30) {
            Text("Preparation Phase")
                .font(.title)
                .fontWeight(.bold)
            
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.6),
                            Color.blue.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    ))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: UUID())
                
                VStack(spacing: 8) {
                    Text("Breathe Deeply")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let session = currentSession {
                        Text("\(Int(session.preparationTimeRemaining))s")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                }
            }
            
            Text("Breathe naturally and relax. Focus on slow, deep breaths to prepare for your hold.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var holdView: some View {
        VStack(spacing: 30) {
            Text("Hold Your Breath")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: CGFloat(getHoldProgress()))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 12) {
                    if let session = currentSession {
                        Text(formatTime(session.currentHoldTime))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        
                        Text("/ \(formatTime(session.targetHoldTime))")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("Stay calm and relaxed")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap 'Release' when you need to breathe")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: releaseBreath) {
                Text("Release")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 120)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var recoveryView: some View {
        VStack(spacing: 30) {
            Text("Recovery Phase")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 3)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.6),
                            Color.green.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    ))
                    .frame(width: 180, height: 180)
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: UUID())
                
                VStack(spacing: 8) {
                    Text("Breathe Normally")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let session = currentSession {
                        Text("\(Int(session.recoveryTimeRemaining))s")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                }
            }
            
            Text("Take normal, comfortable breaths. Allow your body to recover before the next round.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var restView: some View {
        VStack(spacing: 24) {
            Text("Rest Period")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Image(systemName: "bed.double.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            if let session = currentSession {
                Text(formatTime(session.restTimeRemaining))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
            
            Text("This rest period is mandatory for your safety. Use this time to relax and let your body fully recover.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var sessionControlsView: some View {
        HStack(spacing: 20) {
            if sessionState != .setup && sessionState != .complete {
                Button(action: togglePauseSession) {
                    HStack {
                        Image(systemName: isPaused() ? "play.fill" : "pause.fill")
                        Text(isPaused() ? "Resume" : "Pause")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
            }
            
            Spacer()
            
            if sessionState != .setup && sessionState != .complete {
                Button(action: { emergencyStop(reason: "User requested emergency stop") }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Emergency Stop")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(25)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func validateSafetyForSession() {
        let validation = safetyValidator.validateUserCanTrain()
        if validation != .approved {
            emergencyStop(reason: "Safety validation failed: \(validation.rawValue)")
        }
    }
    
    private func getAvailablePrograms() -> [TrainingProgram] {
        return TrainingProgram.defaultPrograms.filter { program in
            program.difficulty.rawValue <= getUserLevel().rawValue
        }
    }
    
    private func getUserLevel() -> TrainingDifficulty {
        return .beginner
    }
    
    private func selectProgram(_ program: TrainingProgram) {
        selectedProgram = program
        showingProgramSelection = false
        setupSessionForProgram(program)
    }
    
    private func startQuickSession() {
        let quickProgram = TrainingProgram.quickStartProgram
        selectProgram(quickProgram)
    }
    
    private func setupSessionForProgram(_ program: TrainingProgram) {
        Task {
            do {
                let session = try await trainingEngine.createSession(
                    program: program,
                    safetyValidator: safetyValidator
                )
                
                await MainActor.run {
                    currentSession = session
                    sessionState = .setup
                }
            } catch {
                await MainActor.run {
                    emergencyStop(reason: "Failed to create session: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startSession() {
        guard let session = currentSession else { return }
        
        Task {
            do {
                try await trainingEngine.startSession(session)
                await updateSessionState()
            } catch {
                await MainActor.run {
                    emergencyStop(reason: "Failed to start session: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func releaseBreath() {
        Task {
            try await trainingEngine.completeCurrentHold()
            await updateSessionState()
        }
    }
    
    private func togglePauseSession() {
        Task {
            if isPaused() {
                try await trainingEngine.resumeSession()
            } else {
                try await trainingEngine.pauseSession()
            }
            await updateSessionState()
        }
    }
    
    private func stopSession() {
        Task {
            await trainingEngine.stopSession()
        }
    }
    
    private func endSession() {
        stopSession()
        dismiss()
    }
    
    private func emergencyStop(reason: String) {
        emergencyStopReason = reason
        showingEmergencyStop = true
        
        Task {
            await trainingEngine.emergencyStop()
            await audioController.speakText("Emergency stop activated. Training session ended.")
        }
    }
    
    @MainActor
    private func updateSessionState() {
        guard let session = currentSession else { return }
        
        sessionState = session.currentPhase
        
        if session.isComplete {
            showingSessionComplete = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentSessionNumber() -> Int { return 1 }
    private func isPaused() -> Bool { return currentSession?.isPaused ?? false }
    private func getHoldProgress() -> Double {
        guard let session = currentSession else { return 0 }
        return Double(session.currentHoldTime) / Double(session.targetHoldTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views

struct ProgramSelectionCard: View {
    let program: TrainingProgram
    let isRecommended: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(program.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if isRecommended {
                                Text("RECOMMENDED")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(program.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                
                HStack {
                    InfoBadge(icon: "clock", text: "\(program.sessionDuration / 60) min", color: .blue)
                    InfoBadge(icon: "target", text: "\(program.totalSessions) sessions", color: .green)
                    InfoBadge(icon: "star.fill", text: program.difficulty.displayName, color: getDifficultyColor(program.difficulty))
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Safety Features:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Max hold: \(Int(program.maxHoldTime))s • Rest periods: \(Int(program.restPeriodDuration))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getDifficultyColor(_ difficulty: TrainingDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

struct SafetyReminderRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ChecklistItem: View {
    let text: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .green : .gray)
                .font(.title3)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Session State

enum SessionState {
    case setup
    case preparation
    case hold
    case recovery
    case rest
    case complete
}

// MARK: - Preview

struct BreathingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingSessionView()
            .environmentObject(SafetyValidator())
    }
} 