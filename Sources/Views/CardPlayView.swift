import SwiftUI

/// Card-by-card play with flip, "Got it!" / "Try again", and completion screen.
struct CardPlayView: View {
    let deck: KidsDeck

    @State private var cards: [KidsCard] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var correctCount = 0
    @State private var isLoading = true
    @State private var isComplete = false
    @Environment(\.dismiss) private var dismiss

    private let api = KidsAPIClient()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading cards...")
            } else if isComplete {
                completionView
            } else if cards.isEmpty {
                ContentUnavailableView("No Cards", systemImage: "rectangle.slash")
            } else {
                cardView
            }
        }
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadCards() }
    }

    private var cardView: some View {
        VStack(spacing: 24) {
            // Progress
            Text("Card \(currentIndex + 1) of \(cards.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: Double(currentIndex), total: Double(cards.count))
                .tint(.orange)
                .padding(.horizontal)

            Spacer()

            // Card
            let card = cards[currentIndex]
            ZStack {
                // Question
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    Text(card.question)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    if !isFlipped {
                        Text("Tap to reveal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity, minHeight: 250)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

                // Answer
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text(card.answer)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .frame(maxWidth: .infinity, minHeight: 250)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isFlipped.toggle()
                }
            }

            Spacer()

            // Buttons (only shown when flipped)
            if isFlipped {
                HStack(spacing: 20) {
                    Button {
                        advance(correct: false)
                    } label: {
                        Label("Try Again", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.red, in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        advance(correct: true)
                    } label: {
                        Label("Got It!", systemImage: "hand.thumbsup")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.green, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)

            Text("Great Job!")
                .font(.largeTitle.bold())

            Text("You got \(correctCount) out of \(cards.count) correct!")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                Button {
                    restart()
                } label: {
                    Label("Play Again", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(.orange, in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                }
            }

            Spacer()
        }
    }

    private func loadCards() async {
        isLoading = true
        defer { isLoading = false }
        do {
            cards = try await api.getCards(deckId: deck.id)
        } catch {
            // Empty cards handled by ContentUnavailableView
        }
    }

    private func advance(correct: Bool) {
        if correct { correctCount += 1 }

        if currentIndex + 1 >= cards.count {
            withAnimation { isComplete = true }
        } else {
            withAnimation {
                isFlipped = false
                currentIndex += 1
            }
        }
    }

    private func restart() {
        currentIndex = 0
        correctCount = 0
        isFlipped = false
        isComplete = false
    }
}
