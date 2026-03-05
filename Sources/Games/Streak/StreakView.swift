import SwiftUI

struct StreakView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var selected: String?
    @State private var showResult = false
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var isGameOver = false
    @State private var isLoading = true
    @State private var isNewBest = false

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading…") }
            else if isGameOver { gameOverView }
            else if let c = challenges[safe: currentIndex] { questionView(c) }
        }
        .navigationTitle("Streak")
        .task { await load() }
    }

    private func questionView(_ c: TriviaChallenge) -> some View {
        VStack(spacing: 20) {
            // Flame streak indicator
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: min(24 + Double(streak) * 3, 52)))
                    .foregroundStyle(.red)
                    .animation(.spring(response: 0.3), value: streak)
                if streak > 0 {
                    Text("\(streak)").font(.title.bold()).foregroundStyle(.red)
                }
            }
            .frame(height: 56)

            Text(c.question)
                .font(.title3).multilineTextAlignment(.center).padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(c.answers, id: \.self) { answer in
                    Button { pick(answer, challenge: c) } label: {
                        HStack {
                            Text(answer).frame(maxWidth: .infinity, alignment: .leading)
                            if showResult {
                                if answer == c.correct {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                } else if answer == selected {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                }
                            }
                        }
                        .padding(12)
                        .background(answerBg(answer, c: c), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(showResult)
                }
            }
            .padding(.horizontal)

            if showResult {
                if selected == c.correct {
                    Button("Keep Going 🔥") { advance() }.buttonStyle(.borderedProminent).tint(.red)
                } else {
                    Button("See Score") { isGameOver = true }.buttonStyle(.borderedProminent).tint(.gray)
                }
            }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Image(systemName: streak > 0 ? "flame.fill" : "flame.slash.fill")
                .font(.system(size: 64)).foregroundStyle(streak > 0 ? .red : .gray)
            Text(streak > 0 ? "Streak broken!" : "No streak this time").font(.title.bold())
            Text("You got \(streak) in a row").font(.title2).foregroundStyle(.secondary)
            if isNewBest {
                Label("New best: \(bestStreak)!", systemImage: "star.fill")
                    .font(.headline).foregroundStyle(.yellow)
            } else if bestStreak > 0 {
                Text("Best: \(bestStreak)").font(.subheadline).foregroundStyle(.secondary)
            }
            Button("Try Again") { Task { await load() } }.buttonStyle(.borderedProminent).tint(.red)
        }.padding()
    }

    private func answerBg(_ answer: String, c: TriviaChallenge) -> Color {
        guard showResult else { return Color.gray.opacity(0.15) }
        if answer == c.correct { return .green.opacity(0.2) }
        if answer == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ answer: String, challenge: TriviaChallenge) {
        selected = answer
        if answer == challenge.correct {
            streak += 1
            if streak > bestStreak {
                bestStreak = streak
                isNewBest = true
                if let pid = ctx.currentPlayer?.id {
                    ScoreStore(playerId: pid).updateStreakHighScore(streak)
                }
            }
        }
        withAnimation { showResult = true }
        if answer != challenge.correct {
            Task {
                try? await Task.sleep(for: .milliseconds(800))
                isGameOver = true
            }
        }
    }

    private func advance() {
        selected = nil
        showResult = false
        if currentIndex + 1 >= challenges.count {
            // Fetch more
            Task {
                let more = (try? await ctx.api.getTrivia(limit: 10)) ?? []
                challenges.append(contentsOf: more)
                currentIndex += 1
            }
        } else {
            currentIndex += 1
        }
    }

    private func load() async {
        isLoading = true
        isGameOver = false
        isNewBest = false
        currentIndex = 0
        streak = 0
        selected = nil
        showResult = false
        bestStreak = ctx.currentPlayer.map { ScoreStore(playerId: $0.id).streakHighScore } ?? 0
        challenges = (try? await ctx.api.getTrivia(limit: 20)) ?? []
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
