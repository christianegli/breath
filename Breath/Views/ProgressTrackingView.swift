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
                    value: get