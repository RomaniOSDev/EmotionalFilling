import SwiftUI
import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: Mood
    let comment: String?
    let activities: [Activity]?
    let energyLevel: EnergyLevel?
    let sleepHours: Double?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Mood, comment: String? = nil, activities: [Activity]? = nil, energyLevel: EnergyLevel? = nil, sleepHours: Double? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.comment = comment
        self.activities = activities
        self.energyLevel = energyLevel
        self.sleepHours = sleepHours
    }
}

enum Mood: String, Codable, CaseIterable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😞"
    case angry = "😡"
    case love = "😍"
    
    var color: String {
        switch self {
        case .happy: return "moodHappy"
        case .neutral: return "moodNeutral"
        case .sad: return "moodSad"
        case .angry: return "moodAngry"
        case .love: return "moodLove"
        }
    }
    
    var points: Int {
        switch self {
        case .happy: return 10
        case .love: return 15
        case .neutral: return 5
        case .sad: return 2
        case .angry: return 1
        }
    }
}

enum Activity: String, Codable, CaseIterable {
    case exercise = "🏃‍♂️"
    case meditation = "🧘‍♀️"
    case reading = "📚"
    case music = "🎵"
    case cooking = "👨‍🍳"
    case walking = "🚶‍♂️"
    case socializing = "👥"
    case gaming = "🎮"
    case work = "💼"
    case study = "📝"
    
    var name: String {
        switch self {
        case .exercise: return "Exercise"
        case .meditation: return "Meditation"
        case .reading: return "Reading"
        case .music: return "Music"
        case .cooking: return "Cooking"
        case .walking: return "Walking"
        case .socializing: return "Socializing"
        case .gaming: return "Gaming"
        case .work: return "Work"
        case .study: return "Study"
        }
    }
    
    var points: Int {
        switch self {
        case .exercise: return 8
        case .meditation: return 10
        case .reading: return 6
        case .music: return 4
        case .cooking: return 5
        case .walking: return 6
        case .socializing: return 7
        case .gaming: return 3
        case .work: return 5
        case .study: return 6
        }
    }
}

enum EnergyLevel: Int, Codable, CaseIterable {
    case veryLow = 1
    case low = 2
    case medium = 3
    case high = 4
    case veryHigh = 5
    
    var emoji: String {
        switch self {
        case .veryLow: return "😴"
        case .low: return "😐"
        case .medium: return "😊"
        case .high: return "😃"
        case .veryHigh: return "🤩"
        }
    }
    
    var description: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
}

struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let type: AchievementType
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, type: AchievementType, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

enum AchievementType: String, Codable {
    case streak
    case totalEntries
    case moodVariety
    case activityCompletion
    case perfectWeek
}

struct UserStats: Codable {
    var totalPoints: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalEntries: Int = 0
    var achievements: [Achievement] = []
    var lastEntryDate: Date?
    
    static func defaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Step", description: "Record your first mood", icon: "🌟", type: .totalEntries),
            Achievement(title: "Week Warrior", description: "Record moods for 7 days in a row", icon: "🔥", type: .streak),
            Achievement(title: "Mood Explorer", description: "Try all 5 different moods", icon: "🌈", type: .moodVariety),
            Achievement(title: "Activity Master", description: "Complete 10 different activities", icon: "🏆", type: .activityCompletion),
            Achievement(title: "Perfect Week", description: "Record moods every day for a week", icon: "⭐", type: .perfectWeek),
            Achievement(title: "Month Master", description: "Record moods for 30 days", icon: "👑", type: .streak),
            Achievement(title: "Happiness Seeker", description: "Record 50 happy moods", icon: "😊", type: .totalEntries),
            Achievement(title: "Consistency King", description: "Maintain a 14-day streak", icon: "💎", type: .streak)
        ]
    }
}



