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
