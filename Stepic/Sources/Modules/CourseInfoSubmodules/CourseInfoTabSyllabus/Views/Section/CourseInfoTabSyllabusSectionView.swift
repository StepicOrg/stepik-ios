import SnapKit
import UIKit

extension CourseInfoTabSyllabusSectionView {
    struct Appearance {
        let backgroundColor = UIColor.stepikLightSecondaryBackground

        let indexTextColor = UIColor.stepikMaterialSecondaryText
        let indexFont = Typography.title3Font
        let indexLabelInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 12)
        // Width for two-digit indexes
        let indexLabelWidth: CGFloat = 25

        let badgesViewHeight: CGFloat = 21

        let examActionButtonHeight: CGFloat = 44

        let textStackViewSpacing: CGFloat = 10
        let textStackViewInsets = UIEdgeInsets(top: 19, left: 12, bottom: 0, right: 15)

        let titleTextColor = UIColor.stepikMaterialPrimaryText
        let titleFont = Typography.subheadlineFont

        let progressTextColor = UIColor.stepikMaterialSecondaryText
        let progressTextFont = Typography.caption1Font

        let requirementsTextColor = UIColor.stepikMaterialSecondaryText
        let requirementsTextFont = Typography.caption1Font

        let downloadButtonInsets = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 16)
        let downloadButtonSize = CGSize(width: 22, height: 22)
        let downloadButtonCenterYOffsetOnCachedState: CGFloat = 9

        let downloadedSizeLabelFont = Typography.caption1Font
        let downloadedSizeLabelTextColor = UIColor.stepikMaterialSecondaryText
        let downloadedSizeLabelInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 16)

        let deadlinesInsets = UIEdgeInsets(top: 16, left: 0, bottom: 19, right: 0)

        let progressViewHeight: CGFloat = 3
        let progressViewMainColor = UIColor.stepikGreenFixed
        let progressViewSecondaryColor = UIColor.clear

        let tapProxyViewSize = CGSize(width: 60, height: 60)

        let enabledStateAlpha: CGFloat = 1.0
        let disabledStateAlpha: CGFloat = 0.5
    }
}

final class CourseInfoTabSyllabusSectionView: UIView {
    let appearance: Appearance

    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.indexFont
        label.textAlignment = .center
        label.textColor = self.appearance.indexTextColor
        return label
    }()

    private lazy var badgesView = CourseInfoTabSyllabusSectionBadgesView()

    private lazy var badgesContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.isHidden = true
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.progressTextFont
        label.textColor = self.appearance.progressTextColor
        return label
    }()

    private lazy var requirementsLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.requirementsTextFont
        label.textColor = self.appearance.requirementsTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var examActionButton: CourseInfoTabSyllabusSectionExamActionButton = {
        let button = CourseInfoTabSyllabusSectionExamActionButton()
        button.addTarget(self, action: #selector(self.examButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var downloadButtonTapProxyView = TapProxyView(targetView: self.downloadButton)

    private lazy var downloadButton: DownloadControlView = {
        let view = DownloadControlView(initialState: .readyToDownloading)
        view.isHidden = true
        view.addTarget(self, action: #selector(self.downloadButtonClicked), for: .touchUpInside)
        return view
    }()

    private lazy var downloadedSizeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.downloadedSizeLabelFont
        label.textColor = self.appearance.downloadedSizeLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.textStackViewSpacing
        return stackView
    }()

    private lazy var progressIndicatorView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = self.appearance.progressViewSecondaryColor
        view.progressTintColor = self.appearance.progressViewMainColor
        view.transform = CGAffineTransform(rotationAngle: .pi / -2)
        return view
    }()

    // To use rotated view w/ auto-layout
    private lazy var progressIndicatorViewContainerView = UIView()

    private lazy var deadlinesView: CourseInfoTabSyllabusSectionDeadlinesView = {
        let appearance = CourseInfoTabSyllabusSectionDeadlinesView.Appearance(
            verticalHorizontalOffset: self.appearance.indexLabelInsets.left
                + self.appearance.indexLabelWidth
                + self.appearance.textStackViewInsets.left
        )
        let view = CourseInfoTabSyllabusSectionDeadlinesView(appearance: appearance)
        return view
    }()

    // To properly center index label
    private var indexLabelCenterYBadgesConstraint: Constraint?
    private var indexLabelCenterYTitleConstraint: Constraint?

    private var textStackViewTrailingToDownloadButtonLeadingConstraint: Constraint?
    private var textStackViewTrailingToSuperviewConstraint: Constraint?

    // To properly center when downloaded size visible
    private var downloadButtonCenterYConstraint: Constraint?

    var onExamButtonClick: (() -> Void)?
    var onDownloadButtonClick: (() -> Void)?

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

    func configure(viewModel: CourseInfoTabSyllabusSectionViewModel) {
        self.titleLabel.text = viewModel.title
        self.indexLabel.text = viewModel.index
        self.requirementsLabel.text = viewModel.requirementsLabelText
        self.progressLabel.text = viewModel.progressLabelText
        self.progressIndicatorView.progress = viewModel.progress

        self.progressLabel.isHidden = viewModel.progressLabelText == nil
        self.requirementsLabel.isHidden = viewModel.requirementsLabelText == nil

        self.updateBadges(viewModel: viewModel)
        self.updateExamActionButton(viewModel: viewModel.exam)
        self.updateDownloadState(newState: viewModel.downloadState)
        self.updateEnabledAppearance(isEnabled: !viewModel.isDisabled)

        if let deadlines = viewModel.deadlines {
            self.deadlinesView.isHidden = false
            self.deadlinesView.snp.makeConstraints { make in
                make.top
                    .greaterThanOrEqualTo(self.downloadButton.snp.bottom)
                    .offset(self.appearance.deadlinesInsets.top)
                make.top
                    .greaterThanOrEqualTo(self.textStackView.snp.bottom)
                    .offset(self.appearance.deadlinesInsets.top)
            }

            self.deadlinesView.configure(
                items: deadlines.timelineItems.map { item in
                    .init(text: item.title, progressBefore: item.lineFillingProgress, isCompleted: item.isPointFilled)
                }
            )
        } else {
            self.deadlinesView.isHidden = true
            self.textStackView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-self.appearance.deadlinesInsets.bottom).priority(.medium)
            }
        }
    }

    func updateDownloadState(newState: CourseInfoTabSyllabus.DownloadState) {
        var downloadedBytesTotal: UInt64?

        switch newState {
        case .notAvailable:
            self.downloadButton.isHidden = true
        case .cached(let bytesTotal, let hasUnitWithCachedVideosOrImages):
            if hasUnitWithCachedVideosOrImages {
                self.downloadButton.isHidden = false
                self.downloadButton.actionState = .readyToRemoving
                downloadedBytesTotal = bytesTotal
            } else {
                self.downloadButton.isHidden = true
            }
        case .notCached:
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .readyToDownloading
        case .waiting:
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .pending
        case .downloading(let progress):
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .downloading(progress: progress)
        }

        if self.downloadButton.isHidden {
            self.textStackViewTrailingToDownloadButtonLeadingConstraint?.deactivate()
            self.textStackViewTrailingToSuperviewConstraint?.activate()
        } else {
            self.textStackViewTrailingToSuperviewConstraint?.deactivate()
            self.textStackViewTrailingToDownloadButtonLeadingConstraint?.activate()
        }

        if let downloadedBytesTotal = downloadedBytesTotal {
            self.downloadedSizeLabel.text = FormatterHelper.megabytesInBytes(downloadedBytesTotal)
            self.downloadedSizeLabel.isHidden = false
            self.downloadButtonCenterYConstraint?.update(
                offset: -self.appearance.downloadButtonCenterYOffsetOnCachedState
            )
        } else {
            self.downloadedSizeLabel.text = nil
            self.downloadedSizeLabel.isHidden = true
            self.downloadButtonCenterYConstraint?.update(offset: 0)
        }
    }

    private func updateBadges(viewModel: CourseInfoTabSyllabusSectionViewModel) {
        self.badgesView.configure(viewModel: viewModel)

        if self.badgesView.isEmpty {
            self.badgesContainerStackView.isHidden = true

            self.indexLabelCenterYBadgesConstraint?.deactivate()
            self.indexLabelCenterYTitleConstraint?.activate()
        } else {
            self.badgesContainerStackView.isHidden = false

            self.indexLabelCenterYTitleConstraint?.deactivate()
            self.indexLabelCenterYBadgesConstraint?.activate()
        }
    }

    private func updateExamActionButton(viewModel: CourseInfoTabSyllabusSectionViewModel.ExamViewModel?) {
        if let viewModel = viewModel {
            let title: String? = {
                switch viewModel.state {
                case .canStart:
                    return NSLocalizedString("SyllabusExamStartInWeb", comment: "")
                case .inProgress:
                    return NSLocalizedString("SyllabusExamContinueInWeb", comment: "")
                case .canNotStart, .finished:
                    return nil
                }
            }()

            self.examActionButton.setTitle(title, for: .normal)
            self.examActionButton.isHidden = title == nil
        } else {
            self.examActionButton.isHidden = true
        }
    }

    private func updateEnabledAppearance(isEnabled: Bool) {
        // Not dims the requirements label, to make section requirements visible
        let alpha = isEnabled
            ? self.appearance.enabledStateAlpha
            : self.appearance.disabledStateAlpha
        [
            self.indexLabel,
            self.titleLabel,
            self.progressLabel,
            self.downloadButton,
            self.downloadedSizeLabel,
            self.deadlinesView,
            self.progressIndicatorViewContainerView
        ].forEach { $0.alpha = alpha }
    }

    @objc
    private func downloadButtonClicked() {
        self.onDownloadButtonClick?()
    }

    @objc
    private func examButtonClicked() {
        self.onExamButtonClick?()
    }
}

extension CourseInfoTabSyllabusSectionView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.indexLabel)

        self.badgesContainerStackView.addArrangedSubview(self.badgesView)
        self.textStackView.addArrangedSubview(self.badgesContainerStackView)
        self.textStackView.addArrangedSubview(self.titleLabel)
        self.textStackView.addArrangedSubview(self.progressLabel)
        self.textStackView.addArrangedSubview(self.requirementsLabel)
        self.textStackView.addArrangedSubview(self.examActionButton)
        self.addSubview(self.textStackView)

        self.addSubview(self.downloadButtonTapProxyView)
        self.addSubview(self.downloadButton)
        self.addSubview(self.downloadedSizeLabel)
        self.addSubview(self.deadlinesView)

        self.addSubview(self.progressIndicatorViewContainerView)
        self.progressIndicatorViewContainerView.addSubview(self.progressIndicatorView)
    }

    func makeConstraints() {
        self.progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorView.snp.makeConstraints { make in
            make.width.equalTo(self.progressIndicatorViewContainerView.snp.height)
            make.height.equalTo(self.appearance.progressViewHeight)
            make.centerY.centerX.equalToSuperview()
        }

        self.progressIndicatorViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.progressIndicatorViewContainerView.snp.makeConstraints { make in
            make.leading.height.bottom.equalToSuperview()
            make.width.equalTo(self.progressIndicatorView.snp.height)
        }

        self.indexLabel.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.indexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.indexLabelInsets.left)
            make.width.equalTo(self.appearance.indexLabelWidth)

            self.indexLabelCenterYTitleConstraint = make.centerY.equalTo(self.titleLabel.snp.centerY).constraint

            self.indexLabelCenterYBadgesConstraint = make.centerY.equalTo(self.badgesView.snp.centerY).constraint
            self.indexLabelCenterYBadgesConstraint?.deactivate()
        }

        self.badgesContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.badgesContainerStackView.snp.makeConstraints { $0.height.equalTo(self.appearance.badgesViewHeight) }

        self.examActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.examActionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.examActionButtonHeight) }

        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.downloadButtonSize)
            make.trailing.equalToSuperview().offset(-self.appearance.downloadButtonInsets.right)
            self.downloadButtonCenterYConstraint = make.centerY.equalTo(self.textStackView.snp.centerY).constraint
        }

        self.downloadedSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.downloadedSizeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadedSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.downloadButton.snp.bottom).offset(self.appearance.downloadedSizeLabelInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.downloadedSizeLabelInsets.right)
        }

        self.downloadButtonTapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButtonTapProxyView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.tapProxyViewSize)
            make.center.equalTo(self.downloadButton.snp.center)
        }

        self.textStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.textStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.textStackViewInsets.top)
            make.leading.equalTo(self.indexLabel.snp.trailing).offset(self.appearance.textStackViewInsets.left)

            self.textStackViewTrailingToDownloadButtonLeadingConstraint = make
                .trailing
                .equalTo(self.downloadButton.snp.leading)
                .offset(-self.appearance.textStackViewInsets.right)
                .constraint

            self.textStackViewTrailingToSuperviewConstraint = make
                .trailing
                .equalToSuperview()
                .offset(-self.appearance.textStackViewInsets.right)
                .constraint
            self.textStackViewTrailingToSuperviewConstraint?.deactivate()
        }

        self.deadlinesView.translatesAutoresizingMaskIntoConstraints = false
        self.deadlinesView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.deadlinesInsets.bottom).priority(.medium)
        }
    }
}
