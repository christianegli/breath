import SwiftUI

/**
 * SafetyEducationProgressView: Visual progress indicator for safety education
 * 
 * PURPOSE: Shows users their progress through the mandatory safety education
 * steps. Provides clear visual feedback about completion status and remaining
 * steps to encourage completion.
 * 
 * RATIONALE: Visual progress indicators improve completion rates and help
 * users understand the scope of safety education required.
 */
struct SafetyEducationProgressView: View {
    let currentStep: SafetyEducationStep
    let totalSteps: Int
    let animate: Bool
    
    private var progress: Double {
        return Double(currentStep.stepNumber) / Double(totalSteps)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            // MARK: - Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Safety Education Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(currentStep.stepNumber) of \(totalSteps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.5), value: animate)
                    }
                }
                .frame(height: 8)
            }
            
            // MARK: - Step Indicator
            HStack {
                Text("Current Step:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(currentStep.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if progress < 1.0 {
                    Text("\(Int((1.0 - progress) * 100))% remaining")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Complete")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        SafetyEducationProgressView(
            currentStep: .ageVerification,
            totalSteps: 8,
            animate: false
        )
        
        SafetyEducationProgressView(
            currentStep: .safetyQuiz,
            totalSteps: 8,
            animate: true
        )
        
        SafetyEducationProgressView(
            currentStep: .completion,
            totalSteps: 8,
            animate: false
        )
    }
    .padding()
} 