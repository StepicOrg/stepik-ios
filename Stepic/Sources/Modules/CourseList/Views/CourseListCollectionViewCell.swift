import UIKit

protocol CourseListCollectionViewCellDelegate: AnyObject {
    func widgetPrimaryButtonClicked(viewModel: CourseWidgetViewModel?)
}

extension CourseListCollectionViewCell {
    enum Appearance {
        static let borderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 13.0
    }
}

class CourseListCollectionViewCell: UICollectionViewCell, Reusable {
    weak var delegate: CourseListCollectionViewCellDelegate?

    private let colorMode: CourseListColorMode
    private var configurationViewModel: CourseWidgetViewModel?

    private lazy var widgetView: CourseWidgetView = {
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
    }()

    override init(frame: CGRect) {
        self.colorMode = .default
        super.init(frame: frame)
    }

    init(frame: CGRect, colorMode: CourseListColorMode) {
        self.colorMode = colorMode
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

        self.layer.cornerRadius = Appearance.cornerRadius
        self.layer.borderWidth = Appearance.borderWidth
        self.layer.borderColor = self.colorMode.courseWidgetBorderColor.cgColor
        self.layer.masksToBounds = true
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
