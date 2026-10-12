import Foundation
import WebKit

@MainActor
final class PortalModel: ObservableObject {
    static let startURL = URL(string: "https://portal.childrensmanor.com/tp/pa/login")!
    static let checkInURL = URL(string: "https://portal.childrensmanor.com/tp/ur/signin_out")!
    static let dashboardURL = URL(string: "https://portal.childrensmanor.com/tp/ur/dashboard")!

    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = true
    @Published var pageTitle = "Parent Portal"
    @Published var lastError: String?
    @Published var isLoginPage = true
    @Published var showFaceIDButton = false
    @Published var isAuthenticating = false
    @Published var isUnlocked = false
    @Published var hidePortal = true
    @Published var startOnCheckIn = AppSettings.startOnCheckIn
    @Published var isCheckInPage = false
    @Published var showSettings = false
    @Published var saveLogin = AppSettings.saveLogin
    @Published var lockDelaySeconds = AppSettings.lockDelaySeconds

    var shouldHideAppBar: Bool {
        startOnCheckIn && isCheckInPage && isUnlocked && !hidePortal
    }

    weak var webView: WKWebView?
    private var wasLoginPage = true
    private var didRedirectToCheckIn = false
    private var suppressAutoFill = false
    /// Typed on the login form; saved to the Keychain only after the portal accepts it.
    private var pendingCredentials: (username: String, password: String)?
    /// The app submitted the saved passcode and is waiting to see if it worked.
    private var autoFillSubmitted = false
    private var backgroundedAt: Date?

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        lastError = nil
        if webView?.url == nil {
            loadHome()
        } else {
            webView?.reload()
        }
    }

    func loadHome() {
        lastError = nil
        webView?.load(URLRequest(url: Self.startURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    func loadCheckIn() {
        lastError = nil
        webView?.load(URLRequest(url: Self.checkInURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    func loadDashboard() {
        lastError = nil
        webView?.load(URLRequest(url: Self.dashboardURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    func signOutToLogin() {
        suppressAutoFill = true
        pendingCredentials = nil
        didRedirectToCheckIn = false
        wasLoginPage = true
        lastError = nil
        let store = webView?.configuration.websiteDataStore ?? WKWebsiteDataStore.default()
        let types: Set<String> = [
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
        ]
        store.fetchDataRecords(ofTypes: types) { records in
            let portal = records.filter { rec in
                let name = rec.displayName.lowercased()
                return name.contains("childrensmanor") || name.contains("childrensmagnet")
            }
            store.removeData(ofTypes: types, for: portal) {
                Task { @MainActor in
                    self.webView?.load(
                        URLRequest(
                            url: Self.startURL,
                            cachePolicy: .reloadIgnoringLocalCacheData,
                            timeoutInterval: 30
                        )
                    )
                }
            }
        }
    }

    func signInWithSavedCredentials() {
        Task { await signInWithSavedCredentialsAsync() }
    }

    func loginSubmitted(username: String, password: String) {
        pendingCredentials = (username, password)
        // The person is typing; don't race them with the saved passcode.
        suppressAutoFill = true
    }

    private func signInWithSavedCredentialsAsync() async {
        if FaceIDAuth.canAuthenticate {
            guard !isAuthenticating else { return }
            isAuthenticating = true
            let ok = await FaceIDAuth.authenticate(reason: "Sign in to the parent portal.")
            isAuthenticating = false
            guard ok else { return }
        }
        suppressAutoFill = false
        guard let creds = FaceIDAuth.load() else { return }
        fillLogin(username: creds.username, password: creds.password)
    }

    func setSaveLogin(_ value: Bool) {
        AppSettings.saveLogin = value
        saveLogin = value
        if !value {
            FaceIDAuth.delete()
            pendingCredentials = nil
            refreshSavedLogin()
        }
    }

    func setLockDelay(_ seconds: Int) {
        AppSettings.lockDelaySeconds = seconds
        lockDelaySeconds = seconds
    }

    private func refreshSavedLogin() {
        showFaceIDButton = isLoginPage && FaceIDAuth.hasCredentials && FaceIDAuth.canAuthenticate && isUnlocked
    }

    func setStartOnCheckIn(_ value: Bool) {
        AppSettings.startOnCheckIn = value
        startOnCheckIn = value
        applySimpleModeToPage()
    }

    func applySimpleModeToPage() {
        let flag = startOnCheckIn ? "true" : "false"
        webView?.evaluateJavaScript(
            "window.__cmmsApplySimpleMode && window.__cmmsApplySimpleMode(\(flag));",
            completionHandler: nil
        )
    }

    func sync(from webView: WKWebView) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        isLoading = webView.isLoading
        if let title = webView.title, !title.isEmpty {
            pageTitle = title
        }
        if (webView.url?.path.lowercased() ?? "").contains("logout") {
            suppressAutoFill = true
        }
        let login = Self.isLogin(webView.url)
        isLoginPage = login
        isCheckInPage = Self.isCheckIn(webView.url)
        showFaceIDButton = login && FaceIDAuth.hasCredentials && FaceIDAuth.canAuthenticate && isUnlocked
    }

    func pageFinished(in webView: WKWebView) {
        sync(from: webView)
        applySimpleModeToPage()
        handleSignInResult(url: webView.url)
        if isUnlocked {
            fillLoginIfNeeded()
        }
        let nowLogin = isLoginPage
        if nowLogin {
            didRedirectToCheckIn = false
        }
        if wasLoginPage, !nowLogin, startOnCheckIn, !Self.isCheckIn(webView.url), !didRedirectToCheckIn {
            didRedirectToCheckIn = true
            loadCheckIn()
        }
        if Self.isCheckIn(webView.url) {
            didRedirectToCheckIn = true
        }
        wasLoginPage = nowLogin
    }

    private func handleSignInResult(url: URL?) {
        if isLoginPage {
            // Back on the login page after the app sent the saved passcode:
            // the portal turned it down, so stop sending it.
            if autoFillSubmitted { suppressAutoFill = true }
        } else if PortalHost.isFirstParty(url?.host) {
            if let creds = pendingCredentials, AppSettings.saveLogin {
                FaceIDAuth.save(username: creds.username, password: creds.password)
                refreshSavedLogin()
            }
            pendingCredentials = nil
            suppressAutoFill = false
        }
        autoFillSubmitted = false
    }

    func coverForAppSwitch() {
        hidePortal = true
    }

    func lockForBackground() {
        hidePortal = true
        isAuthenticating = false
        if lockDelaySeconds > 0, isUnlocked {
            backgroundedAt = backgroundedAt ?? Date()
        } else {
            isUnlocked = false
        }
    }

    func handleBecameActive() async {
        if let since = backgroundedAt {
            backgroundedAt = nil
            if Date().timeIntervalSince(since) >= TimeInterval(lockDelaySeconds) {
                isUnlocked = false
            }
        }
        hidePortal = !isUnlocked
        if isUnlocked { return }
        await unlockWithFaceID()
    }

    func unlockWithFaceID() async {
        if !FaceIDAuth.canAuthenticate {
            isUnlocked = true
            hidePortal = false
            fillLoginIfNeeded()
            return
        }
        guard !isAuthenticating else { return }
        isAuthenticating = true
        let ok = await FaceIDAuth.authenticate(reason: "Unlock Manor Parent.")
        isAuthenticating = false
        guard ok else {
            hidePortal = true
            return
        }
        isUnlocked = true
        hidePortal = false
        fillLoginIfNeeded()
    }

    private func fillLoginIfNeeded() {
        guard !suppressAutoFill, isLoginPage, let creds = FaceIDAuth.load() else { return }
        fillLogin(username: creds.username, password: creds.password)
    }

    private func fillLogin(username: String, password: String) {
        guard let webView, webView.url?.host?.lowercased() == PortalHost.login else { return }
        pendingCredentials = nil
        let payload: [String] = [username, password]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8)
        else { return }
        let js = "\(MobileFixes.fillLoginJavaScript)(\(json.dropFirst().dropLast()));"
        webView.evaluateJavaScript(js) { result, _ in
            if (result as? Bool) == true {
                Task { @MainActor in self.autoFillSubmitted = true }
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                webView.evaluateJavaScript(js) { result, _ in
                    guard (result as? Bool) == true else { return }
                    Task { @MainActor in self.autoFillSubmitted = true }
                }
            }
        }
    }

    static func isLogin(_ url: URL?) -> Bool {
        guard let path = url?.path.lowercased() else { return true }
        return path.contains("/login") || path.contains("forgotpassword")
    }

    static func isCheckIn(_ url: URL?) -> Bool {
        (url?.path.lowercased() ?? "").contains("signin_out")
    }
}

/// Hosts the app treats as the school's own site.
enum PortalHost {
    static let login = "portal.childrensmanor.com"

    static func isFirstParty(_ host: String?) -> Bool {
        guard let h = host?.lowercased() else { return false }
        return h == "childrensmanor.com"
            || h.hasSuffix(".childrensmanor.com")
            || h == "childrensmagnet.com"
            || h.hasSuffix(".childrensmagnet.com")
    }
}
