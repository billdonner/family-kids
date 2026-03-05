import SwiftUI

@main
struct FlasherKidzApp: App {
    @StateObject private var ctx = AppContext()
    @State private var onboardingComplete = UserDefaults.standard.bool(forKey: "kids_onboarding_complete")

    var body: some Scene {
        WindowGroup {
            RootView(onboardingComplete: $onboardingComplete)
                .environmentObject(ctx)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    @Binding var onboardingComplete: Bool
    @EnvironmentObject var ctx: AppContext

    var body: some View {
        Group {
            if !onboardingComplete {
                KidsOnboardingView(isComplete: $onboardingComplete)
            } else if ctx.familyId == nil {
                FamilySetupView()
                    .environmentObject(ctx)
            } else if ctx.currentPlayer == nil {
                PlayerSetupView()
                    .environmentObject(ctx)
            } else {
                LauncherView()
                    .environmentObject(ctx)
            }
        }
        .animation(.easeInOut, value: onboardingComplete)
        .animation(.easeInOut, value: ctx.familyId)
        .animation(.easeInOut, value: ctx.currentPlayer?.id)
    }
}
