import SwiftUI
import Charts

/**
 * DetailedStatsView: Comprehensive statistics and analytics dashboard
 * 
 * PURPOSE: Provides in-depth analysis of user progress, performance trends,
 * and detailed metrics with a focus on safety compliance and consistency.
 * 
 * SAFETY DESIGN: All analytics emphasize safety metrics and consistent
 * practice patterns rather than encouraging maximum performance.
 */
struct DetailedStatsView: View {
    
    let progressData: ProgressData?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: StatTab = .overview
    @State private var selectedTimeRange: TimeRange = .month
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Tab Selection
                tabSelector
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        
                        switch selectedTab {
                        case .overview:
                            overviewContent
                        case .consistency:
                            consistencyContent
                        case .safety:
                            safetyContent
                        case .performance:
                            performanceContent
                        case .insights:
                            insightsContent
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Detailed Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Time Range") {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Button(range.displayName) {
                                selectedTimeRange = range
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(StatTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.title3)
                            
                            Text(tab.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: 24) {
            
            // Key Metrics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                
                MetricCard(
                    title: "Total Sessions",
                    value: "\(progressData?.totalSessions ?? 0)",
                    subtitle: "Completed",
                    icon: "lungs.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Current Streak",
                    value: "\(progressData?.currentStreak ?? 0) days",
                    subtitle: "Consistent practice",
                    icon: "flame.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Safety Score",
                    value: "\(Int((progressData?.safetyScore ?? 1.0) * 100))%",
                    subtitle: "Perfect compliance",
                    icon: "shield.checkered",
                    color: .green
                )
                
                MetricCard(
                    title: "Experience Level",
                    value: progressData?.experienceLevel.displayName ?? "Beginner",
                    subtitle: "Current proficiency",
                    icon: "star.fill",
                    color: .purple
                )
            }
            
            // Progress Summary Chart
            progressSummaryChart
            
            // Weekly Activity Heatmap
            weeklyActivityHeatmap
            
            // Quick Insights
            quickInsightsList
        }
    }
    
    // MARK: - Consistency Content
    
    private var consistencyContent: some View {
        VStack(spacing: 24) {
            
            // Consistency Metrics
            consistencyMetricsGrid
            
            // Daily Consistency Chart
            dailyConsistencyChart
            
            // Best Streaks
            bestStreaksSection
            
            // Consistency Patterns
            consistencyPatternsSection
        }
    }
    
    // MARK: - Safety Content
    
    private var safetyContent: some View {
        VStack(spacing: 24) {
            
            Text("Safety Metrics")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Detailed safety analytics coming soon")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Performance Content
    
    private var performanceContent: some View {
        VStack(spacing: 24) {
            
            Text("Performance Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Detailed performance metrics coming soon")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Insights Content
    
    private var insightsContent: some View {
        VStack(spacing: 24) {
            
            Text("Personalized Insights")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("AI-powered insights coming soon")
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Component Views
    
    private var progressSummaryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Progress Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let data = progressData?.progressTrendData {
                Chart(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Average Hold", item.averageHoldTime)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Average Hold", item.averageHoldTime)
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                }
                .frame(height: 200)
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
                    .frame(height: 200)
                    .overlay(
                        Text("Complete more sessions to see progress trends")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var weeklyActivityHeatmap: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Weekly Activity Pattern")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Simplified heatmap
            VStack(spacing: 8) {
                
                HStack {
                    Text("Mon")
                        .font(.caption)
                        .frame(width: 30)
                    ForEach(0..<7) { week in
                        Rectangle()
                            .fill(getActivityColor(for: week, day: 0))
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                    }
                }
                
                ForEach(1..<7) { day in
                    HStack {
                        Text(getDayName(day))
                            .font(.caption)
                            .frame(width: 30)
                        ForEach(0..<7) { week in
                            Rectangle()
                                .fill(getActivityColor(for: week, day: day))
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            HStack {
                Text("Less")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { intensity in
                        Rectangle()
                            .fill(Color.green.opacity(Double(intensity) * 0.2 + 0.1))
                            .frame(width: 12, height: 12)
                            .cornerRadius(2)
                    }
                }
                
                Text("More")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var quickInsightsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Quick Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(getQuickInsights(), id: \.self) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(insight)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var consistencyMetricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            
            MetricCard(
                title: "Consistency Rate",
                value: "\(Int((progressData?.consistencyRate ?? 0) * 100))%",
                subtitle: "Overall consistency",
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )
            
            MetricCard(
                title: "Best Streak",
                value: "\(progressData?.bestStreak ?? 0) days",
                subtitle: "Longest consistent period",
                icon: "flame.fill",
                color: .orange
            )
            
            MetricCard(
                title: "Active Days",
                value: "\(progressData?.activeDays ?? 0)",
                subtitle: "Days with sessions",
                icon: "calendar.badge.checkmark",
                color: .blue
            )
            
            MetricCard(
                title: "Rest Days",
                value: "\(progressData?.restDays ?? 0)",
                subtitle: "Proper recovery",
                icon: "bed.double.fill",
                color: .purple
            )
        }
    }
    
    private var dailyConsistencyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Daily Consistency")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let data = progressData?.consistencyData {
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
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Text("No consistency data available")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var bestStreaksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Best Streaks")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(getBestStreaks(), id: \.startDate) { streak in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(streak.length) days")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("\(streak.startDate.formatted(date: .abbreviated, time: .omitted)) - \(streak.endDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var consistencyPatternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Consistency Patterns")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(getConsistencyPatterns(), id: \.pattern) { pattern in
                    HStack {
                        Image(systemName: pattern.iconName)
                            .foregroundColor(pattern.color)
                            .font(.title3)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pattern.pattern)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(pattern.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(pattern.frequency * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(pattern.color)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    private func getActivityColor(for week: Int, day: Int) -> Color {
        // Simulate activity data
        let activity = Double.random(in: 0...1)
        return Color.green.opacity(activity * 0.8 + 0.1)
    }
    
    private func getDayName(_ day: Int) -> String {
        let days = ["Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return day < days.count ? days[day] : ""
    }
    
    private func getQuickInsights() -> [String] {
        guard let data = progressData else {
            return ["Complete more sessions to see personalized insights"]
        }
        
        var insights: [String] = []
        
        if data.currentStreak >= 7 {
            insights.append("Excellent consistency! You're building a strong habit.")
        }
        
        if data.safetyScore >= 0.95 {
            insights.append("Perfect safety compliance - you're training the right way.")
        }
        
        if data.consistencyRate >= 0.8 {
            insights.append("Your consistency rate is outstanding - keep it up!")
        }
        
        if insights.isEmpty {
            insights.append("Focus on building consistent daily practice for better results.")
        }
        
        return insights
    }
    
    private func getBestStreaks() -> [StreakData] {
        // Mock data - in real implementation, this would come from progressData
        return [
            StreakData(length: 14, startDate: Date().addingTimeInterval(-20 * 24 * 3600), endDate: Date().addingTimeInterval(-7 * 24 * 3600)),
            StreakData(length: 7, startDate: Date().addingTimeInterval(-35 * 24 * 3600), endDate: Date().addingTimeInterval(-29 * 24 * 3600)),
            StreakData(length: 5, startDate: Date().addingTimeInterval(-50 * 24 * 3600), endDate: Date().addingTimeInterval(-46 * 24 * 3600))
        ]
    }
    
    private func getConsistencyPatterns() -> [ConsistencyPattern] {
        return [
            ConsistencyPattern(pattern: "Morning Sessions", description: "You train most often in the morning", frequency: 0.7, iconName: "sunrise.fill", color: .orange),
            ConsistencyPattern(pattern: "Weekday Focus", description: "Higher consistency on weekdays", frequency: 0.8, iconName: "calendar.badge.checkmark", color: .blue),
            ConsistencyPattern(pattern: "Rest Day Compliance", description: "Good at taking proper rest days", frequency: 0.9, iconName: "bed.double.fill", color: .purple)
        ]
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
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

// MARK: - Supporting Types

enum StatTab: String, CaseIterable {
    case overview = "overview"
    case consistency = "consistency"
    case safety = "safety"
    case performance = "performance"
    case insights = "insights"
    
    var displayName: String {
        switch self {
        case .overview: return "Overview"
        case .consistency: return "Consistency"
        case .safety: return "Safety"
        case .performance: return "Performance"
        case .insights: return "Insights"
        }
    }
    
    var iconName: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .consistency: return "calendar.badge.checkmark"
        case .safety: return "shield.checkered"
        case .performance: return "chart.line.uptrend.xyaxis"
        case .insights: return "lightbulb.fill"
        }
    }
}

enum TimeRange: String, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .week: return "This Week"
        case .month: return "This Month"
        case .quarter: return "3 Months"
        case .year: return "This Year"
        case .all: return "All Time"
        }
    }
}

struct StreakData {
    let length: Int
    let startDate: Date
    let endDate: Date
}

struct ConsistencyPattern {
    let pattern: String
    let description: String
    let frequency: Double
    let iconName: String
    let color: Color
}

// MARK: - Preview

struct DetailedStatsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedStatsView(progressData: nil)
    }
} 