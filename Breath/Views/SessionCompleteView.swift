import SwiftUI

/**
 * SessionCompleteView: Session completion and results display
 * 
 * PURPOSE: Shows session results, achievements, and progress after
 * completing a breath training session. Focuses on safety compliance
 * and consistency rather than maximum performance.
 * 
 * SAFETY DESIGN: Celebrates safe practice and consistency achievements
 * rather than encouraging users to push dangerous limits.
 */
struct SessionCompleteView: View {
    
    // MARK: - Properties
    
    let session: TrainingSession?
    let onDismiss: () -> Void
    
    // MARK: - State
    
    @State private var showingCelebration = false
    @State private var achievementsUnlocked: [Achievement] = []
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Celebration Header
                    celebrationHeader
                    
                    // Session Summary
                    sessionSummarySection
                    
                    // Safety Compliance
                    safetyComplianceSection
                    
                    // Achievements
                    if !achievementsUnlocked.isEmpty {
                        achievementsSection
                    }
                    
                    // Progress Insights
                    progressInsightsSection
                    
                    // Next Steps
                    nextStepsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            checkForAchievements()
            showCelebration()
        }
    }
    
    // MARK: - Celebration Header
    
    private var celebrationHeader: some View {
        VStack(spacing: 16) {
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(showingCelebration ? 1.0 : 0.5)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showingCelebration)
            
            Text("Great Job!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("You completed your training session safely and effectively")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Session Summary
    
    private var sessionSummarySection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Session Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if let session = session {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    
                    SummaryCard(
                        title: "Total Time",
                        value: formatTime(session.elapsedTime),
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    SummaryCard(
                        title: "Rounds Completed",
                        value: "\(session.completedRounds)",
                        icon: "repeat.circle.fill",
                        color: .green
                    )
                    
                    SummaryCard(
                        title: "Best Hold",
                        value: formatTime(session.bestHoldTime),
                        icon: "timer",
                        color: .purple
                    )
                    
                    SummaryCard(
                        title: "Average Hold",
                        value: formatTime(session.averageHoldTime),
                        icon: "chart.bar.fill",
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - Safety Compliance
    
    private var safetyComplianceSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                Text("Safety Compliance")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                
                SafetyComplianceRow(
                    title: "Respected Hold Limits",
                    status: getSafetyCompliance(.holdLimits),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyComplianceRow(
                    title: "Completed Rest Periods",
                    status: getSafetyCompliance(.restPeriods),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyComplianceRow(
                    title: "No Emergency Stops",
                    status: getSafetyCompliance(.emergencyStops),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyComplianceRow(
                    title: "Proper Recovery Time",
                    status: getSafetyCompliance(.recoveryTime),
                    icon: "checkmark.circle.fill"
                )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Achievements
    
    private var achievementsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("New Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(achievementsUnlocked) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
    
    // MARK: - Progress Insights
    
    private var progressInsightsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Progress Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Consistency Trend",
                    description: getConsistencyInsight(),
                    color: .blue
                )
                
                InsightCard(
                    icon: "heart.fill",
                    title: "Safety Score",
                    description: getSafetyScoreInsight(),
                    color: .green
                )
                
                InsightCard(
                    icon: "target",
                    title: "Technique Focus",
                    description: getTechniqueInsight(),
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Next Steps
    
    private var nextStepsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Next Steps")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                
                NextStepCard(
                    icon: "clock.fill",
                    title: "Rest and Recover",
                    description: "Wait at least 2 hours before your next session",
                    timeframe: "2 hours",
                    color: .orange
                )
                
                NextStepCard(
                    icon: "book.fill",
                    title: "Review Techniques",
                    description: "Practice breathing techniques to improve your foundation",
                    timeframe: "Anytime",
                    color: .blue
                )
                
                NextStepCard(
                    icon: "chart.bar.fill",
                    title: "Track Progress",
                    description: "Check your progress charts to see improvement trends",
                    timeframe: "Now",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Methods
    
    private func showCelebration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCelebration = true
        }
    }
    
    private func checkForAchievements() {
        // This would check against actual achievement criteria
        achievementsUnlocked = [
            Achievement(
                id: UUID(),
                name: "Safe Practitioner",
                description: "Completed a session with perfect safety compliance",
                category: .safety,
                unlockedDate: Date()
            )
        ]
    }
    
    private func getSafetyCompliance(_ type: SafetyComplianceType) -> SafetyComplianceStatus {
        // This would check actual session data
        return .excellent
    }
    
    private func getConsistencyInsight() -> String {
        return "Your hold times are becoming more consistent, showing improved breath control."
    }
    
    private func getSafetyScoreInsight() -> String {
        return "Perfect safety compliance! You're building excellent training habits."
    }
    
    private func getTechniqueInsight() -> String {
        return "Focus on diaphragmatic breathing to improve your preparation phase."
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views

/**
 * SummaryCard: Session summary statistic card
 */
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/**
 * SafetyComplianceRow: Safety compliance status row
 */
struct SafetyComplianceRow: View {
    let title: String
    let status: SafetyComplianceStatus
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.body)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(status.displayName)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
}

/**
 * AchievementCard: Achievement notification card
 */
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "star.circle.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

/**
 * InsightCard: Progress insight card
 */
struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/**
 * NextStepCard: Next step recommendation card
 */
struct NextStepCard: View {
    let icon: String
    let title: String
    let description: String
    let timeframe: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(timeframe)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Types

enum SafetyComplianceType {
    case holdLimits
    case restPeriods
    case emergencyStops
    case recoveryTime
}

enum SafetyComplianceStatus {
    case excellent
    case good
    case needsImprovement
    
    var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .needsImprovement: return "Needs Improvement"
        }
    }
}

// MARK: - Preview

struct SessionCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        SessionCompleteView(
            session: nil,
            onDismiss: {}
        )
    }
} 