import Atributika
import SnapKit
import UIKit

extension ProcessedContentView {
    struct Appearance {
        let labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let labelTextColor = UIColor.stepikSystemPrimaryText

        var insets = LayoutInsets(insets: .zero)
        var backgroundColor = UIColor.stepikBackground
    }
}

final class ProcessedContentView: UIView {
    typealias ContentProcessorBuilder = (String) -> ContentProcessorProtocol

    let appearance: Appearance

    private lazy var attributedLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.numberOfLines = 0
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.onClick = { [weak self] label, detection in
            guard let strongSelf = self else {
                return
            }

            switch detection.type {
            case .link(let url):
                break
            case .tag(let tag):
                if tag.name == "a",
                    let href = tag.attributes["href"],
                    let url = URL(string: href) {
                    break
                }
            default:
                break
            }
        }
        return label
    }()

    private lazy var webView: ProcessedContentWebView = {
        var appearance = ProcessedContentWebView.Appearance(
            insets: .init(insets: .zero),
            backgroundColor: .clear
        )
        let view = ProcessedContentWebView(appearance: appearance)
        return view
    }()

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol
    private let contentProcessorBuilder: ContentProcessorBuilder

    private var didSetupAttributedLabel = false
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
                self.setAttributedLabelText(textValue)
            case .html(let textValue):
                self.setWebViewText(textValue)
            }
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol,
        contentProcessorBuilder: @escaping ContentProcessorBuilder
    ) {
        self.appearance = appearance
        self.htmlToAttributedStringConverter = htmlToAttributedStringConverter
        self.contentProcessorBuilder = contentProcessorBuilder

        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(_ text: String?) {
        if text?.isEmpty ?? true {
            self.processedContent = nil
        } else {
            let contentProcessor = self.contentProcessorBuilder(text ?? "")
            self.processedContent = contentProcessor.processContent()
        }
    }

    private func clearContent(oldProcessedContent: ProcessedContent?) {
        guard let oldProcessedContent = oldProcessedContent else {
            return
        }

        switch oldProcessedContent {
        case .text:
            self.attributedLabel.attributedText = nil
        case .html:
            self.webView.clearContent()
        }
    }

    private func setAttributedLabelText(_ text: String) {
        if !self.didSetupAttributedLabel {
            self.didSetupAttributedLabel = true
            self.setupAttributedLabel()
        }

        if self.didSetupWebView {
            self.webView.isHidden = true
        }
        self.attributedLabel.isHidden = false

        let attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(htmlString: text)
        self.attributedLabel.attributedText = attributedText
    }

    private func setWebViewText(_ text: String) {
        if !self.didSetupWebView {
            self.didSetupWebView = true
            self.setupWebView()
        }

        if self.didSetupAttributedLabel {
            self.attributedLabel.isHidden = true
        }
        self.webView.isHidden = false

        self.webView.loadHTMLText(text)
    }
}

extension ProcessedContentView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    private func setupAttributedLabel() {
        self.addSubview(self.attributedLabel)
        self.attributedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.attributedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }

    private func setupWebView() {
        self.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
