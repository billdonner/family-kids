import SwiftUI

/// Shows the player's flashcard decks and lets them pick one to play.
struct FlashcardLaunchView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var decks: [KidsDeck] = []
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var error: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading decks…")
            } else if decks.isEmpty {
                ContentUnavailableView {
                    Label("No Decks Yet", systemImage: "rectangle.on.rectangle")
                } description: {
                    Text("Ask a parent to generate flashcard decks for you, or tap below.")
                } actions: {
                    Button("Generate My Decks") {
                        Task { await generateDecks() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating)
                }
            } else {
                List {
                    ForEach(decks) { deck in
                        NavigationLink(value: deck) {
                            HStack {
                                Image(systemName: "rectangle.on.rectangle.angled.fill")
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading) {
                                    Text(deck.title).font(.headline)
                                    Text("\(deck.cardCount) cards").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Section {
                        Button {
                            Task { await generateDecks() }
                        } label: {
                            Label(isGenerating ? "Regenerating…" : "Regenerate Decks", systemImage: "arrow.clockwise")
                        }
                        .disabled(isGenerating)
                    }
                }
                .navigationDestination(for: KidsDeck.self) { deck in
                    CardPlayView(deck: deck)
                        .onAppear {
                            if let pid = ctx.currentPlayer?.id {
                                ScoreStore(playerId: pid).recordFlashcardSession()
                            }
                        }
                }
            }
        }
        .navigationTitle("Flashcards")
        .task { await loadDecks() }
        .refreshable { await loadDecks() }
        .alert("Error", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }

    private func loadDecks() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isLoading = true
        decks = (try? await ctx.api.getDecks(familyId: familyId, playerId: player.id)) ?? []
        isLoading = false
    }

    private func generateDecks() async {
        guard let familyId = ctx.familyId, let player = ctx.currentPlayer else { return }
        isGenerating = true
        do {
            _ = try await ctx.api.generateDecks(familyId: familyId, playerId: player.id)
            await loadDecks()
        } catch {
            self.error = error.localizedDescription
        }
        isGenerating = false
    }
}
