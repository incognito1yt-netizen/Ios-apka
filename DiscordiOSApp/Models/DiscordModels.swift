import Foundation

// MARK: - Modele Discord API v10

struct DiscordUser: Codable, Identifiable {
    let id: String
    let username: String
    let discriminator: String?
    let global_name: String?
    let avatar: String?

    var displayName: String { global_name ?? username }

    var avatarURL: URL? {
        guard let avatar else { return nil }
        return URL(string: "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png?size=128")
    }
}

struct DiscordGuild: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String?
    let owner: Bool?
    let permissions: String?

    var iconURL: URL? {
        guard let icon else { return nil }
        return URL(string: "https://cdn.discordapp.com/icons/\(id)/\(icon).png?size=128")
    }
}

struct DiscordChannel: Codable, Identifiable, Hashable {
    let id: String
    let type: Int
    let name: String?
    let position: Int?
    let parent_id: String?

    var isText: Bool { type == 0 || type == 5 }
    var displayName: String { name ?? "kanał-\(id.prefix(4))" }
}

struct DiscordAuthor: Codable {
    let id: String
    let username: String
    let global_name: String?
    let avatar: String?
    let bot: Bool?

    var displayName: String { global_name ?? username }
}

struct DiscordMessage: Codable, Identifiable, Hashable {
    let id: String
    let channel_id: String
    let content: String
    let author: DiscordAuthor
    let timestamp: String
    let attachments: [DiscordAttachment]?

    static func == (lhs: DiscordMessage, rhs: DiscordMessage) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var date: Date {
        ISO8601DateFormatter().date(from: timestamp) ?? Date()
    }
}

struct DiscordAttachment: Codable {
    let id: String
    let filename: String
    let url: String
    let content_type: String?
}

// Odpowiedź tokenowa OAuth2
struct DiscordTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String
    let scope: String
}
