import SwiftUI
import WebKit

struct PortalWebView: UIViewRepresentable {
    @ObservedObject var model: PortalModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> WKWebView {
        let boot = WKUserScript(
            source: "window.__cmmsSimpleCheckIn = \(AppSettings.startOnCheckIn ? "true" : "false");",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        let js = WKUserScript(
            source: MobileFixes.javaScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.preferredContentMode = .mobile
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()
        config.userContentController.addUserScript(boot)
        config.userContentController.addUserScript(js)
        config.userContentController.add(context.coordinator, name: "cmmsAuth")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.alwaysBounceVertical = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0, green: 91 / 255, blue: 171 / 255, alpha: 1)

        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.pullToRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        model.webView = webView
        context.coordinator.webView = webView
        webView.load(URLRequest(url: PortalModel.startURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        model.webView = uiView
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let model: PortalModel
        weak var webView: WKWebView?

        init(model: PortalModel) {
            self.model = model
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Only the school's own page (not Google or an embedded frame) may
            // hand over a passcode or sign the app out.
            guard message.name == "cmmsAuth",
                  message.frameInfo.isMainFrame,
                  PortalHost.isFirstParty(message.frameInfo.securityOrigin.host),
                  let body = message.body as? [String: Any],
                  let type = body["type"] as? String
            else { return }
            if type == "loginSubmitted",
               let username = body["username"] as? String,
               let password = body["password"] as? String
            {
                Task { @MainActor in
                    model.loginSubmitted(username: username, password: password)
                }
                return
            }
            if type == "haptic" {
                Task { @MainActor in
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                return
            }
            if type == "codeSave" {
                let value = body["value"] as? String ?? ""
                let student = body["student"] as? String
                ClassroomCodeStore.set(value, student: student)
                return
            }
            if type == "codeLoad" {
                let student = body["student"] as? String
                let code = ClassroomCodeStore.get(student: student)
                let payload = (try? JSONSerialization.data(withJSONObject: [code]))
                    .flatMap { String(data: $0, encoding: .utf8) }
                    .map { String($0.dropFirst().dropLast()) } ?? "\"\""
                webView?.evaluateJavaScript("window.__cmmsApplyClassroomCode && window.__cmmsApplyClassroomCode(\(payload));", completionHandler: nil)
                return
            }
            if type == "logout" {
                Task { @MainActor in
                    model.signOutToLogin()
                }
            }
        }

        @objc func pullToRefresh(_ control: UIRefreshControl) {
            webView?.reload()
            // didFinish/didFail end it; this covers a reload that never starts.
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                control.endRefreshing()
            }
        }

        private func allowedHost(_ host: String?) -> Bool {
            guard let host else { return false }
            let h = host.lowercased()
            return PortalHost.isFirstParty(h)
                || h == "calendar.google.com"
                || h.hasSuffix(".google.com")
        }

        /// A load that was stopped on purpose (a new page started, or the
        /// link opened in Safari) is not something to show as an error.
        private func isCancellation(_ error: Error) -> Bool {
            let ns = error as NSError
            return (ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled)
                || (ns.domain == "WebKitErrorDomain" && ns.code == 102) // frame load interrupted
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                model.lastError = nil
                model.sync(from: webView)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
            webView.evaluateJavaScript(MobileFixes.javaScript, completionHandler: nil)
            Task { @MainActor in
                model.isLoading = false
                model.pageFinished(in: webView)
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            let message = isCancellation(error) ? nil : error.localizedDescription
            Task { @MainActor in
                model.isLoading = webView.isLoading
                if let message { model.lastError = message }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
            let message = isCancellation(error) ? nil : error.localizedDescription
            Task { @MainActor in
                model.isLoading = webView.isLoading
                if let message { model.lastError = message }
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if url.scheme == "tel" || url.scheme == "mailto" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            if navigationAction.targetFrame == nil {
                if allowedHost(url.host) {
                    webView.load(URLRequest(url: url))
                } else {
                    UIApplication.shared.open(url)
                }
                decisionHandler(.cancel)
                return
            }

            if let host = url.host, !allowedHost(host), url.scheme == "http" || url.scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                if allowedHost(url.host) {
                    webView.load(URLRequest(url: url))
                } else {
                    UIApplication.shared.open(url)
                }
            }
            return nil
        }

        // Without these, the portal's alert() does nothing and confirm()
        // silently answers "Cancel", so actions that ask first never happen.
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            if !present(alert, over: webView) { completionHandler() }
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
            if !present(alert, over: webView) { completionHandler(false) }
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            alert.addTextField { $0.text = defaultText }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak alert] _ in
                completionHandler(alert?.textFields?.first?.text)
            })
            if !present(alert, over: webView) { completionHandler(nil) }
        }

        private func present(_ alert: UIAlertController, over webView: WKWebView) -> Bool {
            guard var top = webView.window?.rootViewController else { return false }
            while let next = top.presentedViewController { top = next }
            top.present(alert, animated: true)
            return true
        }
    }
}
