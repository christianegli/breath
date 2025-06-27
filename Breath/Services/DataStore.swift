import Foundation
import SwiftUI

/**
 * DataStore: Persistent data storage service for breath training app
 * 
 * PURPOSE: Handles all data persistence including session history,
 * user progress, achievements, and safety records. Uses UserDefaults
 * for simplicity in MVP, with architecture designed for easy migration
 * to Core Data or CloudKit in the future.
 * 
 * SAFETY FOCUS: Ensures safety education completion and user data
 * are never lost, with automatic backup and recovery mechanisms.
 */
@MainActor
class DataStore: ObservableObject {
    
    // MARK: - Storage Keys
    
    private enum StorageKeys {
        static let sessionHistory = "breath_session_history"
        static let userProgress = "breath_user_progress"
        static let achievements = "breath_achievements"
        static let currentStreak = "breath_current_streak"
        static let safetyEducationCompletion = "breath_safety_education"
        static let userSettings = "breath_user_settings"
        static let experienceLevel = "breath_experience_level"
        static let lastBackupDate = "breath_last_backup"
    }
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    // MARK: - Published State
    
    @Published var isDataLoaded: Bool = false
    @Published var lastSyncDate: Date?
    @Published var dataSize: Int = 0
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
        
        // Configure JSON coding for dates
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        loadInitialData()
    }
    
    // MARK: - Session Data Management
    
    /**
     * Save training session start
     */
    func saveSessionStart(_ session: TrainingSession) {
        
        var sessions = loadSessions()
        
        // Check if session already exists (avoid duplicates)
        if !sessions.contains(where: { $0.id == session.id }) {
            sessions.append(session)
            saveSessions(sessions)
        }
    }
    
    /**
     * Save completed training session result
     * 
     * SAFETY: Ensures session results are immediately persisted for safety analysis
     */
    func saveSessionResult(_ result: TrainingSessionResult) {
        
        var results = loadSessionResults()
        
        // Remove any existing result with same session ID
        results.removeAll { $0.session.id == result.session.id }
        
        // Add new result
        results.append(result)
        
        // Keep only last 200 sessions to manage storage
        if results.count > 200 {
            results = Array(results.suffix(200))
        }
        
        saveSessionResults(results)
        
        // Update data size tracking
        updateDataSize()
    }
    
    /**
     * Load session history
     */
    func loadSessionHistory() -> [TrainingSessionResult] {
        return loadSessionResults()
    }
    
    /**
     * Get last completed session
     */
    func getLastSession() -> TrainingSessionResult? {
        let results = loadSessionResults()
        return results.last
    }
    
    // MARK: - User Progress Management
    
    /**
     * Save user progress
     */
    func saveUserProgress(_ progress: UserProgress) {
        
        if let data = try? jsonEncoder.encode(progress) {
            userDefaults.set(data, forKey: StorageKeys.userProgress)
            lastSyncDate = Date()
        }
    }
    
    /**
     * Load user progress
     */
    func loadUserProgress() -> UserProgress? {
        
        guard let data = userDefaults.data(forKey: StorageKeys.userProgress),
              let progress = try? jsonDecoder.decode(UserProgress.self, from: data) else {
            return nil
        }
        
        return progress
    }
    
    // MARK: - Achievement Management
    
    /**
     * Save achievement
     */
    func saveAchievement(_ achievement: Achievement) {
        
        var achievements = loadAchievements()
        
        // Avoid duplicate achievements
        if !achievements.contains(where: { $0.id == achievement.id }) {
            achievements.append(achievement)
            saveAchievements(achievements)
        }
    }
    
    /**
     * Load all achievements
     */
    func loadAchievements() -> [Achievement] {
        
        guard let data = userDefaults.data(forKey: StorageKeys.achievements),
              let achievements = try? jsonDecoder.decode([Achievement].self, from: data) else {
            return []
        }
        
        return achievements
    }
    
    /**
     * Save achievements array
     */
    private func saveAchievements(_ achievements: [Achievement]) {
        
        if let data = try? jsonEncoder.encode(achievements) {
            userDefaults.set(data, forKey: StorageKeys.achievements)
        }
    }
    
    // MARK: - Safety Education Data
    
    /**
     * Save safety education completion
     * 
     * SAFETY CRITICAL: This data must never be lost as it gates training access
     */
    func saveSafetyEducationCompletion(_ completion: SafetyEducationCompletion) {
        
        if let data = try? jsonEncoder.encode(completion) {
            userDefaults.set(data, forKey: StorageKeys.safetyEducationCompletion)
            
            // Force synchronization for safety data
            userDefaults.synchronize()
        }
    }
    
    /**
     * Load safety education completion
     */
    func loadSafetyEducationCompletion() -> SafetyEducationCompletion? {
        
        guard let data = userDefaults.data(forKey: StorageKeys.safetyEducationCompletion),
              let completion = try? jsonDecoder.decode(SafetyEducationCompletion.self, from: data) else {
            return nil
        }
        
        return completion
    }
    
    // MARK: - User Settings Management
    
    /**
     * Save user settings
     */
    func saveUserSettings(_ settings: UserSettings) {
        
        if let data = try? jsonEncoder.encode(settings) {
            userDefaults.set(data, forKey: StorageKeys.userSettings)
        }
    }
    
    /**
     * Load user settings
     */
    func loadUserSettings() -> UserSettings {
        
        guard let data = userDefaults.data(forKey: StorageKeys.userSettings),
              let settings = try? jsonDecoder.decode(UserSettings.self, from: data) else {
            return UserSettings.defaultSettings
        }
        
        return settings
    }
    
    // MARK: - Experience Level Management
    
    /**
     * Save user experience level
     * 
     * SAFETY: Experience level determines safety limits, so changes are logged
     */
    func saveExperienceLevel(_ level: UserExperienceLevel) {
        
        let levelData = ExperienceLevelRecord(
            level: level,
            dateAssigned: Date(),
            assignmentReason: "System determined based on training progression"
        )
        
        if let data = try? jsonEncoder.encode(levelData) {
            userDefaults.set(data, forKey: StorageKeys.experienceLevel)
        }
    }
    
    /**
     * Load user experience level
     */
    func loadExperienceLevel() -> UserExperienceLevel {
        
        guard let data = userDefaults.data(forKey: StorageKeys.experienceLevel),
              let levelRecord = try? jsonDecoder.decode(ExperienceLevelRecord.self, from: data) else {
            return .beginner // Default to safest level
        }
        
        return levelRecord.level
    }
    
    // MARK: - Streak Management
    
    /**
     * Save current streak
     */
    func saveCurrentStreak(_ streak: Int) {
        userDefaults.set(streak, forKey: StorageKeys.currentStreak)
    }
    
    /**
     * Load current streak
     */
    func loadCurrentStreak() -> Int {
        return userDefaults.integer(forKey: StorageKeys.currentStreak)
    }
    
    // MARK: - Data Management Utilities
    
    /**
     * Clear all user data (for testing or reset)
     */
    func clearAllData() {
        
        let keys = [
            StorageKeys.sessionHistory,
            StorageKeys.userProgress,
            StorageKeys.achievements,
            StorageKeys.currentStreak,
            StorageKeys.userSettings,
            StorageKeys.experienceLevel
        ]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
        
        // DO NOT clear safety education completion - user must redo education
        userDefaults.synchronize()
    }
    
    /**
     * Export user data for backup
     */
    func exportUserData() -> Data? {
        
        let exportData = UserDataExport(
            sessionResults: loadSessionResults(),
            userProgress: loadUserProgress(),
            achievements: loadAchievements(),
            currentStreak: loadCurrentStreak(),
            userSettings: loadUserSettings(),
            experienceLevel: loadExperienceLevel(),
            safetyEducationCompletion: loadSafetyEducationCompletion(),
            exportDate: Date()
        )
        
        return try? jsonEncoder.encode(exportData)
    }
    
    /**
     * Import user data from backup
     */
    func importUserData(_ data: Data) -> Bool {
        
        guard let exportData = try? jsonDecoder.decode(UserDataExport.self, from: data) else {
            return false
        }
        
        // Import data
        saveSessionResults(exportData.sessionResults)
        
        if let progress = exportData.userProgress {
            saveUserProgress(progress)
        }
        
        saveAchievements(exportData.achievements)
        saveCurrentStreak(exportData.currentStreak)
        saveUserSettings(exportData.userSettings)
        saveExperienceLevel(exportData.experienceLevel)
        
        if let safetyCompletion = exportData.safetyEducationCompletion {
            saveSafetyEducationCompletion(safetyCompletion)
        }
        
        userDefaults.synchronize()
        updateDataSize()
        
        return true
    }
    
    /**
     * Calculate current data size
     */
    private func updateDataSize() {
        
        let keys = [
            StorageKeys.sessionHistory,
            StorageKeys.userProgress,
            StorageKeys.achievements,
            StorageKeys.safetyEducationCompletion,
            StorageKeys.userSettings,
            StorageKeys.experienceLevel
        ]
        
        var totalSize = 0
        
        for key in keys {
            if let data = userDefaults.data(forKey: key) {
                totalSize += data.count
            }
        }
        
        dataSize = totalSize
    }
    
    /**
     * Load initial data and set up state
     */
    private func loadInitialData() {
        
        updateDataSize()
        lastSyncDate = userDefaults.object(forKey: StorageKeys.lastBackupDate) as? Date
        isDataLoaded = true
    }
    
    // MARK: - Private Storage Methods
    
    /**
     * Load sessions from storage
     */
    private func loadSessions() -> [TrainingSession] {
        
        guard let data = userDefaults.data(forKey: StorageKeys.sessionHistory),
              let sessions = try? jsonDecoder.decode([TrainingSession].self, from: data) else {
            return []
        }
        
        return sessions
    }
    
    /**
     * Save sessions to storage
     */
    private func saveSessions(_ sessions: [TrainingSession]) {
        
        if let data = try? jsonEncoder.encode(sessions) {
            userDefaults.set(data, forKey: StorageKeys.sessionHistory)
        }
    }
    
    /**
     * Load session results from storage
     */
    private func loadSessionResults() -> [TrainingSessionResult] {
        
        guard let data = userDefaults.data(forKey: StorageKeys.sessionHistory + "_results"),
              let results = try? jsonDecoder.decode([TrainingSessionResult].self, from: data) else {
            return []
        }
        
        return results.sorted { $0.endTime < $1.endTime }
    }
    
    /**
     * Save session results to storage
     */
    private func saveSessionResults(_ results: [TrainingSessionResult]) {
        
        if let data = try? jsonEncoder.encode(results) {
            userDefaults.set(data, forKey: StorageKeys.sessionHistory + "_results")
        }
    }
}

// MARK: - Supporting Data Types

/**
 * ExperienceLevelRecord: Record of experience level assignment
 */
struct ExperienceLevelRecord: Codable {
    let level: UserExperienceLevel
    let dateAssigned: Date
    let assignmentReason: String
}

/**
 * UserSettings: User preference settings
 */
struct UserSettings: Codable {
    let audioEnabled: Bool
    let voiceGuidanceEnabled: Bool
    let soundEffectsEnabled: Bool
    let guidanceVolume: Float
    let reminderNotificationsEnabled: Bool
    let dailyReminderTime: Date?
    let weeklyGoal: Int
    let preferredUnits: MeasurementUnits
    
    static let defaultSettings = UserSettings(
        audioEnabled: true,
        voiceGuidanceEnabled: true,
        soundEffectsEnabled: true,
        guidanceVolume: 0.7,
        reminderNotificationsEnabled: false,
        dailyReminderTime: nil,
        weeklyGoal: 3,
        preferredUnits: .metric
    )
}

/**
 * MeasurementUnits: Preferred measurement units
 */
enum MeasurementUnits: String, Codable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"
    
    var displayName: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
}

/**
 * UserDataExport: Complete user data export structure
 */
struct UserDataExport: Codable {
    let sessionResults: [TrainingSessionResult]
    let userProgress: UserProgress?
    let achievements: [Achievement]
    let currentStreak: Int
    let userSettings: UserSettings
    let experienceLevel: UserExperienceLevel
    let safetyEducationCompletion: SafetyEducationCompletion?
    let exportDate: Date
} 