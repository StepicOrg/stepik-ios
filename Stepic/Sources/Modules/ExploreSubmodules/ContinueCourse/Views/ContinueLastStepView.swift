import SnapKit
import UIKit

extension ContinueLastStepView {
    struct Appearance {
        let primaryColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikSystemPrimaryText)
        let backgroundColor = UIColor.stepikSecondaryBackground
        let defaultInsets = LayoutInsets.default

        let coverCornerRadius: CGFloat = 8
        let coverSize = CGSize(width: 40, height: 40)

        let courseLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let courseLabelInsets = LayoutInsets(left: 8, right: 8)

        let statsViewHeight: CGFloat = 17
        let progressFillColor = UIColor.stepikGreenFixed
        let progressLabelTextColor = UIColor.white

        let rightDetailImageSize = CGSize(width: 20, height: 30)
    }
}

final class ContinueLastStepView: UIControl {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverCornerRadius
        return view
    }()

    private lazy var courseNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.primaryColor
        label.font = self.appearance.courseLabelFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var statsView: CourseWidgetStatsView = {
        let appearance = CourseWidgetStatsView.Appearance(
            leftInset: 0,
            imagesRenderingBackgroundColor: self.appearance.primaryColor,
            imagesRenderingTintColor: self.appearance.progressFillColor,
            itemTextColor: self.appearance.primaryColor,
            itemImageTintColor: self.appearance.primaryColor
        )
        let view = CourseWidgetStatsView(appearance: appearance)
        view.hideAllItems()
        return view
    }()

    private lazy var rightDetailImageView: UIImageView = {
        let image = UIImage(named: "continue_learning_arrow_right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.primaryColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "continue_learning_gradient"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var courseTitle: String? {
        didSet {
            self.courseNameLabel.text = self.courseTitle
        }
    }

    var progressText: String? {
        didSet {
            self.updateProgress()
        }
    }

    var progress: Float = 0 {
        didSet {
            self.updateProgress()
        }
    }

    var coverImageURL: URL? {
        didSet {
            self.coverImageView.loadImage(url: self.coverImageURL)
        }
    }

    var tooltipAnchorView: UIView { self.rightDetailImageView }

    private var contentViews: [UIView] {
        [
            self.coverImageView,
            self.courseNameLabel,
            self.statsView,
            self.rightDetailImageView
        ]
    }

    override var isHighlighted: Bool {
        didSet {
            self.contentViews.forEach { $0.alpha = self.isHighlighted ? 0.5 : 1.0 }
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateBackground()
        }
    }

    func setContentHidden(_ isHidden: Bool) {
        self.contentViews.forEach { $0.isHidden = isHidden }
    }

    private func updateBackground() {
        self.backgroundColor = self.appearance.backgroundColor
        self.backgroundImageView.isHidden = self.isDarkInterfaceStyle
    }

    private func updateProgress() {
        self.statsView.updateProgress(
            viewModel: .init(progress: self.progress, progressLabelText: self.progressText ?? "")
        )
    }
}

extension ContinueLastStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateBackground()
    }

    func addSubviews() {
        self.addSubviews([
            self.backgroundImageView,
            self.coverImageView,
            self.courseNameLabel,
            self.statsView,
            self.rightDetailImageView
        ])
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.leading
                .equalTo(self.safeAreaLayoutGuide.snp.leading)
                .offset(self.appearance.defaultInsets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.coverSize)
        }

        self.rightDetailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailImageView.snp.makeConstraints { make in
            make.trailing
                .equalTo(self.safeAreaLayoutGuide.snp.trailing)
                .offset(-self.appearance.defaultInsets.right)
            make.centerY.equalTo(self.coverImageView.snp.centerY)
            make.size.equalTo(self.appearance.rightDetailImageSize)
        }

        self.courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.courseNameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImageView.snp.top)
            make.leading
                .equalTo(self.coverImageView.snp.trailing)
                .offset(self.appearance.courseLabelInsets.left)
            make.trailing
                .equalTo(self.rightDetailImageView.snp.leading)
                .offset(-self.appearance.courseLabelInsets.right)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.leading.equalTo(self.courseNameLabel.snp.leading)
            make.bottom.equalTo(self.coverImageView.snp.bottom)
            make.trailing.equalTo(self.courseNameLabel.snp.trailing)
            make.height.equalTo(self.appearance.statsViewHeight)
        }
    }
}
