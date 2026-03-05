import SwiftUI

struct HighScoresView: View {
    @EnvironmentObject var ctx: AppContext
    @Environment(\.dismiss) private var dismiss

    private var store: ScoreStore? {
        ctx.currentPlayer.map { ScoreStore(playerId: $0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.04, blue: 0.1), Color(red: 0.07, green: 0.05, blue: 0.14)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Player badge
                        if let player = ctx.currentPlayer {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.2))
                                        .frame(width: 72, height: 72)
                                    Text(String(player.displayName.prefix(1)).uppercased())
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(.yellow)
                                }
                                Text(player.displayName)
                                    .font(.title2.bold()).foregroundStyle(.white)
                                Text("Personal Bests").font(.subheadline).foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.top, 8)
                        }

                        // Score cards
                        VStack(spacing: 12) {
                            ScoreRow(
                                icon: "flame.fill",
                                color: .red,
                                title: "Streak",
                                subtitle: "Best consecutive correct",
                                value: store.map { "\($0.streakHighScore) in a row" } ?? "—",
                                isEmpty: (store?.streakHighScore ?? 0) == 0
                            )
                            ScoreRow(
                                icon: "bolt.circle.fill",
                                color: .orange,
                                title: "Speed Round",
                                subtitle: "Best score in 15 seconds",
                                value: store.map { "\($0.speedHighScore) correct" } ?? "—",
                                isEmpty: (store?.speedHighScore ?? 0) == 0
                            )
                            ScoreRow(
                                icon: "questionmark.circle.fill",
                                color: .blue,
                                title: "Trivia",
                                subtitle: "Best score per round",
                                value: store.map { "\($0.triviaHighScore) correct" } ?? "—",
                                isEmpty: (store?.triviaHighScore ?? 0) == 0
                            )
                            ScoreRow(
                                icon: "calendar.badge.checkmark",
                                color: .teal,
                                title: "Daily Challenge",
                                subtitle: "Total days completed",
                                value: store.map { "\($0.dailiesCompleted) day\($0.dailiesCompleted == 1 ? "" : "s")" } ?? "—",
                                isEmpty: (store?.dailiesCompleted ?? 0) == 0
                            )
                            ScoreRow(
                                icon: "rectangle.on.rectangle.angled.fill",
                                color: .orange,
                                title: "Flashcards",
                                subtitle: "Total sessions played",
                                value: store.map { "\($0.flashcardSessions) session\($0.flashcardSessions == 1 ? "" : "s")" } ?? "—",
                                isEmpty: (store?.flashcardSessions ?? 0) == 0
                            )
                        }
                        .padding(.horizontal)

                        if allZero {
                            Text("Play some games to see your scores here!")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 8)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("High Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var allZero: Bool {
        guard let s = store else { return true }
        return s.streakHighScore == 0 && s.speedHighScore == 0 &&
               s.triviaHighScore == 0 && s.dailiesCompleted == 0 &&
               s.flashcardSessions == 0
    }
}

private struct ScoreRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let value: String
    let isEmpty: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.2)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 22)).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(isEmpty ? .white.opacity(0.3) : color)
        }
        .padding()
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
    }
}
