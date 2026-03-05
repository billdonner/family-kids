import SwiftUI

struct LauncherView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var showChildSwitcher = false
    @State private var showHighScores = false
    @State private var activeGame: GameType?

    private var player: KidsPlayer { ctx.currentPlayer! }
    private var age: Int { ctx.currentAge }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.04, blue: 0.07), Color(red: 0.07, green: 0.07, blue: 0.12)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hi, \(player.displayName)!")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                            Text("What do you want to play?")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            Button { showHighScores = true } label: {
                                ZStack {
                                    Circle().fill(.white.opacity(0.15)).frame(width: 44, height: 44)
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 18)).foregroundStyle(.yellow)
                                }
                            }
                            Button { showChildSwitcher = true } label: {
                                ZStack {
                                    Circle().fill(.white.opacity(0.15)).frame(width: 44, height: 44)
                                    Text(String(player.displayName.prefix(1)).uppercased())
                                        .font(.headline).foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Game grid
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(GameType.allCases) { game in
                            let locked = age < game.minAge
                            Button {
                                if !locked { activeGame = game }
                            } label: {
                                GameTileView(game: game, isLocked: locked)
                                    .frame(height: 180)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Version footer
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0"
                    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
                    Text("v\(version) (\(build))  ·  Flasherz Kidz")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $activeGame) { game in
                GameRouter(game: game)
                    .environmentObject(ctx)
            }
            .sheet(isPresented: $showChildSwitcher) {
                ChildSwitcherView().environmentObject(ctx)
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView().environmentObject(ctx)
            }
        }
    }
}

/// Routes to the right game launcher based on GameType.
struct GameRouter: View {
    let game: GameType
    @EnvironmentObject var ctx: AppContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch game {
                case .flashcard:      FlashcardLaunchView().environmentObject(ctx)
                case .storyTime:      StoryTimeView().environmentObject(ctx)
                case .memoryMatch:    MemoryMatchView().environmentObject(ctx)
                case .trueOrFalse:    TrueOrFalseView().environmentObject(ctx)
                case .flashcardQuiz:  FlashcardQuizView().environmentObject(ctx)
                case .pictureQuiz:    PictureQuizView().environmentObject(ctx)
                case .dailyChallenge: DailyChallengeView().environmentObject(ctx)
                case .categoryTrivia: CategoryTriviaView().environmentObject(ctx)
                case .spellIt:        SpellItView().environmentObject(ctx)
                case .trivia:         TriviaPlayView().environmentObject(ctx)
                case .speedRound:     SpeedRoundView().environmentObject(ctx)
                case .wordScramble:   WordScrambleView().environmentObject(ctx)
                case .streak:         StreakView().environmentObject(ctx)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
