import SwiftUI

struct PortalScreen: View {
    @StateObject private var model = PortalModel()

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ZStack {
                PortalWebView(model: model)
                    .ignoresSafeArea(edges: .bottom)

                if let message = model.lastError {
                    errorBanner(message)
                }
            }
        }
        .background(Color(red: 0.0, green: 0.357, blue: 0.671).ignoresSafeArea())
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Button {
                model.goBack()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .disabled(!model.canGoBack)
            .opacity(model.canGoBack ? 1 : 0.35)

            Button {
                model.loadHome()
            } label: {
                Image(systemName: "house")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Parent login")

            Spacer()

            Text("Manor Parent")
                .font(.headline)
                .lineLimit(1)

            Spacer()

            if model.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(width: 36, height: 36)
            } else {
                Button {
                    model.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("Reload")
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(red: 0.0, green: 0.357, blue: 0.671))
    }

    private func errorBanner(_ message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Text("Couldn’t load the portal")
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Try again") { model.reload() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .frame(maxWidth: 320)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding()
            Spacer()
        }
    }
}
