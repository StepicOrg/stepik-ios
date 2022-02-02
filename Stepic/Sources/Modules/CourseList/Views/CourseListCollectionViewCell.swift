import UIKit

protocol CourseListCollectionViewCellDelegate: AnyObject {
    func widgetPrimaryButtonClicked(viewModel: CourseWidgetViewModel?)
}

extension CourseListCollectionViewCell {
    enum Appearance {
        static let cornerRadius: CGFloat = 13.0

        static let shadowColor = UIColor.black
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 4.0
        static let shadowOpacity: Float = 0.1
    }
}

class CourseListCollectionViewCell: UICollectionViewCell, Reusable {
    weak var delegate: CourseListCollectionViewCellDelegate?

    private let colorMode: CourseListColorMode
    private let cardStyle: CourseListCardStyle
    private var configurationViewModel: CourseWidgetViewModel?

    private lazy var widgetView: CourseWidgetViewProtocol = {
        switch self.cardStyle {
        case .small:
            return SmallCourseWidgetView(colorMode: self.colorMode)
        case .normal:
            let widget = CourseWidgetView(colorMode: self.colorMode)
            // Pass clicks from widget view to collection view delegate
            widget.onContinueLearningButtonClick = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.delegate?.widgetPrimaryButtonClicked(
                    viewModel: strongSelf.configurationViewModel
                )
            }
            return widget
        }
    }()

    override init(frame: CGRect) {
        self.colorMode = .default
        self.cardStyle = .default
        super.init(frame: frame)
    }

    init(frame: CGRect, colorMode: CourseListColorMode, cardStyle: CourseListCardStyle) {
        self.colorMode = colorMode
        self.cardStyle = cardStyle
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.widgetView.layer.cornerRadius = Appearance.cornerRadius
        self.widgetView.layer.masksToBounds = true

        self.layer.shadowColor = Appearance.shadowColor.cgColor
        self.layer.shadowOffset = Appearance.shadowOffset
        self.layer.shadowRadius = Appearance.shadowRadius
        self.layer.shadowOpacity = Appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.contentView.layer.cornerRadius
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.widgetView.prepareForReuse()
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.widgetView.configure(viewModel: viewModel)
        self.configurationViewModel = viewModel
    }
}

extension CourseListCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
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
