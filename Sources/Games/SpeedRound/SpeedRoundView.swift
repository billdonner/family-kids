import SwiftUI

private let kDuration: Double = 15.0

struct SpeedRoundView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var selected: String?
    @State private var showResult = false
    @State private var score = 0
    @State private var timeLeft: Double = kDuration
    @State private var isFinished = false
    @State private var isLoading = true
    @State private var timerTask: Task<Void, Never>?

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading…") }
            else if isFinished { resultView }
            else if let c = challenges[safe: currentIndex] { questionView(c) }
        }
        .navigationTitle("Speed Round")
        .task { await load() }
        .onDisappear { timerTask?.cancel() }
    }

    private func questionView(_ c: TriviaChallenge) -> some View {
        VStack(spacing: 16) {
            // Timer ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: timeLeft / kDuration)
                    .stroke(timeLeft > 5 ? Color.orange : Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: timeLeft)
                Text(String(format: "%.0f", ceil(timeLeft)))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(timeLeft > 5 ? .primary : .red)
            }
            .frame(width: 90, height: 90)
            .padding(.top, 8)

            Text("Score: \(score)  ·  \(currentIndex + 1)/\(challenges.count)")
                .font(.caption).foregroundStyle(.secondary)

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
                Button("Next →") { advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bolt.circle.fill").font(.system(size: 64)).foregroundStyle(.orange)
            Text("Time's up!").font(.largeTitle.bold())
            Text("\(score) of \(challenges.count) correct").font(.title2)
            let pct = challenges.isEmpty ? 0 : Int(Double(score)/Double(challenges.count)*100)
            Text("\(pct)%").font(.system(size: 52, weight: .bold))
                .foregroundStyle(pct >= 70 ? .green : pct >= 40 ? .orange : .red)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent).tint(.orange)
        }.padding()
    }

    private func answerBg(_ answer: String, c: TriviaChallenge) -> Color {
        guard showResult else { return Color.gray.opacity(0.15) }
        if answer == c.correct { return .green.opacity(0.2) }
        if answer == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ answer: String, challenge: TriviaChallenge) {
        timerTask?.cancel()
        selected = answer
        if answer == challenge.correct { score += 1 }
        withAnimation { showResult = true }
    }

    private func advance() {
        selected = nil
        showResult = false
        if currentIndex + 1 >= challenges.count { isFinished = true; return }
        currentIndex += 1
        startTimer()
    }

    private func startTimer() {
        timerTask?.cancel()
        timeLeft = kDuration
        timerTask = Task {
            while !Task.isCancelled && timeLeft > 0 {
                try? await Task.sleep(for: .milliseconds(100))
                if Task.isCancelled { return }
                timeLeft = max(0, timeLeft - 0.1)
                if timeLeft <= 0 { isFinished = true; return }
            }
        }
    }

    private func load() async {
        timerTask?.cancel()
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        selected = nil
        showResult = false
        challenges = (try? await ctx.api.getTrivia(limit: 10)) ?? []
        isLoading = false
        startTimer()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
