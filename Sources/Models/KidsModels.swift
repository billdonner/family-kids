import Foundation

struct KidsPlayer: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let nickname: String?

    var displayName: String {
        nickname ?? name
    }
}

struct KidsDeck: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let cardCount: Int
    let kind: String // "flashcard" or "trivia"
}

struct KidsCard: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let question: String
    let answer: String
    let hint: String?
}

// Server response wrappers
struct PlayerResponse: Codable, Sendable {
    let id: UUID
    let family_id: UUID
    let name: String
    let nickname: String?

    func toPlayer() -> KidsPlayer {
        KidsPlayer(id: id, name: name, nickname: nickname)
    }
}

struct DeckResponse: Codable, Sendable {
    let deck_id: UUID
    let title: String
    let card_count: Int
    let kind: String

    func toDeck() -> KidsDeck {
        KidsDeck(id: deck_id, title: title, cardCount: card_count, kind: kind)
    }
}

struct CardResponse: Codable, Sendable {
    let id: UUID
    let front: String
    let back: String
    let hint: String?

    func toCard() -> KidsCard {
        KidsCard(id: id, question: front, answer: back, hint: hint)
    }
}

struct GenerateDeckResponse: Codable, Sendable {
    let deck_ids: [UUID]
    let cards_created: Int
    let player_name: String
}

// MARK: - Trivia (from cardzerver /api/v1/trivia)

struct TriviaChallenge: Identifiable, Codable, Sendable {
    let id: String
    let topic: String
    let question: String
    let answers: [String]
    let correct: String
    let explanation: String

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString
        topic = try c.decode(String.self, forKey: .topic)
        question = try c.decode(String.self, forKey: .question)
        answers = try c.decode([String].self, forKey: .answers)
        correct = try c.decode(String.self, forKey: .correct)
        explanation = (try? c.decode(String.self, forKey: .explanation)) ?? ""
    }
}

struct TriviaResponse: Codable, Sendable {
    let challenges: [TriviaChallenge]
}

struct TriviaCategory: Identifiable, Codable, Sendable {
    let id: String
    let label: String
}

struct CategoriesResponse: Codable, Sendable {
    let categories: [TriviaCategory]
}
