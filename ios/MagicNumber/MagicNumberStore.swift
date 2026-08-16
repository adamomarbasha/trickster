import Foundation
import Combine

@MainActor
final class MagicNumberStore: ObservableObject {
    @Published private(set) var firstDigit: Int {
        didSet { persist() }
    }
    @Published private(set) var secondDigit: Int {
        didSet { persist() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let f = defaults.integer(forKey: Keys.firstDigit)
        let s = defaults.integer(forKey: Keys.secondDigit)
        // Ensure range 0...9
        self.firstDigit = (f % 10 + 10) % 10
        self.secondDigit = (s % 10 + 10) % 10
    }

    var combinedValue: String {
        "\(firstDigit)\(secondDigit)"
    }

    func incrementFirstDigit(hapticsEnabled: Bool = true) {
        firstDigit = (firstDigit + 1) % 10
        if hapticsEnabled { Haptics.light() }
    }

    func incrementSecondDigit(hapticsEnabled: Bool = true) {
        secondDigit = (secondDigit + 1) % 10
        if hapticsEnabled { Haptics.light() }
    }

    func reset(hapticsEnabled: Bool = true) {
        firstDigit = 0
        secondDigit = 0
        if hapticsEnabled { Haptics.subtle() }
    }

    private func persist() {
        defaults.set(firstDigit, forKey: Keys.firstDigit)
        defaults.set(secondDigit, forKey: Keys.secondDigit)
    }

    private enum Keys {
        static let firstDigit = "magic.firstDigit"
        static let secondDigit = "magic.secondDigit"
    }
}

// Simple haptics helper used by the app
enum Haptics {
    static func light() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    static func subtle() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}
