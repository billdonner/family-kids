import SwiftUI

struct GameTileView: View {
    let game: GameType
    let isLocked: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isLocked
                        ? LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: game.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Image(systemName: isLocked ? "lock.fill" : game.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                Text(game.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(isLocked ? "Ages \(game.minAge)+" : game.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.vertical, 20)
        }
        .opacity(isLocked ? 0.6 : 1.0)
    }
}
