import Foundation

/// Per-child score persistence. Keyed by player UUID string.
@MainActor
final class ScoreStore: ObservableObject {
    private let playerId: String

    init(playerId: UUID) {
        self.playerId = playerId.uuidString
    }

    private func key(_ suffix: String) -> String { "score_\(playerId)_\(suffix)" }

    var flashcardSessions: Int {
        get { UserDefaults.standard.integer(forKey: key("fc_sessions")) }
    }
    var triviaHighScore: Int {
        get { UserDefaults.standard.integer(forKey: key("trivia_best")) }
    }

    func recordFlashcardSession() {
        let current = flashcardSessions
        UserDefaults.standard.set(current + 1, forKey: key("fc_sessions"))
    }

    func updateTriviaHighScore(_ score: Int) {
        if score > triviaHighScore {
            UserDefaults.standard.set(score, forKey: key("trivia_best"))
        }
    }
}
