import SnapKit
import UIKit

extension CourseInfoPurchaseModalActionButtonsView {
    struct Appearance {
        let actionButtonHeight: CGFloat = 44

        let buyButtonTextColor = UIColor.white
        let buyButtonBackgroundColor = UIColor.stepikGreenFixed
        let buyButtonPromoPriceBackgroundColor = UIColor.stepikVioletFixed
        let buyButtonFullPriceFont = UIFont.systemFont(ofSize: 12)

        let wishlistButtonTextColor = UIColor.stepikVioletFixed
        let wishlistButtonBackgroundColor = UIColor.clear
        let wishlistButtonBorderColor = UIColor.stepikVioletFixed
        let wishlistButtonDisabledBorderColor = UIColor.stepikVioletFixed.withAlphaComponent(0.12)
        let wishlistButtonBorderWidth: CGFloat = 1

        let stackViewSpacing: CGFloat = 16
        var stackViewInsets = LayoutInsets(horizontal: 16)
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

    var onBuyButtonClick: (() -> Void)?
    var onWishlistButtonClick: (() -> Void)?

    var isEnabled = true {
        didSet {
            self.buyButton.isEnabled = self.isEnabled
            self.wishlistButton.isEnabled = self.isEnabled
        }
    }

    var buyButtonIsEnabled: Bool {
        get {
            self.buyButton.isEnabled
        }
        set {
            self.buyButton.isEnabled = newValue
        }
    }

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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public API

    func updateBuyButtonState(newState: BuyButtonState) {
        switch newState {
        case .loading:
            self.buyButton.isLoadingActivityIndicatorVisible = true
            self.buyButton.text = NSLocalizedString(
                "CourseInfoPurchaseModalBuyButtonPurchaseInProgressTitle",
                comment: ""
            )
        case .result(let viewModel):
            self.buyButton.isLoadingActivityIndicatorVisible = false
            self.configureBuyButton(viewModel: viewModel)
        }
    }

    func configureWishlistButton(viewModel: CourseInfoPurchaseModalWishlistViewModel) {
        self.wishlistButton.appearance = .init(
            loadingIndicatorColor: self.appearance.wishlistButtonTextColor,
            textLabelTextColor: self.appearance.wishlistButtonTextColor,
            backgroundColor: self.appearance.wishlistButtonBackgroundColor,
            borderWidth: self.appearance.wishlistButtonBorderWidth,
            borderColor: viewModel.isInWishlist
                ? self.appearance.wishlistButtonDisabledBorderColor
                : self.appearance.wishlistButtonBorderColor
        )

        self.wishlistButton.text = viewModel.title

        self.wishlistButton.isLoadingActivityIndicatorVisible = viewModel.isLoading
        self.wishlistButton.isUserInteractionEnabled = !viewModel.isInWishlist && !viewModel.isLoading
    }

    // MARK: Private API

    private func configureBuyButton(viewModel: CourseInfoPurchaseModalPriceViewModel) {
        self.buyButton.appearance = .init(
            loadingIndicatorColor: self.appearance.buyButtonTextColor,
            textLabelTextColor: self.appearance.buyButtonTextColor,
            backgroundColor: viewModel.promoDisplayPrice != nil
                ? self.appearance.buyButtonPromoPriceBackgroundColor
                : self.appearance.buyButtonBackgroundColor
        )

        if let promoDisplayPrice = viewModel.promoDisplayPrice {
            let buyWithPromoTitle = String(format: NSLocalizedString("WidgetButtonBuy", comment: ""), promoDisplayPrice)
            let formattedTitle = "\(buyWithPromoTitle) \(viewModel.displayPrice)"

            let buyButtonAppearance = CourseInfoPurchaseModalActionButton.Appearance()

            let attributedTitle = NSMutableAttributedString(
                string: formattedTitle,
                attributes: [
                    .font: buyButtonAppearance.textLabelFont,
                    .foregroundColor: buyButtonAppearance.textLabelTextColor
                ]
            )

            if let displayPriceLocation = formattedTitle.indexOf(viewModel.displayPrice) {
                attributedTitle.addAttributes(
                    [
                        .font: self.appearance.buyButtonFullPriceFont,
                        .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        .strikethroughColor: buyButtonAppearance.textLabelTextColor
                    ],
                    range: NSRange(location: displayPriceLocation, length: viewModel.displayPrice.count)
                )
            }

            self.buyButton.attributedText = attributedTitle
        } else {
            self.buyButton.text = String(
                format: NSLocalizedString("WidgetButtonBuy", comment: ""),
                viewModel.displayPrice
            )
        }
    }

    @objc
    private func buyButtonClicked() {
        self.onBuyButtonClick?()
    }

    @objc
    private func wishlistButtonClicked() {
        self.onWishlistButtonClick?()
    }

    // MARK: Inner Types

    enum BuyButtonState {
        case loading
        case result(CourseInfoPurchaseModalPriceViewModel)
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
