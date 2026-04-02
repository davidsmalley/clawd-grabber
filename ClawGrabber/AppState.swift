import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
        }
    }

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
    }
}
