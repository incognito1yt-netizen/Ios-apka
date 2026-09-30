import SwiftUI

struct ChannelListView: View {
    @EnvironmentObject var auth: DiscordAuthManager
    let guild: DiscordGuild
    @State private var channels: [DiscordChannel] = []
    @State private var loading = true
    @State private var err: String?

    var body: some View {
        Group {
            if loading { ProgressView("Ładowanie kanałów…") }
            else if let err { Text(err).foregroundColor(.red).padding() }
            else {
                List(channels) { c in
                    NavigationLink(value: c) {
                        Label(c.displayName, systemImage: "number")
                    }
                }
            }
        }
        .navigationTitle(guild.name)
        .navigationDestination(for: DiscordChannel.self) { c in ChatView(channel: c) }
        .task { await load() }
    }

    func load() async {
        loading = true
        guard let t = auth.accessToken else { loading = false; return }
        do { channels = try await DiscordAPIService.shared.channels(guildId: guild.id, token: t) }
        catch { err = error.localizedDescription }
        loading = false
    }
}
