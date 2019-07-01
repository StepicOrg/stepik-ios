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
        var backgroundColor = UIColor.white
    }
}

final class ProcessedContentTextView: UIView {
    private static let reloadTimeStandardInterval: TimeInterval = 0.5
    private static let reloadTimeout: TimeInterval = 10.0
    private static let defaultWebviewHeight: CGFloat = 5

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

        let userScriptViewport = WKUserScript(
            source: """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0');
            document.getElementsByTagName('head')[0].appendChild(meta);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        userContentController.addUserScript(userScript)
        userContentController.addUserScript(userScriptViewport)
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        return webViewConfig
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: self.webViewConfiguration)
        webView.isOpaque = false
        webView.backgroundColor = self.appearance.backgroundColor
        webView.scrollView.backgroundColor = self.appearance.backgroundColor

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
            height: self.webView.intrinsicContentSize.height
                + self.appearance.insets.top
                + self.appearance.insets.bottom
        )
    }

    var isScrollEnabled: Bool {
        get {
            return self.webView.scrollView.isScrollEnabled
        }
        set {
            self.webView.scrollView.isScrollEnabled = newValue
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    // MARK: Public API

    func loadHTMLText(_ text: String) {
        let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
        self.webView.loadHTMLString(text, baseURL: baseURL)
    }

    // MARK: Private API

    private func refreshContentHeight() -> Guarantee<Void> {
        return Guarantee { seal in
            self.webView.evaluateJavaScript("document.readyState;") { _, _ in
                seal(())
            }
        }
    }

    private func getContentHeight() -> Guarantee<Int> {
        return Guarantee { seal in
            self.webView.evaluateJavaScript("document.body.scrollHeight;") { res, _ in
                if let height = res as? Int {
                    seal(height)
                    return
                }

                seal(0)
            }
        }
    }

    private func fetchHeightWithInterval(_ count: Int = 0) {
        let currentTime = TimeInterval(count) * ProcessedContentTextView.reloadTimeStandardInterval
        guard currentTime <= ProcessedContentTextView.reloadTimeout else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) { [weak self] in
            self?.getContentHeight().done { [weak self] height in
                self?.webView.snp.updateConstraints { $0.height.equalTo(height) }
            }
            self?.fetchHeightWithInterval(count + 1)
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
            make.height.equalTo(ProcessedContentTextView.defaultWebviewHeight)
        }
    }
}

extension ProcessedContentTextView: WKNavigationDelegate {
    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.refreshContentHeight().then {
            self.getContentHeight()
        }.done { height in
            self.webView.snp.updateConstraints { $0.height.equalTo(height) }
            self.delegate?.processedContentTextViewDidLoadContent(self)

            self.fetchHeightWithInterval()
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
