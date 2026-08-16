import Foundation

enum AppMode: String, CaseIterable, Identifiable {
    case practice
    case stealth

    var id: String { rawValue }

    var title: String {
        switch self {
        case .practice:
            return "Practice"
        case .stealth:
            return "Stealth"
        }
    }
}
