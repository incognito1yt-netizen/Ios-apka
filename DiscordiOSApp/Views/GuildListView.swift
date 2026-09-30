import SwiftUI

struct GuildListView: View {
    @EnvironmentObject var auth: DiscordAuthManager
    @State private var guilds: [DiscordGuild] = []
    @State private var loading = true
    @State private var err: String?

    var body: some View {
        NavigationStack {
            Group {
                if loading { ProgressView("Ładowanie serwerów…") }
                else if let err { Text(err).foregroundColor(.red).padding() }
                else if guilds.isEmpty { Text("Brak serwerów na tym koncie.") }
                else {
                    List(guilds) { g in
                        NavigationLink(value: g) {
                            HStack {
                                AsyncImage(url: g.iconURL) { img in img.resizable() } placeholder: { Image(systemName: "server.rack").resizable().padding(8) }
                                    .frame(width: 44, height: 44).background(Color.gray.opacity(0.2)).clipShape(Circle())
                                Text(g.name).font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Serwery")
            .navigationDestination(for: DiscordGuild.self) { g in ChannelListView(guild: g) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        AsyncImage(url: auth.me?.avatarURL) { i in i.resizable() } placeholder: { Circle().fill(Color.gray) }
                            .frame(width: 30, height: 30).clipShape(Circle())
                        Text(auth.me?.displayName ?? "").font(.subheadline)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Wyloguj") { auth.logout() }
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    func load() async {
        loading = true; err = nil
        guard let t = auth.accessToken else { loading = false; return }
        do { guilds = try await DiscordAPIService.shared.guilds(token: t) }
        catch { err = error.localizedDescription }
        loading = false
    }
}
