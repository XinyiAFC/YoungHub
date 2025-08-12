import SwiftUI

@main
struct YoungHubApp: App {
    var body: some Scene {
        WindowGroup {
            EnhancedArticleListView()
                .preferredColorScheme(.light)
        }
    }
}