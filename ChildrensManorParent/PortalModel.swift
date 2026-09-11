import Foundation
import WebKit

@MainActor
final class PortalModel: ObservableObject {
    static let startURL = URL(string: "https://portal.childrensmanor.com/tp/pa/login")!

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

    weak var webView: WKWebView?

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

    func sync(from webView: WKWebView) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        isLoading = webView.isLoading
        if let title = webView.title, !title.isEmpty {
            pageTitle = title
        }
        let login = Self.isLogin(webView.url)
        isLoginPage = login
        showFaceIDButton = login && FaceIDAuth.hasCredentials && FaceIDAuth.canAuthenticate && isUnlocked
    }

    func pageFinished(in webView: WKWebView) {
        sync(from: webView)
        if isUnlocked {
            fillLoginIfNeeded()
        }
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
}
