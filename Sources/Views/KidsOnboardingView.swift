import SwiftUI

struct KidsOnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("figure.child", "Flasherz Kidz", "Learn about your family and test your knowledge!", .orange),
        ("rectangle.on.rectangle.angled.fill", "Flip & Learn", "Tap flashcards to reveal answers about your family.", .blue),
        ("questionmark.circle.fill", "Play Trivia", "Test your general knowledge with fun quiz questions!", .purple),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.07), Color(red: 0.07, green: 0.07, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(page.color.opacity(0.15))
                                    .frame(width: 140, height: 140)
                                Image(systemName: page.icon)
                                    .font(.system(size: 56, weight: .medium))
                                    .foregroundStyle(page.color)
                            }

                            Text(page.title)
                                .font(.largeTitle.bold())

                            Text(page.subtitle)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                Button {
                    withAnimation(.easeInOut) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            UserDefaults.standard.set(true, forKey: "kids_onboarding_complete")
                            isComplete = true
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Let's Go!")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.orange, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
}
