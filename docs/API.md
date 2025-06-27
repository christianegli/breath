# API Documentation

## Overview

This document outlines the internal APIs and interfaces used within the Breath app. These are not external web APIs, but rather the internal service interfaces and data models that make up the app's architecture.

## Core Services

### SafetyValidator

Validates user safety and enforces safety limits throughout the app.

```swift
protocol SafetyValidatorProtocol {
    func validateUserCanTrain() -> SafetyValidationResult
    func validateSessionParameters(_ params: SessionParameters) -> Bool
    func checkRestPeriodCompliance() -> Bool
    func recordSafetyEducationCompletion()
}
```

#### Methods

**`validateUserCanTrain() -> SafetyValidationResult`**
- **Purpose**: Checks if user is eligible to start training
- **Returns**: `SafetyValidationResult` with validation status and reason
- **Safety Checks**:
  - Safety education completion
  - Rest period compliance
  - Daily training limits
  - User age verification

**`validateSessionParameters(_ params: SessionParameters) -> Bool`**
- **Purpose**: Validates training session parameters are within safe limits
- **Parameters**: 
  - `params`: Session configuration including hold times, rest periods
- **Returns**: `true` if parameters are safe, `false` otherwise
- **Safety Limits**:
  - Maximum hold time: 3 minutes (beginners), 5 minutes (advanced)
  - Minimum rest between holds: 1 minute
  - Maximum session duration: 30 minutes

**`checkRestPeriodCompliance() -> Bool`**
- **Purpose**: Ensures adequate rest between training sessions
- **Returns**: `true` if sufficient rest period has elapsed
- **Rules**:
  - Minimum 4 hours between intensive sessions
  - Minimum 1 hour between light sessions
  - Maximum 3 intensive sessions per day

---

### TrainingEngine

Manages training session execution and progression.

```swift
protocol TrainingEngineProtocol {
    func startSession(_ program: TrainingProgram) -> TrainingSession
    func pauseSession()
    func resumeSession()
    func endSession() -> SessionResult
    func getAvailablePrograms() -> [TrainingProgram]
}
```

#### Methods

**`startSession(_ program: TrainingProgram) -> TrainingSession`**
- **Purpose**: Initiates a new training session
- **Parameters**: `program` - Selected training program
- **Returns**: Active `TrainingSession` instance
- **Preconditions**: Safety validation must pass

**`getAvailablePrograms() -> [TrainingProgram]`**
- **Purpose**: Returns list of available training programs based on user level
- **Returns**: Array of `TrainingProgram` objects
- **Filtering**: Programs filtered by user progression and safety clearance

---

### ProgressCalculator

Calculates user progress and performance metrics.

```swift
protocol ProgressCalculatorProtocol {
    func calculateImprovement(from baseline: TimeInterval, to current: TimeInterval) -> ProgressMetrics
    func getProgressSummary(for period: TimePeriod) -> ProgressSummary
    func updateUserLevel() -> UserLevel
    func generateRecommendations() -> [TrainingRecommendation]
}
```

#### Methods

**`calculateImprovement(from:to:) -> ProgressMetrics`**
- **Purpose**: Calculates improvement metrics between two measurements
- **Parameters**:
  - `baseline`: Starting breath hold time
  - `current`: Current breath hold time
- **Returns**: `ProgressMetrics` with improvement data
- **Metrics**:
  - Absolute improvement (seconds)
  - Percentage improvement
  - Rate of improvement
  - Consistency score

---

### AudioController

Manages audio cues and breathing guidance.

```swift
protocol AudioControllerProtocol {
    func playBreathingCue(_ cue: BreathingCue)
    func startGuidedBreathing(_ pattern: BreathingPattern)
    func stopAudio()
    func setVolume(_ volume: Float)
}
```

#### Audio Cues

**Breathing Patterns**:
- Box breathing (4-4-4-4 pattern)
- Preparation breathing (custom timing)
- Recovery breathing (guided)

**Cue Types**:
- Inhale cue
- Exhale cue
- Hold cue
- Rest cue
- Session complete

---

## Data Models

### TrainingProgram

```swift
struct TrainingProgram {
    let id: UUID
    let name: String
    let description: String
    let difficulty: DifficultyLevel
    let sessions: [SessionTemplate]
    let prerequisites: [Prerequisite]
    let safetyLevel: SafetyLevel
}
```

### SessionTemplate

```swift
struct SessionTemplate {
    let breathingPhase: BreathingPhase
    let holdPhase: HoldPhase
    let recoveryPhase: RecoveryPhase
    let repetitions: Int
    let restBetweenReps: TimeInterval
}
```

### ProgressMetrics

```swift
struct ProgressMetrics {
    let baselineTime: TimeInterval
    let currentTime: TimeInterval
    let absoluteImprovement: TimeInterval
    let percentImprovement: Double
    let consistencyScore: Double
    let trend: ProgressTrend
}
```

### SafetyValidationResult

```swift
struct SafetyValidationResult {
    let isValid: Bool
    let reason: String?
    let blockedFeatures: [AppFeature]
    let recommendedAction: SafetyAction?
}
```

## Enums & Types

### DifficultyLevel

```swift
enum DifficultyLevel: Int, CaseIterable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    
    var maxHoldTime: TimeInterval {
        switch self {
        case .beginner: return 120 // 2 minutes
        case .intermediate: return 240 // 4 minutes
        case .advanced: return 300 // 5 minutes
        }
    }
}
```

### SafetyLevel

```swift
enum SafetyLevel {
    case low      // Basic breathing exercises
    case medium   // Structured hold training
    case high     // Advanced techniques
}
```

### BreathingCue

```swift
enum BreathingCue {
    case inhale(duration: TimeInterval)
    case exhale(duration: TimeInterval)
    case hold(duration: TimeInterval)
    case rest(duration: TimeInterval)
    case sessionComplete
}
```

## Error Handling

### SafetyError

```swift
enum SafetyError: Error {
    case educationNotCompleted
    case restPeriodViolation
    case dailyLimitExceeded
    case ageRestriction
    case unsafeParameters
    
    var localizedDescription: String {
        // User-friendly error messages
    }
    
    var recoveryAction: SafetyAction {
        // Recommended action to resolve error
    }
}
```

### TrainingError

```swift
enum TrainingError: Error {
    case sessionNotStarted
    case invalidProgram
    case audioNotAvailable
    case timerFailure
    
    var localizedDescription: String {
        // User-friendly error messages
    }
}
```

## Constants

### Safety Limits

```swift
struct SafetyLimits {
    static let maxHoldTimeBeginner: TimeInterval = 120
    static let maxHoldTimeAdvanced: TimeInterval = 300
    static let minRestBetweenHolds: TimeInterval = 60
    static let minRestBetweenSessions: TimeInterval = 14400 // 4 hours
    static let maxSessionsPerDay = 3
    static let minAgeRequirement = 13
}
```

### Training Parameters

```swift
struct TrainingParameters {
    static let boxBreathingPattern = BreathingPattern(
        inhale: 4, hold: 4, exhale: 4, rest: 4
    )
    static let preparationBreathingDuration: TimeInterval = 120
    static let recoveryBreathingDuration: TimeInterval = 60
}
```

## Notifications

### Training Events

```swift
extension Notification.Name {
    static let trainingSessionStarted = Notification.Name("trainingSessionStarted")
    static let trainingSessionEnded = Notification.Name("trainingSessionEnded")
    static let progressUpdated = Notification.Name("progressUpdated")
    static let safetyViolation = Notification.Name("safetyViolation")
}
```

## Usage Examples

### Starting a Training Session

```swift
// Validate safety
guard safetyValidator.validateUserCanTrain().isValid else {
    // Handle safety violation
    return
}

// Get available programs
let programs = trainingEngine.getAvailablePrograms()
let beginnerProgram = programs.first { $0.difficulty == .beginner }

// Start session
let session = trainingEngine.startSession(beginnerProgram)
```

### Calculating Progress

```swift
let metrics = progressCalculator.calculateImprovement(
    from: userProfile.baselineHoldTime,
    to: session.maxHoldTime
)

print("Improvement: \(metrics.percentImprovement)%")
```

---

*Internal API documentation for safe, structured breath training functionality.* 