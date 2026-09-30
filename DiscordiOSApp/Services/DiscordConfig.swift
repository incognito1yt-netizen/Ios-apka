import Foundation

enum DiscordConfig {
    // Client ID z Discord Developer Portal
    static let clientId = "1554876597218189413"

    static let redirectURI = "discordiosapp://oauth"
    static let scopes = "identify guilds messages.read"

    static let authorizeURL = "https://discord.com/oauth2/authorize"
    static let tokenURL = "https://discord.com/api/oauth2/token"
    static let apiBase = "https://discord.com/api/v10"
}
