import SwiftUI

/// Each game plugin registered in the launcher.
/// Add a new case here to add a new game — no other file changes needed.
enum GameType: CaseIterable, Identifiable {
    case flashcard
    case trivia

    var id: String { title }
    var title: String {
        switch self {
        case .flashcard: "Flashcards"
        case .trivia: "Trivia"
        }
    }
    var subtitle: String {
        switch self {
        case .flashcard: "Flip & learn about your family"
        case .trivia: "Test your general knowledge"
        }
    }
    var icon: String {
        switch self {
        case .flashcard: "rectangle.on.rectangle.angled.fill"
        case .trivia: "questionmark.circle.fill"
        }
    }
    var gradient: [Color] {
        switch self {
        case .flashcard: [.orange, .yellow]
        case .trivia: [.blue, .cyan]
        }
    }
    var minAge: Int {
        switch self {
        case .flashcard: 4
        case .trivia: 7
        }
    }
}
