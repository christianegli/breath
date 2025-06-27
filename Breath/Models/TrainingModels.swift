import Foundation

/**
 * TrainingModels: Core data models for breath training system
 * 
 * PURPOSE: Defines the data structures for training sessions, programs,
 * progress tracking, and user experience. These models form the foundation
 * of the training system architecture.
 * 
 * SAFETY DESIGN: All models include safety-related fields and validation
 * to ensure training remains within safe parameters.
 */

// MARK: - User Experience and Safety Models

/**
 * UserExperienceLevel: User's breath training experience level
 * 
 * SAFETY CRITICAL: Determines maximum safe breath hold times and
 * available training programs. Cannot be self-reported - must be
 * validated through training progression.
 */
enum UserExperienceLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var maxSafeHoldTime: TimeInterval {
        switch self {
        case .beginner: return 30.0      // 30 seconds
        case .intermediate: return 60.0   // 1 minute
        case .advanced: return 120.0     // 2 minutes
        }
    }
    
    var description: String {
        switch self {
        case .beginner:
            return "New to breath training or breath holds under 30 seconds"
        case .intermediate:
            return "Comfortable with basic techniques, can hold breath 30-60 seconds"
        case .advanced:
            return "Experienced with breath training, can safely hold breath over 60 seconds"
        }
    }
}

// MARK: - Training Program Models

/**
 * TrainingProgram: Structured breath training program
 * 
 * PURPOSE: Defines a complete training program with progression,
 * safety limits, and educational content.
 */
struct TrainingProgram: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let requiredExperienceLevel: UserExperienceLevel
    let estimatedDuration: TimeInterval
    let targetBreathHolds: Int
    let preparationDuration: TimeInterval
    let maxHoldTime: TimeInterval
    let progressionType: ProgressionType
    let safetyNotes: String
    
    /**
     * Calculate hold time for specific round
     * 
     * SAFETY: Always respects maximum hold time for safety
     */
    func calculateHoldTime(forRound round: Int) -> TimeInterval {
        let baseTime: TimeInterval
        
        switch progressionType {
        case .fixed(let time):
            baseTime = time
            
        case .progressive(let startTime, let increment):
            baseTime = startTime + (TimeInterval(round) * increment)
            
        case .co2Table(let times):
            let index = min(round, times.count - 1)
            baseTime = times[index]
        }
        
        // Always respect maximum hold time for safety
        return min(baseTime, maxHoldTime)
    }
    
    /**
     * Default training programs
     */
    static let defaultPrograms: [TrainingProgram] = [
        
        // Beginner Programs
        TrainingProgram(
            id: UUID(),
            name: "Beginner Foundation",
            description: "Introduction to breath control with very short, safe holds",
            requiredExperienceLevel: .beginner,
            estimatedDuration: 600, // 10 minutes
            targetBreathHolds: 5,
            preparationDuration: 60, // 1 minute prep
            maxHoldTime: 15, // Start with 15 seconds max
            progressionType: .fixed(10), // 10 second holds
            safetyNotes: "Perfect for first-time users. Focus on relaxation and technique."
        ),
        
        TrainingProgram(
            id: UUID(),
            name: "Beginner Progressive",
            description: "Gradual progression from 10 to 25 seconds",
            requiredExperienceLevel: .beginner,
            estimatedDuration: 900, // 15 minutes
            targetBreathHolds: 6,
            preparationDuration: 90,
            maxHoldTime: 25,
            progressionType: .progressive(startTime: 10, increment: 3),
            safetyNotes: "Slowly builds tolerance. Stop if you feel any discomfort."
        ),
        
        // Intermediate Programs
        TrainingProgram(
            id: UUID(),
            name: "Intermediate Foundation",
            description: "Consistent 30-45 second holds for technique development",
            requiredExperienceLevel: .intermediate,
            estimatedDuration: 1200, // 20 minutes
            targetBreathHolds: 8,
            preparationDuration: 120,
            maxHoldTime: 45,
            progressionType: .fixed(35),
            safetyNotes: "Focus on maintaining calm and control throughout holds."
        ),
        
        TrainingProgram(
            id: UUID(),
            name: "CO2 Tolerance Builder",
            description: "Progressive CO2 tolerance training with fixed preparation",
            requiredExperienceLevel: .intermediate,
            estimatedDuration: 1500, // 25 minutes
            targetBreathHolds: 8,
            preparationDuration: 120,
            maxHoldTime: 60,
            progressionType: .co2Table([20, 25, 30, 35, 40, 45, 50, 55]),
            safetyNotes: "Advanced technique. Ensure you're comfortable with basic holds first."
        ),
        
        // Advanced Programs
        TrainingProgram(
            id: UUID(),
            name: "Advanced Endurance",
            description: "Extended holds for experienced practitioners",
            requiredExperienceLevel: .advanced,
            estimatedDuration: 1800, // 30 minutes
            targetBreathHolds: 6,
            preparationDuration: 180,
            maxHoldTime: 90,
            progressionType: .progressive(startTime: 45, increment: 8),
            safetyNotes: "Only for experienced users. Requires mastery of safety protocols."
        )
    ]
}

/**
 * ProgressionType: How hold times progress during a session
 */
enum ProgressionType: Codable {
    case fixed(TimeInterval)                           // Same time each round
    case progressive(startTime: TimeInterval, increment: TimeInterval) // Increasing each round
    case co2Table([TimeInterval])                      // Predefined sequence
}

/**
 * TrainingProgramProgress: User's progress through a training program
 */
struct TrainingProgramProgress: Codable {
    let programId: UUID
    let sessionsCompleted: Int
    let totalSessions: Int
    let averageHoldTime: TimeInterval
    let bestHoldTime: TimeInterval
    let safetyScore: Double
    let lastSessionDate: Date
    let isCompleted: Bool
    
    var completionPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(sessionsCompleted) / Double(totalSessions)
    }
}

// MARK: - Training Session Models

/**
 * TrainingSession: Individual training session data
 * 
 * PURPOSE: Represents a single training session with all metadata
 * needed for safety validation and progress tracking.
 */
struct TrainingSession: Identifiable, Codable {
    let id: UUID
    let program: TrainingProgram
    let startTime: Date
    let userExperienceLevel: UserExperienceLevel
    
    // Session metadata
    var endTime: Date?
    var actualDuration: TimeInterval?
    var breathHoldsCompleted: Int = 0
    var safetyEvents: [SafetyEvent] = []
    var notes: String = ""
}

/**
 * TrainingSessionResult: Complete result of a training session
 * 
 * PURPOSE: Comprehensive record of session outcome including
 * safety compliance and performance metrics.
 */
struct TrainingSessionResult: Codable {
    let session: TrainingSession
    let endTime: Date
    let totalDuration: TimeInterval
    let breathHoldsCompleted: Int
    let averageHoldTime: TimeInterval
    let safetyCompliance: SafetyCompliance
    let completionReason: SessionCompletionReason
    
    // Performance metrics
    let holdTimes: [TimeInterval]
    let restTimes: [TimeInterval]
    let safetyEvents: [SafetyEvent]
    
    // Calculated properties
    var bestHoldTime: TimeInterval {
        holdTimes.max() ?? 0
    }
    
    var consistencyScore: Double {
        guard holdTimes.count > 1 else { return 1.0 }
        let average = averageHoldTime
        let variance = holdTimes.map { pow($0 - average, 2) }.reduce(0, +) / Double(holdTimes.count)
        let standardDeviation = sqrt(variance)
        return max(0, 1.0 - (standardDeviation / average))
    }
    
    var safetyScore: Double {
        switch safetyCompliance {
        case .fullCompliance: return 1.0
        case .minorViolations: return 0.8
        case .limitsExceeded: return 0.5
        case .emergencyStop: return 0.0
        }
    }
    
    init(
        session: TrainingSession,
        endTime: Date,
        totalDuration: TimeInterval,
        breathHoldsCompleted: Int,
        averageHoldTime: TimeInterval,
        safetyCompliance: SafetyCompliance,
        completionReason: SessionCompletionReason,
        holdTimes: [TimeInterval] = [],
        restTimes: [TimeInterval] = [],
        safetyEvents: [SafetyEvent] = []
    ) {
        self.session = session
        self.endTime = endTime
        self.totalDuration = totalDuration
        self.breathHoldsCompleted = breathHoldsCompleted
        self.averageHoldTime = averageHoldTime
        self.safetyCompliance = safetyCompliance
        self.completionReason = completionReason
        self.holdTimes = holdTimes
        self.restTimes = restTimes
        self.safetyEvents = safetyEvents
    }
}

/**
 * SafetyEvent: Record of safety-related events during training
 * 
 * SAFETY CRITICAL: Tracks all safety events for analysis and
 * improvement of safety protocols.
 */
struct SafetyEvent: Codable {
    let id: UUID
    let timestamp: Date
    let eventType: SafetyEventType
    let description: String
    let severity: SafetyEventSeverity
    let userResponse: String?
    let automaticAction: String?
    
    init(
        eventType: SafetyEventType,
        description: String,
        severity: SafetyEventSeverity,
        userResponse: String? = nil,
        automaticAction: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.eventType = eventType
        self.description = description
        self.severity = severity
        self.userResponse = userResponse
        self.automaticAction = automaticAction
    }
}

/**
 * SafetyEventType: Types of safety events that can occur
 */
enum SafetyEventType: String, CaseIterable, Codable {
    case limitExceeded = "limit_exceeded"
    case userReportedDiscomfort = "user_discomfort"
    case emergencyStop = "emergency_stop"
    case sessionTerminated = "session_terminated"
    case restPeriodViolation = "rest_violation"
    case safetyValidationFailed = "validation_failed"
}

/**
 * SafetyEventSeverity: Severity levels for safety events
 */
enum SafetyEventSeverity: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Progress Tracking Models

/**
 * UserProgress: Overall user progress and statistics
 * 
 * PURPOSE: Tracks user's overall progress, achievements, and
 * safety compliance across all training sessions.
 */
struct UserProgress: Codable {
    let userId: UUID
    let currentExperienceLevel: UserExperienceLevel
    let totalSessions: Int
    let totalTrainingTime: TimeInterval
    let averageSessionDuration: TimeInterval
    let bestHoldTime: TimeInterval
    let currentStreak: Int
    let longestStreak: Int
    let safetyScore: Double
    let lastSessionDate: Date?
    let programsCompleted: [UUID]
    let achievements: [Achievement]
    
    // Calculated properties
    var sessionsThisWeek: Int {
        // Would be calculated from session history
        return 0
    }
    
    var consistencyScore: Double {
        // Would be calculated based on session frequency
        return 0.8
    }
    
    var improvementRate: Double {
        // Would be calculated from progress over time
        return 0.1
    }
}

/**
 * Achievement: User achievements and milestones
 */
struct Achievement: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let unlockedDate: Date
    let isRare: Bool
    
    static let defaultAchievements: [Achievement] = [
        Achievement(
            id: UUID(),
            name: "First Breath",
            description: "Complete your first training session",
            iconName: "lungs.fill",
            category: .milestone,
            unlockedDate: Date(),
            isRare: false
        ),
        Achievement(
            id: UUID(),
            name: "Safety First",
            description: "Complete safety education with 100% score",
            iconName: "shield.checkered",
            category: .safety,
            unlockedDate: Date(),
            isRare: false
        ),
        Achievement(
            id: UUID(),
            name: "Consistent Trainer",
            description: "Complete 7 consecutive days of training",
            iconName: "calendar.badge.checkmark",
            category: .consistency,
            unlockedDate: Date(),
            isRare: true
        )
    ]
}

/**
 * AchievementCategory: Categories for organizing achievements
 */
enum AchievementCategory: String, CaseIterable, Codable {
    case milestone = "milestone"
    case safety = "safety"
    case consistency = "consistency"
    case technique = "technique"
    case endurance = "endurance"
    case education = "education"
    
    var displayName: String {
        switch self {
        case .milestone: return "Milestones"
        case .safety: return "Safety"
        case .consistency: return "Consistency"
        case .technique: return "Technique"
        case .endurance: return "Endurance"
        case .education: return "Education"
        }
    }
}

// MARK: - Breathing Technique Models

/**
 * BreathingTechnique: Specific breathing technique definition
 * 
 * PURPOSE: Defines the parameters and guidance for different
 * breathing techniques used in training.
 */
struct BreathingTechnique: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let category: TechniqueCategory
    let difficulty: TechniqueDifficulty
    let duration: TimeInterval
    let pattern: BreathingPattern
    let instructions: [String]
    let safetyNotes: String
    let benefits: [String]
    
    static let defaultTechniques: [BreathingTechnique] = [
        BreathingTechnique(
            id: UUID(),
            name: "Box Breathing",
            description: "4-4-4-4 breathing pattern for relaxation and control",
            category: .preparation,
            difficulty: .beginner,
            duration: 240, // 4 minutes
            pattern: .box(inhale: 4, hold: 4, exhale: 4, pause: 4),
            instructions: [
                "Inhale for 4 counts",
                "Hold for 4 counts",
                "Exhale for 4 counts",
                "Pause for 4 counts",
                "Repeat the cycle"
            ],
            safetyNotes: "Completely safe for all users. Stop if you feel dizzy.",
            benefits: [
                "Reduces stress and anxiety",
                "Improves focus and concentration",
                "Builds breathing control",
                "Activates parasympathetic nervous system"
            ]
        ),
        
        BreathingTechnique(
            id: UUID(),
            name: "Diaphragmatic Breathing",
            description: "Deep belly breathing for maximum efficiency",
            category: .preparation,
            difficulty: .beginner,
            duration: 300, // 5 minutes
            pattern: .diaphragmatic(inhale: 6, exhale: 8),
            instructions: [
                "Place one hand on chest, one on belly",
                "Breathe slowly into your belly",
                "Feel your lower hand rise",
                "Exhale slowly and completely",
                "Keep chest relatively still"
            ],
            safetyNotes: "Natural technique. Practice lying down initially.",
            benefits: [
                "Increases oxygen efficiency",
                "Strengthens diaphragm muscle",
                "Improves lung capacity utilization",
                "Promotes deep relaxation"
            ]
        )
    ]
}

/**
 * BreathingPattern: Specific breathing pattern definition
 */
enum BreathingPattern: Codable {
    case box(inhale: Int, hold: Int, exhale: Int, pause: Int)
    case diaphragmatic(inhale: Int, exhale: Int)
    case relaxation(inhale: Int, exhale: Int)
    case custom(phases: [BreathingPhase])
}

/**
 * BreathingPhase: Individual phase of a breathing pattern
 */
struct BreathingPhase: Codable {
    let type: PhaseType
    let duration: Int // in counts
    let instruction: String
}

/**
 * PhaseType: Types of breathing phases
 */
enum PhaseType: String, Codable {
    case inhale = "inhale"
    case hold = "hold"
    case exhale = "exhale"
    case pause = "pause"
}

/**
 * TechniqueCategory: Categories for breathing techniques
 */
enum TechniqueCategory: String, CaseIterable, Codable {
    case preparation = "preparation"
    case training = "training"
    case recovery = "recovery"
    case relaxation = "relaxation"
    
    var displayName: String {
        switch self {
        case .preparation: return "Preparation"
        case .training: return "Training"
        case .recovery: return "Recovery"
        case .relaxation: return "Relaxation"
        }
    }
}

/**
 * TechniqueDifficulty: Difficulty levels for techniques
 */
enum TechniqueDifficulty: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// MARK: - Default Training Programs

extension TrainingProgram {
    
    /**
     * Default training programs available in the app
     * 
     * SAFETY DESIGN: All programs have hard-coded safety limits and
     * progressive difficulty that prioritizes safety over performance.
     */
    static let defaultPrograms: [TrainingProgram] = [
        beginnerFoundation,
        intermediateDevelopment,
        advancedMastery
    ]
    
    // Quick Start Program
    static let quickStartProgram = TrainingProgram(
        id: UUID(),
        name: "Quick Start",
        description: "5-minute introduction to breath training",
        difficulty: .beginner,
        totalSessions: 1,
        sessionDuration: 300, // 5 minutes
        maxHoldTime: 15, // 15 seconds max
        preparationTime: 60, // 1 minute prep
        recoveryTime: 30, // 30 second recovery
        restPeriodDuration: 60, // 1 minute rest
        roundsPerSession: 3,
        progressionRules: ProgressionRules(
            holdTimeIncrement: 2,
            maxIncrementPerSession: 5,
            safetyThresholds: SafetyThresholds(
                maxConsecutiveSessions: 1,
                minRestBetweenSessions: 3600, // 1 hour
                maxDailyHolds: 5
            )
        )
    )
    
    // Beginner Foundation Program
    static let beginnerFoundation = TrainingProgram(
        id: UUID(),
        name: "Beginner Foundation",
        description: "4-week program building safe breath control basics",
        difficulty: .beginner,
        totalSessions: 20,
        sessionDuration: 900, // 15 minutes
        maxHoldTime: 30, // 30 seconds max
        preparationTime: 120, // 2 minutes prep
        recoveryTime: 60, // 1 minute recovery
        restPeriodDuration: 120, // 2 minutes rest
        roundsPerSession: 5,
        progressionRules: ProgressionRules(
            holdTimeIncrement: 2,
            maxIncrementPerSession: 5,
            safetyThresholds: SafetyThresholds(
                maxConsecutiveSessions: 2,
                minRestBetweenSessions: 3600, // 1 hour
                maxDailyHolds: 10
            )
        )
    )
    
    // Intermediate Development Program
    static let intermediateDevelopment = TrainingProgram(
        id: UUID(),
        name: "Intermediate Development",
        description: "6-week program for developing advanced breath control",
        difficulty: .intermediate,
        totalSessions: 30,
        sessionDuration: 1200, // 20 minutes
        maxHoldTime: 60, // 1 minute max
        preparationTime: 180, // 3 minutes prep
        recoveryTime: 90, // 1.5 minutes recovery
        restPeriodDuration: 180, // 3 minutes rest
        roundsPerSession: 6,
        progressionRules: ProgressionRules(
            holdTimeIncrement: 3,
            maxIncrementPerSession: 8,
            safetyThresholds: SafetyThresholds(
                maxConsecutiveSessions: 3,
                minRestBetweenSessions: 3600, // 1 hour
                maxDailyHolds: 15
            )
        )
    )
    
    // Advanced Mastery Program
    static let advancedMastery = TrainingProgram(
        id: UUID(),
        name: "Advanced Mastery",
        description: "8-week program for expert breath control mastery",
        difficulty: .advanced,
        totalSessions: 40,
        sessionDuration: 1800, // 30 minutes
        maxHoldTime: 120, // 2 minutes max
        preparationTime: 240, // 4 minutes prep
        recoveryTime: 120, // 2 minutes recovery
        restPeriodDuration: 240, // 4 minutes rest
        roundsPerSession: 8,
        progressionRules: ProgressionRules(
            holdTimeIncrement: 5,
            maxIncrementPerSession: 10,
            safetyThresholds: SafetyThresholds(
                maxConsecutiveSessions: 3,
                minRestBetweenSessions: 7200, // 2 hours
                maxDailyHolds: 20
            )
        )
    )
}

// MARK: - Progress Tracking Models

/**
 * ProgressData: Comprehensive progress tracking data
 * 
 * PURPOSE: Contains all progress metrics, analytics, and insights
 * for user progress visualization and gamification.
 * 
 * SAFETY DESIGN: All metrics prioritize safety compliance and
 * consistency over maximum performance metrics.
 */
struct ProgressData: Codable {
    let totalSessions: Int
    let currentStreak: Int
    let previousStreak: Int
    let bestStreak: Int
    let activeDays: Int
    let restDays: Int
    let safetyScore: Double
    let consistencyRate: Double
    let experienceLevel: UserExperienceLevel
    let totalTrainingTime: TimeInterval
    let averageHoldTime: TimeInterval
    let longestSafeHold: TimeInterval
    let averageSessionDuration: TimeInterval
    
    // Chart Data
    let consistencyData: [ConsistencyDataPoint]
    let progressTrendData: [ProgressDataPoint]
    let sessionQualityData: [SessionQualityDataPoint]
    
    // Progress Analysis
    let progressTrend: ProgressTrend
    let safetyMetrics: SafetyMetrics
    let personalizedInsights: [PersonalizedInsight]
}

/**
 * ConsistencyDataPoint: Data point for consistency tracking
 */
struct ConsistencyDataPoint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let sessionCount: Int
    let qualityScore: Double
    
    private enum CodingKeys: String, CodingKey {
        case date, sessionCount, qualityScore
    }
}

/**
 * ProgressDataPoint: Data point for progress trend analysis
 */
struct ProgressDataPoint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let averageHoldTime: TimeInterval
    let safetyScore: Double
    let consistencyScore: Double
    
    private enum CodingKeys: String, CodingKey {
        case date, averageHoldTime, safetyScore, consistencyScore
    }
}

/**
 * SessionQualityDataPoint: Data point for session quality tracking
 */
struct SessionQualityDataPoint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let qualityScore: Double
    let safetyCompliance: Double
    
    private enum CodingKeys: String, CodingKey {
        case date, duration, qualityScore, safetyCompliance
    }
}

/**
 * ProgressTrend: Overall progress trend analysis
 */
enum ProgressTrend: String, Codable {
    case improving = "improving"
    case stable = "stable"
    case needsAttention = "needsAttention"
    
    var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .needsAttention: return "Needs Attention"
        }
    }
}

/**
 * SafetyMetrics: Detailed safety compliance metrics
 */
struct SafetyMetrics: Codable {
    let holdLimitsCompliance: Double
    let restPeriodsCompliance: Double
    let emergencyStopsAvoidance: Double
    let sessionSpacingCompliance: Double
    let overallSafetyScore: Double
}

/**
 * PersonalizedInsight: AI-generated insights for user improvement
 */
struct PersonalizedInsight: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: InsightCategory
    let priority: InsightPriority
    let actionable: Bool
    let iconName: String
    let color: String // Color name for SwiftUI
    
    private enum CodingKeys: String, CodingKey {
        case title, description, category, priority, actionable, iconName, color
    }
}

/**
 * InsightCategory: Categories for personalized insights
 */
enum InsightCategory: String, CaseIterable, Codable {
    case consistency = "consistency"
    case safety = "safety"
    case technique = "technique"
    case motivation = "motivation"
    case health = "health"
    
    var displayName: String {
        switch self {
        case .consistency: return "Consistency"
        case .safety: return "Safety"
        case .technique: return "Technique"
        case .motivation: return "Motivation"
        case .health: return "Health"
        }
    }
}

/**
 * InsightPriority: Priority levels for insights
 */
enum InsightPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

/**
 * UserExperienceLevel: User's current experience level
 */
enum UserExperienceLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case novice = "novice"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
    
    var experiencePoints: Int {
        switch self {
        case .beginner: return 0
        case .novice: return 100
        case .intermediate: return 300
        case .advanced: return 750
        case .expert: return 1500
        }
    }
}

// MARK: - Achievement System Models

/**
 * Achievement: Individual achievement definition
 * 
 * SAFETY DESIGN: All achievements focus on safety compliance,
 * consistency, and proper technique rather than maximum performance.
 */
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let difficulty: Int // 1-5 stars
    let points: Int
    let unlockCriteria: String
    let isUnlocked: Bool
    let unlockedDate: Date
    let progress: Double // 0.0 to 1.0
    let isRare: Bool
    
    // Static achievement definitions
    static let allAchievements: [Achievement] = [
        // Consistency Achievements
        Achievement(
            id: "first_session",
            name: "First Steps",
            description: "Complete your first breathing session with perfect safety compliance",
            iconName: "lungs.fill",
            category: .consistency,
            difficulty: 1,
            points: 10,
            unlockCriteria: "Complete 1 breathing session",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        ),
        
        Achievement(
            id: "week_streak",
            name: "Weekly Warrior",
            description: "Maintain a 7-day practice streak with proper rest days",
            iconName: "flame.fill",
            category: .consistency,
            difficulty: 2,
            points: 50,
            unlockCriteria: "Complete 7 consecutive days of practice",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        ),
        
        Achievement(
            id: "month_streak",
            name: "Monthly Master",
            description: "Achieve a 30-day practice streak with excellent consistency",
            iconName: "calendar.badge.checkmark",
            category: .consistency,
            difficulty: 4,
            points: 200,
            unlockCriteria: "Complete 30 consecutive days of practice",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: true
        ),
        
        // Safety Achievements
        Achievement(
            id: "safety_perfect",
            name: "Safety Champion",
            description: "Maintain 100% safety compliance for 50 sessions",
            iconName: "shield.checkered",
            category: .safety,
            difficulty: 3,
            points: 100,
            unlockCriteria: "Complete 50 sessions with perfect safety score",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        ),
        
        Achievement(
            id: "emergency_avoided",
            name: "Wisdom Guardian",
            description: "Complete 100 sessions without any emergency stops",
            iconName: "heart.circle.fill",
            category: .safety,
            difficulty: 3,
            points: 150,
            unlockCriteria: "Complete 100 sessions with no emergency stops",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        ),
        
        // Technique Achievements
        Achievement(
            id: "technique_master",
            name: "Technique Master",
            description: "Master all fundamental breathing techniques",
            iconName: "star.fill",
            category: .technique,
            difficulty: 4,
            points: 250,
            unlockCriteria: "Complete tutorials for all breathing techniques",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: true
        ),
        
        // Progress Achievements
        Achievement(
            id: "steady_progress",
            name: "Steady Progress",
            description: "Show consistent improvement over 4 weeks",
            iconName: "chart.line.uptrend.xyaxis",
            category: .progress,
            difficulty: 3,
            points: 75,
            unlockCriteria: "Maintain positive progress trend for 4 weeks",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        ),
        
        // Education Achievements
        Achievement(
            id: "safety_scholar",
            name: "Safety Scholar",
            description: "Pass the comprehensive safety quiz with 100% score",
            iconName: "graduationcap.fill",
            category: .education,
            difficulty: 2,
            points: 40,
            unlockCriteria: "Score 100% on safety quiz",
            isUnlocked: false,
            unlockedDate: Date(),
            progress: 0.0,
            isRare: false
        )
    ]
}

/**
 * AchievementCategory: Categories for achievements
 */
enum AchievementCategory: String, CaseIterable, Codable {
    case consistency = "consistency"
    case safety = "safety"
    case technique = "technique"
    case progress = "progress"
    case education = "education"
    
    var displayName: String {
        switch self {
        case .consistency: return "Consistency"
        case .safety: return "Safety"
        case .technique: return "Technique"
        case .progress: return "Progress"
        case .education: return "Education"
        }
    }
    
    var iconName: String {
        switch self {
        case .consistency: return "flame.fill"
        case .safety: return "shield.checkered"
        case .technique: return "star.fill"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .education: return "graduationcap.fill"
        }
    }
    
    var color: String {
        switch self {
        case .consistency: return "orange"
        case .safety: return "green"
        case .technique: return "purple"
        case .progress: return "blue"
        case .education: return "yellow"
        }
    }
}

// MARK: - Color Extension for Achievement Categories

extension AchievementCategory {
    var swiftUIColor: Color {
        switch self {
        case .consistency: return .orange
        case .safety: return .green
        case .technique: return .purple
        case .progress: return .blue
        case .education: return .yellow
        }
    }
}

// MARK: - Color Extension for PersonalizedInsight

extension PersonalizedInsight {
    var swiftUIColor: Color {
        switch color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        default: return .gray
        }
    }
} 