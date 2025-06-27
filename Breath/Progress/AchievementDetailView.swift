import SwiftUI

/**
 * AchievementDetailView: Detailed view for individual achievements
 * 
 * PURPOSE: Shows comprehensive information about a specific achievement
 * including unlock criteria, progress, and celebration of the accomplishment.
 * 
 * SAFETY DESIGN: All achievements focus on safety compliance and consistency
 * rather than encouraging users to push dangerous limits.
 */
struct AchievementDetailView: View {
    
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Achievement Header
                    achievementHeader
                    
                    // Achievement Details
                    achievementDetails
                    
                    // Progress Information
                    if !achievement.isUnlocked {
                        progressSection
                    }
                    
                    // Related Achievements
                    relatedAchievementsSection
                    
                    // Tips and Motivation
                    tipsSection
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Achievement Header
    
    private var achievementHeader: some View {
        VStack(spacing: 16) {
            
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.category.color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(achievement.isUnlocked ? achievement.category.color : .gray)
            }
            
            // Achievement Name
            Text(achievement.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Achievement Status
            HStack {
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unlocked")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "lock.circle.fill")
                        .foregroundColor(.gray)
                    Text("Locked")
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                }
                
                if achievement.isRare {
                    Text("• RARE")
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                }
            }
            .font(.subheadline)
            
            // Unlock Date
            if achievement.isUnlocked {
                Text("Unlocked on \(achievement.unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Achievement Details
    
    private var achievementDetails: some View {
        VStack(spacing: 16) {
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Category and Difficulty
            HStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: achievement.category.iconName)
                            .foregroundColor(achievement.category.color)
                        Text(achievement.category.displayName)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Difficulty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < achievement.difficulty ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Points and Rewards
            if achievement.points > 0 {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(achievement.points) Experience Points")
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(achievement.progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            // Progress Bar
            ProgressView(value: achievement.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            // Progress Details
            VStack(alignment: .leading, spacing: 8) {
                Text("How to Unlock")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(achievement.unlockCriteria)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Related Achievements
    
    private var relatedAchievementsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Related Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(getRelatedAchievements()) { relatedAchievement in
                    RelatedAchievementRow(achievement: relatedAchievement)
                }
            }
        }
    }
    
    // MARK: - Tips Section
    
    private var tipsSection: some View {
        VStack(spacing: 16) {
            
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("Tips & Motivation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(getTipsForAchievement(), id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.top, 2)
                        
                        Text(tip)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getRelatedAchievements() -> [Achievement] {
        return Achievement.allAchievements.filter { otherAchievement in
            otherAchievement.id != achievement.id &&
            otherAchievement.category == achievement.category
        }.prefix(3).map { $0 }
    }
    
    private func getTipsForAchievement() -> [String] {
        switch achievement.category {
        case .consistency:
            return [
                "Set a specific time each day for your breathing practice",
                "Start with shorter sessions to build the habit",
                "Use calendar reminders to stay consistent",
                "Remember: rest days are part of healthy consistency"
            ]
            
        case .safety:
            return [
                "Always follow the safety guidelines without exception",
                "Never skip rest periods between holds",
                "Stop immediately if you feel dizzy or uncomfortable",
                "Safety compliance is more important than performance"
            ]
            
        case .technique:
            return [
                "Focus on proper breathing form over hold duration",
                "Practice diaphragmatic breathing daily",
                "Use the guided tutorials to perfect your technique",
                "Quality of breath is more important than quantity"
            ]
            
        case .progress:
            return [
                "Progress comes from consistent practice, not pushing limits",
                "Celebrate small improvements in technique and consistency",
                "Track your safety compliance as your primary metric",
                "Remember: slow and steady wins the race"
            ]
            
        case .education:
            return [
                "Take time to understand the science behind breath training",
                "Review safety materials regularly",
                "Share what you learn with others safely",
                "Knowledge is the foundation of safe practice"
            ]
        }
    }
}

// MARK: - Supporting Views

struct RelatedAchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: achievement.iconName)
                .foregroundColor(achievement.isUnlocked ? achievement.category.color : .gray)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else {
                Text("\(Int(achievement.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct AchievementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementDetailView(
            achievement: Achievement(
                id: "sample",
                name: "First Steps",
                description: "Complete your first breathing session with perfect safety compliance",
                iconName: "lungs.fill",
                category: .consistency,
                difficulty: 1,
                points: 10,
                unlockCriteria: "Complete 1 breathing session",
                isUnlocked: true,
                unlockedDate: Date(),
                progress: 1.0,
                isRare: false
            )
        )
    }
} 