import SwiftUI

/**
 * DangerousTechniquesStepView: Education about dangerous breathing techniques
 * 
 * PURPOSE: Critical education about breathing techniques that are popular
 * but dangerous for breath-holding. This step could save lives by preventing
 * users from using unsafe techniques they may have learned elsewhere.
 * 
 * SAFETY CRITICAL: This education directly addresses dangerous misinformation
 * that is widely available online. Users must understand why certain
 * techniques are dangerous before they can access training features.
 */
struct DangerousTechniquesStepView: View {
    
    @State private var acknowledgedDangers: Set<String> = []
    @State private var showWimHofWarning: Bool = false
    @State private var showHyperventilationWarning: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Dangerous Techniques")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("CRITICAL: Learn about popular but dangerous breathing techniques that you must NEVER use for breath-holding training.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Warning banner
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text("These techniques can cause blackouts and death")
                            .font(.headline)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    Text("The techniques below are widely promoted online but are scientifically proven to be dangerous for breath-holding. Understanding why they're dangerous is essential for your safety.")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 2)
                )
                
                // Dangerous techniques
                VStack(spacing: 20) {
                    
                    DangerousTechniqueCard(
                        title: "❌ Wim Hof Method for Breath-Holding",
                        subtitle: "EXTREMELY DANGEROUS",
                        dangerLevel: .extreme,
                        whyPopular: "Promoted by Wim Hof and widely available online. Seems to improve breath-holding performance initially.",
                        whyDangerous: """
                        • Creates FALSE confidence by depleting CO2
                        • Reduces oxygen warning signals in your brain
                        • Can cause blackouts at dangerous oxygen levels
                        • Multiple deaths documented from this technique
                        • Especially deadly in or near water
                        """,
                        science: "Research shows the Wim Hof breathing method reduces CO2 levels, which normally trigger the urge to breathe. This creates a false sense of breath-holding ability while actually making blackouts more likely.",
                        isAcknowledged: acknowledgedDangers.contains("wimhof"),
                        onAcknowledge: {
                            acknowledgedDangers.insert("wimhof")
                        },
                        onLearnMore: {
                            showWimHofWarning = true
                        }
                    )
                    
                    DangerousTechniqueCard(
                        title: "❌ Hyperventilation (Any Form)",
                        subtitle: "UNIVERSALLY DANGEROUS",
                        dangerLevel: .extreme,
                        whyPopular: "Seems to allow longer breath holds and is often taught in martial arts or online tutorials.",
                        whyDangerous: """
                        • Depletes CO2 which is your safety warning system
                        • Creates hypocapnia (dangerously low CO2)
                        • Can cause immediate blackouts without warning
                        • Reduces oxygen delivery to the brain
                        • Contraindicated by all medical authorities
                        """,
                        science: "Hyperventilation removes CO2 from your blood, which eliminates the urge to breathe. However, CO2 levels, not oxygen levels, trigger breathing. This can lead to unconsciousness from oxygen depletion without any warning.",
                        isAcknowledged: acknowledgedDangers.contains("hyperventilation"),
                        onAcknowledge: {
                            acknowledgedDangers.insert("hyperventilation")
                        },
                        onLearnMore: {
                            showHyperventilationWarning = true
                        }
                    )
                    
                    DangerousTechniqueCard(
                        title: "⚠️ Breath-Holding in Water",
                        subtitle: "POTENTIALLY FATAL",
                        dangerLevel: .fatal,
                        whyPopular: "Seems natural and is promoted in freediving communities without proper safety protocols.",
                        whyDangerous: """
                        • Shallow water blackout can occur without warning
                        • Drowning is silent and happens quickly
                        • Even experienced swimmers can lose consciousness
                        • Cold water increases risk significantly
                        • No safe way to practice alone
                        """,
                        science: "Shallow water blackout occurs when oxygen levels drop to unconsciousness levels while CO2 levels remain low. This happens without warning signs, leading to drowning even in shallow water.",
                        isAcknowledged: acknowledgedDangers.contains("water"),
                        onAcknowledge: {
                            acknowledgedDangers.insert("water")
                        },
                        onLearnMore: { }
                    )
                    
                    DangerousTechniqueCard(
                        title: "⚠️ Competitive Breath-Holding",
                        subtitle: "HIGH RISK",
                        dangerLevel: .high,
                        whyPopular: "Social media challenges and competitions make breath-holding seem like a game or sport.",
                        whyDangerous: """
                        • Peer pressure leads to unsafe limits
                        • Encourages ignoring safety signals
                        • Creates performance anxiety and risk-taking
                        • Often combined with other dangerous techniques
                        • Removes focus from safety and technique
                        """,
                        science: "Competition creates psychological pressure to exceed safe limits. The stress response can also affect breathing patterns and increase oxygen consumption, making blackouts more likely.",
                        isAcknowledged: acknowledgedDangers.contains("competition"),
                        onAcknowledge: {
                            acknowledgedDangers.insert("competition")
                        },
                        onLearnMore: { }
                    )
                }
                
                // Summary and commitment
                if acknowledgedDangers.count >= 3 {
                    VStack(spacing: 16) {
                        Text("✅ Safety Commitment")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        VStack(spacing: 12) {
                            CommitmentCheckbox(
                                text: "I understand these techniques are dangerous and can cause death",
                                isChecked: acknowledgedDangers.contains("understand")
                            ) {
                                if acknowledgedDangers.contains("understand") {
                                    acknowledgedDangers.remove("understand")
                                } else {
                                    acknowledgedDangers.insert("understand")
                                }
                            }
                            
                            CommitmentCheckbox(
                                text: "I commit to NEVER using hyperventilation or Wim Hof method for breath-holding",
                                isChecked: acknowledgedDangers.contains("commit")
                            ) {
                                if acknowledgedDangers.contains("commit") {
                                    acknowledgedDangers.remove("commit")
                                } else {
                                    acknowledgedDangers.insert("commit")
                                }
                            }
                            
                            CommitmentCheckbox(
                                text: "I will NEVER practice breath-holding in or near water",
                                isChecked: acknowledgedDangers.contains("water-commit")
                            ) {
                                if acknowledgedDangers.contains("water-commit") {
                                    acknowledgedDangers.remove("water-commit")
                                } else {
                                    acknowledgedDangers.insert("water-commit")
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .alert("Wim Hof Method Warning", isPresented: $showWimHofWarning) {
            Button("I Understand") { }
        } message: {
            Text("The Wim Hof breathing method has been directly linked to multiple deaths when used for breath-holding. It creates a dangerous false confidence by reducing CO2 levels while not improving actual oxygen capacity. NEVER use this method for breath-holding training.")
        }
        .alert("Hyperventilation Warning", isPresented: $showHyperventilationWarning) {
            Button("I Understand") { }
        } message: {
            Text("Hyperventilation before breath-holding is universally condemned by medical authorities and safety experts. It removes your body's natural warning system (CO2 buildup) and can cause sudden blackouts without warning. This technique has caused numerous deaths.")
        }
    }
}

/**
 * DangerLevel: Enumeration of danger levels for techniques
 */
enum DangerLevel {
    case high
    case extreme
    case fatal
    
    var color: Color {
        switch self {
        case .high: return .orange
        case .extreme: return .red
        case .fatal: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .high: return "exclamationmark.triangle.fill"
        case .extreme: return "xmark.octagon.fill"
        case .fatal: return "skull.fill"
        }
    }
}

/**
 * DangerousTechniqueCard: Individual dangerous technique education card
 */
struct DangerousTechniqueCard: View {
    let title: String
    let subtitle: String
    let dangerLevel: DangerLevel
    let whyPopular: String
    let whyDangerous: String
    let science: String
    let isAcknowledged: Bool
    let onAcknowledge: () -> Void
    let onLearnMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: dangerLevel.icon)
                        .foregroundColor(dangerLevel.color)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(dangerLevel.color)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
            }
            
            // Content sections
            VStack(alignment: .leading, spacing: 12) {
                
                EducationSection(
                    title: "Why It's Popular:",
                    content: whyPopular,
                    icon: "questionmark.circle",
                    color: .blue
                )
                
                EducationSection(
                    title: "Why It's Dangerous:",
                    content: whyDangerous,
                    icon: "exclamationmark.triangle",
                    color: .red
                )
                
                EducationSection(
                    title: "The Science:",
                    content: science,
                    icon: "brain",
                    color: .purple
                )
            }
            
            // Acknowledgment
            Button(action: onAcknowledge) {
                HStack(spacing: 12) {
                    Image(systemName: isAcknowledged ? "checkmark.square.fill" : "square")
                        .foregroundColor(isAcknowledged ? .green : .gray)
                        .font(.title2)
                    
                    Text("I understand why this technique is dangerous")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(dangerLevel.color, lineWidth: 2)
        )
    }
}

/**
 * EducationSection: Individual education section within a card
 */
struct EducationSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
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
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, 24) // Align with icon
    }
}

/**
 * CommitmentCheckbox: Safety commitment checkbox
 */
struct CommitmentCheckbox: View {
    let text: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .green : .gray)
                    .font(.title2)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

#Preview {
    DangerousTechniquesStepView()
} 