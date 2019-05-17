import PromiseKit
import SnapKit
import UIKit
import WebKit

protocol ProcessedContentTextViewDelegate: class {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView)
}

extension ProcessedContentTextView {
    struct Appearance { }
}

final class ProcessedContentTextView: UIView {
    let appearance: Appearance
    weak var delegate: ProcessedContentTextViewDelegate?

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let userContentController = WKUserContentController()
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
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return webView
    }()

    override var intrinsicContentSize: CGSize {
        return webView.scrollView.contentSize
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
            make.edges.equalToSuperview()
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
