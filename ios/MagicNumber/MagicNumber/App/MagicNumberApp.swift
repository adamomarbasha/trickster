import SwiftUI

@main
struct MagicNumberApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var store = MagicNumberStore()
    @StateObject private var viewModel: MagicNumberViewModel

    init() {
        let store = MagicNumberStore()
        _store = StateObject(wrappedValue: store)
        _viewModel = StateObject(wrappedValue: MagicNumberViewModel(store: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(viewModel)
        }
    }
}
