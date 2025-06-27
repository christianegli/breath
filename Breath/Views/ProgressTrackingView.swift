import SwiftUI
import Charts

/**
 * ProgressTrackingView: Comprehensive progress tracking and analytics
 * 
 * PURPOSE: Provides detailed progress tracking, statistics, and achievements
 * with a safety-first approach that celebrates consistency and proper technique
 * rather than encouraging users to push dangerous limits.
 * 
 * SAFETY DESIGN: All metrics and gamification focus on consistency, safety
 * compliance, and gradual improvement rather than maximum performance.
 */
struct ProgressTrackingView: View {
    
    // MARK: - Dependencies
    
    @StateObject private var progressCalculator = ProgressCalculator()
    @StateObject private var dataStore = DataStore()
    @EnvironmentObject private var safetyValidator: SafetyValidator
    
    // MARK: - State
    
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var progressData: ProgressData?
    @State private var achievements: [Achievement] = []
    @State private var showingAchievementDetail: Achievement?
    @State private var showingStatsDetail = false
    @State private var isLoading = true
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Overview Section
                    overviewSection
                    
                    // Progress Charts
                    progressChartsSection
                    
                    // Achievement Gallery
                    achievementGallerySection
                    
                    // Statistics Dashboard
                    statisticsDashboardSection
                    
                    // Safety Compliance
                    safetyComplianceSection
                    
                    // Insights and Recommendations
                    insightsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Details") {
                        showingStatsDetail = true
                    }
                }
            }
            .refreshable {
                await loadProgressData()
            }
        }
        .sheet(item: $showingAchievementDetail) { achievement in
            AchievementDetailView(achievement: achievement)
        }
        .sheet(isPresented: $showingStatsDetail) {
            DetailedStatsView(progressData: progressData)
        }
        .onAppear {
            Task {
                await loadProgressData()
            }
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            
            // Progress Summary Cards
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                
                OverviewCard(
                    title: "Current Streak",
                    value: "\(getCurrentStreak()) days",
                    subtitle: "Consistent practice",
                    icon: "flame.fill",
                    color: .orange,
                    trend: getStreakTrend()
                )
                
                OverviewCard(
                    title: "Safety Score",
                    value: "\(Int(getSafetyScore() * 100))%",
                    subtitle: "Perfect compliance",
                    icon: "shield.checkered",
                    color: .green,
                    trend: .stable
                )
                
                OverviewCard(
                    title: "Total Sessions",
                    value: "\(getTotalSessions())",
                    subtitle: "Training completed",
                    icon: "lungs.fill",
                    color: .blue,
                    trend: getTotalSessionsTrend()
                )
                
                OverviewCard(
                    title: "Experience Level",
                    value: getUserLevel().displayName,
                    subtitle: "Current proficiency",
                    icon: "star.fill",
                    color: .purple,
                    trend: .stable
                )
            }
            
            // Motivational Message
            motivationalMessageCard
        }
    }
    
    private var motivationalMessageCard: some View {
        VStack(spacing: 12) {
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Keep It Up!")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            Text(getMotivationalMessage())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Progress Charts Section
    
    private var progressChartsSection: some View {
        VStack(spacing: 16) {
            
            // Section Header
            HStack {
                Text("Progress Charts")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Timeframe Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.displayName).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            // Consistency Chart
            consistencyChart
            
            // Progress Trend Chart
            progressTrendChart
            
            // Session Duration Chart
            sessionDurationChart
        }
    }
    
    private var consistencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Consistency Tracking")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(getConsistencyPercentage())% consistent")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            if let data = getConsistencyData() {
                Chart(data) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Sessions", item.sessionCount)
                    )
                    .foregroundStyle(item.sessionCount > 0 ? .green : .gray.opacity(0.3))
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Text("No data available")
                            .foregroundColor(.secondary)
                    )
            }
            
            Text("Shows daily training consistency. Green bars indicate training days.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var progressTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Progress Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(getProgressTrendDescription())
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
            
            if let data = getProgressTrendData() {
                Chart(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Average Hold", item.averageHoldTime)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Average Hold", item.averageHoldTime)
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .number.precision(.fractionLength(0)))
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Text("Complete more sessions to see trends")
                            .foregroundColor(.secondary)
                    )
            }
            
            Text("Shows your average hold time progression over time (within safety limits).")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var sessionDurationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Session Quality")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Avg: \(getAverageSessionDuration()) min")
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .fontWeight(.medium)
            }
            
            if let data = getSessionQualityData() {
                Chart(data) { item in
                    RectangleMark(
                        x: .value("Date", item.date),
                        y: .value("Duration", item.duration),
                        width: .fixed(20),
                        height: .value("Quality", item.qualityScore * 100)
                    )
                    .foregroundStyle(getQualityColor(item.qualityScore))
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Text("Complete sessions to see quality metrics")
                            .foregroundColor(.secondary)
                    )
            }
            
            Text("Shows session duration and quality score based on safety compliance.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Achievement Gallery Section
    
    private var achievementGallerySection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(getUnlockedAchievements().count)/\(Achievement.allAchievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Recent Achievements
            if !getRecentAchievements().isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Recently Unlocked")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(getRecentAchievements().prefix(3)) { achievement in
                            AchievementRowView(achievement: achievement) {
                                showingAchievementDetail = achievement
                            }
                        }
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Achievement Categories
            achievementCategoriesGrid
        }
    }
    
    private var achievementCategoriesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            
            ForEach(AchievementCategory.allCases, id: \.self) { category in
                AchievementCategoryCard(
                    category: category,
                    unlockedCount: getUnlockedCount(for: category),
                    totalCount: getTotalCount(for: category)
                )
            }
        }
    }
    
    // MARK: - Statistics Dashboard Section
    
    private var statisticsDashboardSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("View All") {
                    showingStatsDetail = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                
                StatCard(
                    title: "Total Training Time",
                    value: formatDuration(getTotalTrainingTime()),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Average Hold Time",
                    value: "\(Int(getAverageHoldTime()))s",
                    icon: "timer",
                    color: .green
                )
                
                StatCard(
                    title: "Longest Safe Hold",
                    value: "\(Int(getLongestSafeHold()))s",
                    icon: "target",
                    color: .purple
                )
                
                StatCard(
                    title: "Consistency Rate",
                    value: "\(getConsistencyPercentage())%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Safety Compliance Section
    
    private var safetyComplianceSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Safety Compliance")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(Int(getSafetyScore() * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 12) {
                
                SafetyMetricRow(
                    title: "Respected Hold Limits",
                    score: getSafetyMetric(.holdLimits),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyMetricRow(
                    title: "Completed Rest Periods",
                    score: getSafetyMetric(.restPeriods),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyMetricRow(
                    title: "No Emergency Stops",
                    score: getSafetyMetric(.emergencyStops),
                    icon: "checkmark.circle.fill"
                )
                
                SafetyMetricRow(
                    title: "Proper Session Spacing",
                    score: getSafetyMetric(.sessionSpacing),
                    icon: "checkmark.circle.fill"
                )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            Text("Perfect safety compliance builds the foundation for long-term progress and prevents injury.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Insights & Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(getPersonalizedInsights(), id: \.id) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadProgressData() async {
        isLoading = true
        
        do {
            // Load progress data from services
            let sessions = await dataStore.getAllSessions()
            let userAchievements = await dataStore.getUserAchievements()
            
            await MainActor.run {
                self.progressData = progressCalculator.calculateProgress(
                    sessions: sessions,
                    timeframe: selectedTimeframe
                )
                self.achievements = userAchievements
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentStreak() -> Int {
        return progressData?.currentStreak ?? 0
    }
    
    private func getStreakTrend() -> TrendDirection {
        guard let data = progressData else { return .stable }
        return data.currentStreak > data.previousStreak ? .up : 
               data.currentStreak < data.previousStreak ? .down : .stable
    }
    
    private func getSafetyScore() -> Double {
        return progressData?.safetyScore ?? 1.0
    }
    
    private func getTotalSessions() -> Int {
        return progressData?.totalSessions ?? 0
    }
    
    private func getTotalSessionsTrend() -> TrendDirection {
        return .up // Always trending up as users complete more sessions
    }
    
    private func getUserLevel() -> UserExperienceLevel {
        return progressData?.experienceLevel ?? .beginner
    }
    
    private func getMotivationalMessage() -> String {
        let streak = getCurrentStreak()
        let safetyScore = getSafetyScore()
        
        if safetyScore >= 0.95 && streak >= 7 {
            return "Outstanding! You're maintaining perfect safety while building an excellent training habit. Your consistency is the key to long-term success."
        } else if safetyScore >= 0.9 {
            return "Great safety compliance! You're building excellent training habits. Keep focusing on consistency over intensity."
        } else if streak >= 3 {
            return "Nice streak! Consistency is more valuable than intensity. Keep up the regular practice."
        } else {
            return "Every session counts! Focus on building a consistent habit with perfect safety compliance."
        }
    }
    
    private func getConsistencyPercentage() -> Int {
        return Int((progressData?.consistencyRate ?? 0) * 100)
    }
    
    private func getConsistencyData() -> [ConsistencyDataPoint]? {
        return progressData?.consistencyData
    }
    
    private func getProgressTrendData() -> [ProgressDataPoint]? {
        return progressData?.progressTrendData
    }
    
    private func getProgressTrendDescription() -> String {
        guard let trend = progressData?.progressTrend else { return "Building foundation" }
        
        switch trend {
        case .improving: return "Improving steadily"
        case .stable: return "Consistent performance"
        case .needsAttention: return "Focus on consistency"
        }
    }
    
    private func getSessionQualityData() -> [SessionQualityDataPoint]? {
        return progressData?.sessionQualityData
    }
    
    private func getQualityColor(_ score: Double) -> Color {
        if score >= 0.8 { return .green }
        else if score >= 0.6 { return .orange }
        else { return .red }
    }
    
    private func getAverageSessionDuration() -> Int {
        return Int((progressData?.averageSessionDuration ?? 0) / 60)
    }
    
    private func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    private func getRecentAchievements() -> [Achievement] {
        let recent = getUnlockedAchievements().filter {
            Calendar.current.isDate($0.unlockedDate, inSameDayAs: Date()) ||
            Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.contains($0.unlockedDate) == true
        }
        return Array(recent.sorted { $0.unlockedDate > $1.unlockedDate }.prefix(5))
    }
    
    private func getUnlockedCount(for category: AchievementCategory) -> Int {
        return getUnlockedAchievements().filter { $0.category == category }.count
    }
    
    private func getTotalCount(for category: AchievementCategory) -> Int {
        return Achievement.allAchievements.filter { $0.category == category }.count
    }
    
    private func getTotalTrainingTime() -> TimeInterval {
        return progressData?.totalTrainingTime ?? 0
    }
    
    private func getAverageHoldTime() -> TimeInterval {
        return progressData?.averageHoldTime ?? 0
    }
    
    private func getLongestSafeHold() -> TimeInterval {
        return progressData?.longestSafeHold ?? 0
    }
    
    private func getSafetyMetric(_ type: SafetyMetricType) -> Double {
        switch type {
        case .holdLimits: return progressData?.safetyMetrics.holdLimitsCompliance ?? 1.0
        case .restPeriods: return progressData?.safetyMetrics.restPeriodsCompliance ?? 1.0
        case .emergencyStops: return progressData?.safetyMetrics.emergencyStopsAvoidance ?? 1.0
        case .sessionSpacing: return progressData?.safetyMetrics.sessionSpacingCompliance ?? 1.0
        }
    }
    
    private func getPersonalizedInsights() -> [PersonalizedInsight] {
        return progressData?.personalizedInsights ?? []
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct OverviewCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: trend.iconName)
                    .foregroundColor(trend.color)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
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

struct AchievementRowView: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: achievement.iconName)
                    .foregroundColor(.yellow)
                    .font(.title3)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(achievement.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if achievement.isRare {
                    Text("RARE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AchievementCategoryCard: View {
    let category: AchievementCategory
    let unlockedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.iconName)
                .foregroundColor(category.color)
                .font(.title2)
            
            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("\(unlockedCount)/\(totalCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SafetyMetricRow: View {
    let title: String
    let score: Double
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
            
            Text("\(Int(score * 100))%")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
}

struct InsightCard: View {
    let insight: PersonalizedInsight
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: insight.iconName)
                .foregroundColor(insight.color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(insight.description)
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

enum TimeFrame: String, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "3 Months"
        case .year: return "Year"
        }
    }
}

enum TrendDirection {
    case up
    case down
    case stable
    
    var iconName: String {
        switch self {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .stable: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .stable: return .gray
        }
    }
}

enum SafetyMetricType {
    case holdLimits
    case restPeriods
    case emergencyStops
    case sessionSpacing
}

// MARK: - Preview

struct ProgressTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTrackingView()
            .environmentObject(SafetyValidator())
    }
} 