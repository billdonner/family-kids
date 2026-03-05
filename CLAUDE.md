# FlasherKidz

Kids game launcher — 13 games using family flashcard decks + general trivia, with age gating per game and per-child profiles.

**App Store listing:** com.billdonner.obo ("Flasherz Kids")
**Backend:** https://bd-cardzerver.fly.dev
**iOS:** 17.0+, Swift 6.0

## App Flow

1. **Onboarding** (3 pages) — first launch only
2. **Family Setup** — enter UUID shared from the Family Tree app (cardz-studio-ios)
3. **Player Setup** — pick which child is playing + set their age
4. **Launcher** — 2-column scrollable grid of game tiles; tiles locked if child is too young
5. **Child Switcher** — tap avatar in top-right to change player or age

## All Games (ordered by min age)

| Game | Min Age | Data Source | Description |
|------|---------|-------------|-------------|
| Flashcards | 4 | Family decks | 3D flip cards, Got It / Try Again |
| Story Time | 4 | Player name | Personalized 6-page template story |
| Memory Match | 4 | Family decks | 4×4 flip-pair matching grid |
| True or False | 5 | Trivia API | Is this answer correct? T/F buttons |
| Flashcard Quiz | 5 | Family decks | 4-choice MCQ from flashcard answers |
| Name Quiz | 5 | Family players | First-initial hint, pick from 4 names |
| Daily Challenge | 6 | Trivia API | 5 questions per day, once only |
| Category Trivia | 6 | Trivia API | Pick topic, then play Q&A |
| Spell It | 6 | Family decks | Tap letter tiles to spell the answer |
| Trivia | 7 | Trivia API | 4-choice general knowledge Q&A |
| Speed Round | 7 | Trivia API | 15-second timer, score as many as possible |
| Word Scramble | 8 | Family decks | Unscramble answer, type in text field |
| Streak | 8 | Trivia API | Answer in a row — one wrong ends it |

## Plugin Architecture

Adding a new game requires exactly **3 changes**:
1. Add a case to `Sources/App/GameType.swift` — set title, subtitle, icon, gradient, minAge
2. Add a view in `Sources/Games/<GameName>/<GameName>View.swift`
3. Add the case to the `switch` in `GameRouter` inside `LauncherView.swift`

## Build & Deploy

```bash
cd ~/family-kids

# Regenerate Xcode project (after any project.yml change)
xcodegen generate

# Build for simulator
xcodebuild -scheme FlasherKidz -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Archive + upload to TestFlight
# 1. Bump CURRENT_PROJECT_VERSION in project.yml
# 2. xcodegen generate
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
| `Sources/App/GameType.swift` | Plugin registry — all 13 games listed here |
| `Sources/App/AppContext.swift` | Shared @MainActor state (family, player, age) |
| `Sources/Services/KidsAPIClient.swift` | actor REST client (flashcards + trivia) |
| `Sources/Services/ScoreStore.swift` | Per-child scores: trivia, streak, speed round |
| `Sources/Views/Launcher/LauncherView.swift` | Main launcher grid + GameRouter switch |
| `Sources/Views/Launcher/GameTileView.swift` | Colored gradient tile with age-lock overlay |
| `Sources/Views/Launcher/ChildSwitcherView.swift` | Switch player + age stepper sheet |
| `Sources/Games/Flashcard/FlashcardLaunchView.swift` | Deck picker → CardPlayView |
| `Sources/Games/FlashcardQuiz/FlashcardQuizView.swift` | 4-choice MCQ from family card answers |
| `Sources/Games/MemoryMatch/MemoryMatchView.swift` | Card-pair matching grid |
| `Sources/Games/TrueOrFalse/TrueOrFalseView.swift` | T/F trivia |
| `Sources/Games/SpellIt/SpellItView.swift` | Letter-tile spelling |
| `Sources/Games/WordScramble/WordScrambleView.swift` | Scrambled-word text entry |
| `Sources/Games/PictureQuiz/PictureQuizView.swift` | Family name guessing |
| `Sources/Games/StoryTime/StoryTimeView.swift` | Personalized template story |
| `Sources/Games/Trivia/TriviaPlayView.swift` | 4-choice trivia Q&A |
| `Sources/Games/SpeedRound/SpeedRoundView.swift` | 15-second timed trivia |
| `Sources/Games/Streak/StreakView.swift` | Consecutive correct answers |
| `Sources/Games/DailyChallenge/DailyChallengeView.swift` | 5 Qs once per day, saves result |
| `Sources/Games/CategoryTrivia/CategoryTriviaView.swift` | Topic picker + Q&A |

## API Endpoints Used

| Endpoint | Used By |
|----------|---------|
| `GET /api/v1/family/{id}/players` | Player Setup, Child Switcher, Name Quiz |
| `GET /api/v1/family/{id}/deck/{pid}` | Flashcards, Flashcard Quiz, Memory Match, Spell It, Word Scramble |
| `GET /api/v1/decks/{id}` | Memory Match, Spell It, Word Scramble, Flashcard Quiz (card fetch) |
| `POST /api/v1/family/{id}/generate/{pid}` | Flashcards (generate button) |
| `GET /api/v1/trivia?limit=N` | Trivia, True or False, Speed Round, Streak, Daily Challenge |
| `GET /api/v1/trivia?limit=N&topic=X` | Category Trivia |
| `GET /api/v1/trivia/categories` | Category Trivia (topic picker) |

## Score Persistence

`ScoreStore(playerId:)` stores per-child scores in UserDefaults:
- `streakHighScore` — best consecutive correct in Streak
- `speedHighScore` — best score in a Speed Round session
- `triviaHighScore` — best trivia score
- `flashcardSessions` — total flashcard sessions played

Daily Challenge completion stored as `daily_<playerId>_<YYYY-MM-DD>` = `"correct/total"`.

## Dependencies

None — pure SwiftUI + URLSession, no SPM packages.
