import SwiftUI

@main
struct FamilyKidsApp: App {
    @State private var onboardingComplete = UserDefaults.standard.bool(forKey: "kids_onboarding_complete")
    @AppStorage("kids_family_id") private var familyIdString: String = ""

    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingComplete {
                    KidsOnboardingView(isComplete: $onboardingComplete)
                } else if familyIdString.isEmpty {
                    FamilyIdSetupView()
                } else if let familyId = UUID(uuidString: familyIdString) {
                    PlayerSelectView(familyId: familyId)
                } else {
                    Text("Invalid family ID")
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

/// Simple view to enter the family ID (shared from family-ios)
private struct FamilyIdSetupView: View {
    @AppStorage("kids_family_id") private var familyIdString: String = ""
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "figure.child")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Family Kids")
                .font(.title.bold())

            Text("Enter the family ID shared from the Family Tree app.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Family ID", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 32)
                .autocorrectionDisabled()

            Button {
                familyIdString = inputText.trimmingCharacters(in: .whitespaces)
            } label: {
                Text("Connect")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(UUID(uuidString: inputText.trimmingCharacters(in: .whitespaces)) == nil)
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}
