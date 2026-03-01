import SwiftUI

/// Shows the player's available decks.
struct DeckListView: View {
    let familyId: UUID
    let player: KidsPlayer

    @State private var decks: [KidsDeck] = []
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var error: String?

    private let api = KidsAPIClient()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading decks...")
            } else if decks.isEmpty {
                ContentUnavailableView {
                    Label("No Decks Yet", systemImage: "rectangle.on.rectangle")
                } description: {
                    Text("Ask a parent to generate flashcard decks for you!")
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(decks) { deck in
                            NavigationLink(value: deck) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(deck.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("\(deck.cardCount) cards")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: deck.kind == "flashcard" ? "rectangle.on.rectangle" : "questionmark.circle")
                                        .font(.title2)
                                        .foregroundStyle(.blue)

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
        }
        .navigationTitle("\(player.displayName)'s Decks")
        .navigationDestination(for: KidsDeck.self) { deck in
            CardPlayView(deck: deck)
        }
        .task { await loadDecks() }
        .refreshable { await loadDecks() }
    }

    private func loadDecks() async {
        isLoading = true
        defer { isLoading = false }
        do {
            decks = try await api.getDecks(familyId: familyId, playerId: player.id)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
