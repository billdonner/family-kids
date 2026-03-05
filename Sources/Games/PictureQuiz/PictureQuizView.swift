import SwiftUI

/// "Name Quiz" — show a scrambled / partially hidden player name, pick from 4 options.
struct PictureQuizView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var players: [KidsPlayer] = []
    @State private var rounds: [(answer: KidsPlayer, choices: [KidsPlayer])] = []
    @State private var currentIndex = 0
    @State private var selected: UUID? = nil
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading family…") }
            else if players.count < 2 {
                ContentUnavailableView {
                    Label("Not enough family members", systemImage: "person.2.slash")
                } description: {
                    Text("Add at least 2 people in the Family Tree app.")
                }
            }
            else if isFinished { resultView }
            else if let round = rounds[safe: currentIndex] { roundView(round) }
        }
        .navigationTitle("Name Quiz")
        .task { await load() }
    }

    private func roundView(_ round: (answer: KidsPlayer, choices: [KidsPlayer])) -> some View {
        VStack(spacing: 28) {
            Text("\(currentIndex + 1) of \(rounds.count)")
                .font(.caption).foregroundStyle(.secondary)

            // Mystery icon
            ZStack {
                Circle().fill(Color.purple.opacity(0.2)).frame(width: 120, height: 120)
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 48)).foregroundStyle(.purple)
            }

            VStack(spacing: 4) {
                Text("Who is this family member?").font(.subheadline).foregroundStyle(.secondary)
                // Show first initial + dashes for the rest
                let name = round.answer.displayName
                let hint = String(name.prefix(1)) + String(repeating: " _", count: max(0, name.count - 1))
                Text(hint).font(.system(size: 28, weight: .bold, design: .monospaced)).foregroundStyle(.purple)
            }

            VStack(spacing: 12) {
                ForEach(round.choices) { choice in
                    Button { pick(choice, answer: round.answer) } label: {
                        HStack {
                            Text(choice.displayName).frame(maxWidth: .infinity, alignment: .leading)
                            if let sel = selected {
                                if choice.id == round.answer.id {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                } else if choice.id == sel {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                }
                            }
                        }
                        .padding()
                        .background(choiceBg(choice, answer: round.answer), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(selected == nil ? .primary : (choice.id == round.answer.id ? .white : .primary))
                    }
                    .buttonStyle(.plain)
                    .disabled(selected != nil)
                }
            }
            .padding(.horizontal)

            if selected != nil {
                Button("Next") { advance() }.buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.checkmark").font(.system(size: 60)).foregroundStyle(.purple)
            Text("Family Expert!").font(.largeTitle.bold())
            Text("\(score) of \(rounds.count)").font(.title2)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }
    }

    private func choiceBg(_ choice: KidsPlayer, answer: KidsPlayer) -> Color {
        guard let sel = selected else { return Color.gray.opacity(0.15) }
        if choice.id == answer.id { return .green.opacity(0.7) }
        if choice.id == sel { return .red.opacity(0.3) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ choice: KidsPlayer, answer: KidsPlayer) {
        selected = choice.id
        if choice.id == answer.id { score += 1 }
    }

    private func advance() {
        selected = nil
        if currentIndex + 1 >= rounds.count { isFinished = true }
        else { currentIndex += 1 }
    }

    private func buildRounds() {
        rounds = players.map { answer in
            var others = players.filter { $0.id != answer.id }.shuffled()
            let choices = Array(([answer] + others.prefix(3)).shuffled())
            return (answer: answer, choices: choices)
        }.shuffled()
    }

    private func load() async {
        guard let familyId = ctx.familyId else { return }
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        selected = nil
        players = (try? await ctx.api.getPlayers(familyId: familyId)) ?? []
        buildRounds()
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
