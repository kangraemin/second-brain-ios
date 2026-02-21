import ComposableArchitecture
import SwiftUI

@main
struct StashApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(store: Self.store.scope(state: \.home, action: \.home))
        }
    }
}
