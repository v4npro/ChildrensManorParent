import SwiftUI
import WebKit

struct PortalWebView: UIViewRepresentable {
    @ObservedObject var model: PortalModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> WKWebView {
        let js = WKUserScript(
            source: MobileFixes.javaScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.preferredContentMode = .mobile
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()
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
            guard message.name == "cmmsAuth",
                  let body = message.body as? [String: Any],
                  let type = body["type"] as? String
            else { return }
            if type == "save",
               let username = body["username"] as? String,
               let password = body["password"] as? String
            {
                FaceIDAuth.save(username: username, password: password)
                Task { @MainActor in
                    model.showFaceIDButton = FaceIDAuth.hasCredentials && FaceIDAuth.canAuthenticate
                }
            }
        }

        @objc func pullToRefresh(_ control: UIRefreshControl) {
            webView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                control.endRefreshing()
            }
        }

        private func allowedHost(_ host: String?) -> Bool {
            guard let host else { return false }
            let h = host.lowercased()
            return h == "portal.childrensmanor.com"
                || h.hasSuffix(".childrensmanor.com")
                || h == "childrensmanor.com"
                || h == "childrensmagnet.com"
                || h.hasSuffix(".childrensmagnet.com")
                || h == "calendar.google.com"
                || h.hasSuffix(".google.com")
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                model.lastError = nil
                model.sync(from: webView)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(MobileFixes.javaScript, completionHandler: nil)
            Task { @MainActor in
                model.isLoading = false
                model.pageFinished(in: webView)
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                model.isLoading = false
                model.lastError = error.localizedDescription
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let ns = error as NSError
            if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled { return }
            Task { @MainActor in
                model.isLoading = false
                model.lastError = error.localizedDescription
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
    }
}
