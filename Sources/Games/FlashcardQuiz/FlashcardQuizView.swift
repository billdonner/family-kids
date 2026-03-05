import SwiftUI

/// Flashcard Q with 4 multiple-choice answers (other cards' answers as distractors).
struct FlashcardQuizView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var cards: [KidsCard] = []
    @State private var currentIndex = 0
    @State private var choices: [String] = []
    @State private var selected: String?
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading…") }
            else if let err = error { Text(err).foregroundStyle(.red).padding() }
            else if isFinished { resultView }
            else if let card = cards[safe: currentIndex] { questionView(card) }
        }
        .navigationTitle("Flashcard Quiz")
        .task { await load() }
    }

    private func questionView(_ card: KidsCard) -> some View {
        VStack(spacing: 20) {
            Text("\(currentIndex + 1) of \(cards.count)")
                .font(.caption).foregroundStyle(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [.orange.opacity(0.8), .yellow.opacity(0.6)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 8)
                Text(card.question)
                    .font(.title3).multilineTextAlignment(.center)
                    .foregroundStyle(.white).padding(24)
            }
            .frame(maxWidth: .infinity).frame(height: 140)
            .padding(.horizontal)

            VStack(spacing: 10) {
                ForEach(choices, id: \.self) { choice in
                    Button { pick(choice, card: card) } label: {
                        HStack {
                            Text(choice).frame(maxWidth: .infinity, alignment: .leading)
                            if let sel = selected {
                                if choice == card.answer {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                } else if choice == sel {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                }
                            }
                        }
                        .padding(12)
                        .background(choiceBg(choice, card: card), in: RoundedRectangle(cornerRadius: 10))
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
            Image(systemName: "graduationcap.fill").font(.system(size: 60)).foregroundStyle(.yellow)
            Text("Quiz Complete!").font(.largeTitle.bold())
            Text("\(score) of \(cards.count)").font(.title2)
            let pct = cards.isEmpty ? 0 : Int(Double(score)/Double(cards.count)*100)
            Text("\(pct)%").font(.system(size: 52, weight: .bold))
                .foregroundStyle(pct >= 70 ? .green : pct >= 40 ? .orange : .red)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }.padding()
    }

    private func choiceBg(_ choice: String, card: KidsCard) -> Color {
        guard selected != nil else { return Color.gray.opacity(0.15) }
        if choice == card.answer { return .green.opacity(0.2) }
        if choice == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ choice: String, card: KidsCard) {
        selected = choice
        if choice == card.answer { score += 1 }
    }

    private func advance() {
        selected = nil
        if currentIndex + 1 >= cards.count { isFinished = true; return }
        currentIndex += 1
        buildChoices()
    }

    private func buildChoices() {
        guard let card = cards[safe: currentIndex] else { return }
        var distractors = cards.filter { $0.id != card.id }.map { $0.answer }.shuffled()
        let wrong = Array(distractors.prefix(3))
        choices = ([card.answer] + wrong).shuffled()
    }

    private func load() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        selected = nil
        do {
            let decks = try await ctx.api.getDecks(familyId: familyId, playerId: player.id)
            guard let deck = decks.first else {
                error = "No decks found. Generate flashcard decks first."; isLoading = false; return
            }
            let raw = try await ctx.api.getCards(deckId: deck.id)
            cards = Array(raw.filter { !$0.answer.isEmpty }.shuffled().prefix(10))
            buildChoices()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
