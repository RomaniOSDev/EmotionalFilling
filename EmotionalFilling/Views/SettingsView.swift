import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var viewModel: MoodViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingClearConfirmation = false
    @State private var showingRatingSheet = false
    @AppStorage("userRating") private var userRating: Int = 0
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("moodNeutral").opacity(0.13), Color.blue.opacity(0.10), Color.purple.opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    SettingsSectionCard {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .font(.headline)
                    }
                    
                    SettingsSectionCard {
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            SettingsButtonLabel(title: "Clear All Data", systemImage: "trash", gradient: [Color.red, Color.orange])
                        }
                    }
                    
                    SettingsSectionCard {
                        Link(destination: URL(string: "https://www.termsfeed.com/live/4aaa81f0-86a5-4353-8ccb-0c36e28b3717")!) {
                            SettingsButtonLabel(title: "Privacy Policy", systemImage: "hand.raised", gradient: [Color.gray, Color.blue])
                        }
                        Divider().padding(.vertical, 2)
                        Button {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        } label: {
                            SettingsButtonLabel(title: "Rate App", systemImage: "star", gradient: [Color.yellow, Color.orange])
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 12)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Clear All Data", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("Are you sure you want to delete all your mood entries? This action cannot be undone.")
            }
        }
    }
}

struct SettingsSectionCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
    }
}

struct SettingsButtonLabel: View {
    let title: String
    let systemImage: String
    let gradient: [Color]
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
        .environmentObject(MoodViewModel())
} 
