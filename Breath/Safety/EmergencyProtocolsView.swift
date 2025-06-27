import SwiftUI

/**
 * EmergencyProtocolsStepView: Emergency response and safety protocols education
 * 
 * PURPOSE: Teaches users how to recognize emergencies, respond appropriately,
 * and prevent dangerous situations during breath training. This could save
 * lives by ensuring users know how to handle emergency situations.
 * 
 * SAFETY CRITICAL: Emergency protocols are essential knowledge that every
 * user must understand before accessing training features.
 */
struct EmergencyProtocolsStepView: View {
    
    @State private var acknowledgedProtocols: Set<String> = []
    @State private var showEmergencyDemo: Bool = false
    @State private var selectedProtocol: EmergencyProtocol? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "cross.case.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Emergency Protocols")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("Learn essential emergency response procedures and warning signs that could save your life or someone else's during breath training.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Emergency banner
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text("Emergency preparedness is mandatory")
                            .font(.headline)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    Text("Every breath training practitioner must know how to recognize and respond to emergency situations. This knowledge could save a life.")
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
                
                // Warning signs section
                WarningSignsSection()
                
                // Emergency response protocols
                VStack(spacing: 20) {
                    
                    Text("🚨 Emergency Response Protocols")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    EmergencyProtocolCard(
                        protocol: .unconsciousness,
                        title: "Loss of Consciousness",
                        severity: .critical,
                        signs: [
                            "Person becomes unresponsive",
                            "Stops breathing normally",
                            "No response to voice or touch",
                            "Possible convulsions or jerking"
                        ],
                        immediateActions: [
                            "Check for breathing and pulse",
                            "Call emergency services (911) immediately",
                            "Place in recovery position if breathing",
                            "Begin CPR if not breathing",
                            "Stay with person until help arrives"
                        ],
                        prevention: [
                            "Never practice dangerous techniques",
                            "Always have supervision",
                            "Respect safety limits",
                            "Stop at first sign of distress"
                        ],
                        isAcknowledged: acknowledgedProtocols.contains("unconsciousness"),
                        onAcknowledge: {
                            acknowledgedProtocols.insert("unconsciousness")
                        }
                    )
                    
                    EmergencyProtocolCard(
                        protocol: .severeDizziness,
                        title: "Severe Dizziness or Fainting",
                        severity: .high,
                        signs: [
                            "Extreme dizziness or lightheadedness",
                            "Feeling like you might faint",
                            "Vision changes or tunnel vision",
                            "Nausea or vomiting",
                            "Confusion or disorientation"
                        ],
                        immediateActions: [
                            "Stop breath training immediately",
                            "Sit or lie down safely",
                            "Breathe normally and deeply",
                            "If symptoms persist, seek medical help",
                            "Do not attempt to continue training"
                        ],
                        prevention: [
                            "Start with very short holds",
                            "Progress gradually over weeks",
                            "Never push through discomfort",
                            "Maintain proper nutrition and hydration"
                        ],
                        isAcknowledged: acknowledgedProtocols.contains("dizziness"),
                        onAcknowledge: {
                            acknowledgedProtocols.insert("dizziness")
                        }
                    )
                    
                    EmergencyProtocolCard(
                        protocol: .chestPain,
                        title: "Chest Pain or Breathing Difficulty",
                        severity: .critical,
                        signs: [
                            "Chest pain or pressure",
                            "Difficulty breathing normally",
                            "Rapid or irregular heartbeat",
                            "Sweating or clamminess",
                            "Pain radiating to arms or jaw"
                        ],
                        immediateActions: [
                            "Stop all activity immediately",
                            "Call emergency services (911)",
                            "Sit upright and try to stay calm",
                            "Take prescribed medications if available",
                            "Do not drive yourself to hospital"
                        ],
                        prevention: [
                            "Medical clearance before starting",
                            "Know your medical conditions",
                            "Start very gradually",
                            "Never ignore warning signs"
                        ],
                        isAcknowledged: acknowledgedProtocols.contains("chestpain"),
                        onAcknowledge: {
                            acknowledgedProtocols.insert("chestpain")
                        }
                    )
                    
                    EmergencyProtocolCard(
                        protocol: .panicAttack,
                        title: "Panic Attack or Severe Anxiety",
                        severity: .moderate,
                        signs: [
                            "Sudden intense fear or anxiety",
                            "Rapid heartbeat",
                            "Sweating or trembling",
                            "Feeling of impending doom",
                            "Hyperventilation"
                        ],
                        immediateActions: [
                            "Stop breath training immediately",
                            "Focus on slow, normal breathing",
                            "Use grounding techniques (5-4-3-2-1)",
                            "Remove yourself from stressful environment",
                            "Seek support from others if needed"
                        ],
                        prevention: [
                            "Avoid competitive pressure",
                            "Practice in comfortable environment",
                            "Start with relaxation techniques",
                            "Address underlying anxiety issues"
                        ],
                        isAcknowledged: acknowledgedProtocols.contains("panic"),
                        onAcknowledge: {
                            acknowledgedProtocols.insert("panic")
                        }
                    )
                }
                
                // Emergency contacts section
                EmergencyContactsSection()
                
                // Knowledge verification
                if acknowledgedProtocols.count >= 3 {
                    EmergencyKnowledgeVerification(
                        acknowledgedProtocols: $acknowledgedProtocols
                    )
                }
            }
            .padding()
        }
    }
}

/**
 * EmergencyProtocol: Types of emergency protocols
 */
enum EmergencyProtocol {
    case unconsciousness
    case severeDizziness
    case chestPain
    case panicAttack
}

/**
 * EmergencySeverity: Severity levels for emergencies
 */
enum EmergencySeverity {
    case critical
    case high
    case moderate
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .moderate: return .yellow
        }
    }
    
    var displayName: String {
        switch self {
        case .critical: return "CRITICAL"
        case .high: return "HIGH"
        case .moderate: return "MODERATE"
        }
    }
}

/**
 * WarningSignsSection: General warning signs education
 */
struct WarningSignsSection: View {
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("⚠️ Warning Signs to Watch For")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                WarningSignRow(
                    icon: "brain.head.profile",
                    title: "Neurological Signs",
                    signs: ["Dizziness", "Confusion", "Vision changes", "Tingling"],
                    color: .red
                )
                
                WarningSignRow(
                    icon: "heart.fill",
                    title: "Cardiovascular Signs",
                    signs: ["Chest pain", "Rapid heartbeat", "Irregular pulse", "Sweating"],
                    color: .red
                )
                
                WarningSignRow(
                    icon: "lungs.fill",
                    title: "Respiratory Signs",
                    signs: ["Difficulty breathing", "Gasping", "Blue lips/fingers", "Wheezing"],
                    color: .red
                )
                
                WarningSignRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "General Signs",
                    signs: ["Nausea", "Weakness", "Anxiety", "Feeling of doom"],
                    color: .orange
                )
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

/**
 * WarningSignRow: Individual warning sign category
 */
struct WarningSignRow: View {
    let icon: String
    let title: String
    let signs: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                    .fontWeight(.bold)
            }
            
            Text(signs.joined(separator: " • "))
                .font(.body)
                .foregroundColor(.primary)
                .padding(.leading, 32)
        }
    }
}

/**
 * EmergencyProtocolCard: Individual emergency protocol card
 */
struct EmergencyProtocolCard: View {
    let protocol: EmergencyProtocol
    let title: String
    let severity: EmergencySeverity
    let signs: [String]
    let immediateActions: [String]
    let prevention: [String]
    let isAcknowledged: Bool
    let onAcknowledge: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "cross.circle.fill")
                        .foregroundColor(severity.color)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(severity.displayName)
                            .font(.subheadline)
                            .foregroundColor(severity.color)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                }
            }
            
            // Content sections
            VStack(alignment: .leading, spacing: 12) {
                
                EmergencySection(
                    title: "Warning Signs:",
                    icon: "eye.fill",
                    color: .red,
                    items: signs
                )
                
                EmergencySection(
                    title: "Immediate Actions:",
                    icon: "bolt.fill",
                    color: .orange,
                    items: immediateActions
                )
                
                EmergencySection(
                    title: "Prevention:",
                    icon: "shield.checkered",
                    color: .green,
                    items: prevention
                )
            }
            
            // Acknowledgment
            Button(action: onAcknowledge) {
                HStack(spacing: 12) {
                    Image(systemName: isAcknowledged ? "checkmark.square.fill" : "square")
                        .foregroundColor(isAcknowledged ? .green : .gray)
                        .font(.title2)
                    
                    Text("I understand this emergency protocol")
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
                .stroke(severity.color, lineWidth: 2)
        )
    }
}

/**
 * EmergencySection: Individual section within emergency protocol
 */
struct EmergencySection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]
    
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
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(color)
                            .font(.system(size: 6))
                        
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

/**
 * EmergencyContactsSection: Emergency contact information
 */
struct EmergencyContactsSection: View {
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("📞 Emergency Contact Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                EmergencyContactCard(
                    title: "Emergency Services",
                    number: "911",
                    description: "For life-threatening emergencies",
                    color: .red
                )
                
                EmergencyContactCard(
                    title: "Poison Control",
                    number: "1-800-222-1222",
                    description: "For poisoning emergencies",
                    color: .orange
                )
                
                EmergencyContactCard(
                    title: "Crisis Text Line",
                    number: "Text HOME to 741741",
                    description: "For mental health crises",
                    color: .blue
                )
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            Text("💡 Tip: Program these numbers into your phone and keep emergency contacts easily accessible during training sessions.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

/**
 * EmergencyContactCard: Individual emergency contact display
 */
struct EmergencyContactCard: View {
    let title: String
    let number: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "phone.fill")
                .foregroundColor(color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(number)
                    .font(.title3)
                    .foregroundColor(color)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

/**
 * EmergencyKnowledgeVerification: Final knowledge check
 */
struct EmergencyKnowledgeVerification: View {
    @Binding var acknowledgedProtocols: Set<String>
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("✅ Emergency Preparedness Verification")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                EmergencyCommitmentCheckbox(
                    text: "I know the warning signs of breathing emergencies",
                    isChecked: acknowledgedProtocols.contains("warning-signs"),
                    onToggle: {
                        if acknowledgedProtocols.contains("warning-signs") {
                            acknowledgedProtocols.remove("warning-signs")
                        } else {
                            acknowledgedProtocols.insert("warning-signs")
                        }
                    }
                )
                
                EmergencyCommitmentCheckbox(
                    text: "I know how to respond to loss of consciousness",
                    isChecked: acknowledgedProtocols.contains("response-unconscious"),
                    onToggle: {
                        if acknowledgedProtocols.contains("response-unconscious") {
                            acknowledgedProtocols.remove("response-unconscious")
                        } else {
                            acknowledgedProtocols.insert("response-unconscious")
                        }
                    }
                )
                
                EmergencyCommitmentCheckbox(
                    text: "I have emergency contact numbers easily accessible",
                    isChecked: acknowledgedProtocols.contains("emergency-contacts"),
                    onToggle: {
                        if acknowledgedProtocols.contains("emergency-contacts") {
                            acknowledgedProtocols.remove("emergency-contacts")
                        } else {
                            acknowledgedProtocols.insert("emergency-contacts")
                        }
                    }
                )
                
                EmergencyCommitmentCheckbox(
                    text: "I will stop training immediately if I experience warning signs",
                    isChecked: acknowledgedProtocols.contains("stop-commitment"),
                    onToggle: {
                        if acknowledgedProtocols.contains("stop-commitment") {
                            acknowledgedProtocols.remove("stop-commitment")
                        } else {
                            acknowledgedProtocols.insert("stop-commitment")
                        }
                    }
                )
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

/**
 * EmergencyCommitmentCheckbox: Emergency commitment checkbox
 */
struct EmergencyCommitmentCheckbox: View {
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
    EmergencyProtocolsStepView()
} 