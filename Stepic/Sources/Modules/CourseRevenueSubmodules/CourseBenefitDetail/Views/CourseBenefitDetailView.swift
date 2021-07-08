import SnapKit
import UIKit

protocol CourseBenefitDetailViewDelegate: AnyObject {
    func courseBenefitDetailViewDidClickCloseButton(_ view: CourseBenefitDetailView)
    func courseBenefitDetailViewDidClickCourseButton(_ view: CourseBenefitDetailView)
    func courseBenefitDetailViewDidClickBuyerButton(_ view: CourseBenefitDetailView)
}

extension CourseBenefitDetailView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)

        let insets = LayoutInsets.default
    }
}

final class CourseBenefitDetailView: UIView {
    let appearance: Appearance

    weak var delegate: CourseBenefitDetailViewDelegate?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var headerView = CourseBenefitDetailHeaderView()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        return scrollableStackView
    }()

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        let height = self.scrollableStackView.contentSize.height + self.appearance.insets.bottom

        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: height
        )
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

    func showLoading() {
        self.scrollableStackView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func configure(viewModel: CourseBenefitDetailViewModel) {
        self.scrollableStackView.removeAllArrangedViews()

        self.scrollableStackView.addArrangedView(self.headerView)
        self.headerView.title = viewModel.title

        var itemViews = [CourseBenefitDetailItemView]()

        let dateItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailDateTitle", comment: ""),
            detailTitle: viewModel.formattedDate
        )
        self.scrollableStackView.addArrangedView(dateItem)
        itemViews.append(dateItem)

        let courseItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailCourseTitle", comment: ""),
            detailTitle: viewModel.courseTitle,
            isClickable: true
        )
        courseItem.onRightDetailLabelTapped = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseBenefitDetailViewDidClickCourseButton(strongSelf)
        }
        self.scrollableStackView.addArrangedView(courseItem)
        itemViews.append(courseItem)

        let buyerItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailBuyerTitle", comment: ""),
            detailTitle: viewModel.buyerName,
            isClickable: true
        )
        buyerItem.onRightDetailLabelTapped = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseBenefitDetailViewDidClickBuyerButton(strongSelf)
        }
        self.scrollableStackView.addArrangedView(buyerItem)
        itemViews.append(buyerItem)

        let paymentAmountItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailPaymentAmountTitle", comment: ""),
            detailTitle: viewModel.formattedPaymentAmount
        )
        self.scrollableStackView.addArrangedView(paymentAmountItem)
        itemViews.append(paymentAmountItem)

        if let promoCodeName = viewModel.promoCodeName {
            let promoCodeItem = self.makeItemView(
                title: NSLocalizedString("CourseBenefitDetailPromoCodeTitle", comment: ""),
                detailTitle: promoCodeName
            )
            self.scrollableStackView.addArrangedView(promoCodeItem)
            itemViews.append(promoCodeItem)
        }

        let channelItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailChannelTitle", comment: ""),
            detailTitle: viewModel.channelName
        )
        self.scrollableStackView.addArrangedView(channelItem)
        itemViews.append(channelItem)

        let amountPercentItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailAmountPercentTitle", comment: ""),
            detailTitle: viewModel.formattedAmountPercent
        )
        self.scrollableStackView.addArrangedView(amountPercentItem)
        itemViews.append(amountPercentItem)

        self.scrollableStackView.addArrangedView(CourseBenefitDetailItemSeparatorView())

        let amountItem = self.makeItemView(
            title: NSLocalizedString("CourseBenefitDetailAmountTitle", comment: ""),
            detailTitle: viewModel.formattedAmount,
            isLargeTitles: true
        )
        self.scrollableStackView.addArrangedView(amountItem)
        itemViews.append(amountItem)

        let maxTitleWidth = itemViews.map(\.titleLabelIntrinsicContentWidth).max() ?? self.bounds.width / 3
        itemViews.forEach { $0.setTitleLabelWidth(maxTitleWidth) }

        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }

    private func makeItemView(
        title: String,
        detailTitle: String,
        isClickable: Bool = false,
        isLargeTitles: Bool = false
    ) -> CourseBenefitDetailItemView {
        let view = CourseBenefitDetailItemView(isClickable: isClickable, isLargeTitles: isLargeTitles)
        view.title = title
        view.detailTitle = detailTitle
        return view
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.courseBenefitDetailViewDidClickCloseButton(self)
    }
}

extension CourseBenefitDetailView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.closeButton)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.closeButtonWidthHeight)
            make.top.equalToSuperview().offset(self.appearance.closeButtonInsets.top)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.closeButtonInsets.right)
        }
    }
}

extension CourseBenefitDetailView: PanModalScrollable {
    var panScrollable: UIScrollView? {
        self.loadingIndicator.isAnimating
            ? nil
            : self.scrollableStackView.panScrollable
    }
}
