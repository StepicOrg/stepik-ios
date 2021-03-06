import UIKit

extension DefaultSimpleCourseListCollectionViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 13.0
    }
}

final class DefaultSimpleCourseListCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var widgetView = DefaultSimpleCourseListWidgetView()

    override var isHighlighted: Bool {
        didSet {
            self.widgetView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: SimpleCourseListWidgetViewModel, colorMode: ColorMode) {
        self.widgetView.configure(viewModel: viewModel)

        self.widgetView.titleLabelTextColor = colorMode.textColor
        self.widgetView.subtitleLabelTextColor = colorMode.textColor
        self.widgetView.backgroundColor = colorMode.backgroundColor
    }

    enum ColorMode: Int, CaseIterable {
        case green
        case blue
        case violet

        fileprivate var textColor: UIColor {
            switch self {
            case .green:
                return .stepikGreen
            case .blue:
                return UIColor(hex6: 0x2F80ED)
            case .violet:
                return .stepikVioletFixed
            }
        }

        fileprivate var backgroundColor: UIColor {
            self.textColor.withAlphaComponent(0.12)
        }
    }
}

extension DefaultSimpleCourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.widgetView)
    }

    func makeConstraints() {
        self.widgetView.translatesAutoresizingMaskIntoConstraints = false
        self.widgetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
