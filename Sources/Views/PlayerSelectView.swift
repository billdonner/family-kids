import SwiftUI

/// "Who are you?" player picker.
struct PlayerSelectView: View {
    let familyId: UUID
    @State private var players: [KidsPlayer] = []
    @State private var isLoading = true
    @State private var error: String?

    private let api = KidsAPIClient()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading players...")
                } else if players.isEmpty {
                    ContentUnavailableView {
                        Label("No Players", systemImage: "figure.child")
                    } description: {
                        Text("No players found. Ask a parent to mark someone as a player in the Family Tree app.")
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Who are you?")
                                .font(.largeTitle.bold())
                                .padding(.top, 24)

                            ForEach(players) { player in
                                NavigationLink(value: player) {
                                    HStack {
                                        Image(systemName: "figure.child")
                                            .font(.title)
                                            .foregroundStyle(.orange)
                                            .frame(width: 50, height: 50)
                                            .background(.orange.opacity(0.15), in: Circle())

                                        Text(player.displayName)
                                            .font(.title2.bold())
                                            .foregroundStyle(.primary)

                                        Spacer()

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
                    }
                }
            }
            .navigationTitle("Family Kids")
            .navigationDestination(for: KidsPlayer.self) { player in
                DeckListView(familyId: familyId, player: player)
            }
            .task { await loadPlayers() }
            .refreshable { await loadPlayers() }
        }
    }

    private func loadPlayers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            players = try await api.getPlayers(familyId: familyId)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
