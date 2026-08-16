import AppIntents
import Foundation

struct GetMagicNumberIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Magic Number"
    static var description = IntentDescription("Returns the current two-digit MagicNumber value.")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let defaults = UserDefaults.standard
        // Prefer the combined persisted value written by MagicNumberStore
        let raw = defaults.object(forKey: "magic.combinedDigits") as? Int ?? {
            // Fallback to legacy separate digits if combined isn't present
            let first = defaults.integer(forKey: "magic.firstDigit")
            let second = defaults.integer(forKey: "magic.secondDigit")
            let clampedFirst = (first % 10 + 10) % 10
            let clampedSecond = (second % 10 + 10) % 10
            return clampedFirst * 10 + clampedSecond
        }()
        let normalized = (raw % 100 + 100) % 100
        let combined = String(format: "%02d", normalized)
        return .result(value: combined)
    }

    private enum Keys {
        static let firstDigit = "magic.firstDigit"
        static let secondDigit = "magic.secondDigit"
    }
}

struct MagicNumberShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: GetMagicNumberIntent(), phrases: [
            "Get Magic Number in ${applicationName}",
            "${applicationName} Magic Number",
            "Get my Magic Number in ${applicationName}"
        ], shortTitle: "Get Magic Number", systemImageName: "number")
    }
}

