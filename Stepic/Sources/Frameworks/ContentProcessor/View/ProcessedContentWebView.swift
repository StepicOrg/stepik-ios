import PromiseKit
import SnapKit
import UIKit
import WebKit

// MARK: ProcessedContentWebViewDelegate: class -

protocol ProcessedContentWebViewDelegate: AnyObject {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentWebView)
    func processedContentTextView(_ view: ProcessedContentWebView, didReportNewHeight height: Int)
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImageURL url: URL)
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImage image: UIImage)
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenLink url: URL)
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenARKitLink url: URL)
}

extension ProcessedContentWebViewDelegate {
    func processedContentTextView(_ view: ProcessedContentWebView, didReportNewHeight height: Int) {}
    func processedContentTextView(_ view: ProcessedContentWebView, didOpenARKitLink url: URL) {}
}

// MARK: - Appearance -

extension ProcessedContentWebView {
    struct Appearance {
        var insets = LayoutInsets(top: 10, left: 16, bottom: 4, right: 16)
        var backgroundColor = UIColor.stepikBackground
    }
}

// MARK: - ProcessedContentWebView: UIView -

final class ProcessedContentWebView: UIView {
    private static let pollDocumentReadyStateInterval: TimeInterval = 0.5
    private static let reloadTimeStandardInterval: TimeInterval = 0.5
    private static let reloadTimeout: TimeInterval = 10.0
    private static let defaultWebViewHeight: CGFloat = 5
    private static let clearWebViewContentURL = URL(string: "about:blank").require()

    let appearance: Appearance
    weak var delegate: ProcessedContentWebViewDelegate?

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
        webViewConfig.dataDetectorTypes = [.link]

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
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        return webView
    }()

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.webView.intrinsicContentSize.height
                + self.appearance.insets.top
                + self.appearance.insets.bottom
        )
    }

    /// A Boolean value that determines whether auto-scrolling is enabled.
    ///
    /// If the value of this property is `true`, auto-scrolling is enabled and view will enable scrolling for wider content than webView's size,
    /// and if it is `false`, auto-scrolling is disabled.
    var isAutoScrollingEnabled = true

    var isScrollEnabled: Bool {
        get {
            self.webView.scrollView.isScrollEnabled
        }
        set {
            self.webView.scrollView.isScrollEnabled = newValue
        }
    }

    var insets: LayoutInsets? {
        didSet {
            let insets = self.insets ?? LayoutInsets(insets: .zero)
            self.webView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(insets.top)
                make.leading.equalToSuperview().offset(insets.left)
                make.trailing.equalToSuperview().offset(-insets.right)
                make.bottom.equalToSuperview().offset(-insets.bottom)
            }
            self.layoutIfNeeded()
        }
    }

    /// Keeps track of current web view height.
    private(set) var currentWebViewHeight = Int(ProcessedContentWebView.defaultWebViewHeight)
    private var isLoadingHTMLText = false
    private var isClearingContent = false
    private var htmlTextToLoadAfterClearing: String?

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
        if self.isClearingContent {
            self.htmlTextToLoadAfterClearing = text
        } else {
            self.isLoadingHTMLText = true

            self.webView.stopLoading()
            let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
            self.webView.loadHTMLString(text, baseURL: baseURL)
        }
    }

    func reset() {
        if self.isClearingContent {
            return
        }

        self.isClearingContent = true

        self.webView.snp.updateConstraints { $0.height.equalTo(Self.defaultWebViewHeight) }
        self.currentWebViewHeight = Int(Self.defaultWebViewHeight)

        self.webView.stopLoading()
        self.webView.load(URLRequest(url: Self.clearWebViewContentURL))
    }

    // MARK: Private API

    private func waitCompleteState() -> Guarantee<Void> {
        Guarantee { seal in
            func poll(retryCount: Int) {
                after(
                    seconds: Double(retryCount) * Self.pollDocumentReadyStateInterval
                ).done {
                    self.webView.evaluateJavaScript("document.readyState;") { res, error in
                        if error != nil {
                            seal(())
                        } else if let readyState = res as? String, readyState == "complete" {
                            seal(())
                        } else {
                            poll(retryCount: retryCount + 1)
                        }
                    }
                }
            }

            poll(retryCount: 1)
        }
    }

    private func getContentHeight() -> Guarantee<Int> {
        Guarantee { seal in
            self.webView.evaluateJavaScript("document.body.scrollHeight;") { [weak self] res, _ in
                if let height = res as? Int {
                    if let strongSelf = self, strongSelf.currentWebViewHeight != height {
                        strongSelf.currentWebViewHeight = height
                        strongSelf.delegate?.processedContentTextView(strongSelf, didReportNewHeight: height)
                    }
                    seal(height)
                    return
                }

                seal(0)
            }
        }
    }

    private func fetchHeightWithInterval(_ count: Int = 0) {
        let currentTime = TimeInterval(count) * Self.reloadTimeStandardInterval
        guard currentTime <= Self.reloadTimeout else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) { [weak self] in
            self?.getContentHeight().done { [weak self] height in
                self?.webView.snp.updateConstraints { $0.height.equalTo(height) }
            }
            self?.fetchHeightWithInterval(count + 1)
        }
    }

    private func getContentWidth() -> Guarantee<Int> {
        Guarantee { seal in
            self.webView.evaluateJavaScript("document.body.scrollWidth;") { res, _ in
                if let width = res as? Int {
                    seal(width)
                    return
                }
                seal(0)
            }
        }
    }

    private func fetchWidthWithInterval(_ count: Int = 0) {
        let currentTime = TimeInterval(count) * Self.reloadTimeStandardInterval
        guard currentTime <= Self.reloadTimeout else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + currentTime) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.getContentWidth().done { width in
                if strongSelf.isAutoScrollingEnabled {
                    strongSelf.isScrollEnabled = CGFloat(width) > strongSelf.webView.bounds.size.width
                }
            }
            strongSelf.fetchWidthWithInterval(count + 1)
        }
    }
}

// MARK: - ProcessedContentWebView: ProgrammaticallyInitializableViewProtocol -

extension ProcessedContentWebView: ProgrammaticallyInitializableViewProtocol {
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
            make.height.equalTo(Self.defaultWebViewHeight)
        }
    }
}

// MARK: - ProcessedContentWebView: WKNavigationDelegate -

extension ProcessedContentWebView: WKNavigationDelegate {
    private static let imageLinkPrefix: String = "openimg://"
    private static let arImageLinkPrefix: String = "openar://"

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.waitCompleteState().then {
            self.getContentHeight()
        }.done { height in
            self.webView.snp.updateConstraints { $0.height.equalTo(height) }
            self.isLoadingHTMLText = false

            if self.isClearingContent {
                self.isClearingContent = false
                if let htmlText = self.htmlTextToLoadAfterClearing {
                    self.loadHTMLText(htmlText)
                } else {
                    self.delegate?.processedContentTextViewDidLoadContent(self)
                }
                self.htmlTextToLoadAfterClearing = nil
            } else {
                self.delegate?.processedContentTextViewDidLoadContent(self)
            }

            self.fetchHeightWithInterval()
            self.fetchWidthWithInterval()
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

        if url.absoluteString.starts(with: Self.imageLinkPrefix) {
            var validPath = String(url.absoluteString.dropFirst(Self.imageLinkPrefix.count))

            if validPath.starts(with: "data:image") {
                let imageDataProvider = Base64ImageDataProvider(base64StringOrNot: validPath)

                guard let imageData = imageDataProvider.data,
                      let image = UIImage(data: imageData) else {
                    return decisionHandler(.cancel)
                }

                self.delegate?.processedContentTextView(self, didOpenImage: image)

                return decisionHandler(.cancel)
            } else {
                validPath.replaceFirst(matching: "//", with: "://")

                if let imageURL = URL(string: validPath) {
                    self.delegate?.processedContentTextView(self, didOpenImageURL: imageURL)
                }

                return decisionHandler(.cancel)
            }
        } else if url.absoluteString.starts(with: Self.arImageLinkPrefix) {
            var validPath = String(url.absoluteString.dropFirst(Self.arImageLinkPrefix.count))
            validPath.replaceFirst(matching: "//", with: "://")

            if let usdzURL = URL(string: validPath) {
                self.delegate?.processedContentTextView(self, didOpenARKitLink: usdzURL)
            }

            return decisionHandler(.cancel)
        }

        if self.isLoadingHTMLText && navigationAction.navigationType == .other {
            return decisionHandler(.allow)
        }

        if url.absoluteString == ProcessedContentWebView.clearWebViewContentURL.absoluteString {
            return decisionHandler(.allow)
        }

        self.delegate?.processedContentTextView(self, didOpenLink: url)

        return decisionHandler(.cancel)
    }
}

// MARK: - ProcessedContentWebView: UIScrollViewDelegate -

extension ProcessedContentWebView: UIScrollViewDelegate {
    // swiftlint:disable:next identifier_name
    func viewForZooming(in: UIScrollView) -> UIView? { nil }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
