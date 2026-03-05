import SwiftUI

struct DailyChallengeView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var selected: String?
    @State private var score = 0
    @State private var answers: [Bool] = []
    @State private var isFinished = false
    @State private var isLoading = true
    @State private var alreadyPlayed = false
    @State private var savedScore = 0
    @State private var savedTotal = 0

    private static let questionsPerDay = 5

    private var todayKey: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let playerId = ctx.currentPlayer?.id.uuidString ?? "anon"
        return "daily_\(playerId)_\(df.string(from: Date()))"
    }

    private var todayLabel: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: Date())
    }

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading…") }
            else if alreadyPlayed { alreadyPlayedView }
            else if isFinished { resultView }
            else if let c = challenges[safe: currentIndex] { questionView(c) }
        }
        .navigationTitle("Daily Challenge")
        .task { await load() }
    }

    private func questionView(_ c: TriviaChallenge) -> some View {
        VStack(spacing: 20) {
            // Calendar header
            HStack {
                Image(systemName: "calendar").foregroundStyle(.blue)
                Text(todayLabel).font(.subheadline.bold()).foregroundStyle(.blue)
                Spacer()
                Text("\(currentIndex + 1) / \(Self.questionsPerDay)").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Answer dots
            HStack(spacing: 8) {
                ForEach(0..<Self.questionsPerDay, id: \.self) { i in
                    Circle()
                        .fill(i < answers.count ? (answers[i] ? Color.green : Color.red) :
                              i == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }

            Text(c.question)
                .font(.title3).multilineTextAlignment(.center).padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(c.answers, id: \.self) { answer in
                    Button { pick(answer, challenge: c) } label: {
                        HStack {
                            Text(answer).frame(maxWidth: .infinity, alignment: .leading)
                            if selected != nil {
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
                    .disabled(selected != nil)
                }
            }
            .padding(.horizontal)

            if selected != nil {
                Button(currentIndex + 1 < Self.questionsPerDay ? "Next" : "Finish") { advance() }
                    .buttonStyle(.borderedProminent).tint(.blue)
            }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.checkmark").font(.system(size: 60)).foregroundStyle(.blue)
            Text("Daily Complete!").font(.largeTitle.bold())
            Text(todayLabel).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(answers, id: \.self) { correct in
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(correct ? .green : .red)
                        .font(.title2)
                }
            }
            Text("\(score) of \(Self.questionsPerDay) correct").font(.title2)
            Text("Come back tomorrow for a new challenge!").font(.caption).foregroundStyle(.secondary)
        }.padding()
    }

    private var alreadyPlayedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 60)).foregroundStyle(.green)
            Text("Already played today!").font(.title.bold())
            Text(todayLabel).font(.subheadline).foregroundStyle(.secondary)
            Text("\(savedScore) of \(savedTotal) correct").font(.title2)
            Text("Come back tomorrow for a new challenge!").font(.subheadline).foregroundStyle(.secondary)
        }.padding()
    }

    private func answerBg(_ answer: String, c: TriviaChallenge) -> Color {
        guard selected != nil else { return Color.gray.opacity(0.15) }
        if answer == c.correct { return .green.opacity(0.2) }
        if answer == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ answer: String, challenge: TriviaChallenge) {
        selected = answer
        let correct = answer == challenge.correct
        if correct { score += 1 }
        answers.append(correct)
    }

    private func advance() {
        selected = nil
        if currentIndex + 1 >= Self.questionsPerDay || currentIndex + 1 >= challenges.count {
            // Save result
            UserDefaults.standard.set("\(score)/\(Self.questionsPerDay)", forKey: todayKey)
            isFinished = true
        } else {
            currentIndex += 1
        }
    }

    private func load() async {
        isLoading = true
        // Check if already played today
        if let saved = UserDefaults.standard.string(forKey: todayKey) {
            let parts = saved.split(separator: "/").compactMap { Int($0) }
            if parts.count == 2 { savedScore = parts[0]; savedTotal = parts[1]; alreadyPlayed = true }
        }
        if !alreadyPlayed {
            challenges = (try? await ctx.api.getTrivia(limit: Self.questionsPerDay)) ?? []
        }
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
