import Foundation

/**
 * SafetyQuizQuestion: Comprehensive safety knowledge validation
 * 
 * PURPOSE: These questions validate that users understand critical safety
 * concepts before being granted access to breath training features. Each
 * question addresses potentially life-threatening misconceptions.
 * 
 * SAFETY RATIONALE: This quiz can literally save lives. Many breath training
 * injuries and deaths occur due to misconceptions about "safe" techniques.
 * The quiz ensures users understand dangerous techniques to avoid and proper
 * safety protocols to follow.
 * 
 * ARCHITECTURE DECISION: Questions are designed to be unambiguous with clear
 * correct answers. 80% passing grade ensures solid understanding while
 * allowing for minor mistakes.
 */
struct SafetyQuizQuestion {
    let id: Int
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let category: SafetyCategory
    
    enum SafetyCategory {
        case dangerousTechniques
        case properTechniques
        case emergencyProtocols
        case medicalContraindications
        case safetyLimits
    }
    
    /**
     * Comprehensive safety quiz questions
     * RATIONALE: Covers all critical safety topics that could prevent injury or death
     */
    static let allQuestions: [SafetyQuizQuestion] = [
        
        // MARK: - Dangerous Techniques Questions
        
        SafetyQuizQuestion(
            id: 1,
            question: "Which breathing technique is DANGEROUS when combined with breath holding?",
            options: [
                "Diaphragmatic breathing",
                "Box breathing (4-4-4-4)",
                "Wim Hof Method hyperventilation",
                "Gentle extended exhales"
            ],
            correctAnswer: 2,
            explanation: "The Wim Hof Method involves hyperventilation which depletes CO2 and can cause blackouts during breath holding. This has led to drowning deaths.",
            category: .dangerousTechniques
        ),
        
        SafetyQuizQuestion(
            id: 2,
            question: "What is the primary danger of hyperventilation before breath holding?",
            options: [
                "It makes you hold your breath longer",
                "It can cause blackouts without warning",
                "It improves oxygen levels",
                "It strengthens the diaphragm"
            ],
            correctAnswer: 1,
            explanation: "Hyperventilation reduces CO2 levels, which delays the urge to breathe but can cause sudden loss of consciousness without warning signs.",
            category: .dangerousTechniques
        ),
        
        SafetyQuizQuestion(
            id: 3,
            question: "Where should you NEVER practice breath holding?",
            options: [
                "In a comfortable chair",
                "On a yoga mat",
                "In water (pool, bath, ocean)",
                "On your bed"
            ],
            correctAnswer: 2,
            explanation: "Breath holding in water can lead to shallow water blackout and drowning. Many deaths have occurred from this practice.",
            category: .dangerousTechniques
        ),
        
        // MARK: - Safety Limits Questions
        
        SafetyQuizQuestion(
            id: 4,
            question: "What is the maximum safe breath hold time for beginners?",
            options: [
                "30 seconds",
                "2 minutes",
                "5 minutes",
                "As long as possible"
            ],
            correctAnswer: 0,
            explanation: "Beginners should limit breath holds to 30 seconds to build tolerance safely without risk of hypoxia or blackout.",
            category: .safetyLimits
        ),
        
        SafetyQuizQuestion(
            id: 5,
            question: "How often should you practice breath training sessions?",
            options: [
                "Multiple times per day",
                "Once daily with rest days",
                "Continuously throughout the day",
                "Only when feeling stressed"
            ],
            correctAnswer: 1,
            explanation: "Daily practice with rest days allows recovery and prevents overexertion. Continuous practice can lead to respiratory fatigue.",
            category: .safetyLimits
        ),
        
        SafetyQuizQuestion(
            id: 6,
            question: "What should you do if you feel dizzy during breath training?",
            options: [
                "Continue to build tolerance",
                "Breathe faster to compensate",
                "Stop immediately and breathe normally",
                "Hold your breath longer"
            ],
            correctAnswer: 2,
            explanation: "Dizziness indicates insufficient oxygen or CO2 imbalance. Stop immediately and return to normal breathing to prevent fainting.",
            category: .emergencyProtocols
        ),
        
        // MARK: - Medical Contraindications Questions
        
        SafetyQuizQuestion(
            id: 7,
            question: "Who should NOT practice breath holding exercises?",
            options: [
                "Healthy adults only",
                "People with heart conditions, pregnant women, those with respiratory issues",
                "Athletes only",
                "Anyone over 18"
            ],
            correctAnswer: 1,
            explanation: "People with cardiovascular, respiratory conditions, or pregnancy should avoid breath holding due to increased risks of complications.",
            category: .medicalContraindications
        ),
        
        SafetyQuizQuestion(
            id: 8,
            question: "What should you do before starting any breath training program?",
            options: [
                "Start immediately",
                "Consult with a healthcare provider",
                "Practice in water first",
                "Learn advanced techniques first"
            ],
            correctAnswer: 1,
            explanation: "Medical consultation ensures you don't have contraindications and can practice safely based on your health status.",
            category: .medicalContraindications
        ),
        
        // MARK: - Emergency Protocols Questions
        
        SafetyQuizQuestion(
            id: 9,
            question: "What is the first sign that you should stop breath training immediately?",
            options: [
                "Feeling relaxed",
                "Any discomfort, dizziness, or unusual sensations",
                "Improved focus",
                "Slower heart rate"
            ],
            correctAnswer: 1,
            explanation: "Any negative symptoms indicate potential danger. Stop immediately and return to normal breathing patterns.",
            category: .emergencyProtocols
        ),
        
        SafetyQuizQuestion(
            id: 10,
            question: "If someone faints during breath training, what should you do?",
            options: [
                "Continue their breathing exercise",
                "Splash water on their face",
                "Call emergency services and ensure they're breathing normally",
                "Move them to a different position"
            ],
            correctAnswer: 2,
            explanation: "Fainting during breath training is a medical emergency. Call for help and monitor their breathing and consciousness.",
            category: .emergencyProtocols
        ),
        
        // MARK: - Proper Techniques Questions
        
        SafetyQuizQuestion(
            id: 11,
            question: "What is the safest way to practice breath awareness?",
            options: [
                "Holding breath as long as possible",
                "Hyperventilating rapidly",
                "Observing natural breathing without forcing",
                "Breathing as fast as possible"
            ],
            correctAnswer: 2,
            explanation: "Natural breath observation is the safest practice. It builds awareness without forcing dangerous breath patterns.",
            category: .properTechniques
        ),
        
        SafetyQuizQuestion(
            id: 12,
            question: "What characterizes safe diaphragmatic breathing?",
            options: [
                "Rapid, shallow breaths",
                "Slow, deep breaths using the diaphragm",
                "Holding breath between breaths",
                "Breathing only through the mouth"
            ],
            correctAnswer: 1,
            explanation: "Diaphragmatic breathing involves slow, controlled breaths using the diaphragm muscle, which is safe and beneficial.",
            category: .properTechniques
        ),
        
        SafetyQuizQuestion(
            id: 13,
            question: "What is the proper ratio for box breathing?",
            options: [
                "1-1-1-1 (very fast)",
                "4-4-4-4 (moderate pace)",
                "10-10-10-10 (very slow)",
                "Random timing"
            ],
            correctAnswer: 1,
            explanation: "Box breathing with 4-count intervals is safe and effective for most people, providing benefits without strain.",
            category: .properTechniques
        ),
        
        // MARK: - Advanced Safety Questions
        
        SafetyQuizQuestion(
            id: 14,
            question: "Why is it important to practice breath training with supervision initially?",
            options: [
                "It's not necessary",
                "To ensure proper technique and immediate help if needed",
                "To make it more social",
                "To compete with others"
            ],
            correctAnswer: 1,
            explanation: "Supervision ensures safe technique and provides immediate assistance if any adverse reactions occur.",
            category: .emergencyProtocols
        ),
        
        SafetyQuizQuestion(
            id: 15,
            question: "What should you never do while practicing breath holding?",
            options: [
                "Sit comfortably",
                "Practice near water or while driving",
                "Use a timer",
                "Practice indoors"
            ],
            correctAnswer: 1,
            explanation: "Never practice breath holding in situations where loss of consciousness could be dangerous (water, driving, heights).",
            category: .dangerousTechniques
        ),
        
        SafetyQuizQuestion(
            id: 16,
            question: "How should you end a breath training session?",
            options: [
                "With the longest breath hold possible",
                "Abruptly stopping",
                "Gradually returning to normal breathing",
                "With rapid breathing"
            ],
            correctAnswer: 2,
            explanation: "Gradual return to normal breathing prevents sudden changes that could cause dizziness or other adverse effects.",
            category: .properTechniques
        ),
        
        SafetyQuizQuestion(
            id: 17,
            question: "What is the most important rule for breath training?",
            options: [
                "Push your limits every session",
                "Never feel discomfort",
                "Listen to your body and stop if anything feels wrong",
                "Practice for hours at a time"
            ],
            correctAnswer: 2,
            explanation: "Body awareness and immediate response to warning signs is the most critical safety principle in breath training.",
            category: .emergencyProtocols
        ),
        
        SafetyQuizQuestion(
            id: 18,
            question: "Why do we emphasize safety so heavily in breath training?",
            options: [
                "To make it less enjoyable",
                "Because breath training can be dangerous if done incorrectly",
                "To waste time",
                "It's not really necessary"
            ],
            correctAnswer: 1,
            explanation: "Improper breath training has caused serious injuries and deaths. Safety education prevents these tragedies.",
            category: .emergencyProtocols
        )
    ]
    
    /**
     * Calculates quiz score based on correct answers
     * RATIONALE: 80% passing grade ensures solid understanding of safety concepts
     */
    static func calculateScore(answers: [Int]) -> Double {
        guard answers.count == allQuestions.count else { return 0.0 }
        
        let correctAnswers = zip(answers, allQuestions).reduce(0) { count, pair in
            let (userAnswer, question) = pair
            return count + (userAnswer == question.correctAnswer ? 1 : 0)
        }
        
        return Double(correctAnswers) / Double(allQuestions.count)
    }
    
    /**
     * Gets questions by category for focused review
     * RATIONALE: Allows users to review specific safety topics if needed
     */
    static func questions(for category: SafetyCategory) -> [SafetyQuizQuestion] {
        return allQuestions.filter { $0.category == category }
    }
    
    /**
     * Identifies failed questions for review
     * RATIONALE: Helps users understand which safety concepts need reinforcement
     */
    static func failedQuestions(answers: [Int]) -> [SafetyQuizQuestion] {
        guard answers.count == allQuestions.count else { return [] }
        
        return zip(answers, allQuestions).compactMap { pair in
            let (userAnswer, question) = pair
            return userAnswer != question.correctAnswer ? question : nil
        }
    }
} 