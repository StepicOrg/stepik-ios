import Atributika
import SnapKit
import UIKit

protocol ProcessedContentTextViewDelegate: AnyObject {
    func processedContentTextView(_ view: ProcessedContentTextView, didReportNewHeight height: CGFloat)
}

extension ProcessedContentTextView {
    struct Appearance {
        var font = UIFont.systemFont(ofSize: 17, weight: .regular)
        var textColor = UIColor.stepikSystemPrimaryText
    }
}

final class ProcessedContentTextView: UIView {
    let appearance: Appearance

    weak var delegate: ProcessedContentTextViewDelegate?

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var attributedLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.onClick = self.handleAttributedLabelClicked
        label.numberOfLines = 0
        return label
    }()

    private var didSetupLabel = false
    private var didSetupAttributedLabel = false

    private var currentIntrinsicContentHeight: CGFloat = UIView.noIntrinsicMetric {
        didSet {
            if oldValue != self.currentIntrinsicContentHeight {
                self.delegate?.processedContentTextView(self, didReportNewHeight: self.currentIntrinsicContentHeight)
            }
        }
    }

    var onLinkClick: ((URL) -> Void)?

    var text: String? {
        didSet {
            if oldValue == self.text {
                return
            }

            guard let text = self.text else {
                return self.clearText()
            }

            if self.isAttributedLabelSupportNeeded(text: text) {
                self.setAttributedLabelText(text)
            } else {
                self.setLabelText(text)
            }

            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height: CGFloat
        if self.didSetupLabel && !self.label.isHidden {
            height = self.label.intrinsicContentSize.height
        } else if self.didSetupAttributedLabel {
            height = self.attributedLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
        } else {
            height = UIView.noIntrinsicMetric
        }

        self.currentIntrinsicContentHeight = height

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol
    ) {
        self.appearance = appearance
        self.htmlToAttributedStringConverter = htmlToAttributedStringConverter
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func clearText() {
        if self.didSetupLabel && !self.label.isHidden {
            self.label.text = nil
        } else {
            self.attributedLabel.attributedText = nil
        }
    }

    private func isAttributedLabelSupportNeeded(text: String) -> Bool {
        let hasAnyURLScheme = text.contains("http://") || text.contains("https://")
        let hasAnyHTMLTagStartEndSymbol = text.contains("<") || text.contains(">") || text.contains("</")
        return hasAnyURLScheme || hasAnyHTMLTagStartEndSymbol
    }

    private func setLabelText(_ text: String) {
        if !self.didSetupLabel {
            self.didSetupLabel = true
            self.setupLabel()
        }

        if self.didSetupAttributedLabel {
            self.attributedLabel.isHidden = true
            self.attributedLabel.attributedText = nil
        }

        self.label.isHidden = false
        self.label.text = text
    }

    private func setAttributedLabelText(_ text: String) {
        if !self.didSetupAttributedLabel {
            self.didSetupAttributedLabel = true
            self.setupAttributedLabel()
        }

        if self.didSetupLabel {
            self.label.isHidden = true
            self.label.text = nil
        }

        self.attributedLabel.isHidden = false
        self.attributedLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(
            htmlString: text
        )
    }

    private func handleAttributedLabelClicked(label: AttributedLabel, detection: Detection) {
        switch detection.type {
        case .link(let url):
            self.onLinkClick?(url)
        case .tag(let tag):
            if tag.name == "a",
               let href = tag.attributes["href"],
               let url = URL(string: href) {
                self.onLinkClick?(url)
            }
        default:
            break
        }
    }

    private func setupLabel() {
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupAttributedLabel() {
        self.addSubview(self.attributedLabel)
        self.attributedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.attributedLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
