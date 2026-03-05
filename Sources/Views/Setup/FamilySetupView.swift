import SwiftUI

/// Shown when no family ID is configured. User enters the UUID from the family tree app.
struct FamilySetupView: View {
    @EnvironmentObject var ctx: AppContext
    @State private var inputText = ""

    private var isValid: Bool {
        UUID(uuidString: inputText.trimmingCharacters(in: .whitespaces)) != nil
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.07), Color(red: 0.07, green: 0.07, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 140, height: 140)
                    Image(systemName: "figure.2.and.child.holdinghands")
                        .font(.system(size: 52))
                        .foregroundStyle(.orange)
                }

                VStack(spacing: 12) {
                    Text("Connect Your Family")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text("Enter the Family ID shared from\nthe Family Tree app.")
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                }

                TextField("Family ID (UUID)", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 32)

                Button {
                    if let uuid = UUID(uuidString: inputText.trimmingCharacters(in: .whitespaces)) {
                        ctx.setFamily(uuid)
                    }
                } label: {
                    Text("Connect")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isValid ? Color.orange : Color.gray, in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isValid)
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}
