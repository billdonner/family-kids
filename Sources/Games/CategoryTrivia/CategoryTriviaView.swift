import SwiftUI

struct CategoryTriviaView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var categories: [TriviaCategory] = []
    @State private var selected: TriviaCategory?
    @State private var isLoadingCategories = true
    @State private var isPlaying = false

    var body: some View {
        Group {
            if isLoadingCategories { ProgressView("Loading categories…") }
            else if let cat = selected, isPlaying {
                CategoryGameView(category: cat)
                    .environmentObject(ctx)
            } else {
                categoryPicker
            }
        }
        .navigationTitle("Category Trivia")
        .task { await loadCategories() }
    }

    private var categoryPicker: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Pick a topic").font(.title2.bold()).padding(.top, 16).padding(.bottom, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(categories) { cat in
                        Button {
                            selected = cat
                            isPlaying = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(categoryColor(cat).opacity(0.2))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(categoryColor(cat).opacity(0.5), lineWidth: 1))
                                VStack(spacing: 8) {
                                    Image(systemName: categoryIcon(cat))
                                        .font(.system(size: 28)).foregroundStyle(categoryColor(cat))
                                    Text(cat.label).font(.subheadline.bold()).multilineTextAlignment(.center)
                                }
                                .padding(16)
                            }
                            .frame(height: 100)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func categoryColor(_ cat: TriviaCategory) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .teal, .pink, .indigo]
        let idx = abs(cat.id.hashValue) % colors.count
        return colors[idx]
    }

    private func categoryIcon(_ cat: TriviaCategory) -> String {
        let lower = cat.label.lowercased()
        if lower.contains("science") || lower.contains("bio") { return "atom" }
        if lower.contains("history") { return "clock.arrow.circlepath" }
        if lower.contains("geo") { return "globe.americas.fill" }
        if lower.contains("sport") { return "sportscourt.fill" }
        if lower.contains("music") { return "music.note" }
        if lower.contains("art") { return "paintbrush.fill" }
        if lower.contains("animal") { return "pawprint.fill" }
        if lower.contains("food") { return "fork.knife" }
        if lower.contains("tech") || lower.contains("computer") { return "cpu" }
        if lower.contains("movie") || lower.contains("film") { return "film.fill" }
        return "questionmark.circle.fill"
    }

    private func loadCategories() async {
        isLoadingCategories = true
        categories = (try? await ctx.api.getTriviaCategories()) ?? []
        if categories.isEmpty {
            // Fallback: create generic categories from common topics
            categories = [
                TriviaCategory(id: "science", label: "Science"),
                TriviaCategory(id: "history", label: "History"),
                TriviaCategory(id: "geography", label: "Geography"),
                TriviaCategory(id: "animals", label: "Animals"),
                TriviaCategory(id: "sports", label: "Sports"),
                TriviaCategory(id: "music", label: "Music"),
            ]
        }
        isLoadingCategories = false
    }
}

/// Game view once a category is selected.
private struct CategoryGameView: View {
    let category: TriviaCategory
    @EnvironmentObject var ctx: AppContext
    @State private var challenges: [TriviaChallenge] = []
    @State private var currentIndex = 0
    @State private var selected: String?
    @State private var score = 0
    @State private var isFinished = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading { ProgressView("Loading \(category.label)…") }
            else if isFinished { resultView }
            else if let c = challenges[safe: currentIndex] { questionView(c) }
        }
        .task { await load() }
    }

    private func questionView(_ c: TriviaChallenge) -> some View {
        VStack(spacing: 20) {
            Text("\(currentIndex + 1) of \(challenges.count)")
                .font(.caption).foregroundStyle(.secondary)
            Text(c.question).font(.title3).multilineTextAlignment(.center).padding(.horizontal)
            VStack(spacing: 10) {
                ForEach(c.answers, id: \.self) { answer in
                    Button { pick(answer, c: c) } label: {
                        HStack {
                            Text(answer).frame(maxWidth: .infinity, alignment: .leading)
                            if selected != nil {
                                if answer == c.correct { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                                else if answer == selected { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
                            }
                        }
                        .padding(12)
                        .background(bg(answer, c: c), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain).disabled(selected != nil)
                }
            }
            .padding(.horizontal)
            if selected != nil { Button("Next") { advance() }.buttonStyle(.borderedProminent) }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill").font(.system(size: 60)).foregroundStyle(.yellow)
            Text(category.label).font(.title2.bold()
            )
            Text("\(score) of \(challenges.count) correct").font(.title2)
            let pct = challenges.isEmpty ? 0 : Int(Double(score)/Double(challenges.count)*100)
            Text("\(pct)%").font(.system(size: 52, weight: .bold))
                .foregroundStyle(pct >= 70 ? .green : pct >= 40 ? .orange : .red)
            Button("Play Again") { Task { await load() } }.buttonStyle(.borderedProminent)
        }.padding()
    }

    private func bg(_ answer: String, c: TriviaChallenge) -> Color {
        guard selected != nil else { return Color.gray.opacity(0.15) }
        if answer == c.correct { return .green.opacity(0.2) }
        if answer == selected { return .red.opacity(0.2) }
        return Color.gray.opacity(0.15)
    }

    private func pick(_ answer: String, c: TriviaChallenge) {
        selected = answer
        if answer == c.correct { score += 1 }
    }

    private func advance() {
        selected = nil
        if currentIndex + 1 >= challenges.count { isFinished = true } else { currentIndex += 1 }
    }

    private func load() async {
        isLoading = true
        isFinished = false
        currentIndex = 0
        score = 0
        selected = nil
        challenges = (try? await ctx.api.getTrivia(limit: 10, category: category.id)) ?? []
        isLoading = false
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
