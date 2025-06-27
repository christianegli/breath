import SwiftUI

/**
 * SafetyQuizStepView: Comprehensive safety knowledge validation quiz
 * 
 * PURPOSE: Validates that users have understood critical safety concepts
 * before accessing training features. This quiz ensures users can identify
 * dangerous techniques and understand proper safety protocols.
 * 
 * SAFETY CRITICAL: Users must achieve 80% or higher to pass. Questions
 * focus on life-threatening safety issues and proper technique identification.
 */
struct SafetyQuizStepView: View {
    @Binding var answers: [SafetyQuizAnswer]
    
    @State private var currentQuestionIndex: Int = 0
    @State private var selectedAnswers: [String: String] = [:]
    @State private var quizCompleted: Bool = false
    @State private var quizScore: Double = 0.0
    @State private var showResults: Bool = false
    
    private let questions = SafetyQuizQuestion.allQuestions
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Quiz header
            QuizHeaderView(
                currentQuestion: currentQuestionIndex + 1,
                totalQuestions: questions.count,
                score: quizCompleted ? quizScore : nil
            )
            
            if !quizCompleted {
                // Question content
                ScrollView {
                    VStack(spacing: 24) {
                        
                        let currentQuestion = questions[currentQuestionIndex]
                        
                        QuizQuestionView(
                            question: currentQuestion,
                            selectedAnswer: selectedAnswers[currentQuestion.id],
                            onAnswerSelected: { answer in
                                selectedAnswers[currentQuestion.id] = answer
                            }
                        )
                    }
                    .padding()
                }
                
                // Navigation controls
                QuizNavigationView(
                    currentIndex: currentQuestionIndex,
                    totalQuestions: questions.count,
                    canProceed: selectedAnswers[questions[currentQuestionIndex].id] != nil,
                    onPrevious: {
                        if currentQuestionIndex > 0 {
                            currentQuestionIndex -= 1
                        }
                    },
                    onNext: {
                        if currentQuestionIndex < questions.count - 1 {
                            currentQuestionIndex += 1
                        } else {
                            completeQuiz()
                        }
                    }
                )
            } else {
                // Quiz results
                QuizResultsView(
                    score: quizScore,
                    totalQuestions: questions.count,
                    passThreshold: 0.8,
                    onRetake: retakeQuiz,
                    onViewDetails: { showResults = true }
                )
            }
        }
        .sheet(isPresented: $showResults) {
            QuizResultsDetailView(
                questions: questions,
                userAnswers: selectedAnswers,
                onDismiss: { showResults = false }
            )
        }
    }
    
    // MARK: - Private Methods
    
    /**
     * Complete the quiz and calculate results
     */
    private func completeQuiz() {
        // Calculate score
        var correctCount = 0
        var quizAnswers: [SafetyQuizAnswer] = []
        
        for question in questions {
            let userAnswer = selectedAnswers[question.id] ?? ""
            let isCorrect = userAnswer == question.correctAnswer
            
            if isCorrect {
                correctCount += 1
            }
            
            quizAnswers.append(SafetyQuizAnswer(
                questionId: question.id,
                selectedAnswer: userAnswer,
                correctAnswer: question.correctAnswer
            ))
        }
        
        quizScore = Double(correctCount) / Double(questions.count)
        answers = quizAnswers
        quizCompleted = true
    }
    
    /**
     * Reset quiz for retake
     */
    private func retakeQuiz() {
        currentQuestionIndex = 0
        selectedAnswers.removeAll()
        quizCompleted = false
        quizScore = 0.0
        answers.removeAll()
    }
}

/**
 * QuizHeaderView: Quiz progress and scoring header
 */
struct QuizHeaderView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Double?
    
    var body: some View {
        VStack(spacing: 12) {
            
            if let score = score {
                // Results header
                VStack(spacing: 8) {
                    Text("Quiz Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(score >= 0.8 ? .green : .red)
                    
                    Text("Score: \(Int(score * 100))%")
                        .font(.title3)
                        .foregroundColor(score >= 0.8 ? .green : .red)
                }
            } else {
                // Progress header
                VStack(spacing: 8) {
                    Text("Safety Knowledge Quiz")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Question \(currentQuestion) of \(totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(currentQuestion), total: Double(totalQuestions))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

/**
 * QuizQuestionView: Individual quiz question display
 */
struct QuizQuestionView: View {
    let question: SafetyQuizQuestion
    let selectedAnswer: String?
    let onAnswerSelected: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Question header
            VStack(alignment: .leading, spacing: 12) {
                
                // Category badge
                HStack {
                    Text(question.category.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(question.category.color.opacity(0.2))
                        .foregroundColor(question.category.color)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Importance indicator
                    if question.isCritical {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("Critical")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                // Question text
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Context if provided
                if let context = question.context {
                    Text(context)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    QuizAnswerOption(
                        text: option,
                        isSelected: selectedAnswer == option,
                        onSelect: {
                            onAnswerSelected(option)
                        }
                    )
                }
            }
        }
    }
}

/**
 * QuizAnswerOption: Individual answer option button
 */
struct QuizAnswerOption: View {
    let text: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/**
 * QuizNavigationView: Quiz navigation controls
 */
struct QuizNavigationView: View {
    let currentIndex: Int
    let totalQuestions: Int
    let canProceed: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            
            if currentIndex > 0 {
                Button("Previous") {
                    onPrevious()
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(currentIndex == totalQuestions - 1 ? "Complete Quiz" : "Next") {
                onNext()
            }
            .foregroundColor(canProceed ? .blue : .gray)
            .fontWeight(.semibold)
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

/**
 * QuizResultsView: Quiz completion results
 */
struct QuizResultsView: View {
    let score: Double
    let totalQuestions: Int
    let passThreshold: Double
    let onRetake: () -> Void
    let onViewDetails: () -> Void
    
    private var passed: Bool {
        score >= passThreshold
    }
    
    private var correctAnswers: Int {
        Int(score * Double(totalQuestions))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Results header
                VStack(spacing: 16) {
                    Image(systemName: passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(passed ? .green : .red)
                    
                    Text(passed ? "Quiz Passed!" : "Quiz Not Passed")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(passed ? .green : .red)
                    
                    Text("Score: \(Int(score * 100))% (\(correctAnswers)/\(totalQuestions) correct)")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                // Pass/fail message
                VStack(spacing: 12) {
                    if passed {
                        VStack(spacing: 8) {
                            Text("Congratulations!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("You have demonstrated sufficient understanding of safety principles to access training features.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text("Additional Study Required")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("You need at least 80% to pass. Please review the safety education materials and retake the quiz.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(passed ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(12)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("View Detailed Results") {
                        onViewDetails()
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    
                    if !passed {
                        Button("Retake Quiz") {
                            onRetake()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
}

/**
 * QuizResultsDetailView: Detailed quiz results modal
 */
struct QuizResultsDetailView: View {
    let questions: [SafetyQuizQuestion]
    let userAnswers: [String: String]
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        QuizResultDetailCard(
                            questionNumber: index + 1,
                            question: question,
                            userAnswer: userAnswers[question.id] ?? "",
                            isCorrect: userAnswers[question.id] == question.correctAnswer
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Quiz Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

/**
 * QuizResultDetailCard: Individual question result detail
 */
struct QuizResultDetailCard: View {
    let questionNumber: Int
    let question: SafetyQuizQuestion
    let userAnswer: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text("Question \(questionNumber)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.title2)
            }
            
            // Question
            Text(question.question)
                .font(.body)
                .foregroundColor(.primary)
            
            // User answer
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Answer:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(userAnswer)
                    .font(.body)
                    .foregroundColor(isCorrect ? .green : .red)
                    .fontWeight(.semibold)
            }
            
            // Correct answer if wrong
            if !isCorrect {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Correct Answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.correctAnswer)
                        .font(.body)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            // Explanation
            if let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explanation:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(explanation)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    SafetyQuizStepView(answers: .constant([]))
} 