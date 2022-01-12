import SnapKit
import UIKit

extension NewExploreBlockPlaceholderView {
    struct Appearance {
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 12, right: 20)
    }
}

final class NewExploreBlockPlaceholderView: UIView {
    let appearance: Appearance
    private let placeholderStyle: PlaceholderStyle

    private lazy var placeholderView: ExplorePlaceholderView = {
        let view = ExplorePlaceholderView(appearance: self.placeholderStyle.appearance)
        view.title = self.placeholderStyle.title
        view.buttonTitle = self.placeholderStyle.actionButtonTitle
        view.buttonImage = self.placeholderStyle.actionButtonImage
        return view
    }()

    var onActionButtonClick: (() -> Void)? {
        get {
            self.placeholderView.onActionButtonClick
        }
        set {
            self.placeholderView.onActionButtonClick = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.insets.top
            + self.placeholderView.intrinsicContentSize.height
            + self.appearance.insets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        placeholderStyle: PlaceholderStyle,
        appearance: Appearance = Appearance()
    ) {
        self.placeholderStyle = placeholderStyle
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    enum PlaceholderStyle {
        case enrolledEmpty
        case error
        case anonymous

        fileprivate var title: String {
            switch self {
            case .enrolledEmpty:
                return NSLocalizedString("NewHomePlaceholderEmptyEnrolledTitle", comment: "")
            case .error:
                return NSLocalizedString("NewHomePlaceholderErrorTitle", comment: "")
            case .anonymous:
                return NSLocalizedString("NewHomePlaceholderAnonymousTitle", comment: "")
            }
        }

        fileprivate var actionButtonTitle: String {
            switch self {
            case .enrolledEmpty:
                return NSLocalizedString("NewHomePlaceholderEmptyEnrolledButtonTitle", comment: "")
            case .error:
                return NSLocalizedString("NewHomePlaceholderErrorButtonTitle", comment: "")
            case .anonymous:
                return NSLocalizedString("NewHomePlaceholderAnonymousButtonTitle", comment: "")
            }
        }

        fileprivate var actionButtonImage: UIImage? {
            switch self {
            case .enrolledEmpty:
                return UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
            case .error, .anonymous:
                return nil
            }
        }

        fileprivate var appearance: ExplorePlaceholderView.Appearance {
            switch self {
            case .enrolledEmpty:
                return .init(
                    titleFont: Typography.title1Font,
                    titleTextColor: UIColor.stepikVioletFixed.withAlphaComponent(0.38),
                    titleTextAlignment: .left
                )
            case .error, .anonymous:
                return .init(
                    titleFont: Typography.bodyFont,
                    titleTextColor: UIColor.stepikMaterialSecondaryText,
                    titleTextAlignment: .center
                )
            }
        }
    }
}

extension NewExploreBlockPlaceholderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.placeholderView)
    }

    func makeConstraints() {
        self.placeholderView.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }
    }
}
