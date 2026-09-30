import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: DiscordAuthManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "message.fill")
                .font(.system(size: 72))
                .foregroundStyle(.linearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
            Text("DiscordiOSApp")
                .font(.largeTitle.bold())
            Text("Zaloguj się kontem Discord, aby pisać na swoich serwerach.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            if let err = auth.errorMessage {
                Text(err).font(.footnote).foregroundColor(.red).padding(.horizontal)
            }
            Button(action: { auth.login() }) {
                Label("Zaloguj przez Discord", systemImage: "person.crop.circle.badge.checkmark")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.indigo).foregroundColor(.white).cornerRadius(14)
            }
            .padding(.horizontal, 32)
            Text("iOS 26 • SwiftUI • OAuth2 PKCE")
                .font(.caption).foregroundStyle(.secondary)
            Spacer()
        }
    }
}
