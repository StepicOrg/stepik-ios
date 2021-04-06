import SnapKit
import UIKit

protocol ProcessedContentViewDelegate: AnyObject {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView)
    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int)
    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL)
    func processedContentView(_ view: ProcessedContentView, didOpenNativeImage image: UIImage)
    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL)
    func processedContentView(_ view: ProcessedContentView, didOpenARKitLink url: URL)
}

extension ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {}

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {}

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {}

    func processedContentView(_ view: ProcessedContentView, didOpenNativeImage image: UIImage) {}

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {}

    func processedContentView(_ view: ProcessedContentView, didOpenARKitLink url: URL) {}
}

extension ProcessedContentView {
    struct Appearance {
        var labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        var labelTextColor = UIColor.stepikSystemPrimaryText

        var activityIndicatorViewStyle = UIActivityIndicatorView.Style.stepikWhiteLarge
        var activityIndicatorViewColor: UIColor?

        var insets = LayoutInsets(insets: .zero)
        var backgroundColor = UIColor.stepikBackground
    }
}

final class ProcessedContentView: UIView {
    let appearance: Appearance

    weak var delegate: ProcessedContentViewDelegate?

    private lazy var textView: ProcessedContentTextView = {
        let appearance = ProcessedContentTextView.Appearance(
            font: self.appearance.labelFont,
            textColor: self.appearance.labelTextColor
        )

        let view = ProcessedContentTextView(
            frame: .zero,
            appearance: appearance,
            htmlToAttributedStringConverter: self.htmlToAttributedStringConverter
        )
        view.delegate = self
        view.onLinkClick = { [weak self] link in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.processedContentView(strongSelf, didOpenLink: link)
        }

        return view
    }()

    private lazy var webView: ProcessedContentWebView = {
        let appearance = ProcessedContentWebView.Appearance(
            insets: .init(insets: .zero),
            backgroundColor: .clear
        )

        let view = ProcessedContentWebView(appearance: appearance)
        view.isAutoScrollingEnabled = true
        view.delegate = self

        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: self.appearance.activityIndicatorViewStyle)
        activityIndicatorView.hidesWhenStopped = true

        if let activityIndicatorViewColor = self.appearance.activityIndicatorViewColor {
            activityIndicatorView.color = activityIndicatorViewColor
        }

        activityIndicatorView.stopAnimating()

        return activityIndicatorView
    }()

    private lazy var contentView = UIView()
    private var contentViewHeightConstraint: Constraint?

    private let contentProcessor: ContentProcessorProtocol
    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    private var didSetupTextView = false
    private var didSetupWebView = false

    var processedContent: ProcessedContent? = nil {
        didSet {
            if oldValue == self.processedContent {
                return
            }

            guard let processedContent = self.processedContent else {
                return self.clearContent(oldProcessedContent: oldValue)
            }

            switch processedContent {
            case .text(let textValue):
                self.setTextViewText(textValue)
            case .html(let textValue):
                self.setWebViewText(textValue)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentHeight: CGFloat
        if self.didSetupTextView && !self.textView.isHidden {
            contentHeight = self.textView.intrinsicContentSize.height
        } else if self.didSetupWebView {
            contentHeight = self.webView.intrinsicContentSize.height
        } else {
            contentHeight = UIView.noIntrinsicMetric
        }

        let insetsHeight = self.appearance.insets.top + self.appearance.insets.bottom
        let height = contentHeight == UIView.noIntrinsicMetric ? UIView.noIntrinsicMetric : contentHeight + insetsHeight

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        contentProcessor: ContentProcessorProtocol,
        htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol
    ) {
        self.appearance = appearance
        self.contentProcessor = contentProcessor
        self.htmlToAttributedStringConverter = htmlToAttributedStringConverter

        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    convenience init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.init(
            frame: frame,
            appearance: appearance,
            contentProcessor: ContentProcessor(),
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(font: appearance.labelFont)
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let resSize: CGSize

        if self.didSetupTextView && !self.textView.isHidden {
            resSize = self.textView.sizeThatFits(size)
        } else if self.didSetupWebView {
            resSize = self.webView.sizeThatFits(size)
        } else {
            resSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }

        let insetsHeight = self.appearance.insets.top + self.appearance.insets.bottom
        let height = resSize.height == UIView.noIntrinsicMetric
            ? UIView.noIntrinsicMetric
            : ceil(resSize.height + insetsHeight)

        let width = resSize.width == UIView.noIntrinsicMetric
            ? UIView.noIntrinsicMetric
            : ceil(resSize.width)

        return CGSize(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
        self.updateContentViewHeightConstraintOffset()
    }

    // MARK: Public API

    func setText(_ text: String?) {
        if text?.isEmpty ?? true {
            self.processedContent = nil
        } else {
            self.activityIndicatorView.startAnimating()

            DispatchQueue.global(qos: .userInitiated).async {
                let processedContent = self.contentProcessor.processContent(text ?? "")

                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    if processedContent == strongSelf.processedContent {
                        strongSelf.activityIndicatorView.stopAnimating()
                    }

                    strongSelf.processedContent = processedContent

                    if case .text = processedContent {
                        strongSelf.activityIndicatorView.stopAnimating()
                        strongSelf.delegate?.processedContentViewDidLoadContent(strongSelf)
                    }
                }
            }
        }
    }

    // MARK: Private API

    private func updateContentViewHeightConstraintOffset() {
        self.contentViewHeightConstraint?.update(offset: max(0, self.intrinsicContentSize.height))
        self.layoutIfNeeded()
    }

    private func clearContent(oldProcessedContent: ProcessedContent?) {
        guard let oldProcessedContent = oldProcessedContent else {
            return
        }

        switch oldProcessedContent {
        case .text:
            self.textView.text = nil
        case .html:
            self.webView.clearContent()
        }

        self.updateContentViewHeightConstraintOffset()
    }

    private func setTextViewText(_ text: String) {
        if !self.didSetupTextView {
            self.didSetupTextView = true
            self.setupTextView()
        }

        if self.didSetupWebView {
            self.webView.isHidden = true
            self.webView.clearContent()
        }

        self.textView.isHidden = false
        self.textView.text = text

        self.updateContentViewHeightConstraintOffset()
    }

    private func setWebViewText(_ text: String) {
        if !self.activityIndicatorView.isAnimating {
            self.activityIndicatorView.startAnimating()
        }

        if !self.didSetupWebView {
            self.didSetupWebView = true
            self.setupWebView()
        } else {
            self.webView.clearContent()
        }

        if self.didSetupTextView {
            self.textView.isHidden = true
            self.textView.text = nil
        }

        self.webView.isHidden = false
        self.webView.loadHTMLText(text)

        self.updateContentViewHeightConstraintOffset()
    }
}

// MARK: - ProcessedContentView: ProgrammaticallyInitializableViewProtocol -

extension ProcessedContentView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.contentView.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.contentView)
        self.addSubview(self.activityIndicatorView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.contentViewHeightConstraint = make.height.equalTo(0).constraint
        }

        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    // MARK: Private Helpers

    private func setupTextView() {
        self.contentView.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }

    private func setupWebView() {
        self.contentView.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}

// MARK: - ProcessedContentView: ProcessedContentTextViewDelegate -

extension ProcessedContentView: ProcessedContentTextViewDelegate {
    func processedContentTextView(_ view: ProcessedContentTextView, didReportNewHeight height: CGFloat) {
        guard self.didSetupTextView && !self.textView.isHidden else {
            return
        }

        self.updateContentViewHeightConstraintOffset()

        self.delegate?.processedContentView(self, didReportNewHeight: Int(height.rounded(.up)))
    }
}

// MARK: - ProcessedContentView: ProcessedContentWebViewDelegate -

extension ProcessedContentView: ProcessedContentWebViewDelegate {
    private var isWebViewActive: Bool {
        self.didSetupWebView && !self.webView.isHidden
    }

    func processedContentTextViewDidLoadContent(_ view: ProcessedContentWebView) {
        guard self.isWebViewActive else {
            return
        }

        self.activityIndicatorView.stopAnimating()
        self.updateContentViewHeightConstraintOffset()

        self.delegate?.processedContentViewDidLoadContent(self)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didReportNewHeight height: Int) {
        guard self.isWebViewActive else {
            return
        }

        self.updateContentViewHeightConstraintOffset()

        self.delegate?.processedContentView(self, didReportNewHeight: height)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImageURL url: URL) {
        guard self.isWebViewActive else {
            return
        }

        self.delegate?.processedContentView(self, didOpenImageURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenNativeImage image: UIImage) {
        guard self.isWebViewActive else {
            return
        }

        self.delegate?.processedContentView(self, didOpenNativeImage: image)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenLink url: URL) {
        guard self.isWebViewActive else {
            return
        }

        self.delegate?.processedContentView(self, didOpenLink: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenARKitLink url: URL) {
        guard self.isWebViewActive else {
            return
        }

        self.delegate?.processedContentView(self, didOpenARKitLink: url)
    }
}
