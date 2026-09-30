import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: DiscordAuthManager

    var body: some View {
        Group {
            if auth.isLoadingToken {
                ProgressView("Łączenie z Discord…")
            } else if auth.isLoggedIn {
                GuildListView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: auth.isLoggedIn)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView().environmentObject(DiscordAuthManager())
}
