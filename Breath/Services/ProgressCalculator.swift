import Foundation
import SwiftUI

/**
 * ProgressCalculator: Service for calculating and tracking user progress
 * 
 * PURPOSE: Handles all progress calculations, achievement tracking,
 * and statistical analysis of training sessions. Provides insights
 * into user improvement and safety compliance.
 * 
 * SAFETY FOCUS: All calculations prioritize safety metrics over
 * performance metrics, encouraging consistent safe practice.
 */
@MainActor
class ProgressCalculator: ObservableObject {
    
    // MARK: - Dependencies
    
    private let safetyValidator: SafetyValidator
    private let dataStore: DataStore
    
    // MARK: - Published State
    
    @Published var currentProgress: UserProgress?
    @Published var recentSessions: [TrainingSessionResult] = []
    @Published var achievements: [Achievement] = []
    @Published var weeklyStats: WeeklyStats?
    @Published var monthlyStats: MonthlyStats?
    
    // MARK: - Private State
    
    private var sessionHistory: [TrainingSessionResult] = []
    private var currentStreak: Int = 0
    private var lastCalculationDate: Date = Date()
    
    // MARK: - Initialization
    
    init(safetyValidator: SafetyValidator, dataStore: DataStore) {
        self.safetyValidator = safetyValidator
        self.dataStore = dataStore
        
        loadProgressData()
        calculateCurrentProgress()
    }
    
    // MARK: - Session Recording
    
    /**
     * Record the start of a training session
     */
    func recordSessionStart(_ session: TrainingSession) {
        // Store session start for tracking
        dataStore.saveSessionStart(session)
    }
    
    /**
     * Record completion of a training session
     * 
     * SAFETY: Calculates safety compliance and updates safety metrics
     */
    func recordSessionCompletion(_ result: TrainingSessionResult) {
        
        // Add to session history
        sessionHistory.append(result)
        recentSessions.insert(result, at: 0)
        
        // Keep only recent sessions in memory
        if recentSessions.count > 50 {
            recentSessions.removeLast()
        }
        
        // Save to persistent storage
        dataStore.saveSessionResult(result)
        
        // Update progress calculations
        calculateCurrentProgress()
        
        // Check for new achievements
        checkForNewAchievements(result)
        
        // Update streak
        updateStreak(result)
        
        // Calculate weekly/monthly stats
        updatePeriodStats()
    }
    
    /**
     * Get last completed session
     */
    func getLastSession() -> TrainingSessionResult? {
        return sessionHistory.last
    }
    
    // MARK: - Progress Calculations
    
    /**
     * Calculate current user progress
     * 
     * SAFETY PRIORITY: Emphasizes consistency and safety over performance
     */
    private func calculateCurrentProgress() {
        
        guard !sessionHistory.isEmpty else {
            currentProgress = createInitialProgress()
            return
        }
        
        let totalSessions = sessionHistory.count
        let totalTrainingTime = sessionHistory.reduce(0) { $0 + $1.totalDuration }
        let averageSessionDuration = totalTrainingTime / Double(totalSessions)
        
        // Calculate safety-focused metrics
        let safetyScore = calculateOverallSafetyScore()
        let consistencyScore = calculateConsistencyScore()
        let bestHoldTime = sessionHistory.map { $0.bestHoldTime }.max() ?? 0
        
        // Determine experience level based on progression
        let experienceLevel = determineExperienceLevel()
        
        let progress = UserProgress(
            userId: UUID(), // Would be actual user ID
            currentExperienceLevel: experienceLevel,
            totalSessions: totalSessions,
            totalTrainingTime: totalTrainingTime,
            averageSessionDuration: averageSessionDuration,
            bestHoldTime: bestHoldTime,
            currentStreak: currentStreak,
            longestStreak: calculateLongestStreak(),
            safetyScore: safetyScore,
            lastSessionDate: sessionHistory.last?.endTime,
            programsCompleted: calculateCompletedPrograms(),
            achievements: achievements
        )
        
        currentProgress = progress
    }
    
    /**
     * Calculate overall safety score
     * 
     * SAFETY CRITICAL: This is the primary metric for user evaluation
     */
    private func calculateOverallSafetyScore() -> Double {
        
        guard !sessionHistory.isEmpty else { return 1.0 }
        
        let safetyScores = sessionHistory.map { $0.safetyScore }
        let averageSafetyScore = safetyScores.reduce(0, +) / Double(safetyScores.count)
        
        // Weight recent sessions more heavily
        let recentSessions = sessionHistory.suffix(10)
        let recentSafetyScores = recentSessions.map { $0.safetyScore }
        let recentAverageSafetyScore = recentSafetyScores.reduce(0, +) / Double(recentSafetyScores.count)
        
        // Combine overall and recent scores (70% recent, 30% overall)
        return (recentAverageSafetyScore * 0.7) + (averageSafetyScore * 0.3)
    }
    
    /**
     * Calculate consistency score
     * 
     * PURPOSE: Rewards regular practice over sporadic intense sessions
     */
    private func calculateConsistencyScore() -> Double {
        
        guard sessionHistory.count >= 7 else { return 0.5 }
        
        // Calculate sessions per week over last 4 weeks
        let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        let recentSessions = sessionHistory.filter { $0.endTime >= fourWeeksAgo }
        
        let sessionsPerWeek = Double(recentSessions.count) / 4.0
        
        // Ideal is 3-4 sessions per week
        let idealSessionsPerWeek = 3.5
        let consistencyScore = 1.0 - abs(sessionsPerWeek - idealSessionsPerWeek) / idealSessionsPerWeek
        
        return max(0, min(1.0, consistencyScore))
    }
    
    /**
     * Determine user experience level based on progression
     * 
     * SAFETY: Conservative progression based on demonstrated safety compliance
     */
    private func determineExperienceLevel() -> UserExperienceLevel {
        
        guard !sessionHistory.isEmpty else { return .beginner }
        
        let totalSessions = sessionHistory.count
        let safetyScore = calculateOverallSafetyScore()
        let bestHoldTime = sessionHistory.map { $0.bestHoldTime }.max() ?? 0
        
        // Require high safety score for advancement
        guard safetyScore >= 0.9 else { return .beginner }
        
        // Advanced level requirements
        if totalSessions >= 50 && bestHoldTime >= 60 && safetyScore >= 0.95 {
            return .advanced
        }
        
        // Intermediate level requirements
        if totalSessions >= 20 && bestHoldTime >= 30 && safetyScore >= 0.9 {
            return .intermediate
        }
        
        return .beginner
    }
    
    /**
     * Calculate longest streak
     */
    private func calculateLongestStreak() -> Int {
        
        guard !sessionHistory.isEmpty else { return 0 }
        
        var longestStreak = 0
        var currentStreakCount = 0
        var lastSessionDate: Date?
        
        let sortedSessions = sessionHistory.sorted { $0.endTime < $1.endTime }
        
        for session in sortedSessions {
            let sessionDate = Calendar.current.startOfDay(for: session.endTime)
            
            if let lastDate = lastSessionDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: sessionDate).day ?? 0
                
                if daysBetween == 1 {
                    // Consecutive day
                    currentStreakCount += 1
                } else if daysBetween == 0 {
                    // Same day - don't increment streak
                    continue
                } else {
                    // Streak broken
                    longestStreak = max(longestStreak, currentStreakCount)
                    currentStreakCount = 1
                }
            } else {
                currentStreakCount = 1
            }
            
            lastSessionDate = sessionDate
        }
        
        return max(longestStreak, currentStreakCount)
    }
    
    /**
     * Calculate completed programs
     */
    private func calculateCompletedPrograms() -> [UUID] {
        
        var programCompletions: [UUID: Int] = [:]
        
        // Count sessions per program
        for session in sessionHistory {
            let programId = session.session.program.id
            programCompletions[programId, default: 0] += 1
        }
        
        // Determine which programs are completed
        var completedPrograms: [UUID] = []
        
        for (programId, sessionCount) in programCompletions {
            // Find the program to check completion criteria
            if let program = TrainingProgram.defaultPrograms.first(where: { $0.id == programId }) {
                // Consider program completed if user has done 2x the target sessions
                if sessionCount >= program.targetBreathHolds * 2 {
                    completedPrograms.append(programId)
                }
            }
        }
        
        return completedPrograms
    }
    
    // MARK: - Achievement System
    
    /**
     * Check for new achievements after session completion
     * 
     * SAFETY FOCUS: Achievements reward safety compliance and consistency
     */
    private func checkForNewAchievements(_ result: TrainingSessionResult) {
        
        var newAchievements: [Achievement] = []
        
        // First session achievement
        if sessionHistory.count == 1 {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "First Breath",
                description: "Complete your first training session",
                iconName: "lungs.fill",
                category: .milestone,
                unlockedDate: Date(),
                isRare: false
            ))
        }
        
        // Safety achievements
        if result.safetyScore == 1.0 && !hasAchievement("Perfect Safety") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Perfect Safety",
                description: "Complete a session with perfect safety compliance",
                iconName: "shield.checkered",
                category: .safety,
                unlockedDate: Date(),
                isRare: false
            ))
        }
        
        // Consistency achievements
        if currentStreak == 7 && !hasAchievement("Week Warrior") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Week Warrior",
                description: "Complete 7 consecutive days of training",
                iconName: "calendar.badge.checkmark",
                category: .consistency,
                unlockedDate: Date(),
                isRare: true
            ))
        }
        
        if currentStreak == 30 && !hasAchievement("Monthly Master") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Monthly Master",
                description: "Complete 30 consecutive days of training",
                iconName: "star.circle.fill",
                category: .consistency,
                unlockedDate: Date(),
                isRare: true
            ))
        }
        
        // Session count milestones
        let totalSessions = sessionHistory.count
        if totalSessions == 10 && !hasAchievement("Getting Started") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Getting Started",
                description: "Complete 10 training sessions",
                iconName: "10.circle.fill",
                category: .milestone,
                unlockedDate: Date(),
                isRare: false
            ))
        }
        
        if totalSessions == 50 && !hasAchievement("Dedicated Trainer") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Dedicated Trainer",
                description: "Complete 50 training sessions",
                iconName: "50.circle.fill",
                category: .milestone,
                unlockedDate: Date(),
                isRare: true
            ))
        }
        
        // Experience level achievements
        if determineExperienceLevel() == .intermediate && !hasAchievement("Level Up") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Level Up",
                description: "Advance to Intermediate level",
                iconName: "arrow.up.circle.fill",
                category: .milestone,
                unlockedDate: Date(),
                isRare: false
            ))
        }
        
        if determineExperienceLevel() == .advanced && !hasAchievement("Expert Breather") {
            newAchievements.append(Achievement(
                id: UUID(),
                name: "Expert Breather",
                description: "Advance to Advanced level",
                iconName: "crown.fill",
                category: .milestone,
                unlockedDate: Date(),
                isRare: true
            ))
        }
        
        // Add new achievements
        achievements.append(contentsOf: newAchievements)
        
        // Save achievements
        for achievement in newAchievements {
            dataStore.saveAchievement(achievement)
        }
    }
    
    /**
     * Check if user has specific achievement
     */
    private func hasAchievement(_ name: String) -> Bool {
        return achievements.contains { $0.name == name }
    }
    
    // MARK: - Streak Management
    
    /**
     * Update training streak
     * 
     * SAFETY: Celebrates rest days as part of healthy training
     */
    private func updateStreak(_ result: TrainingSessionResult) {
        
        let today = Calendar.current.startOfDay(for: Date())
        let sessionDate = Calendar.current.startOfDay(for: result.endTime)
        
        if let lastSessionDate = sessionHistory.dropLast().last?.endTime {
            let lastDate = Calendar.current.startOfDay(for: lastSessionDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: sessionDate).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // Same day doesn't change streak
        } else {
            // First session
            currentStreak = 1
        }
    }
    
    // MARK: - Statistics Calculation
    
    /**
     * Update weekly and monthly statistics
     */
    private func updatePeriodStats() {
        
        weeklyStats = calculateWeeklyStats()
        monthlyStats = calculateMonthlyStats()
    }
    
    /**
     * Calculate weekly statistics
     */
    private func calculateWeeklyStats() -> WeeklyStats {
        
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklySessions = sessionHistory.filter { $0.endTime >= oneWeekAgo }
        
        let totalSessions = weeklySessions.count
        let totalTime = weeklySessions.reduce(0) { $0 + $1.totalDuration }
        let averageHoldTime = weeklySessions.isEmpty ? 0 : weeklySessions.map { $0.averageHoldTime }.reduce(0, +) / Double(weeklySessions.count)
        let safetyScore = weeklySessions.isEmpty ? 1.0 : weeklySessions.map { $0.safetyScore }.reduce(0, +) / Double(weeklySessions.count)
        
        return WeeklyStats(
            totalSessions: totalSessions,
            totalTime: totalTime,
            averageHoldTime: averageHoldTime,
            safetyScore: safetyScore,
            consistencyScore: calculateWeeklyConsistency(weeklySessions)
        )
    }
    
    /**
     * Calculate monthly statistics
     */
    private func calculateMonthlyStats() -> MonthlyStats {
        
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let monthlySessions = sessionHistory.filter { $0.endTime >= oneMonthAgo }
        
        let totalSessions = monthlySessions.count
        let totalTime = monthlySessions.reduce(0) { $0 + $1.totalDuration }
        let averageHoldTime = monthlySessions.isEmpty ? 0 : monthlySessions.map { $0.averageHoldTime }.reduce(0, +) / Double(monthlySessions.count)
        let safetyScore = monthlySessions.isEmpty ? 1.0 : monthlySessions.map { $0.safetyScore }.reduce(0, +) / Double(monthlySessions.count)
        let improvementRate = calculateImprovementRate(monthlySessions)
        
        return MonthlyStats(
            totalSessions: totalSessions,
            totalTime: totalTime,
            averageHoldTime: averageHoldTime,
            safetyScore: safetyScore,
            improvementRate: improvementRate,
            programsStarted: calculateProgramsStarted(monthlySessions),
            achievementsUnlocked: calculateMonthlyAchievements()
        )
    }
    
    /**
     * Calculate weekly consistency score
     */
    private func calculateWeeklyConsistency(_ sessions: [TrainingSessionResult]) -> Double {
        
        guard !sessions.isEmpty else { return 0 }
        
        // Calculate how many different days had sessions
        let sessionDates = Set(sessions.map { Calendar.current.startOfDay(for: $0.endTime) })
        let daysWithSessions = sessionDates.count
        
        // Ideal is 3-4 days per week
        let idealDays = 3.5
        let consistency = 1.0 - abs(Double(daysWithSessions) - idealDays) / idealDays
        
        return max(0, min(1.0, consistency))
    }
    
    /**
     * Calculate improvement rate over time
     */
    private func calculateImprovementRate(_ sessions: [TrainingSessionResult]) -> Double {
        
        guard sessions.count >= 5 else { return 0 }
        
        let sortedSessions = sessions.sorted { $0.endTime < $1.endTime }
        let firstHalf = sortedSessions.prefix(sessions.count / 2)
        let secondHalf = sortedSessions.suffix(sessions.count / 2)
        
        let firstHalfAverage = firstHalf.map { $0.averageHoldTime }.reduce(0, +) / Double(firstHalf.count)
        let secondHalfAverage = secondHalf.map { $0.averageHoldTime }.reduce(0, +) / Double(secondHalf.count)
        
        guard firstHalfAverage > 0 else { return 0 }
        
        return (secondHalfAverage - firstHalfAverage) / firstHalfAverage
    }
    
    /**
     * Calculate programs started this month
     */
    private func calculateProgramsStarted(_ sessions: [TrainingSessionResult]) -> Int {
        
        let programIds = Set(sessions.map { $0.session.program.id })
        return programIds.count
    }
    
    /**
     * Calculate achievements unlocked this month
     */
    private func calculateMonthlyAchievements() -> Int {
        
        let oneMonthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return achievements.filter { $0.unlockedDate >= oneMonthAgo }.count
    }
    
    // MARK: - Data Management
    
    /**
     * Load progress data from storage
     */
    private func loadProgressData() {
        
        sessionHistory = dataStore.loadSessionHistory()
        achievements = dataStore.loadAchievements()
        currentStreak = dataStore.loadCurrentStreak()
    }
    
    /**
     * Create initial progress for new user
     */
    private func createInitialProgress() -> UserProgress {
        
        return UserProgress(
            userId: UUID(),
            currentExperienceLevel: .beginner,
            totalSessions: 0,
            totalTrainingTime: 0,
            averageSessionDuration: 0,
            bestHoldTime: 0,
            currentStreak: 0,
            longestStreak: 0,
            safetyScore: 1.0,
            lastSessionDate: nil,
            programsCompleted: [],
            achievements: []
        )
    }
}

// MARK: - Supporting Statistics Types

/**
 * WeeklyStats: Weekly training statistics
 */
struct WeeklyStats {
    let totalSessions: Int
    let totalTime: TimeInterval
    let averageHoldTime: TimeInterval
    let safetyScore: Double
    let consistencyScore: Double
}

/**
 * MonthlyStats: Monthly training statistics
 */
struct MonthlyStats {
    let totalSessions: Int
    let totalTime: TimeInterval
    let averageHoldTime: TimeInterval
    let safetyScore: Double
    let improvementRate: Double
    let programsStarted: Int
    let achievementsUnlocked: Int
} 