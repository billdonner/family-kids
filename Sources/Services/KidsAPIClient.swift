import Foundation

/// Pure cardzerver REST client for the kids app.
actor KidsAPIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL = URL(string: "https://bd-cardzerver.fly.dev")!) {
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }

    /// Get all players for a family
    func getPlayers(familyId: UUID) async throws -> [KidsPlayer] {
        let url = baseURL.appendingPathComponent("/api/v1/family/\(familyId.uuidString)/players")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode([PlayerResponse].self, from: data)
        return response.map { $0.toPlayer() }
    }

    /// Get generated decks for a player
    func getDecks(familyId: UUID, playerId: UUID) async throws -> [KidsDeck] {
        let url = baseURL.appendingPathComponent("/api/v1/family/\(familyId.uuidString)/deck/\(playerId.uuidString)")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode([DeckResponse].self, from: data)
        return response.map { $0.toDeck() }
    }

    /// Get cards for a deck
    func getCards(deckId: UUID) async throws -> [KidsCard] {
        let url = baseURL.appendingPathComponent("/api/v1/decks/\(deckId.uuidString)")
        let (data, _) = try await session.data(from: url)

        struct DeckDetail: Codable {
            let cards: [CardResponse]
        }
        let detail = try decoder.decode(DeckDetail.self, from: data)
        return detail.cards.map { $0.toCard() }
    }

    /// Generate new decks for a player
    func generateDecks(familyId: UUID, playerId: UUID, kinds: [String] = ["flashcard"]) async throws -> GenerateDeckResponse {
        let url = baseURL.appendingPathComponent("/api/v1/family/\(familyId.uuidString)/generate/\(playerId.uuidString)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct GeneratePayload: Codable {
            let kinds: [String]
        }
        request.httpBody = try JSONEncoder().encode(GeneratePayload(kinds: kinds))

        let (data, _) = try await session.data(for: request)
        return try decoder.decode(GenerateDeckResponse.self, from: data)
    }

    /// Fetch trivia challenges (general knowledge)
    func getTrivia(limit: Int = 10, category: String? = nil) async throws -> [TriviaChallenge] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/api/v1/trivia"), resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let cat = category { queryItems.append(URLQueryItem(name: "topic", value: cat)) }
        components.queryItems = queryItems
        let (data, _) = try await session.data(from: components.url!)
        let response = try decoder.decode(TriviaResponse.self, from: data)
        return response.challenges
    }

    /// Fetch available trivia categories
    func getTriviaCategories() async throws -> [TriviaCategory] {
        let url = baseURL.appendingPathComponent("/api/v1/trivia/categories")
        let (data, _) = try await session.data(from: url)
        let response = try decoder.decode(CategoriesResponse.self, from: data)
        return response.categories
    }
}
