import SwiftUI

/// Shown after family is set. Player picks which child they are.
struct PlayerSetupView: View {
    @EnvironmentObject var ctx: AppContext

    @State private var players: [KidsPlayer] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.07), Color(red: 0.07, green: 0.07, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.purple)
                }
                .padding(.bottom, 24)

                Text("Who are you?")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text("Tap your name to start playing")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 32)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .padding(.horizontal, 32)
                } else if players.isEmpty {
                    VStack(spacing: 12) {
                        Text("No family members found.")
                            .foregroundStyle(.white.opacity(0.6))
                        Text("Ask a parent to add you in the Family Tree app.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Try Again") { Task { await load() } }
                            .foregroundStyle(.orange)
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(players) { player in
                            Button {
                                ctx.currentPlayer = player
                            } label: {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.3))
                                            .frame(width: 44, height: 44)
                                        Text(String(player.displayName.prefix(1)).uppercased())
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                    Text(player.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .padding()
                                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                // Age picker at the bottom
                VStack(spacing: 8) {
                    Text("Your age")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Stepper("Age: \(ctx.currentAge)", value: Binding(
                        get: { ctx.currentAge },
                        set: { ctx.setAge($0) }
                    ), in: 3...18)
                    .padding()
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard let familyId = ctx.familyId else { return }
        isLoading = true
        error = nil
        do {
            players = try await ctx.api.getPlayers(familyId: familyId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
