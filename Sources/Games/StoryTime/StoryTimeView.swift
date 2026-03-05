import SwiftUI

struct StoryTimeView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var pages: [String] = []
    @State private var currentPage = 0
    @State private var isFinished = false

    var playerName: String { ctx.currentPlayer?.displayName ?? "You" }

    var body: some View {
        Group {
            if pages.isEmpty { ProgressView() }
            else if isFinished { endView }
            else { pageView }
        }
        .navigationTitle("Story Time")
        .onAppear { buildStory() }
    }

    private var pageView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.06, blue: 0.16), Color(red: 0.06, green: 0.04, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Book page
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.14, green: 0.1, blue: 0.22))
                        .shadow(color: .black.opacity(0.4), radius: 20)

                    VStack(spacing: 24) {
                        // Page icon
                        Text(pageIcon(currentPage))
                            .font(.system(size: 64))

                        Text(pages[currentPage])
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .lineSpacing(6)
                    }
                    .padding(32)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Page dots
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: i == currentPage ? 20 : 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                Button {
                    withAnimation(.easeInOut) {
                        if currentPage < pages.count - 1 { currentPage += 1 }
                        else { isFinished = true }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next →" : "The End!")
                        .font(.title3.bold()).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(.purple, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }

    private var endView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.06, blue: 0.16), Color(red: 0.06, green: 0.04, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("⭐️").font(.system(size: 80))
                Text("The End!").font(.largeTitle.bold()).foregroundStyle(.white)
                Text("Great job, \(playerName)!").font(.title3).foregroundStyle(.white.opacity(0.7))
                Button("Read Again") {
                    withAnimation { currentPage = 0; isFinished = false }
                }
                .font(.headline).foregroundStyle(.white)
                .padding(.horizontal, 32).padding(.vertical, 14)
                .background(.purple, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func pageIcon(_ index: Int) -> String {
        let icons = ["📖", "🌟", "🏡", "🎉", "🌈", "❤️"]
        return icons[index % icons.count]
    }

    private func buildStory() {
        let name = playerName
        pages = [
            "Once upon a time, there was an incredible adventurer named \(name).",
            "Every single day, \(name) woke up curious about the world and ready to discover something amazing.",
            "One day, \(name) started exploring their family history — and found the most wonderful stories.",
            "They learned that every person in their family had their own superpower, passed down through generations.",
            "\(name) realized that knowing your family makes you even stronger and braver.",
            "And from that day forward, \(name) carried those stories in their heart — forever. ❤️"
        ]
        currentPage = 0
        isFinished = false
    }
}
