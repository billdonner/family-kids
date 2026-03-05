import Foundation

/// Per-child score persistence. Keyed by player UUID string.
@MainActor
final class ScoreStore: ObservableObject {
    private let playerId: String

    init(playerId: UUID) {
        self.playerId = playerId.uuidString
    }

    private func key(_ suffix: String) -> String { "score_\(playerId)_\(suffix)" }

    var flashcardSessions: Int { UserDefaults.standard.integer(forKey: key("fc_sessions")) }
    var triviaHighScore: Int   { UserDefaults.standard.integer(forKey: key("trivia_best")) }
    var streakHighScore: Int   { UserDefaults.standard.integer(forKey: key("streak_best")) }
    var speedHighScore: Int    { UserDefaults.standard.integer(forKey: key("speed_best")) }

    func recordFlashcardSession() {
        UserDefaults.standard.set(flashcardSessions + 1, forKey: key("fc_sessions"))
    }

    func updateTriviaHighScore(_ score: Int) {
        if score > triviaHighScore { UserDefaults.standard.set(score, forKey: key("trivia_best")) }
    }

    func updateStreakHighScore(_ score: Int) {
        if score > streakHighScore { UserDefaults.standard.set(score, forKey: key("streak_best")) }
    }

    func updateSpeedHighScore(_ score: Int) {
        if score > speedHighScore { UserDefaults.standard.set(score, forKey: key("speed_best")) }
    }
}
