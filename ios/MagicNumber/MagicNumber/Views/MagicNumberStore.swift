import Foundation
import Combine
import UIKit

@MainActor
final class MagicNumberStore: ObservableObject {
    @Published var combinedDigits: Int {
        didSet {
            persist()
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let value = defaults.object(forKey: Keys.combinedDigits) as? Int ?? 0
        self.combinedDigits = (value % 100 + 100) % 100
    }

    var firstDigit: Int {
        get { combinedDigits / 10 }
        set {
            combinedDigits = ((newValue % 10 + 10) % 10) * 10 + (combinedDigits % 10)
        }
    }

    var secondDigit: Int {
        get { combinedDigits % 10 }
        set {
            combinedDigits = (combinedDigits / 10) * 10 + ((newValue % 10 + 10) % 10)
        }
    }

    var combinedValue: String {
        String(format: "%02d", combinedDigits)
    }

    func incrementFirstDigit() {
        firstDigit = (firstDigit + 1) % 10
    }

    func incrementSecondDigit() {
        secondDigit = (secondDigit + 1) % 10
    }

    func reset() {
        combinedDigits = 0
    }

    private func persist() {
        defaults.set(combinedDigits, forKey: Keys.combinedDigits)
    }

    private enum Keys {
        static let combinedDigits = "magic.combinedDigits"
    }
}
