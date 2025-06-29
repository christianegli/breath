import SwiftUI

/**
 * TrainingHomeView: Main training interface for safety-validated users
 * 
 * PURPOSE: This is the main training dashboard that users see after completing
 * mandatory safety education. It provides access to all breath training features
 * while maintaining safety oversight.
 * 
 * SAFETY RATIONALE: Only accessible after completing safety education and
 * passing the safety quiz. Continues to provide safety reminders and monitoring.
 * 
 * ARCHITECTURE DECISION: Placeholder implementation for now - will be expanded
 * with full training features in subsequent development phases.
 */
struct TrainingHomeView: View {
    
    /**
     * Safety validator for ongoing safety monitoring
     * RATIONALE: Even after education completion, safety validation continues
     */
    @EnvironmentObject var safetyValidator: SafetyValidator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // MARK: - Welcome Header
                VStack(spacing: 16) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Welcome to Breath Training!")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    Text("You've successfully completed safety education and can now access training features.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // MARK: - Safety Status
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Safety Education Complete")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    
                    Text("Quiz Score: \(Int(safetyValidator.safetyQuizScore * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Education completed on \(safetyValidator.safetyEducationCompletionDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // MARK: - Coming Soon Features
                VStack(spacing: 16) {
                    Text("Training Features Coming Soon")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        FeaturePreviewCard(
                            icon: "wind",
                            title: "Breathing Techniques",
                            description: "Learn safe diaphragmatic and box breathing"
                        )
                        
                        FeaturePreviewCard(
                            icon: "timer",
                            title: "Guided Sessions",
                            description: "Structured training with safety monitoring"
                        )
                        
                        FeaturePreviewCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress Tracking",
                            description: "Monitor your improvement safely"
                        )
                        
                        FeaturePreviewCard(
                            icon: "trophy",
                            title: "Achievements",
                            description: "Celebrate consistency and safety"
                        )
                    }
                }
                
                Spacer()
                
                // MARK: - Safety Reminder
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Safety Reminder")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text("Always listen to your body and stop immediately if you feel any discomfort, dizziness, or unusual sensations.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Breath Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Safety Info") {
                        // Show safety information
                    }
                    .foregroundColor(.blue)
                    .font(.caption.weight(.semibold))
                }
            }
        }
    }
}

/**
 * FeaturePreviewCard: Preview card for upcoming training features
 */
struct FeaturePreviewCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Soon")
                .font(.caption.weight(.medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TrainingHomeView()
        .environmentObject(SafetyValidator())
} 