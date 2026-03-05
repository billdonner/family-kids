import SwiftUI

/// Simple kids trivia game: fetch challenges, show Q&A one at a time.
struct TriviaPlayView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var selected: String?
    @State private var showResult = false
    @State private var score = 0
    @State private var isLoading = true
    @State private var isFinished = false
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading questions…")
            } else if let err = error {
                ContentUnavailableView {
                    Label("Can't load trivia", systemImage: "wifi.slash")
                } description: {
                    Text(err).font(.caption)
                } actions: {
                    Button("Retry") { Task { await load() } }.buttonStyle(.borderedProminent)
                }
            } else if isFinished {
                resultView
            } else if let challenge = challenges[safe: currentIndex] {
                questionView(challenge)
            }
        }
        .navigationTitle("Trivia")
        .task { await load() }
    }

    // MARK: - Question

    private func questionView(_ challenge: TriviaChallenge) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(currentIndex + 1) of \(challenges.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(challenge.question)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(challenge.topic)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                VStack(spacing: 12) {
                    ForEach(challenge.answers, id: \.self) { answer in
                        Button { selectAnswer(answer, challenge: challenge) } label: {
                            HStack {
                                Text(answer)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if showResult {
                                    if answer == challenge.correct {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                    } else if answer == selected {
                                        Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(answerBg(answer, challenge: challenge))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(showResult)
                    }
                }
                .padding(.horizontal)

                if showResult {
                    VStack(spacing: 8) {
                        if !challenge.explanation.isEmpty {
                            Text(challenge.explanation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        Button("Next") { advance() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(spacing: 24) {
            Image(systemName: score >= challenges.count / 2 ? "star.fill" : "hand.thumbsup.fill")
                .font(.system(size: 64))
                .foregroundStyle(score >= challenges.count / 2 ? .yellow : .orange)

            Text("Done!")
                .font(.largeTitle.bold())

            Text("\(score) of \(challenges.count) correct")
                .font(.title2)

            let pct = challenges.isEmpty ? 0 : Int(Double(score) / Double(challenges.count) * 100)
            Text("\(pct)%")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(pct >= 70 ? .green : pct >= 40 ? .orange : .red)

            Button("Play Again") {
                Task { await load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Helpers

    private func answerBg(_ answer: String, challenge: TriviaChallenge) -> Color {
        guard showResult else { return Color.gray.opacity(0.15) }
        if answer == challenge.correct { return .green.opacity(0.2) }
        if answer == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func selectAnswer(_ answer: String, challenge: TriviaChallenge) {
        selected = answer
        if answer == challenge.correct { score += 1 }
        withAnimation { showResult = true }
    }

    private func advance() {
        selected = nil
        showResult = false
        if currentIndex + 1 >= challenges.count {
            isFinished = true
        } else {
            currentIndex += 1
        }
    }

    private func load() async {
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        selected = nil
        showResult = false
        error = nil
        do {
            challenges = try await ctx.api.getTrivia(limit: 10)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
