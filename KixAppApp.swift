import SwiftUI
import SwiftData

@main
struct KixAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: ClothingItem.self)
    }
}
