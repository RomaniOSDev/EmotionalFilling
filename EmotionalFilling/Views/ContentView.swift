//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MoodViewModel()
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        if isFirstLaunch {
            OnboardingView(isFirstLaunch: $isFirstLaunch)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        } else {
            TabView {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max.fill")
                    }
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "calendar")
                    }
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    }
                
                AchievementsView()
                    .tabItem {
                        Label("Achievements", systemImage: "trophy.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .environmentObject(viewModel)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    ContentView()
}
