import SwiftUI

/**
 * Placeholder step views for safety education flow
 * 
 * PURPOSE: These are simplified placeholder views to get the project compiling.
 * They will be replaced with comprehensive implementations in future iterations.
 * 
 * RATIONALE: Building incrementally - get basic structure working first,
 * then enhance with full functionality.
 */

// MARK: - Medical Disclaimer Step

struct MedicalDisclaimerStepView: View {
    @Binding var hasReadDisclaimer: Bool
    @Binding var hasAcceptedDisclaimer: Bool
    @State private var scrollPosition: CGFloat = 0
    @State private var maxScrollPosition: CGFloat = 0
    @State private var hasScrolledToBottom = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Medical Disclaimer")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Please read the entire disclaimer carefully")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Scrollable Disclaimer Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        disclaimerSection(
                            title: "⚠️ CRITICAL SAFETY WARNING",
                            content: """
                            Breath holding exercises can be DANGEROUS and potentially FATAL. This app is for educational purposes only and should never replace professional medical guidance.
                            
                            NEVER practice breath holding:
                            • In or near water
                            • While driving or operating machinery
                            • If you have any medical conditions
                            • Without proper supervision
                            • Using hyperventilation techniques
                            """
                        )
                        
                        disclaimerSection(
                            title: "🏥 Medical Conditions",
                            content: """
                            DO NOT use this app if you have:
                            • Heart conditions or cardiovascular disease
                            • High or low blood pressure
                            • Respiratory conditions (asthma, COPD, etc.)
                            • Pregnancy or nursing
                            • Epilepsy or seizure disorders
                            • Panic disorder or anxiety conditions
                            • Any other medical condition
                            
                            ALWAYS consult your healthcare provider before beginning any breathing practice.
                            """
                        )
                        
                        disclaimerSection(
                            title: "🚨 Emergency Risks",
                            content: """
                            Breath holding can cause:
                            • Loss of consciousness (blackout)
                            • Shallow water blackout
                            • Cardiac arrhythmia
                            • Brain damage from oxygen deprivation
                            • Death
                            
                            These risks are REAL and have caused fatalities. This is not an exaggeration.
                            """
                        )
                        
                        disclaimerSection(
                            title: "🛡️ Your Responsibility",
                            content: """
                            By using this app, you acknowledge that:
                            • You understand the serious risks involved
                            • You will never practice in or near water
                            • You will always have a trained buddy present
                            • You will stop immediately if you feel unwell
                            • You assume all responsibility for your safety
                            • The app developers are not liable for any injuries or death
                            """
                        )
                        
                        disclaimerSection(
                            title: "📚 Educational Purpose Only",
                            content: """
                            This app provides educational information about breathing techniques. It is NOT:
                            • Medical advice or treatment
                            • A substitute for professional training
                            • Endorsed by medical professionals
                            • Guaranteed to be safe for any individual
                            
                            Professional freediving instruction is strongly recommended before attempting any breath holding practices.
                            """
                        )
                        
                        // Bottom marker for scroll detection
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding()
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollPosition = value
                    maxScrollPosition = min(maxScrollPosition, value)
                    
                    // Check if user has scrolled to bottom (with some tolerance)
                    if !hasScrolledToBottom && maxScrollPosition <= -200 {
                        hasScrolledToBottom = true
                        hasReadDisclaimer = true
                    }
                }
            }
            .frame(maxHeight: 300)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Scroll Progress Indicator
            if !hasScrolledToBottom {
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                    Text("Please scroll to read the complete disclaimer")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            
            // Acceptance Checkbox
            if hasReadDisclaimer {
                VStack(spacing: 12) {
                    Button(action: {
                        hasAcceptedDisclaimer.toggle()
                    }) {
                        HStack {
                            Image(systemName: hasAcceptedDisclaimer ? "checkmark.square.fill" : "square")
                                .foregroundColor(hasAcceptedDisclaimer ? .blue : .gray)
                                .font(.title2)
                            
                            Text("I have read and understand the medical disclaimer and assume all risks")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    if hasAcceptedDisclaimer {
                        Text("✓ Disclaimer accepted")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func disclaimerSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

// Helper for scroll position tracking
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Safety Basics Step

struct SafetyBasicsStepView: View {
    @Binding var hasCompletedBasics: Bool
    @State private var currentSlide = 0
    
    private let safetyBasics = [
        SafetyBasic(
            icon: "person.2.fill",
            title: "Never Practice Alone",
            content: "ALWAYS have a trained buddy present who knows CPR and rescue techniques. Your buddy should remain alert and never practice simultaneously.",
            keyPoints: [
                "Buddy must know CPR and rescue breathing",
                "Buddy stays alert - no simultaneous practice",
                "Establish clear communication signals",
                "Practice buddy rescue scenarios"
            ]
        ),
        SafetyBasic(
            icon: "drop.fill",
            title: "Never Near Water",
            content: "NEVER practice breath holding in or near any body of water. Shallow water blackout can cause drowning in as little as 2 feet of water.",
            keyPoints: [
                "No pools, bathtubs, or any water",
                "Shallow water blackout is silent and deadly",
                "Even experienced practitioners have drowned",
                "Practice only on dry land in safe environments"
            ]
        ),
        SafetyBasic(
            icon: "exclamationmark.triangle.fill",
            title: "Recognize Warning Signs",
            content: "Learn to identify the early warning signs that indicate you should stop immediately and seek help.",
            keyPoints: [
                "Dizziness or lightheadedness",
                "Tingling in hands, feet, or face",
                "Muscle contractions or spasms",
                "Confusion or disorientation",
                "Any unusual sensations"
            ]
        ),
        SafetyBasic(
            icon: "heart.fill",
            title: "Know Your Limits",
            content: "Never push beyond your comfortable limits. Progress should be gradual and comfortable, never forced.",
            keyPoints: [
                "Start with very short holds (10-15 seconds)",
                "Increase duration slowly over weeks/months",
                "Never compete with others",
                "Listen to your body always"
            ]
        ),
        SafetyBasic(
            icon: "phone.fill",
            title: "Emergency Preparedness",
            content: "Know how to respond to emergencies and have emergency contacts readily available.",
            keyPoints: [
                "Know CPR and rescue breathing",
                "Have emergency numbers programmed",
                "Practice emergency scenarios",
                "Know when to call 911 immediately"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Safety Basics")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Essential safety principles you must understand")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<safetyBasics.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentSlide ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Content Slides
            TabView(selection: $currentSlide) {
                ForEach(0..<safetyBasics.count, id: \.self) { index in
                    SafetyBasicSlideView(basic: safetyBasics[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: 400)
            
            // Navigation
            HStack(spacing: 20) {
                if currentSlide > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentSlide -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentSlide < safetyBasics.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentSlide += 1
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    Button("Complete Safety Basics") {
                        hasCompletedBasics = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct SafetyBasic {
    let icon: String
    let title: String
    let content: String
    let keyPoints: [String]
}

struct SafetyBasicSlideView: View {
    let basic: SafetyBasic
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: basic.icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(basic.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(basic.content)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(basic.keyPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(point)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Dangerous Techniques Step

struct DangerousTechniquesStepView: View {
    @Binding var hasLearnedDangers: Bool
    @State private var currentDanger = 0
    
    private let dangerousTechniques = [
        DangerousTechnique(
            name: "Wim Hof Method for Breath Holding",
            icon: "exclamationmark.triangle.fill",
            dangerLevel: "EXTREMELY DANGEROUS",
            description: "The Wim Hof breathing method involves rapid, deep breathing (hyperventilation) followed by breath holding. While this method has benefits for cold exposure and stress management, it is DEADLY when used for breath holding training.",
            whyDangerous: [
                "Hyperventilation artificially lowers CO2 levels",
                "Creates false sense of oxygen availability",
                "Can cause blackout without warning",
                "Has caused multiple documented deaths",
                "Bypasses natural safety mechanisms"
            ],
            safeAlternative: "Use CO2 tolerance tables instead - they train your body to handle CO2 buildup safely without depleting oxygen."
        ),
        DangerousTechnique(
            name: "Hyperventilation Before Breath Holding",
            icon: "lungs.fill",
            dangerLevel: "FATAL",
            description: "Any form of rapid, deep breathing before breath holding is extremely dangerous. This includes any technique that involves 'charging up' with fast breathing.",
            whyDangerous: [
                "Removes CO2 that triggers breathing reflex",
                "Can cause blackout in seconds",
                "No warning signs before unconsciousness",
                "Causes shallow water blackout",
                "Has killed experienced practitioners"
            ],
            safeAlternative: "Always breathe normally before breath holds. Use relaxation breathing to calm down, never hyperventilation."
        ),
        DangerousTechnique(
            name: "Competitive Breath Holding",
            icon: "trophy.fill",
            dangerLevel: "HIGH RISK",
            description: "Competing with others or trying to beat personal records encourages pushing beyond safe limits and ignoring warning signs.",
            whyDangerous: [
                "Encourages ignoring body's warning signals",
                "Creates pressure to exceed safe limits",
                "Peer pressure overrides safety judgment",
                "Leads to risk-taking behavior",
                "Can trigger competitive mindset over safety"
            ],
            safeAlternative: "Focus on consistency and technique improvement rather than maximum times. Celebrate safety compliance, not performance."
        ),
        DangerousTechnique(
            name: "Water-Based Practice",
            icon: "drop.fill",
            dangerLevel: "DEADLY",
            description: "Practicing breath holding in any body of water, including pools, bathtubs, or natural water bodies.",
            whyDangerous: [
                "Shallow water blackout can occur in 2 feet of water",
                "Blackout is silent - no splashing or distress",
                "Even experienced swimmers have drowned",
                "Rescue is often impossible once blackout occurs",
                "Cold water increases risks significantly"
            ],
            safeAlternative: "ONLY practice on dry land in a safe, supervised environment with a trained buddy present."
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Dangerous Techniques")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Critical warnings about deadly practices")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<dangerousTechniques.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentDanger ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Danger Slides
            TabView(selection: $currentDanger) {
                ForEach(0..<dangerousTechniques.count, id: \.self) { index in
                    DangerousTechniqueSlideView(technique: dangerousTechniques[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: 500)
            
            // Navigation
            HStack(spacing: 20) {
                if currentDanger > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentDanger -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentDanger < dangerousTechniques.count - 1 {
                    Button("Next Warning") {
                        withAnimation {
                            currentDanger += 1
                        }
                    }
                    .foregroundColor(.red)
                } else {
                    Button("I Understand the Dangers") {
                        hasLearnedDangers = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct DangerousTechnique {
    let name: String
    let icon: String
    let dangerLevel: String
    let description: String
    let whyDangerous: [String]
    let safeAlternative: String
}

struct DangerousTechniqueSlideView: View {
    let technique: DangerousTechnique
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Danger Header
                VStack(spacing: 12) {
                    Image(systemName: technique.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text(technique.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(technique.dangerLevel)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(20)
                }
                
                // Description
                Text(technique.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Why Dangerous
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why This Is Dangerous:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(technique.whyDangerous, id: \.self) { danger in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Text(danger)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Safe Alternative
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safe Alternative:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(technique.safeAlternative)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - Proper Techniques Step

struct ProperTechniquesStepView: View {
    @Binding var hasLearnedTechniques: Bool
    @State private var currentTechnique = 0
    
    private let properTechniques = [
        ProperTechnique(
            name: "Box Breathing",
            icon: "square",
            safetyLevel: "BEGINNER SAFE",
            description: "A balanced breathing pattern that promotes relaxation and focus without oxygen depletion.",
            pattern: "Inhale 4 - Hold 4 - Exhale 4 - Hold 4",
            benefits: [
                "Reduces stress and anxiety",
                "Improves focus and concentration",
                "Balances nervous system",
                "Safe for daily practice"
            ],
            instructions: [
                "Sit comfortably with good posture",
                "Breathe naturally through your nose",
                "Inhale slowly for 4 counts",
                "Hold your breath for 4 counts",
                "Exhale slowly for 4 counts",
                "Hold empty for 4 counts",
                "Repeat 5-10 cycles"
            ],
            safetyNotes: "This technique is very safe and can be practiced daily. Stop if you feel dizzy."
        ),
        ProperTechnique(
            name: "Diaphragmatic Breathing",
            icon: "lungs.fill",
            safetyLevel: "VERY SAFE",
            description: "Deep belly breathing that maximizes oxygen efficiency and promotes relaxation.",
            pattern: "Deep belly breaths with natural rhythm",
            benefits: [
                "Improves oxygen efficiency",
                "Strengthens diaphragm muscle",
                "Reduces breathing rate naturally",
                "Enhances lung capacity safely"
            ],
            instructions: [
                "Lie down or sit comfortably",
                "Place one hand on chest, one on belly",
                "Breathe so only the belly hand moves",
                "Inhale slowly through nose",
                "Exhale slowly through mouth",
                "Focus on smooth, natural rhythm",
                "Practice 10-15 minutes daily"
            ],
            safetyNotes: "This is the foundation of safe breathing practice. Cannot be done incorrectly."
        ),
        ProperTechnique(
            name: "CO2 Tolerance Tables",
            icon: "chart.line.uptrend.xyaxis",
            safetyLevel: "INTERMEDIATE SAFE",
            description: "Gradual training to handle CO2 buildup safely without oxygen depletion.",
            pattern: "Progressive breath holds with normal breathing",
            benefits: [
                "Safely increases breath hold time",
                "Trains CO2 tolerance naturally",
                "Maintains oxygen levels",
                "Progressive and measurable"
            ],
            instructions: [
                "Start with comfortable breath holds",
                "Never hyperventilate beforehand",
                "Breathe normally between holds",
                "Gradually increase hold times",
                "Stop at first urge to breathe",
                "Rest completely between sessions",
                "Progress slowly over weeks"
            ],
            safetyNotes: "Always breathe normally before holds. Never push past the first urge to breathe."
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Proper Techniques")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Safe methods for breath training")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<properTechniques.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentTechnique ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Technique Slides
            TabView(selection: $currentTechnique) {
                ForEach(0..<properTechniques.count, id: \.self) { index in
                    ProperTechniqueSlideView(technique: properTechniques[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: 500)
            
            // Navigation
            HStack(spacing: 20) {
                if currentTechnique > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentTechnique -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentTechnique < properTechniques.count - 1 {
                    Button("Next Technique") {
                        withAnimation {
                            currentTechnique += 1
                        }
                    }
                    .foregroundColor(.green)
                } else {
                    Button("Complete Techniques") {
                        hasLearnedTechniques = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct ProperTechnique {
    let name: String
    let icon: String
    let safetyLevel: String
    let description: String
    let pattern: String
    let benefits: [String]
    let instructions: [String]
    let safetyNotes: String
}

struct ProperTechniqueSlideView: View {
    let technique: ProperTechnique
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Technique Header
                VStack(spacing: 12) {
                    Image(systemName: technique.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text(technique.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(technique.safetyLevel)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(20)
                }
                
                // Description & Pattern
                VStack(spacing: 12) {
                    Text(technique.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Text(technique.pattern)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    Text("Benefits:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    ForEach(technique.benefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(benefit)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Practice:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ForEach(Array(technique.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text(instruction)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Safety Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety Notes:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text(technique.safetyNotes)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - Emergency Protocols Step

struct EmergencyProtocolsStepView: View {
    @Binding var hasLearnedProtocols: Bool
    @State private var currentProtocol = 0
    
    private let emergencyProtocols = [
        EmergencyProtocol(
            title: "Recognizing Emergencies",
            icon: "eye.fill",
            urgency: "CRITICAL",
            description: "Learn to identify emergency situations that require immediate action.",
            signs: [
                "Loss of consciousness (blackout)",
                "Muscle contractions or convulsions",
                "Blue lips or fingernails (cyanosis)",
                "Gasping or irregular breathing",
                "Confusion or disorientation",
                "Inability to respond to voice/touch"
            ],
            actions: [
                "Check responsiveness immediately",
                "Call 911 if no response",
                "Position person safely",
                "Monitor breathing and pulse",
                "Be ready to start CPR"
            ]
        ),
        EmergencyProtocol(
            title: "Immediate Response",
            icon: "bolt.fill",
            urgency: "SECONDS COUNT",
            description: "First actions to take when someone loses consciousness during breath holding.",
            signs: [
                "Person becomes unresponsive",
                "Eyes may be open but not tracking",
                "May have brief muscle contractions",
                "Breathing may be absent or gasping"
            ],
            actions: [
                "Ensure airway is clear and open",
                "Position on back with head tilted back",
                "Check for breathing for 10 seconds",
                "If no normal breathing, start rescue breaths",
                "Call 911 immediately",
                "Continue monitoring until help arrives"
            ]
        ),
        EmergencyProtocol(
            title: "CPR Protocol",
            icon: "heart.fill",
            urgency: "LIFE SAVING",
            description: "Proper CPR technique for breath holding emergencies.",
            signs: [
                "No pulse detected",
                "No normal breathing",
                "Unconscious and unresponsive",
                "Blue or gray skin color"
            ],
            actions: [
                "Call 911 immediately",
                "Place heel of hand on center of chest",
                "Push hard and fast at least 2 inches deep",
                "Compress at 100-120 beats per minute",
                "Give 30 compressions, then 2 rescue breaths",
                "Continue until emergency services arrive"
            ]
        ),
        EmergencyProtocol(
            title: "When to Call 911",
            icon: "phone.fill",
            urgency: "DON'T HESITATE",
            description: "Clear guidelines on when emergency services are needed.",
            signs: [
                "Any loss of consciousness",
                "Difficulty breathing after recovery",
                "Chest pain or heart irregularities",
                "Persistent confusion or disorientation",
                "Any seizure-like activity",
                "When in doubt - ALWAYS CALL"
            ],
            actions: [
                "Call 911 immediately - don't wait",
                "State 'breathing emergency' clearly",
                "Give exact location",
                "Describe what happened",
                "Follow dispatcher instructions",
                "Stay on line until help arrives"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "cross.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Emergency Protocols")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Life-saving procedures you must know")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<emergencyProtocols.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentProtocol ? Color.red : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Protocol Slides
            TabView(selection: $currentProtocol) {
                ForEach(0..<emergencyProtocols.count, id: \.self) { index in
                    EmergencyProtocolSlideView(protocol: emergencyProtocols[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: 500)
            
            // Navigation
            HStack(spacing: 20) {
                if currentProtocol > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentProtocol -= 1
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                if currentProtocol < emergencyProtocols.count - 1 {
                    Button("Next Protocol") {
                        withAnimation {
                            currentProtocol += 1
                        }
                    }
                    .foregroundColor(.red)
                } else {
                    Button("Complete Emergency Training") {
                        hasLearnedProtocols = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct EmergencyProtocol {
    let title: String
    let icon: String
    let urgency: String
    let description: String
    let signs: [String]
    let actions: [String]
}

struct EmergencyProtocolSlideView: View {
    let `protocol`: EmergencyProtocol
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Protocol Header
                VStack(spacing: 12) {
                    Image(systemName: protocol.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text(protocol.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(protocol.urgency)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(20)
                }
                
                // Description
                Text(protocol.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Warning Signs
                VStack(alignment: .leading, spacing: 12) {
                    Text("Warning Signs:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    ForEach(protocol.signs, id: \.self) { sign in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            
                            Text(sign)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Action Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Action Steps:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    ForEach(Array(protocol.actions.enumerated()), id: \.offset) { index, action in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            Text(action)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - Safety Quiz Step

struct SafetyQuizStepView: View {
    @Binding var answers: [Int]
    @Binding var completed: Bool
    @Binding var score: Double
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Safety Quiz")
                .font(.largeTitle.weight(.bold))
            
            Text("This is a placeholder for the safety quiz step. The full implementation will include 18 comprehensive safety questions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Complete Quiz (Mock)") {
                // Mock quiz completion with passing score
                answers = Array(repeating: 0, count: SafetyQuizQuestion.allQuestions.count)
                score = 0.85 // 85% passing score
                completed = true
            }
            .buttonStyle(.borderedProminent)
            
            if completed {
                Text("Quiz Score: \(Int(score * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Completion Step

struct SafetyEducationCompletionView: View {
    let score: Double
    @Binding var showCelebration: Bool
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Safety Education Complete!")
                .font(.largeTitle.weight(.bold))
            
            Text("Congratulations! You've successfully completed the safety education with a score of \(Int(score * 100))%.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Training") {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
} 