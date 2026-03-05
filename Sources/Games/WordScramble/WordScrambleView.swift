import SwiftUI

struct WordScrambleView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var cards: [KidsCard] = []
    @State private var currentIndex = 0
    @State private var scrambled = ""
    @State private var userInput = ""
    @State private var isCorrect: Bool? = nil
    @State private var hints = 0
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true
    @State private var error: String?
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading cards…") }
            else if let err = error { Text(err).foregroundStyle(.red).padding() }
            else if isFinished { resultView }
            else if let card = cards[safe: currentIndex] { gameView(card) }
        }
        .navigationTitle("Word Scramble")
        .task { await load() }
    }

    private func gameView(_ card: KidsCard) -> some View {
        VStack(spacing: 24) {
            Text("\(currentIndex + 1) of \(cards.count)")
                .font(.caption).foregroundStyle(.secondary)

            Text(card.question)
                .font(.title3).multilineTextAlignment(.center).padding(.horizontal)

            VStack(spacing: 4) {
                Text("Unscramble the answer:").font(.subheadline).foregroundStyle(.secondary)
                Text(scrambled)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)
                    .tracking(6)
            }

            if let correct = isCorrect {
                VStack(spacing: 12) {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 48)).foregroundStyle(correct ? .green : .red)
                    if !correct {
                        Text("Answer: \(card.answer)").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Button("Next") { advance() }.buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 12) {
                    TextField("Type your answer…", text: $userInput)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isFocused)
                        .padding(.horizontal, 32)

                    Button("Check") { check(card) }
                        .buttonStyle(.borderedProminent)
                        .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)

                    if hints < card.answer.count / 2 {
                        Button("Hint (\(card.answer.count - hints) letters left)") {
                            hints += 1
                            scrambled = String(card.answer.prefix(hints)) +
                                String(scrambleWord(String(card.answer.dropFirst(hints))))
                        }
                        .font(.caption).foregroundStyle(.blue)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 24)
        .onAppear { isFocused = true }
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "textformat.abc.dottedunderline").font(.system(size: 60)).foregroundStyle(.indigo)
            Text("Word Wizard!").font(.largeTitle.bold())
            Text("\(score) of \(cards.count)").font(.title2)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }
    }

    private func check(_ card: KidsCard) {
        isCorrect = userInput.trimmingCharacters(in: .whitespaces).lowercased() == card.answer.lowercased()
        if isCorrect == true { score += 1 }
        isFocused = false
    }

    private func advance() {
        isCorrect = nil
        userInput = ""
        hints = 0
        if currentIndex + 1 >= cards.count { isFinished = true }
        else { currentIndex += 1; setupScramble() }
    }

    private func setupScramble() {
        guard let card = cards[safe: currentIndex] else { return }
        scrambled = scrambleWord(card.answer)
    }

    private func scrambleWord(_ word: String) -> String {
        var letters = Array(word)
        var result: String
        repeat { letters.shuffle(); result = String(letters) }
        while result.lowercased() == word.lowercased() && letters.count > 1
        return result
    }

    private func load() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        isCorrect = nil
        userInput = ""
        hints = 0
        do {
            let decks = try await ctx.api.getDecks(familyId: familyId, playerId: player.id)
            guard let deck = decks.first else {
                error = "No decks found. Generate flashcard decks first."; isLoading = false; return
            }
            let raw = try await ctx.api.getCards(deckId: deck.id)
            cards = Array(raw.filter { $0.answer.count >= 3 }.prefix(8))
            setupScramble()
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
