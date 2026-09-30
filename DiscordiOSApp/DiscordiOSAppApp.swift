import SwiftUI

@main
struct DiscordiOSAppApp: App {
    @StateObject private var auth = DiscordAuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                // Obsługa redirectu discordiosapp://oauth?code=...
                .onOpenURL { url in
                    Task { await auth.handleRedirect(url: url) }
                }
        }
    }
}
