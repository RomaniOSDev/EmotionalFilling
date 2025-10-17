import Foundation
import SwiftUI
import Combine

@MainActor
class MoodViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var selectedMood: Mood?
    @Published var comment: String = ""
    @Published var selectedDate: Date = Date()
    @Published var selectedActivities: Set<Activity> = []
    @Published var selectedEnergyLevel: EnergyLevel?
    @Published var sleepHours: Double = 8.0
    @Published var userStats: UserStats = UserStats()
    @Published var showingAchievement: Achievement?
    
    private let saveKey = "moodEntries"
    private let statsKey = "userStats"
    
    init() {
        loadEntries()
        loadUserStats()
        checkAchievements()
    }
    
    func saveEntry() {
        guard let mood = selectedMood else { return }
        
        let newEntry = MoodEntry(
            date: selectedDate,
            mood: mood,
            comment: comment.isEmpty ? nil : comment,
            activities: selectedActivities.isEmpty ? nil : Array(selectedActivities),
            energyLevel: selectedEnergyLevel,
            sleepHours: sleepHours
        )
        
        // Remove any existing entry for the selected date
        entries.removeAll { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: newEntry.date)
        }
        
        // Add the new entry
        entries.append(newEntry)
        saveEntries()
        
        // Update stats
        updateStats(with: newEntry)
        
        // Check for achievements
        checkAchievements()
        
        // Reset for next entry
        resetForm()
    }
    
    private func resetForm() {
        selectedMood = nil
        comment = ""
        selectedDate = Date()
        selectedActivities.removeAll()
        selectedEnergyLevel = nil
        sleepHours = 8.0
    }
    
    private func updateStats(with entry: MoodEntry) {
        // Update total entries
        userStats.totalEntries += 1
        
        // Update points
        var points = entry.mood.points
        if let activities = entry.activities {
            points += activities.reduce(0) { $0 + $1.points }
        }
        userStats.totalPoints += points
        
        // Update streak
        updateStreak(with: entry.date)
        
        // Update last entry date
        userStats.lastEntryDate = entry.date
        
        saveUserStats()
    }
    
    private func updateStreak(with date: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastEntry = userStats.lastEntryDate {
            let daysBetween = calendar.dateComponents([.day], from: lastEntry, to: date).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive day
                userStats.currentStreak += 1
            } else if daysBetween == 0 {
                // Same day, don't change streak
                return
            } else {
                // Streak broken
                userStats.currentStreak = 1
            }
        } else {
            // First entry
            userStats.currentStreak = 1
        }
        
        // Update longest streak
        if userStats.currentStreak > userStats.longestStreak {
            userStats.longestStreak = userStats.currentStreak
        }
    }
    
    private func checkAchievements() {
        let achievements = userStats.achievements
        
        for i in achievements.indices {
            let achievement = achievements[i]
            if !achievement.isUnlocked {
                var shouldUnlock = false
                
                switch achievement.type {
                case .totalEntries:
                    if achievement.title == "First Step" && userStats.totalEntries >= 1 {
                        shouldUnlock = true
                    } else if achievement.title == "Happiness Seeker" {
                        let happyCount = entries.filter { $0.mood == .happy }.count
                        if happyCount >= 50 {
                            shouldUnlock = true
                        }
                    }
                case .streak:
                    if achievement.title == "Week Warrior" && userStats.currentStreak >= 7 {
                        shouldUnlock = true
                    } else if achievement.title == "Month Master" && userStats.currentStreak >= 30 {
                        shouldUnlock = true
                    } else if achievement.title == "Consistency King" && userStats.currentStreak >= 14 {
                        shouldUnlock = true
                    }
                case .moodVariety:
                    let uniqueMoods = Set(entries.map { $0.mood })
                    if uniqueMoods.count >= 5 {
                        shouldUnlock = true
                    }
                case .activityCompletion:
                    let allActivities = entries.compactMap { $0.activities }.flatMap { $0 }
                    let uniqueActivities = Set(allActivities)
                    if uniqueActivities.count >= 10 {
                        shouldUnlock = true
                    }
                case .perfectWeek:
                    let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                    let weekEntries = entries.filter { $0.date >= weekAgo }
                    let uniqueDays = Set(weekEntries.map { Calendar.current.startOfDay(for: $0.date) })
                    if uniqueDays.count >= 7 {
                        shouldUnlock = true
                    }
                }
                
                if shouldUnlock {
                    userStats.achievements[i] = Achievement(
                        id: achievement.id,
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon,
                        type: achievement.type,
                        isUnlocked: true,
                        unlockedDate: Date()
                    )
                    showingAchievement = userStats.achievements[i]
                    saveUserStats()
                }
            }
        }
    }
    
    func toggleActivity(_ activity: Activity) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
    
    func getWeeklyStats() -> (averageMood: Double, totalEntries: Int, mostActiveDay: String?) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weekEntries = entries.filter { $0.date >= weekAgo }
        
        let totalEntries = weekEntries.count
        let averageMood = weekEntries.isEmpty ? 0 : Double(weekEntries.reduce(0) { $0 + $1.mood.points }) / Double(totalEntries)
        
        // Find most active day
        let dayCounts = Dictionary(grouping: weekEntries) { entry in
            calendar.component(.weekday, from: entry.date)
        }.mapValues { $0.count }
        
        let mostActiveDay = dayCounts.max(by: { $0.value < $1.value })?.key
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        return (averageMood, totalEntries, mostActiveDay.map { dayNames[$0] })
    }
    
    func getMoodDistribution() -> [Mood: Int] {
        return Dictionary(grouping: entries) { $0.mood }.mapValues { $0.count }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            entries = decoded
        }
    }
    
    private func saveUserStats() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    private func loadUserStats() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            userStats = decoded
        } else {
            // Initialize with default achievements
            userStats.achievements = UserStats.defaultAchievements()
        }
    }
    
    func clearAllData() {
        entries.removeAll()
        userStats = UserStats()
        userStats.achievements = UserStats.defaultAchievements()
        UserDefaults.standard.removeObject(forKey: saveKey)
        UserDefaults.standard.removeObject(forKey: statsKey)
    }
    
    func entriesForMonth(_ date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.date, equalTo: date, toGranularity: .month)
        }
    }
    
    func generatePDFData() -> Data? {
        // Create PDF content
        let pdfContent = createPDFContent()
        
        // For now, return nil as we'll implement actual PDF generation
        // This is a placeholder for the PDF export functionality
        return nil
    }
    
    private func createPDFContent() -> String {
        var content = "MoodDots - Your Mood Journal\n"
        content += "Generated on: \(Date().formatted())\n\n"
        
        content += "Summary:\n"
        content += "Total Entries: \(userStats.totalEntries)\n"
        content += "Current Streak: \(userStats.currentStreak) days\n"
        content += "Longest Streak: \(userStats.longestStreak) days\n"
        content += "Total Points: \(userStats.totalPoints)\n\n"
        
        content += "Recent Entries:\n"
        let recentEntries = entries.sorted { $0.date > $1.date }.prefix(20)
        for entry in recentEntries {
            content += "\(entry.date.formatted(date: .abbreviated, time: .shortened)) - \(entry.mood.rawValue) \(entry.mood.rawValue)\n"
            if let comment = entry.comment, !comment.isEmpty {
                content += "  Comment: \(comment)\n"
            }
            content += "\n"
        }
        
        return content
    }
} 
