import SnapKit
import UIKit

extension CourseInfoPurchaseModalActionButtonsView {
    struct Appearance {
        let actionButtonHeight: CGFloat = 44

        let wishlistButtonBorderWidth: CGFloat = 1

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(horizontal: 16)
    }
}

final class CourseInfoPurchaseModalActionButtonsView: UIView {
    let appearance: Appearance

    private lazy var buyButton = CourseInfoPurchaseModalActionButton()

    private lazy var wishlistButton = CourseInfoPurchaseModalActionButton()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    var style = Style.violet {
        didSet {
            self.updateStyle()
        }
    }

    var onBuyButtonClick: (() -> Void)?
    var onWishlistButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: UIView.noIntrinsicMetric, height: stackViewIntrinsicContentSize.height)
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

        self.updateStyle()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func buyButtonClicked() {
        self.onBuyButtonClick?()
    }

    @objc
    private func wishlistButtonClicked() {
        self.onWishlistButtonClick?()
    }

    private func updateStyle() {
        self.buyButton.appearance = .init(
            textLabelTextColor: self.style.buyButtonTextColor,
            backgroundColor: self.style.buyButtonBackgroundColor
        )
        self.wishlistButton.appearance = .init(
            iconImageViewTintColor: self.style.wishlistButtonTextColor,
            textLabelTextColor: self.style.wishlistButtonTextColor,
            backgroundColor: self.style.wishlistButtonBackgroundColor,
            borderWidth: self.appearance.wishlistButtonBorderWidth,
            borderColor: self.style.wishlistButtonBorderColor
        )
    }

    enum Style {
        case violet
        case green

        fileprivate var buyButtonTextColor: UIColor { .white }

        fileprivate var buyButtonBackgroundColor: UIColor {
            switch self {
            case .violet:
                return .stepikVioletFixed
            case .green:
                return .stepikGreenFixed
            }
        }

        fileprivate var wishlistButtonTextColor: UIColor {
            switch self {
            case .violet:
                return .stepikVioletFixed
            case .green:
                return .stepikGreenFixed
            }
        }

        fileprivate var wishlistButtonBackgroundColor: UIColor { .clear }

        fileprivate var wishlistButtonBorderColor: UIColor {
            switch self {
            case .violet:
                return .stepikVioletFixed
            case .green:
                return .stepikGreenFixed
            }
        }
    }
}

extension CourseInfoPurchaseModalActionButtonsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.buyButton.addTarget(self, action: #selector(self.buyButtonClicked), for: .touchUpInside)
        self.wishlistButton.addTarget(self, action: #selector(self.wishlistButtonClicked), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.buyButton)
        self.stackView.addArrangedSubview(self.wishlistButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(self.appearance.stackViewInsets.edgeInsets)
        }

        [self.buyButton, self.wishlistButton].forEach { actionButton in
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.snp.makeConstraints { make in
                make.height.equalTo(self.appearance.actionButtonHeight)
            }
        }
    }
}
