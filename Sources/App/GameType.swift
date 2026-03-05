import SwiftUI

/// Each game plugin. Add a case here + a view in Sources/Games/ + a case in GameRouter to add a new game.
enum GameType: CaseIterable, Identifiable {
    // Age 4
    case flashcard
    case storyTime
    case memoryMatch
    // Age 5
    case trueOrFalse
    case flashcardQuiz
    case pictureQuiz
    // Age 6
    case dailyChallenge
    case categoryTrivia
    case spellIt
    // Age 7
    case trivia
    case speedRound
    // Age 8
    case wordScramble
    case streak

    var id: String { title }

    var title: String {
        switch self {
        case .flashcard:      "Flashcards"
        case .storyTime:      "Story Time"
        case .memoryMatch:    "Memory Match"
        case .trueOrFalse:    "True or False"
        case .flashcardQuiz:  "Flashcard Quiz"
        case .pictureQuiz:    "Name Quiz"
        case .dailyChallenge: "Daily Challenge"
        case .categoryTrivia: "Category Trivia"
        case .spellIt:        "Spell It"
        case .trivia:         "Trivia"
        case .speedRound:     "Speed Round"
        case .wordScramble:   "Word Scramble"
        case .streak:         "Streak"
        }
    }

    var subtitle: String {
        switch self {
        case .flashcard:      "Flip & learn about your family"
        case .storyTime:      "A story just about you"
        case .memoryMatch:    "Match question to answer"
        case .trueOrFalse:    "True or false?"
        case .flashcardQuiz:  "4-choice family card quiz"
        case .pictureQuiz:    "Guess the family member"
        case .dailyChallenge: "5 questions, once a day"
        case .categoryTrivia: "Pick your favorite topic"
        case .spellIt:        "Tap letters to spell it"
        case .trivia:         "General knowledge Q&A"
        case .speedRound:     "Answer before time runs out!"
        case .wordScramble:   "Unscramble the hidden word"
        case .streak:         "How long can you last?"
        }
    }

    var icon: String {
        switch self {
        case .flashcard:      "rectangle.on.rectangle.angled.fill"
        case .storyTime:      "book.fill"
        case .memoryMatch:    "square.grid.2x2.fill"
        case .trueOrFalse:    "checkmark.seal.fill"
        case .flashcardQuiz:  "graduationcap.fill"
        case .pictureQuiz:    "person.fill.questionmark"
        case .dailyChallenge: "calendar.badge.checkmark"
        case .categoryTrivia: "list.bullet.rectangle.fill"
        case .spellIt:        "pencil.circle.fill"
        case .trivia:         "questionmark.circle.fill"
        case .speedRound:     "bolt.circle.fill"
        case .wordScramble:   "textformat.abc.dottedunderline"
        case .streak:         "flame.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .flashcard:      [.orange, .yellow]
        case .storyTime:      [Color(red:0.6,green:0.3,blue:0.1), Color(red:0.8,green:0.5,blue:0.2)]
        case .memoryMatch:    [.green, .mint]
        case .trueOrFalse:    [.teal, .cyan]
        case .flashcardQuiz:  [Color(red:0.8,green:0.7,blue:0.0), .orange]
        case .pictureQuiz:    [.purple, .pink]
        case .dailyChallenge: [.blue, Color(red:0.3,green:0.6,blue:1.0)]
        case .categoryTrivia: [Color(red:0.2,green:0.6,blue:0.4), .green]
        case .spellIt:        [.pink, Color(red:0.9,green:0.4,blue:0.6)]
        case .trivia:         [Color(red:0.2,green:0.4,blue:0.9), .cyan]
        case .speedRound:     [.red, .orange]
        case .wordScramble:   [.indigo, .purple]
        case .streak:         [Color(red:0.8,green:0.1,blue:0.1), .orange]
        }
    }

    var minAge: Int {
        switch self {
        case .flashcard:      4
        case .storyTime:      4
        case .memoryMatch:    4
        case .trueOrFalse:    5
        case .flashcardQuiz:  5
        case .pictureQuiz:    5
        case .dailyChallenge: 6
        case .categoryTrivia: 6
        case .spellIt:        6
        case .trivia:         7
        case .speedRound:     7
        case .wordScramble:   8
        case .streak:         8
        }
    }
}
