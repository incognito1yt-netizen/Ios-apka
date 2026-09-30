import SwiftUI

struct ChatView: View {
    @EnvironmentObject var auth: DiscordAuthManager
    let channel: DiscordChannel
    @State private var messages: [DiscordMessage] = []
    @State private var text = ""
    @State private var err: String?
    @State private var timer: Timer?

    var body: some View {
        VStack {
            if let err { Text(err).font(.caption).foregroundColor(.red) }
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { m in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(m.author.displayName).bold().font(.subheadline)
                                    Text(RelativeDateTimeFormatter().localizedString(for: m.date, relativeTo: Date())).font(.caption2).foregroundStyle(.secondary)
                                }
                                Text(m.content).font(.body)
                            }
                            .padding(8).background(Color.gray.opacity(0.12)).cornerRadius(10).id(m.id)
                        }
                    }.padding()
                }
                .onChange(of: messages.count) { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
            }
            HStack {
                TextField("Napisz wiadomość…", text: $text).textFieldStyle(.roundedBorder)
                Button(action: { Task { await send() } }) {
                    Image(systemName: "paperplane.fill").padding(10).background(Color.indigo).foregroundColor(.white).clipShape(Circle())
                }.disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }.padding()
        }
        .navigationTitle("# " + (channel.displayName))
        .task { await load(); startPolling() }
        .onDisappear { timer?.invalidate() }
    }

    func load() async {
        guard let t = auth.accessToken else { return }
        do { messages = try await DiscordAPIService.shared.messages(channelId: channel.id, token: t) }
        catch { err = error.localizedDescription }
    }
    func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in Task { await load() } }
    }
    func send() async {
        let c = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !c.isEmpty, let t = auth.accessToken else { return }
        text = ""
        do {
            let m = try await DiscordAPIService.shared.sendMessage(channelId: channel.id, content: c, token: t)
            messages.append(m)
        } catch { err = error.localizedDescription }
    }
}
