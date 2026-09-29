import Foundation
import WebKit

@MainActor
final class PortalModel: ObservableObject {
    static let startURL = URL(string: "https://portal.childrensmanor.com/tp/pa/login")!
    static let checkInURL = URL(string: "https://portal.childrensmanor.com/tp/ur/signin_out")!

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

    var shouldHideAppBar: Bool {
        startOnCheckIn && isCheckInPage && isUnlocked && !hidePortal
    }

    weak var webView: WKWebView?
    private var wasLoginPage = true
    private var didRedirectToCheckIn = false

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
        let login = Self.isLogin(webView.url)
        isLoginPage = login
        isCheckInPage = Self.isCheckIn(webView.url)
        showFaceIDButton = login && FaceIDAuth.hasCredentials && FaceIDAuth.canAuthenticate && isUnlocked
    }

    func pageFinished(in webView: WKWebView) {
        sync(from: webView)
        applySimpleModeToPage()
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

    func coverForAppSwitch() {
        hidePortal = true
    }

    func lockForBackground() {
        isUnlocked = false
        hidePortal = true
        isAuthenticating = false
    }

    func handleBecameActive() async {
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
        guard isLoginPage, let creds = FaceIDAuth.load() else { return }
        fillLogin(username: creds.username, password: creds.password)
    }

    private func fillLogin(username: String, password: String) {
        guard let webView else { return }
        let payload: [String] = [username, password]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8)
        else { return }
        let js = "\(MobileFixes.fillLoginJavaScript)(\(json.dropFirst().dropLast()));"
        webView.evaluateJavaScript(js) { result, _ in
            if (result as? Bool) != true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    webView.evaluateJavaScript(js, completionHandler: nil)
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
