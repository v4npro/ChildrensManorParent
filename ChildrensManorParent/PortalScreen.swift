import SwiftUI

struct PortalScreen: View {
    @StateObject private var model = PortalModel()
    @Environment(\.scenePhase) private var scenePhase

    private let schoolBlue = Color(red: 0.0, green: 0.357, blue: 0.671)

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !model.hideAppBar {
                    topBar
                }
                ZStack {
                    PortalWebView(model: model)
                        .ignoresSafeArea(edges: .bottom)

                    if let message = model.lastError {
                        errorBanner(message)
                    }

                    if model.hideAppBar, model.isUnlocked, !model.hidePortal {
                        floatingGear
                    }
                }
            }

            if model.hidePortal || !model.isUnlocked {
                lockCover
            }
        }
        .background(schoolBlue.ignoresSafeArea())
        .sheet(isPresented: $model.showSettings) {
            settingsSheet
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .inactive:
                model.coverForAppSwitch()
            case .background:
                model.lockForBackground()
            case .active:
                Task { await model.handleBecameActive() }
            @unknown default:
                break
            }
        }
        .task {
            await model.handleBecameActive()
        }
    }

    private var lockCover: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "faceid")
                .font(.system(size: 56, weight: .medium))
            Text("Manor Parent")
                .font(.title2.weight(.semibold))
            Text("Unlock with Face ID to continue.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Button {
                Task { await model.unlockWithFaceID() }
            } label: {
                Text(model.isAuthenticating ? "Waiting…" : "Unlock")
                    .font(.headline)
                    .frame(minWidth: 160, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(schoolBlue)
            .disabled(model.isAuthenticating)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
        .background(schoolBlue)
        .ignoresSafeArea()
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

            if model.showFaceIDButton {
                Button {
                    Task { await model.unlockWithFaceID() }
                } label: {
                    Image(systemName: model.isAuthenticating ? "faceid" : "faceid")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .opacity(model.isAuthenticating ? 0.5 : 1)
                }
                .disabled(model.isAuthenticating)
                .accessibilityLabel("Sign in with Face ID")
            }

            Button {
                model.showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Settings")

            if model.isLoading || model.isAuthenticating {
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
        .background(schoolBlue)
    }

    private var floatingGear: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    model.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(schoolBlue.opacity(0.92), in: Circle())
                }
                .accessibilityLabel("Settings")
                .padding(.trailing, 12)
                .padding(.top, 8)
            }
            Spacer()
        }
    }

    private var settingsSheet: some View {
        NavigationStack {
            List {
                Section("After login") {
                    Toggle("Open Check In / Out", isOn: Binding(
                        get: { model.startOnCheckIn },
                        set: { model.setStartOnCheckIn($0) }
                    ))
                }
                Section("App bar") {
                    Toggle("Hide Manor Parent bar", isOn: Binding(
                        get: { model.hideAppBar },
                        set: { model.setHideAppBar($0) }
                    ))
                    Text("Turn this off to bring back Back, Home, and Reload. When it is on, use the gear to open settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Go to") {
                    Button("Check In / Out") {
                        model.showSettings = false
                        model.loadCheckIn()
                    }
                    Button("Dashboard") {
                        model.showSettings = false
                        model.webView?.load(URLRequest(url: URL(string: "https://portal.childrensmanor.com/tp/ur/dashboard")!))
                    }
                    Button("Parent login") {
                        model.showSettings = false
                        model.loadHome()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { model.showSettings = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
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
