import Atributika
import SnapKit
import UIKit

extension CourseInfoPurchaseModalDisclaimerView {
    struct Appearance {
        let font = Typography.caption1Font
        let textColor = UIColor.stepikMaterialPrimaryText
        let linkTextColor = UIColor.stepikVioletFixed
        let insets = LayoutInsets.default
    }
}

final class CourseInfoPurchaseModalDisclaimerView: UIView {
    let appearance: Appearance

    private let htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol

    private lazy var topSeparatorView = SeparatorView()

    private lazy var attributedLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.onClick = self.handleAttributedLabelClicked
        label.numberOfLines = 0
        return label
    }()

    var onLinkClick: ((URL) -> Void)?

    override var intrinsicContentSize: CGSize {
        let topSeparatorHeight = self.topSeparatorView.intrinsicContentSize.height
        let attributedLabelSize = self.attributedLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity))
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: topSeparatorHeight + self.appearance.insets.top + attributedLabelSize.height
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        htmlToAttributedStringConverter: HTMLToAttributedStringConverterProtocol? = nil
    ) {
        self.appearance = appearance

        if let htmlToAttributedStringConverter = htmlToAttributedStringConverter {
            self.htmlToAttributedStringConverter = htmlToAttributedStringConverter
        } else {
            self.htmlToAttributedStringConverter = HTMLToAttributedStringConverter(
                font: appearance.font,
                tagStyles: [
                    Style("a")
                        .foregroundColor(appearance.linkTextColor, .normal)
                        .foregroundColor(appearance.linkTextColor.withAlphaComponent(0.5), .highlighted)
                ]
            )
        }

        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()

        self.attributedLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(
            htmlString: NSLocalizedString("CourseInfoPurchaseModalDisclaimer", comment: "")
        )
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension CourseInfoPurchaseModalDisclaimerView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.topSeparatorView)
        self.addSubview(self.attributedLabel)
    }

    func makeConstraints() {
        self.topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.topSeparatorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.insets.edgeInsets)
        }

        self.attributedLabel.translatesAutoresizingMaskIntoConstraints = false
        self.attributedLabel.snp.makeConstraints { make in
            make.top.equalTo(self.topSeparatorView.snp.bottom).offset(self.appearance.insets.top)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.insets.edgeInsets)
        }
    }
}
