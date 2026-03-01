# family-kids

Kids flashcard app — pure cardzerver REST client for family learning decks.

## Architecture
- Pure REST client (no local database)
- Connects to cardzerver `/api/v1/family/` endpoints
- Bundle ID: `com.billdonner.family-kids`
- iOS 17.0+, Swift 6.0

## App Flow
1. Onboarding (2 pages)
2. Family ID setup (enter UUID shared from family-ios)
3. Player select ("Who are you?")
4. Deck list (player's available decks)
5. Card play (flip cards, "Got it!" / "Try again", completion)

## Build & Run
```bash
cd ~/family-kids && xcodegen generate
xcodebuild -scheme FamilyKids -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' build
```

## API Endpoints Used
- `GET /api/v1/family/{id}/players` — list players
- `GET /api/v1/family/{id}/deck/{pid}` — get player's decks
- `GET /api/v1/decks/{id}` — get deck with cards
- `POST /api/v1/family/{id}/generate/{pid}` — generate decks

## Dependencies
- None (pure SwiftUI + URLSession)
