import SwiftUI

/**
 * BreathingTechniquesView: Main view for breathing technique tutorials
 * 
 * PURPOSE: Provides access to guided breathing technique tutorials including
 * box breathing and diaphragmatic breathing. Serves as the educational hub
 * for proper breathing techniques before training sessions.
 * 
 * SAFETY FOCUS: All techniques are safe for all users and focus on
 * relaxation and proper breathing form rather than performance.
 */
struct BreathingTechniquesView: View {
    
    // MARK: - Dependencies
    
    @StateObject private var audioController = AudioController()
    @EnvironmentObject private var safetyValidator: SafetyValidator
    
    // MARK: - State
    
    @State private var selectedTechnique: BreathingTechnique?
    @State private var showingTutorial = false
    @State private var techniques: [BreathingTechnique] = []
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header Section
                    headerSection
                    
                    // Safety Reminder
                    safetyReminderSection
                    
                    // Techniques List
                    techniquesSection
                    
                    // Benefits Section
                    benefitsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Breathing Techniques")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTechniques()
            }
        }
        .sheet(item: $selectedTechnique) { technique in
            BreathingTutorialView(
                technique: technique,
                audioController: audioController
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            
            Image(systemName: "lungs.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("Master Your Breath")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Learn safe, effective breathing techniques that will improve your breath control and prepare you for training sessions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Safety Reminder Section
    
    private var safetyReminderSection: some View {
        VStack(spacing: 12) {
            
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Safety First")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                SafetyPointView(
                    icon: "checkmark.circle.fill",
                    text: "All techniques are completely safe for everyone",
                    color: .green
                )
                
                SafetyPointView(
                    icon: "exclamationmark.triangle.fill",
                    text: "Stop immediately if you feel dizzy or uncomfortable",
                    color: .orange
                )
                
                SafetyPointView(
                    icon: "heart.fill",
                    text: "Focus on relaxation and natural breathing patterns",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Techniques Section
    
    private var techniquesSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Available Techniques")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(techniques) { technique in
                    TechniqueCardView(technique: technique) {
                        selectedTechnique = technique
                    }
                }
            }
        }
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Why Practice Breathing Techniques?")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                
                BenefitRowView(
                    icon: "brain.head.profile",
                    title: "Improved Focus",
                    description: "Better concentration and mental clarity"
                )
                
                BenefitRowView(
                    icon: "heart.circle",
                    title: "Stress Reduction",
                    description: "Activates relaxation response and reduces anxiety"
                )
                
                BenefitRowView(
                    icon: "lungs",
                    title: "Better Breath Control",
                    description: "Develops awareness and control of breathing patterns"
                )
                
                BenefitRowView(
                    icon: "moon.zzz",
                    title: "Improved Sleep",
                    description: "Calms the nervous system for better rest"
                )
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadTechniques() {
        techniques = BreathingTechnique.defaultTechniques
    }
}

// MARK: - Supporting Views

/**
 * TechniqueCardView: Card displaying a breathing technique
 */
struct TechniqueCardView: View {
    let technique: BreathingTechnique
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(technique.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(technique.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        Text("\(Int(technique.duration / 60)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Difficulty and Category Tags
                HStack {
                    DifficultyTagView(difficulty: technique.difficulty)
                    CategoryTagView(category: technique.category)
                    Spacer()
                }
                
                // Benefits Preview
                if !technique.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Benefits:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(technique.benefits.prefix(2).joined(separator: " • "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/**
 * DifficultyTagView: Shows technique difficulty level
 */
struct DifficultyTagView: View {
    let difficulty: TechniqueDifficulty
    
    var body: some View {
        Text(difficulty.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.2))
            .foregroundColor(difficultyColor)
            .cornerRadius(6)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

/**
 * CategoryTagView: Shows technique category
 */
struct CategoryTagView: View {
    let category: TechniqueCategory
    
    var body: some View {
        Text(category.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(6)
    }
}

/**
 * SafetyPointView: Displays a safety point with icon
 */
struct SafetyPointView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

/**
 * BenefitRowView: Displays a benefit with icon and description
 */
struct BenefitRowView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct BreathingTechniquesView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingTechniquesView()
            .environmentObject(SafetyValidator())
    }
} 