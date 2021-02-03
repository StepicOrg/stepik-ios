import UIKit

protocol PromoPriceButtonProtocol: UIControl {
    func configure(promoPriceString: String, fullPriceString: String)
}

extension PromoPriceButton {
    struct Appearance {
        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let promoPriceFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let fullPriceFont = UIFont.systemFont(ofSize: 12)
    }
}

final class PromoPriceButton: BounceButton, PromoPriceButtonProtocol {
    let appearance: Appearance

    var style: Style {
        didSet {
            self.updateAppearance()
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleLabelIntrinsicContentSize = self.titleLabel?.intrinsicContentSize ?? .zero

        let width: CGFloat = self.appearance.titleInsets.left * 3 + titleLabelIntrinsicContentSize.width

        let height = self.appearance.insets.top
            + titleLabelIntrinsicContentSize.height
            + self.appearance.insets.bottom

        return CGSize(width: width, height: height)
    }

    init(
        frame: CGRect = .zero,
        style: Style = .purple,
        appearance: Appearance = Appearance()
    ) {
        self.style = style
        self.appearance = appearance
        super.init(frame: frame)

        self.updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateAppearance()
    }

    func configure(promoPriceString: String, fullPriceString: String) {
        let formattedTitle = "\(promoPriceString) \(fullPriceString)"

        let attributedTitle = NSMutableAttributedString(
            string: formattedTitle,
            attributes: [
                .font: self.appearance.promoPriceFont,
                .foregroundColor: self.style.titleColor
            ]
        )

        if let fullPriceLocation = formattedTitle.indexOf(fullPriceString) {
            attributedTitle.addAttributes(
                [
                    .font: self.appearance.fullPriceFont,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: self.style.titleColor
                ],
                range: NSRange(location: fullPriceLocation, length: fullPriceString.count)
            )
        }

        self.setAttributedTitle(attributedTitle, for: .normal)
    }

    private func updateAppearance() {
        self.titleEdgeInsets = self.appearance.titleInsets
        self.backgroundColor = self.style.backgroundColor

        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
    }

    enum Style {
        case purple
        case green

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .purple:
                return .stepikVioletFixed
            case .green:
                return .stepikGreenFixed
            }
        }

        fileprivate var titleColor: UIColor { .white }
    }
}
