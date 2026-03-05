import SwiftUI

/// Shared app-wide state. Passed as environment object from the root.
@MainActor
final class AppContext: ObservableObject {
    @Published var familyId: UUID?
    @Published var currentPlayer: KidsPlayer?
    @Published var currentAge: Int = 8

    let api = KidsAPIClient()

    // Persist family ID across launches
    init() {
        if let stored = UserDefaults.standard.string(forKey: "kids_family_id"),
           let uuid = UUID(uuidString: stored) {
            familyId = uuid
        }
        currentAge = UserDefaults.standard.integer(forKey: "kids_current_age")
        if currentAge == 0 { currentAge = 8 }
    }

    func setFamily(_ id: UUID) {
        familyId = id
        UserDefaults.standard.set(id.uuidString, forKey: "kids_family_id")
    }

    func setAge(_ age: Int) {
        currentAge = age
        UserDefaults.standard.set(age, forKey: "kids_current_age")
    }

    func clearFamily() {
        familyId = nil
        currentPlayer = nil
        UserDefaults.standard.removeObject(forKey: "kids_family_id")
    }
}
