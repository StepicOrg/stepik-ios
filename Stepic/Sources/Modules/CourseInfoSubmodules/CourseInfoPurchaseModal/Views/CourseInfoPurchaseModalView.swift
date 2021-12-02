import SnapKit
import UIKit

protocol CourseInfoPurchaseModalViewDelegate: AnyObject {
    func courseInfoPurchaseModalViewDidClickCloseButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidRevealPromoCodeInput(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalView(_ view: CourseInfoPurchaseModalView, didClickLink link: URL)
    func courseInfoPurchaseModalViewDidClickBuyButton(_ view: CourseInfoPurchaseModalView)
    func courseInfoPurchaseModalViewDidClickWishlistButton(_ view: CourseInfoPurchaseModalView)
}

extension CourseInfoPurchaseModalView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(inset: 16)
    }
}

final class CourseInfoPurchaseModalView: UIView {
    weak var delegate: CourseInfoPurchaseModalViewDelegate?

    let appearance: Appearance

    private lazy var headerView = CourseInfoPurchaseModalHeaderView()

    private lazy var coverView = CourseInfoPurchaseModalCourseCoverView()

    private lazy var promoCodeView = CourseInfoPurchaseModalPromoCodeView()

    private lazy var disclaimerView = CourseInfoPurchaseModalDisclaimerView()

    private lazy var actionButtonsView = CourseInfoPurchaseModalActionButtonsView()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.spacing = self.appearance.stackViewSpacing
        return scrollableStackView
    }()

    var contentInsets: UIEdgeInsets {
        get {
            self.scrollableStackView.contentInsets
        }
        set {
            self.scrollableStackView.contentInsets = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        let contentSize = self.scrollableStackView.contentSize
        let height = contentSize.height + self.appearance.stackViewSpacing

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

    func configure(viewModel: CourseInfoPurchaseModalViewModel) {
        self.coverView.coverURL = viewModel.courseCoverImageURL
        self.coverView.titleText = viewModel.courseTitle
    }
}

extension CourseInfoPurchaseModalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.headerView.onCloseClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickCloseButton(strongSelf)
        }

        self.promoCodeView.onInputReveal = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.invalidateIntrinsicContentSize()
            strongSelf.delegate?.courseInfoPurchaseModalViewDidRevealPromoCodeInput(strongSelf)
        }

        self.disclaimerView.onLinkClick = { [weak self] link in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalView(strongSelf, didClickLink: link)
        }

        self.actionButtonsView.onBuyButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickBuyButton(strongSelf)
        }
        self.actionButtonsView.onWishlistButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoPurchaseModalViewDidClickWishlistButton(strongSelf)
        }
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.loadingIndicator)

        self.scrollableStackView.addArrangedView(self.headerView)
        self.scrollableStackView.addArrangedView(self.coverView)
        self.scrollableStackView.addArrangedView(self.promoCodeView)
        self.scrollableStackView.addArrangedView(self.disclaimerView)
        self.scrollableStackView.addArrangedView(self.actionButtonsView)
    }

    func makeConstraints() {
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

// MARK: - CourseInfoPurchaseModalView: PanModalScrollable -

extension CourseInfoPurchaseModalView: PanModalScrollable {
    var panScrollable: UIScrollView? { self.scrollableStackView.panScrollable }
}
