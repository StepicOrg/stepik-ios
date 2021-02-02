import SnapKit
import UIKit

extension TransparentPromoPriceButton {
    struct Appearance {
        let font = UIFont.systemFont(ofSize: 16)
        let textColor = UIColor.white
        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let promoPriceBackgroundColor = UIColor.stepikGreenFixed
        let promoPriceInsets = LayoutInsets(left: 22, right: 22)

        let fullPriceBackgroundColor = UIColor.clear
        let fullPriceBorderWidth: CGFloat = 1
        let fullPriceBorderColor = UIColor.white
    }
}

final class TransparentPromoPriceButton: UIControl, PromoPriceButtonProtocol {
    let appearance: Appearance

    private lazy var promoPriceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.promoPriceBackgroundColor
        return view
    }()
    private lazy var promoPriceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var fullPriceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.fullPriceBackgroundColor
        view.layer.borderWidth = self.appearance.fullPriceBorderWidth
        view.layer.borderColor = self.appearance.fullPriceBorderColor.cgColor
        return view
    }()
    private lazy var fullPriceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.promoPriceLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.fullPriceLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let promoLabelIntrinsicContentSize = self.promoPriceLabel.intrinsicContentSize
        let fullLabelIntrinsicContentSize = self.fullPriceLabel.intrinsicContentSize

        let width: CGFloat = self.appearance.insets.left
            + promoLabelIntrinsicContentSize.width
            + self.appearance.insets.right
            + self.appearance.insets.left
            + fullLabelIntrinsicContentSize.width
            + self.appearance.insets.right

        let height = self.appearance.insets.top
            + max(promoLabelIntrinsicContentSize.height, fullLabelIntrinsicContentSize.height)
            + self.appearance.insets.bottom

        return CGSize(width: width, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = self.bounds.height / 2

        [
            self, self.fullPriceContainerView, self.promoPriceContainerView
        ].forEach { view in
            view.layer.cornerRadius = cornerRadius
            view.clipsToBounds = true
        }
    }

    func configure(promoPriceString: String, fullPriceString: String) {
        self.promoPriceLabel.text = promoPriceString

        let fullPriceAttributedText = NSAttributedString(
            string: fullPriceString,
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: self.appearance.textColor
            ]
        )
        self.fullPriceLabel.attributedText = fullPriceAttributedText
    }
}

extension TransparentPromoPriceButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
    }

    func addSubviews() {
        self.addSubview(self.fullPriceContainerView)
        self.fullPriceContainerView.addSubview(self.fullPriceLabel)

        self.addSubview(self.promoPriceContainerView)
        self.promoPriceContainerView.addSubview(self.promoPriceLabel)
    }

    func makeConstraints() {
        self.fullPriceContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.fullPriceContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.fullPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fullPriceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalToSuperview()
        }

        self.promoPriceContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.promoPriceContainerView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(self.fullPriceLabel.snp.leading).offset(-self.appearance.insets.right / 2)
        }

        self.promoPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.promoPriceLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.promoPriceInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.promoPriceInsets.right)
            make.centerY.equalToSuperview()
        }
    }
}
