import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    private var monthEntries: [MoodEntry] {
        viewModel.entriesForMonth(Date())
            .sorted { $0.date < $1.date }
    }
    
    private var moodCounts: [Mood: Int] {
        Dictionary(grouping: monthEntries, by: { $0.mood })
            .mapValues { $0.count }
    }
    
    private var averageMood: Double {
        guard !monthEntries.isEmpty else { return 0 }
        let total = monthEntries.reduce(0) { $0 + ($1.mood.numericValue) }
        return Double(total) / Double(monthEntries.count)
    }
    
    private var weeklyStats: (averageMood: Double, totalEntries: Int, mostActiveDay: String?) {
        viewModel.getWeeklyStats()
    }
    
    private var moodDistribution: [Mood: Int] {
        viewModel.getMoodDistribution()
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.13), Color("moodHappy").opacity(0.10), Color.blue.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Overall Stats
                    VStack(spacing: 16) {
                        Text("📊 Analytics")
                            .font(.title.bold())
                            .foregroundStyle(LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading, endPoint: .trailing))
                        
                        HStack(spacing: 16) {
                            StatCard(title: "Total Points", value: "\(viewModel.userStats.totalPoints)", color: .purple)
                            StatCard(title: "Current Streak", value: "\(viewModel.userStats.currentStreak) days", color: .orange)
                            StatCard(title: "Total Entries", value: "\(viewModel.userStats.totalEntries)", color: .green)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Weekly Performance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Average Mood")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(weeklyStats.averageMood > 0 ? String(format: "%.1f", weeklyStats.averageMood) : "-")
                                    .font(.title2.bold())
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Entries")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(weeklyStats.totalEntries)")
                                    .font(.title2.bold())
                                    .foregroundColor(.green)
                            }
                            if let mostActiveDay = weeklyStats.mostActiveDay {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Most Active")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(mostActiveDay)
                                        .font(.caption.bold())
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Mood Chart
                    VStack(alignment: .leading, spacing: 0) {
                        Label("Mood Trend", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                            .padding(.bottom, 4)
                        Chart(monthEntries) { entry in
                            LineMark(
                                x: .value("Day", Calendar.current.component(.day, from: entry.date)),
                                y: .value("Mood", entry.mood.numericValue)
                            )
                            .foregroundStyle(Color(entry.mood.color))
                            .interpolationMethod(.catmullRom)
                            PointMark(
                                x: .value("Day", Calendar.current.component(.day, from: entry.date)),
                                y: .value("Mood", entry.mood.numericValue)
                            )
                            .foregroundStyle(Color(entry.mood.color))
                        }
                        .frame(height: 180)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Mood Distribution
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Distribution")
                            .font(.headline)
                            .foregroundColor(.primary)
                        HStack(spacing: 12) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                VStack(spacing: 6) {
                                    Text(mood.rawValue)
                                        .font(.system(size: 28))
                                    Text("\(moodDistribution[mood, default: 0])")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(mood.color).opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Activity Analysis
                    if !monthEntries.isEmpty {
                        ActivityAnalysisView(entries: monthEntries)
                    }
                    
                    // Energy Level Analysis
                    if !monthEntries.isEmpty {
                        EnergyAnalysisView(entries: monthEntries)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 12)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct ActivityAnalysisView: View {
    let entries: [MoodEntry]
    
    private var activityCounts: [Activity: Int] {
        let allActivities = entries.compactMap { $0.activities }.flatMap { $0 }
        return Dictionary(grouping: allActivities, by: { $0 }).mapValues { $0.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Popular Activities")
                .font(.headline)
                .foregroundColor(.primary)
            
            if activityCounts.isEmpty {
                Text("No activities recorded yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                let sortedActivities = activityCounts.sorted { $0.value > $1.value }.prefix(5)
                VStack(spacing: 8) {
                    ForEach(Array(sortedActivities), id: \.key) { activity, count in
                        HStack {
                            Text(activity.rawValue)
                                .font(.title3)
                            Text(activity.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(count)")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
    }
}

struct EnergyAnalysisView: View {
    let entries: [MoodEntry]
    
    private var energyLevels: [EnergyLevel: Int] {
        let validEntries = entries.compactMap { $0.energyLevel }
        return Dictionary(grouping: validEntries, by: { $0 }).mapValues { $0.count }
    }
    
    private var averageSleep: Double {
        let sleepEntries = entries.compactMap { $0.sleepHours }
        guard !sleepEntries.isEmpty else { return 0 }
        return sleepEntries.reduce(0, +) / Double(sleepEntries.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Energy & Sleep Analysis")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Sleep")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f hours", averageSleep))
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Most Common Energy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let mostCommon = energyLevels.max(by: { $0.value < $1.value }) {
                        Text(mostCommon.key.emoji)
                            .font(.title2)
                    } else {
                        Text("-")
                            .font(.title2.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !energyLevels.isEmpty {
                HStack(spacing: 8) {
                    ForEach(EnergyLevel.allCases, id: \.self) { level in
                        VStack(spacing: 4) {
                            Text(level.emoji)
                                .font(.title3)
                            Text("\(energyLevels[level, default: 0])")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
    }
}

private extension Mood {
    var numericValue: Int {
        switch self {
        case .happy: return 5
        case .love: return 4
        case .neutral: return 3
        case .sad: return 2
        case .angry: return 1
        }
    }
    static func fromNumeric(_ value: Double) -> Mood {
        switch value {
        case 4.7...: return .happy
        case 3.7..<4.7: return .love
        case 2.7..<3.7: return .neutral
        case 1.7..<2.7: return .sad
        default: return .angry
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(MoodViewModel())
} 
