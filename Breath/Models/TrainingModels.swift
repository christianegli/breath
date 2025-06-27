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
