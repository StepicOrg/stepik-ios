import SnapKit
import UIKit

extension CourseWidgetStatsView {
    struct Appearance {
        let statItemsSpacing: CGFloat = 8
        let leftInset: CGFloat = 2.0

        let learnersViewImageViewSize = CGSize(width: 8, height: 10)
        let ratingViewImageViewSize = CGSize(width: 8, height: 12)
        let certificatesViewImageViewSize = CGSize(width: 12, height: 12)
        let archiveViewImageViewSize = CGSize(width: 14, height: 13)
        let progressViewImageViewSize = CGSize(width: 12, height: 12)

        let imagesRenderingSize = CGSize(width: 30, height: 30)
        let imagesRenderingLineWidth: CGFloat = 6.0
        var imagesRenderingBackgroundColor = UIColor.stepikAccent
        var imagesRenderingTintColor = UIColor.stepikGreenFixed

        var itemTextColor = UIColor.white
        var itemImageTintColor = UIColor.white
    }
}

final class CourseWidgetStatsView: UIView {
    let appearance: Appearance

    var learnersLabelText: String? {
        didSet {
            self.learnersView.isHidden = self.learnersLabelText?.isEmpty ?? true
            self.learnersView.text = self.learnersLabelText
        }
    }

    var certificatesLabelText: String? {
        didSet {
            self.certificatesView.isHidden = self.certificatesLabelText?.isEmpty ?? true
            self.certificatesView.text = self.certificatesLabelText
        }
    }

    var ratingLabelText: String? {
        didSet {
            self.ratingView.isHidden = self.ratingLabelText?.isEmpty ?? true
            self.ratingView.text = self.ratingLabelText
        }
    }

    var isArchived = false {
        didSet {
            self.archiveView.isHidden = !self.isArchived
        }
    }

    var progress: CourseWidgetProgressViewModel? {
        didSet {
            guard let progress = self.progress else {
                self.progressView.isHidden = true
                return
            }

            self.updateProgress(viewModel: progress)
        }
    }

    private lazy var learnersView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.learnersViewImageViewSize
        appearance.imageTintColor = self.appearance.itemImageTintColor
        appearance.textColor = self.appearance.itemTextColor
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-user")?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var certificatesView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.certificatesViewImageViewSize
        appearance.imageTintColor = self.appearance.itemImageTintColor
        appearance.textColor = self.appearance.itemTextColor
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-certificate")?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var archiveView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.archiveViewImageViewSize
        appearance.imageTintColor = self.appearance.itemImageTintColor
        appearance.textColor = self.appearance.itemTextColor
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-archive")?.withRenderingMode(.alwaysTemplate)
        view.text = NSLocalizedString("CourseWidgetArchived", comment: "")
        return view
    }()

    private lazy var ratingView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.ratingViewImageViewSize
        appearance.imageTintColor = self.appearance.itemImageTintColor
        appearance.textColor = self.appearance.itemTextColor
        let view = CourseWidgetStatsItemView(appearance: appearance)
        view.image = UIImage(named: "course-widget-rating")?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var progressView: CourseWidgetStatsItemView = {
        var appearance = CourseWidgetStatsItemView.Appearance()
        appearance.imageViewSize = self.appearance.progressViewImageViewSize
        appearance.imageTintColor = .clear
        appearance.textColor = self.appearance.itemTextColor
        let view = CourseWidgetStatsItemView(appearance: appearance)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.statItemsSpacing
        return stackView
    }()

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

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        let progressPie = ProgressCircleImage(
            progress: viewModel.progress,
            size: self.appearance.imagesRenderingSize,
            lineWidth: self.appearance.imagesRenderingLineWidth,
            backgroundColor: self.appearance.imagesRenderingBackgroundColor,
            progressColor: self.appearance.imagesRenderingTintColor
        )

        if let pieImage = progressPie.uiImage {
            self.progressView.image = pieImage
            self.progressView.text = viewModel.progressLabelText
            self.progressView.isHidden = false
        }
    }
}

extension CourseWidgetStatsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.archiveView.isHidden = true
        self.ratingView.isHidden = false
        self.progressView.isHidden = false
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.learnersView)
        self.stackView.addArrangedSubview(self.ratingView)
        self.stackView.addArrangedSubview(self.certificatesView)
        self.stackView.addArrangedSubview(self.archiveView)
        self.stackView.addArrangedSubview(self.progressView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leftInset).priority(999)
            make.centerY.equalToSuperview().priority(999)
            make.top.bottom.greaterThanOrEqualToSuperview().priority(999)
            make.trailing.lessThanOrEqualToSuperview().priority(999)
        }
    }
}
