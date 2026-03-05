import SwiftUI

struct ChildSwitcherView: View {
    @EnvironmentObject var ctx: AppContext
    @Environment(\.dismiss) private var dismiss

    @State private var players: [KidsPlayer] = []
    @State private var isLoading = true
    @State private var selectedAge: Int = 8

    var body: some View {
        NavigationStack {
            Form {
                Section("Who's playing?") {
                    if isLoading {
                        ProgressView()
                    } else if players.isEmpty {
                        Text("No family members found").foregroundStyle(.secondary)
                    } else {
                        ForEach(players) { player in
                            Button {
                                ctx.currentPlayer = player
                                dismiss()
                            } label: {
                                HStack {
                                    Text(player.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if ctx.currentPlayer?.id == player.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Stepper("Age: \(ctx.currentAge)", value: Binding(
                        get: { ctx.currentAge },
                        set: { ctx.setAge($0) }
                    ), in: 3...18)
                } header: {
                    Text("Age")
                } footer: {
                    Text("Games are unlocked based on age.")
                }

                Section {
                    Button("Change Family", role: .destructive) {
                        ctx.clearFamily()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Switch Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await loadPlayers() }
        }
    }

    private func loadPlayers() async {
        guard let familyId = ctx.familyId else { return }
        isLoading = true
        players = (try? await ctx.api.getPlayers(familyId: familyId)) ?? []
        isLoading = false
    }
}
