import SwiftUI

/**
 * ProperTechniquesStepView: Education about safe and effective breathing techniques
 * 
 * PURPOSE: Teaches users the scientifically-validated breathing techniques that
 * are safe for breath-holding training. This provides the positive education
 * after warning about dangerous techniques.
 * 
 * SAFETY DESIGN: All techniques taught here are proven safe and effective
 * for gradual breath-holding improvement without dangerous side effects.
 */
struct ProperTechniquesStepView: View {
    
    @State private var selectedTechnique: ProperTechnique? = nil
    @State private var showTechniqueDemo: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Proper Techniques")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Learn safe, scientifically-validated breathing techniques that will improve your breath-holding capacity gradually and safely.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Safety principles banner
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        
                        Text("These techniques are scientifically proven safe")
                            .font(.headline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    Text("All techniques below have been researched and validated by respiratory physiologists and safety experts. They improve breath-holding capacity through safe, natural methods.")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                )
                
                // Proper techniques
                VStack(spacing: 20) {
                    
                    ProperTechniqueCard(
                        technique: .boxBreathing,
                        title: "✅ Box Breathing (4-4-4-4)",
                        subtitle: "FOUNDATION TECHNIQUE",
                        safetyLevel: .foundational,
                        description: "Equal counts for inhale, hold, exhale, hold - builds control and calm.",
                        benefits: [
                            "Develops breathing rhythm and control",
                            "Reduces anxiety and stress",
                            "Improves focus and concentration",
                            "Safe for all experience levels",
                            "No risk of hyperventilation"
                        ],
                        howItWorks: "Box breathing maintains normal CO2 levels while training breath control. The equal timing develops respiratory muscle control without depleting safety warning systems.",
                        safetyNotes: "Completely safe for daily practice. If you feel dizzy, simply breathe normally.",
                        isSelected: selectedTechnique == .boxBreathing,
                        onSelect: {
                            selectedTechnique = .boxBreathing
                        }
                    )
                    
                    ProperTechniqueCard(
                        technique: .diaphragmaticBreathing,
                        title: "✅ Diaphragmatic Breathing",
                        subtitle: "EFFICIENCY TECHNIQUE",
                        safetyLevel: .foundational,
                        description: "Deep belly breathing that maximizes oxygen intake and improves efficiency.",
                        benefits: [
                            "Increases oxygen uptake efficiency",
                            "Strengthens respiratory muscles",
                            "Improves lung capacity utilization",
                            "Reduces breathing effort",
                            "Enhances relaxation response"
                        ],
                        howItWorks: "Diaphragmatic breathing uses the full lung capacity by engaging the diaphragm muscle. This increases oxygen intake per breath and improves overall breathing efficiency.",
                        safetyNotes: "Natural and safe technique. Practice lying down initially to feel the proper movement.",
                        isSelected: selectedTechnique == .diaphragmaticBreathing,
                        onSelect: {
                            selectedTechnique = .diaphragmaticBreathing
                        }
                    )
                    
                    ProperTechniqueCard(
                        technique: .co2ToleranceTables,
                        title: "✅ CO2 Tolerance Tables",
                        subtitle: "PROGRESSIVE TRAINING",
                        safetyLevel: .intermediate,
                        description: "Gradual exposure to higher CO2 levels to improve breath-holding comfort.",
                        benefits: [
                            "Increases CO2 tolerance safely",
                            "Improves breath-holding duration",
                            "Maintains natural warning systems",
                            "Progressive, controlled improvement",
                            "Scientifically validated method"
                        ],
                        howItWorks: "CO2 tables gradually increase breath-holding time while maintaining normal preparation breathing. This trains your body to tolerate higher CO2 levels naturally, which is the key to longer breath holds.",
                        safetyNotes: "Must follow exact protocols. Never skip preparation breaths or exceed recommended times.",
                        isSelected: selectedTechnique == .co2ToleranceTables,
                        onSelect: {
                            selectedTechnique = .co2ToleranceTables
                        }
                    )
                    
                    ProperTechniqueCard(
                        technique: .relaxationBreathing,
                        title: "✅ Relaxation Breathing",
                        subtitle: "PREPARATION TECHNIQUE",
                        safetyLevel: .foundational,
                        description: "Slow, controlled breathing to achieve optimal relaxation before breath holds.",
                        benefits: [
                            "Reduces heart rate and oxygen consumption",
                            "Activates parasympathetic nervous system",
                            "Improves mental state for training",
                            "Enhances body awareness",
                            "Prepares for longer breath holds"
                        ],
                        howItWorks: "Slow, controlled breathing activates the body's relaxation response, reducing oxygen consumption and heart rate. This creates optimal conditions for breath-holding practice.",
                        safetyNotes: "Completely safe. If you feel lightheaded, simply breathe at your normal pace.",
                        isSelected: selectedTechnique == .relaxationBreathing,
                        onSelect: {
                            selectedTechnique = .relaxationBreathing
                        }
                    )
                }
                
                // Key principles summary
                VStack(spacing: 16) {
                    Text("🎯 Key Training Principles")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 12) {
                        TrainingPrincipleRow(
                            icon: "tortoise.fill",
                            title: "Gradual Progression",
                            description: "Improve slowly over weeks and months, not days"
                        )
                        
                        TrainingPrincipleRow(
                            icon: "arrow.clockwise",
                            title: "Consistency Over Intensity",
                            description: "Regular practice beats occasional extreme sessions"
                        )
                        
                        TrainingPrincipleRow(
                            icon: "ear.fill",
                            title: "Listen to Your Body",
                            description: "Respect your limits and stop when uncomfortable"
                        )
                        
                        TrainingPrincipleRow(
                            icon: "shield.checkered",
                            title: "Safety First Always",
                            description: "Never compromise safety for performance"
                        )
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showTechniqueDemo) {
            if let technique = selectedTechnique {
                TechniqueDemoView(technique: technique)
            }
        }
    }
}

/**
 * ProperTechnique: Enumeration of safe breathing techniques
 */
enum ProperTechnique: CaseIterable {
    case boxBreathing
    case diaphragmaticBreathing
    case co2ToleranceTables
    case relaxationBreathing
}

/**
 * SafetyLevel: Safety level classification for techniques
 */
enum SafetyLevel {
    case foundational
    case intermediate
    case advanced
    
    var color: Color {
        switch self {
        case .foundational: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        }
    }
    
    var displayName: String {
        switch self {
        case .foundational: return "Foundational"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

/**
 * ProperTechniqueCard: Individual proper technique education card
 */
struct ProperTechniqueCard: View {
    let technique: ProperTechnique
    let title: String
    let subtitle: String
    let safetyLevel: SafetyLevel
    let description: String
    let benefits: [String]
    let howItWorks: String
    let safetyNotes: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(safetyLevel.color)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Safety level badge
                    Text(safetyLevel.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(safetyLevel.color.opacity(0.2))
                        .foregroundColor(safetyLevel.color)
                        .cornerRadius(4)
                }
            }
            
            // Description
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Content sections
            VStack(alignment: .leading, spacing: 12) {
                
                TechniqueSection(
                    title: "Benefits:",
                    icon: "star.fill",
                    color: .green,
                    content: .list(benefits)
                )
                
                TechniqueSection(
                    title: "How It Works:",
                    icon: "brain.head.profile",
                    color: .blue,
                    content: .text(howItWorks)
                )
                
                TechniqueSection(
                    title: "Safety Notes:",
                    icon: "shield.checkered",
                    color: .orange,
                    content: .text(safetyNotes)
                )
            }
            
            // Selection button
            Button(action: onSelect) {
                HStack {
                    Text("Learn This Technique")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .green : .blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 1)
        )
    }
}

/**
 * TechniqueSection: Individual section within a technique card
 */
struct TechniqueSection: View {
    let title: String
    let icon: String
    let color: Color
    let content: TechniqueSectionContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            switch content {
            case .text(let text):
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 24)
                
            case .list(let items):
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .foregroundColor(color)
                                .font(.caption)
                            
                            Text(item)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 24)
            }
        }
    }
}

/**
 * TechniqueSectionContent: Content type for technique sections
 */
enum TechniqueSectionContent {
    case text(String)
    case list([String])
}

/**
 * TrainingPrincipleRow: Individual training principle display
 */
struct TrainingPrincipleRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

/**
 * TechniqueDemoView: Technique demonstration modal
 */
struct TechniqueDemoView: View {
    let technique: ProperTechnique
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Technique Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Interactive demonstration will be implemented in future phases")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProperTechniquesStepView()
} 