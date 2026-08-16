import Foundation
import UIKit

@MainActor
final class MagicNumberViewModel: ObservableObject {
    @Published private(set) var firstDigit: Int
    @Published private(set) var secondDigit: Int
    @Published var mode: AppMode = .practice

    private let store: MagicNumberStore

    init(store: MagicNumberStore) {
        self.store = store
        self.firstDigit = store.firstDigit
        self.secondDigit = store.secondDigit
    }

    var combinedValue: String { store.combinedValue }

    func incrementFirstDigit(hapticsEnabled: Bool) {
        store.incrementFirstDigit()
        if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        syncFromStore()
    }

    func incrementSecondDigit(hapticsEnabled: Bool) {
        store.incrementSecondDigit()
        if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        syncFromStore()
    }

    func reset() {
        store.reset()
        syncFromStore()
    }

    private func syncFromStore() {
        firstDigit = store.firstDigit
        secondDigit = store.secondDigit
    }
}
