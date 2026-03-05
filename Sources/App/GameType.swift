import SwiftUI

/// Each game plugin. Add a case here + a view in Sources/Games/ to add a new game.
enum GameType: CaseIterable, Identifiable {
    case flashcard
    case storyTime
    case memoryMatch
    case trueOrFalse
    case pictureQuiz
    case spellIt
    case trivia
    case wordScramble

    var id: String { title }
    var title: String {
        switch self {
        case .flashcard:   "Flashcards"
        case .storyTime:   "Story Time"
        case .memoryMatch: "Memory Match"
        case .trueOrFalse: "True or False"
        case .pictureQuiz: "Name Quiz"
        case .spellIt:     "Spell It"
        case .trivia:      "Trivia"
        case .wordScramble:"Word Scramble"
        }
    }
    var subtitle: String {
        switch self {
        case .flashcard:   "Flip & learn about your family"
        case .storyTime:   "A story just about you"
        case .memoryMatch: "Match the question to the answer"
        case .trueOrFalse: "True or false?"
        case .pictureQuiz: "Guess the family member"
        case .spellIt:     "Tap letters to spell the answer"
        case .trivia:      "Test your general knowledge"
        case .wordScramble:"Unscramble the hidden word"
        }
    }
    var icon: String {
        switch self {
        case .flashcard:   "rectangle.on.rectangle.angled.fill"
        case .storyTime:   "book.fill"
        case .memoryMatch: "square.grid.2x2.fill"
        case .trueOrFalse: "checkmark.seal.fill"
        case .pictureQuiz: "person.fill.questionmark"
        case .spellIt:     "pencil.circle.fill"
        case .trivia:      "questionmark.circle.fill"
        case .wordScramble:"textformat.abc.dottedunderline"
        }
    }
    var gradient: [Color] {
        switch self {
        case .flashcard:   [.orange, .yellow]
        case .storyTime:   [Color(red: 0.6, green: 0.3, blue: 0.1), Color(red: 0.8, green: 0.5, blue: 0.2)]
        case .memoryMatch: [.green, .mint]
        case .trueOrFalse: [.teal, .cyan]
        case .pictureQuiz: [.purple, .pink]
        case .spellIt:     [.pink, Color(red: 0.9, green: 0.4, blue: 0.6)]
        case .trivia:      [.blue, .cyan]
        case .wordScramble:[.indigo, .purple]
        }
    }
    var minAge: Int {
        switch self {
        case .flashcard:   4
        case .storyTime:   4
        case .memoryMatch: 4
        case .trueOrFalse: 5
        case .pictureQuiz: 5
        case .spellIt:     6
        case .trivia:      7
        case .wordScramble:8
        }
    }
}
