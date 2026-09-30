import Foundation

final class DiscordAPIService {
    static let shared = DiscordAPIService()
    private init() {}

    func get<T: Decodable>(path: String, token: String) async throws -> T {
        var req = URLRequest(url: URL(string: DiscordConfig.apiBase + path)!)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "DiscordAPI", code: (resp as? HTTPURLResponse)?.statusCode ?? 0,
                          userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Błąd API"])
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func guilds(token: String) async throws -> [DiscordGuild] {
        try await get(path: "/users/@me/guilds", token: token)
    }

    func channels(guildId: String, token: String) async throws -> [DiscordChannel] {
        let all: [DiscordChannel] = try await get(path: "/guilds/\(guildId)/channels", token: token)
        return all.filter { $0.isText }.sorted { ($0.position ?? 0) < ($1.position ?? 0) }
    }

    func messages(channelId: String, limit: Int = 30, token: String) async throws -> [DiscordMessage] {
        let msgs: [DiscordMessage] = try await get(path: "/channels/\(channelId)/messages?limit=\(limit)", token: token)
        return msgs.sorted { $0.date < $1.date }
    }

    func sendMessage(channelId: String, content: String, token: String) async throws -> DiscordMessage {
        var req = URLRequest(url: URL(string: DiscordConfig.apiBase + "/channels/\(channelId)/messages")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["content": content])
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "DiscordAPI", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Nie wysłano"])
        }
        return try JSONDecoder().decode(DiscordMessage.self, from: data)
    }
}
