import SwiftUI

struct TrueOrFalseView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var displayedAnswer = ""
    @State private var isActuallyTrue = false
    @State private var answered: Bool? = nil
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading…") }
            else if isFinished { resultView }
            else if let challenge = challenges[safe: currentIndex] { questionView(challenge) }
        }
        .navigationTitle("True or False")
        .task { await load() }
    }

    private func questionView(_ c: TriviaChallenge) -> some View {
        VStack(spacing: 32) {
            Text("\(currentIndex + 1) of \(challenges.count)")
                .font(.caption).foregroundStyle(.secondary)

            Text(c.question)
                .font(.title3).multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 8) {
                Text("Is this the correct answer?").font(.subheadline).foregroundStyle(.secondary)
                Text("\"\(displayedAnswer)\"")
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            }

            if let ans = answered {
                let correct = ans == isActuallyTrue
                VStack(spacing: 8) {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(correct ? .green : .red)
                    Text(correct ? "Correct!" : "Nope! It was \(isActuallyTrue ? "TRUE" : "FALSE")")
                        .font(.headline)
                    Button("Next") { advance() }.buttonStyle(.borderedProminent)
                }
            } else {
                HStack(spacing: 24) {
                    BigButton(title: "TRUE", color: .green) { answer(true) }
                    BigButton(title: "FALSE", color: .red) { answer(false) }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.top, 24)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "flag.checkered").font(.system(size: 60)).foregroundStyle(.orange)
            Text("Finished!").font(.largeTitle.bold())
            Text("\(score) of \(challenges.count)").font(.title2)
            let pct = challenges.isEmpty ? 0 : Int(Double(score)/Double(challenges.count)*100)
            Text("\(pct)%").font(.system(size: 52, weight: .bold))
                .foregroundStyle(pct >= 70 ? .green : pct >= 40 ? .orange : .red)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }
    }

    private func answer(_ tapped: Bool) {
        answered = tapped
        if tapped == isActuallyTrue { score += 1 }
    }

    private func advance() {
        answered = nil
        if currentIndex + 1 >= challenges.count { isFinished = true }
        else { currentIndex += 1; setupDisplay() }
    }

    private func setupDisplay() {
        guard let c = challenges[safe: currentIndex] else { return }
        isActuallyTrue = Bool.random()
        if isActuallyTrue {
            displayedAnswer = c.correct
        } else {
            displayedAnswer = c.answers.filter { $0 != c.correct }.randomElement() ?? c.correct
        }
    }

    private func load() async {
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        answered = nil
        challenges = (try? await ctx.api.getTrivia(limit: 10)) ?? []
        setupDisplay()
        isLoading = false
    }
}

private struct BigButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.title.bold()).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 20)
                .background(color, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
