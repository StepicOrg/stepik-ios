import SnapKit
import UIKit

extension CourseWidgetView {
    struct Appearance {
        let coverViewInsets = LayoutInsets(top: 16, left: 16)
        let coverViewWidthHeight: CGFloat = 80.0

        let titleLabelInsets = LayoutInsets(left: 8, right: 16)

        let statsViewHeight: CGFloat = 17
        let statsViewInsets = LayoutInsets(top: 8)

        let summaryLabelInsets = LayoutInsets(top: 12, left: 16, bottom: 16, right: 16)

        let continueLearningButtonInsets = LayoutInsets(top: 16)

        let separatorHeight: CGFloat = 0.5
    }
}

final class CourseWidgetView: UIView {
    let appearance: Appearance
    let colorMode: CourseListColorMode

    private lazy var coverView = CourseWidgetCoverView()

    private lazy var titleLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetTitleLabelAppearance
    )
    private lazy var statsView = CourseWidgetStatsView(
        appearance: self.colorMode.courseWidgetStatsViewAppearance
    )

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.colorMode.courseWidgetBorderColor
        return view
    }()

    private lazy var summaryLabel = CourseWidgetLabel(
        appearance: self.colorMode.courseWidgetSummaryLabelAppearance
    )

    private lazy var continueLearningButton: CourseWidgetContinueLearningButton = {
        let button = CourseWidgetContinueLearningButton(
            appearance: self.colorMode.courseWidgetContinueLearningButtonAppearance
        )
        button.addTarget(self, action: #selector(self.continueLearningButtonClicked), for: .touchUpInside)
        return button
    }()

    var onContinueLearningButtonClick: (() -> Void)?

    init(
        frame: CGRect = .zero,
        colorMode: CourseListColorMode = .default,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.colorMode = colorMode
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: CourseWidgetViewModel) {
        self.titleLabel.text = viewModel.title
        self.coverView.coverImageURL = viewModel.coverImageURL
        self.coverView.shouldShowAdaptiveMark = viewModel.isAdaptive

        self.summaryLabel.text = viewModel.summary
        self.summaryLabel.isHidden = viewModel.isEnrolled
        self.separatorView.isHidden = !viewModel.isEnrolled
        self.continueLearningButton.isHidden = !viewModel.isEnrolled

        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.ratingLabelText = viewModel.ratingLabelText
        self.statsView.progress = viewModel.progress
    }

    func updateProgress(viewModel: CourseWidgetProgressViewModel) {
        self.statsView.progress = viewModel
    }

    // MARK: Private API

    @objc
    private func continueLearningButtonClicked() {
        self.onContinueLearningButtonClick?()
    }
}

extension CourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.statsView)
        self.addSubview(self.summaryLabel)
        self.addSubview(self.continueLearningButton)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.coverViewInsets.left)
            make.height
                .width
                .equalTo(self.appearance.coverViewWidthHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.top)
            make.leading
                .equalTo(self.coverView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.titleLabelInsets.right)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsViewInsets.top)
                .priority(.low)
            make.leading
                .equalTo(self.titleLabel.snp.leading)
            make.bottom
                .lessThanOrEqualTo(self.coverView.snp.bottom)
            make.trailing
                .equalTo(self.titleLabel.snp.trailing)
            make.height
                .equalTo(self.appearance.statsViewHeight)
        }

        self.summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.summaryLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.summaryLabelInsets.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.summaryLabelInsets.left)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.bottom)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.summaryLabelInsets.right)
        }

        self.continueLearningButton.translatesAutoresizingMaskIntoConstraints = false
        self.continueLearningButton.snp.makeConstraints { make in
            make.top
                .equalTo(self.coverView.snp.bottom)
                .offset(self.appearance.continueLearningButtonInsets.top)
            make.leading
                .bottom
                .trailing
                .equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading
                .trailing
                .equalToSuperview()
            make.bottom
                .equalTo(self.continueLearningButton.snp.top)
            make.height
                .equalTo(self.appearance.separatorHeight)
        }
    }
}
