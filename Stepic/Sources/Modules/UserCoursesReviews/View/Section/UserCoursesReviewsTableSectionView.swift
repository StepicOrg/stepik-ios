import SnapKit
import UIKit

extension UserCoursesReviewsTableSectionView {
    struct Appearance {
        let titleFont = Typography.caption1Font
        let titleInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
}

final class UserCoursesReviewsTableSectionView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    var style: Style = .normal {
        didSet {
            self.titleLabel.textColor = self.style.textColor
            self.backgroundColor = self.style.backgroundColor
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    enum Style {
        case normal
        case accent

        fileprivate var textColor: UIColor {
            switch self {
            case .normal:
                return .stepikMaterialSecondaryText
            case .accent:
                return .stepikVioletFixed
            }
        }

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .normal:
                return UIColor.dynamic(
                    light: UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1),
                    dark: .stepikSecondaryBackground
                )
            case .accent:
                return UIColor.dynamic(
                    light: UIColor(red: 237 / 255, green: 239 / 255, blue: 250 / 255, alpha: 1),
                    dark: .stepikSecondaryBackground
                )
            }
        }
    }
}

extension UserCoursesReviewsTableSectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.style = .normal
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(self.appearance.titleInsets) }
    }
}
