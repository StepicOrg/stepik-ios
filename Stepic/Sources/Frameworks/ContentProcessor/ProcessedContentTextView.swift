import PromiseKit
import SnapKit
import UIKit
import WebKit

protocol ProcessedContentTextViewDelegate: class {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView)
    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage url: URL)
    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL)
}

extension ProcessedContentTextView {
    struct Appearance {
        var insets = LayoutInsets(top: 10, left: 16, bottom: 4, right: 16)
    }
}

final class ProcessedContentTextView: UIView {
    let appearance: Appearance
    weak var delegate: ProcessedContentTextViewDelegate?

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let userContentController = WKUserContentController()
        // Remove paddings and margins
        let userScript = WKUserScript(
            source: """
            var style = document.createElement('style');
            style.innerHTML = 'body { padding: 0 !important; margin: 0 !important; }';
            document.head.appendChild(style);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(userScript)
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        return webViewConfig
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: self.webViewConfiguration)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInset = .zero
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webView
    }()

    private var isFirstNavigationAction = true

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: webView.scrollView.contentSize.height + self.appearance.insets.top + self.appearance.insets.bottom
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // We should reset WKWebView's delegate (to prevent strange iOS 9 crash)
        self.webView.navigationDelegate = nil
        self.webView.scrollView.delegate = nil
    }

    // MARK: Public API

    func loadHTMLText(_ text: String) {
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        self.webView.loadHTMLString(text, baseURL: baseURL)
    }

    // MARK: Private API

    private func refreshContentHeight() -> Guarantee<Void> {
        return Guarantee { seal in
            self.webView.evaluateJavaScript(
                "document.readyState;",
                completionHandler: { _, _ in
                    seal(())
                }
            )
        }
    }
}

extension ProcessedContentTextView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.webView)
    }

    func makeConstraints() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}

extension ProcessedContentTextView: WKNavigationDelegate {
    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.refreshContentHeight().done { _ in
            self.invalidateIntrinsicContentSize()
            self.delegate?.processedContentTextViewDidLoadContent(self)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.cancel)
        }

        let imageLinkPrefix = "openimg://"
        if url.absoluteString.starts(with: imageLinkPrefix) {
            var validPath = String(url.absoluteString.dropFirst(imageLinkPrefix.count))
            validPath.replaceFirst(matching: "//", with: "://")
            if let imageURL = URL(string: validPath) {
                self.delegate?.processedContentTextView(self, didOpenImage: imageURL)
            }
            return decisionHandler(.cancel)
        }

        if self.isFirstNavigationAction && navigationAction.navigationType == .other {
            self.isFirstNavigationAction = false
            return decisionHandler(.allow)
        }

        self.delegate?.processedContentTextView(self, didOpenLink: url)
        return decisionHandler(.cancel)
    }
}

extension ProcessedContentTextView: UIScrollViewDelegate {
    // swiftlint:disable:next identifier_name
    func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
