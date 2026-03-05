import SwiftUI

private struct MatchCard: Identifiable {
    let id = UUID()
    let text: String
    let pairId: UUID
    let isQuestion: Bool
    var isFaceUp = false
    var isMatched = false
}

struct MemoryMatchView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var cards: [MatchCard] = []
    @State private var selectedId: UUID?
    @State private var isLoading = true
    @State private var isWon = false
    @State private var moves = 0
    @State private var error: String?
    @State private var isChecking = false

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading cards…") }
            else if let err = error { Text(err).foregroundStyle(.red).padding() }
            else if isWon { wonView }
            else { gameGrid }
        }
        .navigationTitle("Memory Match")
        .task { await load() }
    }

    private var gameGrid: some View {
        VStack {
            Text("Moves: \(moves)")
                .font(.caption).foregroundStyle(.secondary)
            let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(cards) { card in
                    cardTile(card)
                }
            }
            .padding()
        }
    }

    private func cardTile(_ card: MatchCard) -> some View {
        Button { tap(card) } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(card.isMatched ? Color.green.opacity(0.3) :
                          card.isFaceUp ? (card.isQuestion ? Color.orange.opacity(0.8) : Color.blue.opacity(0.8)) :
                          Color.gray.opacity(0.3))
                if card.isFaceUp || card.isMatched {
                    Text(card.text)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(4)
                } else {
                    Image(systemName: "questionmark")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 80)
        }
        .buttonStyle(.plain)
        .disabled(card.isMatched || card.isFaceUp || isChecking)
    }

    private var wonView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill").font(.system(size: 60)).foregroundStyle(.yellow)
            Text("You matched them all!").font(.largeTitle.bold())
            Text("\(moves) moves").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }.padding()
    }

    private func tap(_ card: MatchCard) {
        guard let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }
        if let selId = selectedId, let selIdx = cards.firstIndex(where: { $0.id == selId }) {
            // Second tap — check match
            cards[idx].isFaceUp = true
            moves += 1
            if cards[selIdx].pairId == cards[idx].pairId && cards[selIdx].isQuestion != cards[idx].isQuestion {
                cards[selIdx].isMatched = true
                cards[idx].isMatched = true
                selectedId = nil
                if cards.allSatisfy({ $0.isMatched }) { isWon = true }
            } else {
                // No match — flip back after delay
                isChecking = true
                selectedId = nil
                Task {
                    try? await Task.sleep(for: .milliseconds(900))
                    cards[selIdx].isFaceUp = false
                    cards[idx].isFaceUp = false
                    isChecking = false
                }
            }
        } else {
            cards[idx].isFaceUp = true
            selectedId = card.id
        }
    }

    private func load() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isLoading = true
        isWon = false
        moves = 0
        selectedId = nil
        do {
            let decks = try await ctx.api.getDecks(familyId: familyId, playerId: player.id)
            guard let deck = decks.first else {
                error = "No decks found. Generate flashcard decks first."; isLoading = false; return
            }
            let raw = try await ctx.api.getCards(deckId: deck.id)
            let picked = Array(raw.prefix(8))
            var built: [MatchCard] = []
            for c in picked {
                let pid = c.id
                built.append(MatchCard(text: c.question, pairId: pid, isQuestion: true))
                built.append(MatchCard(text: c.answer, pairId: pid, isQuestion: false))
            }
            cards = built.shuffled()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
