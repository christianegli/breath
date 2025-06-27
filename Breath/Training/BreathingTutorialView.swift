import SwiftUI

/**
 * BreathingTutorialView: Interactive breathing technique tutorial
 * 
 * PURPOSE: Provides guided breathing technique tutorials with visual
 * animations, audio cues, and real-time instruction. Teaches proper
 * breathing form and rhythm safely.
 * 
 * SAFETY DESIGN: All tutorials are completely safe with clear instructions
 * to stop if uncomfortable. Focus on relaxation rather than performance.
 */
struct BreathingTutorialView: View {
    
    // MARK: - Properties
    
    let technique: BreathingTechnique
    let audioController: AudioController
    
    // MARK: - State
    
    @State private var isActive = false
    @State private var currentPhase: BreathingPhase?
    @State private var phaseProgress: Double = 0.0
    @State private var currentCycle = 0
    @State private var totalCycles = 0
    @State private var sessionTime: TimeInterval = 0
    @State private var showingInstructions = true
    @State private var animationScale: CGFloat = 1.0
    @State private var animationOpacity: Double = 1.0
    
    @Environment(\.dismiss) private var dismiss
    
    // Timer for tutorial progression
    @State private var tutorialTimer: Timer?
    @State private var phaseTimer: Timer?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                backgroundGradient
                
                if showingInstructions {
                    instructionsView
                } else {
                    tutorialView
                }
            }
            .navigationTitle(technique.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(isActive)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isActive {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isActive {
                        Button("Stop") {
                            stopTutorial()
                        }
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onDisappear {
            stopTutorial()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1),
                Color.blue.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Technique Overview
                techniqueOverviewSection
                
                // Instructions
                instructionsSection
                
                // Safety Notes
                safetyNotesSection
                
                // Start Button
                startButtonSection
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    private var techniqueOverviewSection: some View {
        VStack(spacing: 16) {
            
            // Technique Icon
            Image(systemName: getTechniqueIcon())
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text(technique.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(technique.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Duration and Difficulty
            HStack(spacing: 20) {
                InfoPillView(
                    icon: "clock",
                    text: "\(Int(technique.duration / 60)) minutes",
                    color: .blue
                )
                
                InfoPillView(
                    icon: "star.fill",
                    text: technique.difficulty.displayName,
                    color: .green
                )
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("How to Practice")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(technique.instructions.enumerated()), id: \.offset) { index, instruction in
                    InstructionRowView(
                        number: index + 1,
                        instruction: instruction
                    )
                }
            }
        }
    }
    
    private var safetyNotesSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                Text("Safety Guidelines")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(technique.safetyNotes)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("Remember: This is about relaxation, not performance. Stop immediately if you feel dizzy, lightheaded, or uncomfortable.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var startButtonSection: some View {
        VStack(spacing: 16) {
            
            Button(action: startTutorial) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Tutorial")
                        .fontWeight(.semibold)
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Text("Audio guidance will help you follow the rhythm")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Tutorial View
    
    private var tutorialView: some View {
        VStack(spacing: 40) {
            
            // Progress and Stats
            tutorialHeaderSection
            
            // Main Breathing Animation
            breathingAnimationSection
            
            // Current Phase Indicator
            phaseIndicatorSection
            
            // Progress Bar
            progressSection
            
            // Control Buttons
            controlButtonsSection
            
            Spacer()
        }
        .padding()
    }
    
    private var tutorialHeaderSection: some View {
        VStack(spacing: 12) {
            
            Text("Cycle \(currentCycle + 1) of \(totalCycles)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(formatTime(sessionTime))
                .font(.title3)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }
    
    private var breathingAnimationSection: some View {
        ZStack {
            
            // Outer breathing circle
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // Inner animated circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.6),
                            Color.blue.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(animationScale)
                .opacity(animationOpacity)
                .animation(
                    .easeInOut(duration: getCurrentPhaseDuration()),
                    value: animationScale
                )
            
            // Center instruction text
            VStack(spacing: 8) {
                if let phase = currentPhase {
                    Text(getPhaseInstruction(phase))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Get Ready")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var phaseIndicatorSection: some View {
        HStack(spacing: 20) {
            ForEach(getPhaseSequence(), id: \.type) { phase in
                PhaseIndicatorView(
                    phase: phase,
                    isActive: currentPhase?.type == phase.type,
                    progress: currentPhase?.type == phase.type ? phaseProgress : 0
                )
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 8) {
            
            ProgressView(value: Double(currentCycle), total: Double(totalCycles))
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(y: 2)
            
            Text("Overall Progress")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var controlButtonsSection: some View {
        HStack(spacing: 20) {
            
            Button(action: stopTutorial) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red)
                .cornerRadius(25)
            }
            
            Spacer()
            
            Button(action: pauseResumeTutorial) {
                HStack {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                    Text(isActive ? "Pause" : "Resume")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
    }
    
    // MARK: - Tutorial Control Methods
    
    private func startTutorial() {
        showingInstructions = false
        isActive = true
        currentCycle = 0
        sessionTime = 0
        
        // Calculate total cycles based on technique duration
        let cycleTime = getTotalCycleTime()
        totalCycles = max(1, Int(technique.duration / cycleTime))
        
        // Start the tutorial
        startNextCycle()
        
        // Start session timer
        tutorialTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            sessionTime += 1
        }
    }
    
    private func stopTutorial() {
        isActive = false
        currentPhase = nil
        phaseProgress = 0
        
        // Stop timers
        tutorialTimer?.invalidate()
        tutorialTimer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
        
        // Stop audio
        Task {
            await audioController.stopAllAudio()
        }
        
        // Reset animation
        animationScale = 1.0
        animationOpacity = 1.0
    }
    
    private func pauseResumeTutorial() {
        if isActive {
            // Pause
            isActive = false
            tutorialTimer?.invalidate()
            phaseTimer?.invalidate()
            
            Task {
                await audioController.stopAllAudio()
            }
        } else {
            // Resume
            isActive = true
            
            // Restart session timer
            tutorialTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                sessionTime += 1
            }
            
            // Continue current phase or start next cycle
            if currentPhase != nil {
                continueCurrentPhase()
            } else {
                startNextCycle()
            }
        }
    }
    
    private func startNextCycle() {
        guard currentCycle < totalCycles else {
            completeTutorial()
            return
        }
        
        let phases = getPhaseSequence()
        guard !phases.isEmpty else { return }
        
        startPhase(phases[0], phaseIndex: 0, allPhases: phases)
    }
    
    private func startPhase(_ phase: BreathingPhase, phaseIndex: Int, allPhases: [BreathingPhase]) {
        guard isActive else { return }
        
        currentPhase = phase
        phaseProgress = 0
        
        // Set animation for phase
        setAnimationForPhase(phase)
        
        // Speak phase instruction
        Task {
            let instruction = getPhaseInstruction(phase)
            await audioController.speakText(instruction)
        }
        
        // Start phase timer
        let phaseDuration = TimeInterval(phase.duration)
        let updateInterval = 0.1
        let totalUpdates = Int(phaseDuration / updateInterval)
        var currentUpdate = 0
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            currentUpdate += 1
            phaseProgress = Double(currentUpdate) / Double(totalUpdates)
            
            if currentUpdate >= totalUpdates {
                timer.invalidate()
                
                // Move to next phase or next cycle
                let nextPhaseIndex = phaseIndex + 1
                if nextPhaseIndex < allPhases.count {
                    startPhase(allPhases[nextPhaseIndex], phaseIndex: nextPhaseIndex, allPhases: allPhases)
                } else {
                    // Cycle complete
                    currentCycle += 1
                    currentPhase = nil
                    phaseProgress = 0
                    
                    // Short pause between cycles
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        startNextCycle()
                    }
                }
            }
        }
    }
    
    private func continueCurrentPhase() {
        guard let phase = currentPhase else {
            startNextCycle()
            return
        }
        
        let phases = getPhaseSequence()
        if let phaseIndex = phases.firstIndex(where: { $0.type == phase.type }) {
            startPhase(phase, phaseIndex: phaseIndex, allPhases: phases)
        }
    }
    
    private func completeTutorial() {
        isActive = false
        
        // Stop timers
        tutorialTimer?.invalidate()
        phaseTimer?.invalidate()
        
        Task {
            await audioController.speakText("Tutorial complete. Well done!")
        }
        
        // Show completion message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            dismiss()
        }
    }
    
    // MARK: - Animation Methods
    
    private func setAnimationForPhase(_ phase: BreathingPhase) {
        switch phase.type {
        case .inhale:
            animationScale = 1.3
            animationOpacity = 0.8
        case .hold:
            animationScale = 1.3
            animationOpacity = 1.0
        case .exhale:
            animationScale = 0.7
            animationOpacity = 0.4
        case .pause:
            animationScale = 1.0
            animationOpacity = 0.6
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTechniqueIcon() -> String {
        switch technique.name {
        case "Box Breathing":
            return "square"
        case "Diaphragmatic Breathing":
            return "lungs.fill"
        default:
            return "wind"
        }
    }
    
    private func getPhaseSequence() -> [BreathingPhase] {
        switch technique.pattern {
        case .box(let inhale, let hold, let exhale, let pause):
            return [
                BreathingPhase(type: .inhale, duration: inhale, instruction: "Breathe In"),
                BreathingPhase(type: .hold, duration: hold, instruction: "Hold"),
                BreathingPhase(type: .exhale, duration: exhale, instruction: "Breathe Out"),
                BreathingPhase(type: .pause, duration: pause, instruction: "Pause")
            ]
            
        case .diaphragmatic(let inhale, let exhale):
            return [
                BreathingPhase(type: .inhale, duration: inhale, instruction: "Breathe In Deeply"),
                BreathingPhase(type: .exhale, duration: exhale, instruction: "Breathe Out Slowly")
            ]
            
        case .relaxation(let inhale, let exhale):
            return [
                BreathingPhase(type: .inhale, duration: inhale, instruction: "Inhale Gently"),
                BreathingPhase(type: .exhale, duration: exhale, instruction: "Exhale Completely")
            ]
            
        case .custom(let phases):
            return phases
        }
    }
    
    private func getPhaseInstruction(_ phase: BreathingPhase) -> String {
        return phase.instruction
    }
    
    private func getCurrentPhaseDuration() -> Double {
        guard let phase = currentPhase else { return 1.0 }
        return Double(phase.duration)
    }
    
    private func getTotalCycleTime() -> TimeInterval {
        let phases = getPhaseSequence()
        return TimeInterval(phases.reduce(0) { $0 + $1.duration })
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views

/**
 * InfoPillView: Small info pill with icon and text
 */
struct InfoPillView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

/**
 * InstructionRowView: Numbered instruction row
 */
struct InstructionRowView: View {
    let number: Int
    let instruction: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(instruction)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

/**
 * PhaseIndicatorView: Shows current breathing phase
 */
struct PhaseIndicatorView: View {
    let phase: BreathingPhase
    let isActive: Bool
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        isActive ? Color.blue : Color.gray.opacity(0.5),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: getPhaseIcon())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isActive ? .blue : .gray)
            }
            
            Text(phase.type.rawValue.capitalized)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundColor(isActive ? .blue : .gray)
        }
    }
    
    private func getPhaseIcon() -> String {
        switch phase.type {
        case .inhale: return "arrow.up"
        case .hold: return "pause"
        case .exhale: return "arrow.down"
        case .pause: return "stop"
        }
    }
}

// MARK: - Preview

struct BreathingTutorialView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingTutorialView(
            technique: BreathingTechnique.defaultTechniques[0],
            audioController: AudioController()
        )
    }
} 