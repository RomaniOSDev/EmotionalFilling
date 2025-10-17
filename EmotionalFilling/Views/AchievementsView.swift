import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.15), Color.orange.opacity(0.10), Color.purple.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    VStack(spacing: 16) {
                        Text("🏆 Achievements")
                            .font(.title.bold())
                            .foregroundStyle(LinearGradient(
                                colors: [Color.orange, Color.yellow],
                                startPoint: .leading, endPoint: .trailing))
                        
                        HStack(spacing: 20) {
                            AchievementStatCard(
                                title: "Unlocked",
                                value: "\(viewModel.userStats.achievements.filter { $0.isUnlocked }.count)",
                                color: .green
                            )
                            AchievementStatCard(
                                title: "Total",
                                value: "\(viewModel.userStats.achievements.count)",
                                color: .blue
                            )
                            AchievementStatCard(
                                title: "Progress",
                                value: "\(Int((Double(viewModel.userStats.achievements.filter { $0.isUnlocked }.count) / Double(viewModel.userStats.achievements.count)) * 100))%",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
                    
                    // Achievements Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(viewModel.userStats.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
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

struct AchievementStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: achievement.isUnlocked ? Color.yellow.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                
                Text(achievement.icon)
                    .font(.title)
                    .opacity(achievement.isUnlocked ? 1 : 0.5)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if achievement.isUnlocked, let unlockedDate = achievement.unlockedDate {
                    Text("Unlocked \(unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(achievement.isUnlocked ? 1 : 0.95)
        .opacity(achievement.isUnlocked ? 1 : 0.7)
        .animation(.easeInOut(duration: 0.3), value: achievement.isUnlocked)
    }
}

#Preview {
    AchievementsView()
        .environmentObject(MoodViewModel())
} 