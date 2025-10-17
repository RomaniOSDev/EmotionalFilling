import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Track Your Mood",
            description: "Record your daily emotions and understand your emotional patterns over time.",
            imageName: "heart.fill"
        ),
        OnboardingPage(
            title: "Add Notes",
            description: "Write down what made you feel this way and create a personal journal of your emotional journey.",
            imageName: "note.text"
        ),
        OnboardingPage(
            title: "View History",
            description: "Look back at your mood patterns and gain insights into your emotional well-being.",
            imageName: "calendar"
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.13), Color("moodHappy").opacity(0.10)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()
                        VStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                                    .frame(width: 120, height: 120)
                                Image(systemName: pages[index].imageName)
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                            }
                            Text(pages[index].title)
                                .font(.title.bold())
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading, endPoint: .trailing))
                            Text(pages[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                        .padding(.horizontal, 24)
                        Spacer()
                        if index == pages.count - 1 {
                            Button {
                                isFirstLaunch = false
                            } label: {
                                Text("Get Started")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(18)
                                    .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                            .padding(.bottom, 60)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView(isFirstLaunch: .constant(true))
} 