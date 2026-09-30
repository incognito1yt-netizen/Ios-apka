import Foundation
import AuthenticationServices
import CryptoKit
import Combine

@MainActor
final class DiscordAuthManager: NSObject, ObservableObject {
    @Published var accessToken: String?
    @Published var me: DiscordUser?
    @Published var isLoggedIn = false
    @Published var isLoadingToken = false
    @Published var errorMessage: String?

    private var codeVerifier = ""
    private var authSession: ASWebAuthenticationSession?
    private let keychainService = "com.discordiosapp.token"

    override init() {
        super.init()
        restoreFromKeychain()
    }

    func login() {
        errorMessage = nil
        codeVerifier = Self.randomVerifier()
        let challenge = Self.challenge(for: codeVerifier)
        var comps = URLComponents(string: DiscordConfig.authorizeURL)!
        comps.queryItems = [
            .init(name: "client_id", value: DiscordConfig.clientId),
            .init(name: "redirect_uri", value: DiscordConfig.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: DiscordConfig.scopes),
            .init(name: "code_challenge", value: challenge),
            .init(name: "code_challenge_method", value: "S256"),
            .init(name: "prompt", value: "consent")
        ]
        guard let url = comps.url else { return }
        authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: "discordiosapp") { [weak self] cb, err in
            Task { @MainActor in
                if err != nil { self?.errorMessage = "Anulowano logowanie."; return }
                guard let cb, let code = URLComponents(url: cb, resolvingAgainstBaseURL: false)?
                    .queryItems?.first(where: { $0.name == "code" })?.value else {
                    self?.errorMessage = "Brak kodu autoryzacji."; return
                }
                await self?.exchangeCode(code: code)
            }
        }
        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = false
        authSession?.start()
    }

    func handleRedirect(url: URL) async {
        guard let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else { return }
        await exchangeCode(code: code)
    }
    private func exchangeCode(code: String) async {
        isLoadingToken = true
        errorMessage = nil
        defer { isLoadingToken = false }
        var req = URLRequest(url: URL(string: DiscordConfig.tokenURL)!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let b = "client_id=\(DiscordConfig.clientId)&grant_type=authorization_code&code=\(code)&redirect_uri=\(DiscordConfig.redirectURI)&code_verifier=\(codeVerifier)"
        req.httpBody = b.data(using: .utf8)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                throw NSError(domain: "Discord", code: 1, userInfo: [NSLocalizedDescriptionKey: String(data: data, encoding: .utf8) ?? "Blad tokenu"])
            }
            let token = try JSONDecoder().decode(DiscordTokenResponse.self, from: data)
            saveToken(token.access_token)
            await fetchMe()
        } catch { errorMessage = error.localizedDescription }
    }

    func fetchMe() async {
        guard let accessToken else { return }
        do {
            let user: DiscordUser = try await DiscordAPIService.shared.get(path: "/users/@me", token: accessToken)
            self.me = user; self.isLoggedIn = true
        } catch { errorMessage = "Profil: \(error.localizedDescription)" }
    }

    func logout() {
        accessToken = nil; me = nil; isLoggedIn = false; deleteKeychain()
    }

    private func saveToken(_ token: String) {
        accessToken = token
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: "accessToken"]
        SecItemDelete(q as CFDictionary)
        var add = q; add[kSecValueData as String] = Data(token.utf8)
        SecItemAdd(add as CFDictionary, nil)
    }

    private func restoreFromKeychain() {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: "accessToken", kSecReturnData as String: true]
        var out: AnyObject?
        if SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess, let d = out as? Data, let t = String(data: d, encoding: .utf8) {
            accessToken = t
            Task { await fetchMe() }
        }
    }

    private func deleteKeychain() {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: keychainService, kSecAttrAccount as String: "accessToken"]
        SecItemDelete(q as CFDictionary)
    }

    private static func randomVerifier() -> String {
        let bytes = (0..<64).map { _ in UInt8.random(in: 0...255) }
        return Data(bytes).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
    private static func challenge(for v: String) -> String {
        let d = SHA256.hash(data: Data(v.utf8))
        return Data(d).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
}

extension DiscordAuthManager: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor { ASPresentationAnchor() }
}

