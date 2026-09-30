# DiscordiOSApp — Klient Discord API na iOS 26.6.2

Natywna aplikacja SwiftUI (iOS 17.0+ / zoptymalizowana pod iOS 26) z:
- Logowanie przez Discord OAuth2 + PKCE (bez client_secret w aplikacji!)
- Lista serwerów (Guilds), kanałów, wiadomości
- Wysyłanie wiadomości, odświeżanie / polling + Gateway WebSocket realtime
- Zapis tokenu w Keychain, wylogowanie, avatar, Liquid Glass UI pod iOS 26

## 1. Co musisz mieć
- Mac z Xcode 16+ (iOS 26 SDK). Na Windows NIE da się skompilować IPA — to ograniczenie Apple.
- Konto Discord + aplikacja na https://discord.com/developers/applications

## 2. Załóż aplikację Discord (5 min)
1. Wejdź na Discord Developer Portal → New Application → nazwa np. `DiscordiOSApp`
2. OAuth2 → Redirects → Add Redirect → wpisz dokładnie:
   ```
   discordiosapp://oauth
   ```
3. Skopiuj CLIENT ID (np. 123456789012345678)
4. Scopes NIE musisz ustawiać na portalu — aplikacja sama prosi o:
   `identify guilds guilds.members.read messages.read`
5. Wklej CLIENT ID do pliku `Services/DiscordConfig.swift`

## 3. Utwórz projekt w Xcode (2 min — najpewniejsza metoda)
Ponieważ `.xcodeproj` ręcznie pisany często się psuje, zrób tak:
1. Xcode → File → New → Project → iOS → App
   - Product Name: `DiscordiOSApp`
   - Interface: SwiftUI, Language: Swift, Bundle ID: `com.twojafirma.discordiosapp`
2. Minimum Deployments: iOS 17.0
3. Zamknij Xcode, skopiuj WSZYSTKIE pliki `.swift` z tego folderu do folderu projektu (nadpisz `ContentView.swift` i `DiscordiOSAppApp.swift`)
4. Otwórz `Info.plist` w Xcode → dodaj URL Type:
   - URL Schemes: `discordiosapp`
5. Dodaj Capability: Keychain Sharing (opcjonalnie) — token i tak trzymany jest w Keychain.
6. Run na symulatorze iPhone (iOS 26) lub prawdziwym iPhonie z iOS 26.6.2.

Alternatywnie gotowy `project.pbxproj` jest w `DiscordiOSApp.xcodeproj/` — możesz spróbować otworzyć bezpośrednio.

## 4. Uruchomienie
- Zaloguj się przyciskiem „Zaloguj przez Discord"
- Wybierz serwer → kanał tekstowy → pisz wiadomości
- Wiadomości odświeżają się co 5s + live przez Gateway

## 5. Budowanie IPA na iPhone bez kabla
- Xcode → Product → Archive → Distribute App → TestFlight / Ad Hoc
- Lub na Windows: wrzuć ten folder na GitHub → Actions `build-ios` z macos-15 runnerem.

## Pliki
```
DiscordiOSApp/
  DiscordiOSAppApp.swift
  ContentView.swift
  Models/DiscordModels.swift
  Services/DiscordConfig.swift
  Services/DiscordAuthManager.swift
  Services/DiscordAPIService.swift
  Views/LoginView.swift
  Views/GuildListView.swift
  Views/ChannelListView.swift
  Views/ChatView.swift
```
