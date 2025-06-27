import Foundation
import SwiftUI

/**
 * SafetyQuizQuestion: Individual quiz question structure
 * 
 * PURPOSE: Defines the structure for safety education quiz questions that
 * validate user understanding of critical safety concepts.
 * 
 * SAFETY CRITICAL: Questions are designed to identify dangerous misconceptions
 * and ensure users understand life-threatening safety issues.
 */
struct SafetyQuizQuestion {
    let id: String
    let category: QuizCategory
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    let context: String?
    let isCritical: Bool
    
    /**
     * All safety quiz questions
     * 
     * RATIONALE: Comprehensive question set covering all critical safety
     * aspects taught in the education module. Questions are designed to
     * identify dangerous misconceptions and validate proper understanding.
     */
    static let allQuestions: [SafetyQuizQuestion] = [
        
        // MARK: - Dangerous Techniques Questions
        
        SafetyQuizQuestion(
            id: "dangerous_1",
            category: .dangerousTechniques,
            question: "Which breathing technique is MOST dangerous for breath-holding training?",
            options: [
                "Box breathing (4-4-4-4)",
                "Wim Hof Method hyperventilation",
                "Diaphragmatic breathing",
                "Slow relaxation breathing"
            ],
            correctAnswer: "Wim Hof Method hyperventilation",
            explanation: "The Wim Hof Method involves hyperventilation which depletes CO2 levels, creating false confidence while increasing blackout risk. Multiple deaths have been documented from this technique.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "dangerous_2",
            category: .dangerousTechniques,
            question: "Why is hyperventilation dangerous before breath-holding?",
            options: [
                "It increases oxygen levels too much",
                "It removes CO2 which is your safety warning system",
                "It makes you tired",
                "It increases heart rate"
            ],
            correctAnswer: "It removes CO2 which is your safety warning system",
            explanation: "Hyperventilation removes CO2 from your blood. Since CO2 levels (not oxygen levels) trigger the urge to breathe, this eliminates your natural warning system and can lead to blackouts without warning.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "dangerous_3",
            category: .dangerousTechniques,
            question: "Where should you NEVER practice breath-holding?",
            options: [
                "In a comfortable chair",
                "Lying on your bed",
                "In or near water",
                "In a quiet room"
            ],
            correctAnswer: "In or near water",
            explanation: "Shallow water blackout can occur without warning, leading to drowning. Even experienced swimmers can lose consciousness suddenly. There is no safe way to practice breath-holding in water alone.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "dangerous_4",
            category: .dangerousTechniques,
            question: "What makes competitive breath-holding dangerous?",
            options: [
                "It's too easy and boring",
                "Peer pressure leads to ignoring safety signals",
                "It requires special equipment",
                "It takes too much time"
            ],
            correctAnswer: "Peer pressure leads to ignoring safety signals",
            explanation: "Competition creates psychological pressure to exceed safe limits and ignore the body's warning signals. This significantly increases the risk of blackouts and injury.",
            context: nil,
            isCritical: true
        ),
        
        // MARK: - Proper Techniques Questions
        
        SafetyQuizQuestion(
            id: "proper_1",
            category: .properTechniques,
            question: "What makes box breathing (4-4-4-4) safe for breath training?",
            options: [
                "It increases oxygen levels dramatically",
                "It maintains normal CO2 levels while training control",
                "It allows you to hold your breath for hours",
                "It eliminates the need for rest periods"
            ],
            correctAnswer: "It maintains normal CO2 levels while training control",
            explanation: "Box breathing maintains normal CO2 levels while developing respiratory muscle control and breathing rhythm. This preserves your natural safety warning systems.",
            context: nil,
            isCritical: false
        ),
        
        SafetyQuizQuestion(
            id: "proper_2",
            category: .properTechniques,
            question: "How do CO2 tolerance tables improve breath-holding safely?",
            options: [
                "By removing all CO2 from your blood",
                "By gradually training your body to tolerate higher CO2 levels",
                "By increasing lung capacity to superhuman levels",
                "By eliminating the need to breathe"
            ],
            correctAnswer: "By gradually training your body to tolerate higher CO2 levels",
            explanation: "CO2 tolerance tables gradually expose you to higher CO2 levels through controlled practice, improving comfort with breath-holding while maintaining natural warning systems.",
            context: nil,
            isCritical: false
        ),
        
        SafetyQuizQuestion(
            id: "proper_3",
            category: .properTechniques,
            question: "What is the most important principle for safe breath training?",
            options: [
                "Maximum performance at all costs",
                "Gradual progression and listening to your body",
                "Competing with others for motivation",
                "Training as intensely as possible"
            ],
            correctAnswer: "Gradual progression and listening to your body",
            explanation: "Safe breath training prioritizes gradual improvement over weeks and months, always respecting your body's signals and limits. Consistency and safety are more important than maximum performance.",
            context: nil,
            isCritical: true
        ),
        
        // MARK: - Safety Environment Questions
        
        SafetyQuizQuestion(
            id: "environment_1",
            category: .safetyBasics,
            question: "What is the safest position for breath-holding practice?",
            options: [
                "Standing up",
                "Walking around",
                "Sitting or lying down securely",
                "Hanging upside down"
            ],
            correctAnswer: "Sitting or lying down securely",
            explanation: "Sitting or lying down prevents injury from falling if you become dizzy or lose consciousness. This is a fundamental safety requirement for all breath training.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "environment_2",
            category: .safetyBasics,
            question: "If you feel dizzy during breath training, what should you do?",
            options: [
                "Push through it to build tolerance",
                "Stop immediately and breathe normally",
                "Hold your breath longer to overcome it",
                "Ignore it and continue training"
            ],
            correctAnswer: "Stop immediately and breathe normally",
            explanation: "Dizziness is a warning sign that should never be ignored. Stop immediately and return to normal breathing. Your safety is always more important than training progress.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "environment_3",
            category: .safetyBasics,
            question: "Why is it recommended to have someone nearby during breath training?",
            options: [
                "To time your breath holds",
                "To provide encouragement",
                "For safety in case of emergency",
                "To take photos for social media"
            ],
            correctAnswer: "For safety in case of emergency",
            explanation: "Having someone nearby provides an additional safety layer in case you experience any adverse effects or need assistance. This is especially important for beginners.",
            context: nil,
            isCritical: false
        ),
        
        // MARK: - Medical Safety Questions
        
        SafetyQuizQuestion(
            id: "medical_1",
            category: .medicalSafety,
            question: "Who should consult a doctor before starting breath training?",
            options: [
                "Only people over 65",
                "Only professional athletes",
                "Anyone with heart, respiratory, or blood pressure conditions",
                "No one needs medical consultation"
            ],
            correctAnswer: "Anyone with heart, respiratory, or blood pressure conditions",
            explanation: "People with heart conditions, respiratory issues, blood pressure disorders, or other medical conditions should consult their healthcare provider before starting any breathing exercise program.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "medical_2",
            category: .medicalSafety,
            question: "Which symptom requires immediate medical attention during breath training?",
            options: [
                "Feeling slightly out of breath",
                "Chest pain or severe dizziness",
                "Mild muscle tension",
                "Feeling relaxed"
            ],
            correctAnswer: "Chest pain or severe dizziness",
            explanation: "Chest pain, severe dizziness, fainting, or any unusual symptoms require immediate medical attention. These could indicate serious medical issues.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "medical_3",
            category: .medicalSafety,
            question: "What should pregnant women know about breath training?",
            options: [
                "It's always completely safe",
                "They should consult their doctor first",
                "They should only do extreme techniques",
                "Pregnancy doesn't affect breath training"
            ],
            correctAnswer: "They should consult their doctor first",
            explanation: "Pregnant women should always consult their healthcare provider before starting any new exercise program, including breathing exercises, as pregnancy affects respiratory and cardiovascular systems.",
            context: nil,
            isCritical: true
        ),
        
        // MARK: - Training Limits Questions
        
        SafetyQuizQuestion(
            id: "limits_1",
            category: .trainingLimits,
            question: "What is the maximum safe breath-hold time for beginners?",
            options: [
                "30 seconds",
                "5 minutes",
                "10 minutes",
                "As long as possible"
            ],
            correctAnswer: "30 seconds",
            explanation: "Beginners should start with very short holds (30 seconds or less) and progress gradually. The app enforces these limits to prevent unsafe practices.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "limits_2",
            category: .trainingLimits,
            question: "How long should rest periods be between breath holds?",
            options: [
                "No rest needed",
                "5 seconds",
                "At least twice as long as the hold time",
                "Exactly the same as hold time"
            ],
            correctAnswer: "At least twice as long as the hold time",
            explanation: "Rest periods should be at least twice as long as the breath hold to allow full recovery. This prevents cumulative oxygen debt and maintains safety.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "limits_3",
            category: .trainingLimits,
            question: "How should breath training progress be measured?",
            options: [
                "Maximum hold time only",
                "Consistency and technique improvement",
                "Comparing with others online",
                "Number of blackouts survived"
            ],
            correctAnswer: "Consistency and technique improvement",
            explanation: "Safe progress focuses on consistency of practice and improvement in breathing technique rather than maximum performance. This approach builds sustainable skills and maintains safety.",
            context: nil,
            isCritical: false
        ),
        
        // MARK: - Emergency Response Questions
        
        SafetyQuizQuestion(
            id: "emergency_1",
            category: .emergencyResponse,
            question: "If someone loses consciousness during breath training, what should you do first?",
            options: [
                "Pour water on them",
                "Continue timing their breath hold",
                "Ensure they're breathing and call for medical help",
                "Take a photo for documentation"
            ],
            correctAnswer: "Ensure they're breathing and call for medical help",
            explanation: "Loss of consciousness is a medical emergency. Ensure the person is breathing, place them in recovery position if needed, and call for immediate medical assistance.",
            context: nil,
            isCritical: true
        ),
        
        SafetyQuizQuestion(
            id: "emergency_2",
            category: .emergencyResponse,
            question: "What information should be easily accessible during breath training?",
            options: [
                "Social media passwords",
                "Emergency contact numbers",
                "Training records from other apps",
                "Motivational quotes"
            ],
            correctAnswer: "Emergency contact numbers",
            explanation: "Emergency contact information should always be easily accessible in case medical assistance is needed during training sessions.",
            context: nil,
            isCritical: true
        )
    ]
}

/**
 * QuizCategory: Categories for organizing quiz questions
 */
enum QuizCategory: CaseIterable {
    case dangerousTechniques
    case properTechniques
    case safetyBasics
    case medicalSafety
    case trainingLimits
    case emergencyResponse
    
    var displayName: String {
        switch self {
        case .dangerousTechniques:
            return "Dangerous Techniques"
        case .properTechniques:
            return "Proper Techniques"
        case .safetyBasics:
            return "Safety Basics"
        case .medicalSafety:
            return "Medical Safety"
        case .trainingLimits:
            return "Training Limits"
        case .emergencyResponse:
            return "Emergency Response"
        }
    }
    
    var color: Color {
        switch self {
        case .dangerousTechniques:
            return .red
        case .properTechniques:
            return .green
        case .safetyBasics:
            return .blue
        case .medicalSafety:
            return .orange
        case .trainingLimits:
            return .purple
        case .emergencyResponse:
            return .pink
        }
    }
} 