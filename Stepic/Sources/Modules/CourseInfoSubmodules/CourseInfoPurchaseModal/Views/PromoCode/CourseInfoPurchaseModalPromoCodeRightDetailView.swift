import SnapKit
import UIKit

extension CourseInfoPurchaseModalPromoCodeRightDetailView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 18, height: 22)

        let cornerRadius: CGFloat = 8
    }
}

final class CourseInfoPurchaseModalPromoCodeRightDetailView: UIControl {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }()

    var viewState = ViewState.idle {
        didSet {
            self.updateViewState()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
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

        self.updateViewState()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateBorder()
        }
    }

    private func updateViewState() {
        self.backgroundColor = self.viewState.backgroundColor
        self.updateBorder()

        let isLoadingActivityIndicatorVisible = self.viewState == .loading

        self.iconImageView.image = self.viewState.iconImage
        self.iconImageView.tintColor = self.viewState.tintColor
        self.iconImageView.isHidden = isLoadingActivityIndicatorVisible

        if isLoadingActivityIndicatorVisible {
            self.loadingActivityIndicator.startAnimating()
        } else {
            self.loadingActivityIndicator.stopAnimating()
        }
        self.loadingActivityIndicator.isHidden = !isLoadingActivityIndicatorVisible
        self.loadingActivityIndicator.color = self.viewState.tintColor
    }

    private func updateBorder() {
        self.layer.borderWidth = self.viewState.borderWidth
        self.layer.borderColor = self.viewState.borderColor?.cgColor
    }

    enum ViewState {
        case idle
        case loading
        case error
        case success

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .idle:
                return .stepikGreenFixed
            case .loading:
                return .clear
            case .error:
                return .stepikDiscountPriceText.withAlphaComponent(0.12)
            case .success:
                return .stepikGreenFixed.withAlphaComponent(0.12)
            }
        }

        fileprivate var borderWidth: CGFloat {
            switch self {
            case .idle, .error, .success:
                return 0
            case .loading:
                return 1
            }
        }

        fileprivate var borderColor: UIColor? {
            switch self {
            case .idle, .error, .success:
                return nil
            case .loading:
                return .stepikVioletFixed
            }
        }

        fileprivate var iconImage: UIImage? {
            let imageName: String

            switch self {
            case .idle:
                imageName = "arrow.right"
            case .loading:
                return nil
            case .error:
                imageName = "quiz-mark-wrong"
            case .success:
                imageName = "quiz-mark-correct"
            }

            return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        }

        fileprivate var tintColor: UIColor {
            switch self {
            case .idle:
                return .white
            case .loading:
                return .stepikVioletFixed
            case .error:
                return .stepikDiscountPriceText
            case .success:
                return .stepikGreenFixed
            }
        }
    }
}

extension CourseInfoPurchaseModalPromoCodeRightDetailView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.loadingActivityIndicator)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.appearance.iconImageViewSize)
        }

        self.loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingActivityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
