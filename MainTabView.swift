import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            ClosetView()
                .tabItem {
                    Label("My Closet", systemImage: "cabinet")
                }
            
            ScannerView()
                .tabItem {
                    Label("Scan Kicks", systemImage: "camera.viewfinder")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: ClothingItem.self, inMemory: true)
}
