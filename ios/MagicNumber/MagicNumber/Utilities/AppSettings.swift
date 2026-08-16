import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    @Published var stealthDoubleTapEnabled: Bool {
        didSet { defaults.set(stealthDoubleTapEnabled, forKey: Keys.stealthDoubleTapEnabled) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        stealthDoubleTapEnabled = defaults.object(forKey: Keys.stealthDoubleTapEnabled) as? Bool ?? true
    }

    private enum Keys {
        static let hapticsEnabled = "hapticsEnabled"
        static let stealthDoubleTapEnabled = "stealthDoubleTapEnabled"
    }
}
