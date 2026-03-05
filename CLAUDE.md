# FlasherKidz

Kids game launcher — 8 games using family flashcard decks + general trivia, with age gating per game and per-child profiles.

**App Store listing:** com.billdonner.obo ("Flasherz Kids")
**Backend:** https://bd-cardzerver.fly.dev
**iOS:** 17.0+, Swift 6.0

## App Flow

1. **Onboarding** (3 pages) — first launch only
2. **Family Setup** — enter UUID shared from the Family Tree app (cardz-studio-ios)
3. **Player Setup** — pick which child is playing + set their age
4. **Launcher** — 2-column grid of game tiles; games locked if child is too young
5. **Child Switcher** — tap avatar in top-right to change player or age

## Games (ordered by min age)

| Game | Min Age | Data Source |
|------|---------|-------------|
| Flashcards | 4 | Family decks (flip + reveal) |
| Story Time | 4 | Template story with player's name |
| Memory Match | 4 | Family deck card pairs (4×4 grid) |
| True or False | 5 | Trivia questions as T/F statements |
| Name Quiz | 5 | Guess family member from initial hint |
| Spell It | 6 | Tap letter tiles to spell flashcard answers |
| Trivia | 7 | 4-choice general knowledge Q&A |
| Word Scramble | 8 | Unscramble hidden answers, type in field |

## Plugin Architecture

Adding a new game requires exactly two changes:
1. Add a case to `Sources/App/GameType.swift` — set title, subtitle, icon, gradient, minAge
2. Add a view in `Sources/Games/<GameName>/<GameName>View.swift`
3. Add the case to the `switch` in `GameRouter` in `LauncherView.swift`

## Build & Deploy

```bash
cd ~/family-kids

# Regenerate Xcode project (run after any project.yml change)
xcodegen generate

# Build for simulator
xcodebuild -scheme FlasherKidz -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Archive + upload to TestFlight
# 1. Bump CURRENT_PROJECT_VERSION in project.yml first
# 2. Run xcodegen generate
xcodebuild -project FlasherKidz.xcodeproj -scheme FlasherKidz \
  -destination "generic/platform=iOS" -configuration Release \
  archive -archivePath /tmp/FlasherKidz.xcarchive -allowProvisioningUpdates

xcodebuild -exportArchive \
  -archivePath /tmp/FlasherKidz.xcarchive \
  -exportPath /tmp/FlasherKidzExport \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates \
  -authenticationKeyPath ~/.private_keys/AuthKey_MN6H2P6385.p8 \
  -authenticationKeyID MN6H2P6385 \
  -authenticationKeyIssuerID 69a6de6f-2572-47e3-e053-5b8c7c11a4d1
```

## Key Files

| File | Purpose |
|------|---------|
| `Sources/App/GameType.swift` | Plugin registry — all games listed here |
| `Sources/App/AppContext.swift` | Shared @MainActor state (family, player, age) |
| `Sources/Services/KidsAPIClient.swift` | actor REST client (flashcards + trivia) |
| `Sources/Services/ScoreStore.swift` | Per-child score persistence in UserDefaults |
| `Sources/Views/Launcher/LauncherView.swift` | Main launcher + GameRouter |
| `Sources/Games/Flashcard/FlashcardLaunchView.swift` | Deck picker → CardPlayView |
| `Sources/Games/Trivia/TriviaPlayView.swift` | 4-choice trivia Q&A |
| `Sources/Games/MemoryMatch/MemoryMatchView.swift` | Card-pair matching grid |
| `Sources/Games/TrueOrFalse/TrueOrFalseView.swift` | T/F trivia game |
| `Sources/Games/SpellIt/SpellItView.swift` | Letter-tile spelling game |
| `Sources/Games/WordScramble/WordScrambleView.swift` | Scrambled-word text entry |
| `Sources/Games/PictureQuiz/PictureQuizView.swift` | Family name guessing game |
| `Sources/Games/StoryTime/StoryTimeView.swift` | Personalized template story |

## API Endpoints Used

| Endpoint | Used By |
|----------|---------|
| `GET /api/v1/family/{id}/players` | Player Setup, Child Switcher, Name Quiz |
| `GET /api/v1/family/{id}/deck/{pid}` | Flashcards, Memory Match, Spell It, Word Scramble |
| `GET /api/v1/decks/{id}` | Memory Match, Spell It, Word Scramble (card fetch) |
| `POST /api/v1/family/{id}/generate/{pid}` | Flashcards (generate button) |
| `GET /api/v1/trivia?limit=N` | Trivia, True or False |
| `GET /api/v1/trivia/categories` | (available, not yet used in UI) |

## Dependencies

None — pure SwiftUI + URLSession, no SPM packages.
