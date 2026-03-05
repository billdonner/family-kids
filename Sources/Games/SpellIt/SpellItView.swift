import SwiftUI

private struct LetterTile: Identifiable {
    let id = UUID()
    let letter: Character
    var isUsed = false
}

struct SpellItView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var cards: [KidsCard] = []
    @State private var currentIndex = 0
    @State private var tiles: [LetterTile] = []
    @State private var typed: [LetterTile] = []
    @State private var isCorrect: Bool? = nil
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading cards…") }
            else if let err = error { Text(err).foregroundStyle(.red).padding() }
            else if isFinished { resultView }
            else if let card = cards[safe: currentIndex] { gameView(card) }
        }
        .navigationTitle("Spell It")
        .task { await load() }
    }

    private func gameView(_ card: KidsCard) -> some View {
        VStack(spacing: 20) {
            Text("\(currentIndex + 1) of \(cards.count)")
                .font(.caption).foregroundStyle(.secondary)

            Text(card.question)
                .font(.title3).multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Spell the answer (\(card.answer.count) letters)")
                .font(.subheadline).foregroundStyle(.secondary)

            // Typed so far
            HStack(spacing: 6) {
                ForEach(typed) { t in
                    Button { untap(t) } label: {
                        Text(String(t.letter).uppercased())
                            .font(.title2.bold())
                            .frame(width: 36, height: 44)
                            .background(Color.blue.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                ForEach(0..<max(0, card.answer.count - typed.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 36, height: 44)
                }
            }
            .padding(.horizontal)

            if let correct = isCorrect {
                VStack(spacing: 8) {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(correct ? .green : .red)
                    if !correct {
                        Text("Answer: \(card.answer)").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Button("Next") { advance() }.buttonStyle(.borderedProminent)
                }
            } else {
                // Letter tiles
                let rows = tiles.chunked(into: 7)
                VStack(spacing: 8) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 6) {
                            ForEach(row) { tile in
                                Button { tap(tile) } label: {
                                    Text(String(tile.letter).uppercased())
                                        .font(.title3.bold())
                                        .frame(width: 40, height: 44)
                                        .background(tile.isUsed ? Color.gray.opacity(0.2) : Color.orange.opacity(0.7),
                                                    in: RoundedRectangle(cornerRadius: 8))
                                        .foregroundStyle(tile.isUsed ? .gray : .white)
                                }
                                .buttonStyle(.plain)
                                .disabled(tile.isUsed)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                if typed.count == card.answer.count {
                    Button("Check!") { checkAnswer(card) }
                        .buttonStyle(.borderedProminent)
                }

                Button("Clear") { clearTyped() }
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "pencil.circle.fill").font(.system(size: 60)).foregroundStyle(.pink)
            Text("Spell-tacular!").font(.largeTitle.bold())
            Text("\(score) of \(cards.count)").font(.title2)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }
    }

    private func tap(_ tile: LetterTile) {
        guard let idx = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
        tiles[idx].isUsed = true
        typed.append(tiles[idx])
    }

    private func untap(_ tile: LetterTile) {
        typed.removeAll { $0.id == tile.id }
        if let idx = tiles.firstIndex(where: { $0.id == tile.id }) {
            tiles[idx].isUsed = false
        }
    }

    private func clearTyped() {
        for t in typed {
            if let idx = tiles.firstIndex(where: { $0.id == t.id }) { tiles[idx].isUsed = false }
        }
        typed.removeAll()
    }

    private func checkAnswer(_ card: KidsCard) {
        let spelled = typed.map { String($0.letter) }.joined()
        isCorrect = spelled.lowercased() == card.answer.lowercased()
        if isCorrect == true { score += 1 }
    }

    private func advance() {
        isCorrect = nil
        typed.removeAll()
        if currentIndex + 1 >= cards.count { isFinished = true }
        else { currentIndex += 1; setupTiles() }
    }

    private func setupTiles() {
        guard let card = cards[safe: currentIndex] else { return }
        // Add extra decoy letters
        var letters = Array(card.answer)
        let extras = "abcdefghijklmnoprstuvwy"
        let needed = max(0, 10 - letters.count)
        letters += Array(extras.shuffled().prefix(needed))
        tiles = letters.shuffled().map { LetterTile(letter: $0) }
    }

    private func load() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        isCorrect = nil
        typed.removeAll()
        do {
            let decks = try await ctx.api.getDecks(familyId: familyId, playerId: player.id)
            guard let deck = decks.first else {
                error = "No decks found. Generate flashcard decks first."; isLoading = false; return
            }
            let raw = try await ctx.api.getCards(deckId: deck.id)
            cards = Array(raw.prefix(8))
            setupTiles()
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
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
