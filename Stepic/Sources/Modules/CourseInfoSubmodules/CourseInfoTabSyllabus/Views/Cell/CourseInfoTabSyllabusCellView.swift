import SnapKit
import UIKit

extension CourseInfoTabSyllabusCellView {
    struct Appearance {
        let coverImageViewCornerRadius: CGFloat = 4
        let coverImageViewInsets = UIEdgeInsets(top: 20, left: 23, bottom: 20, right: 0)
        let coverImageViewSize = CGSize(width: 30, height: 30)

        let titleTextColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleLabelInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 8)

        let downloadButtonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        let downloadButtonSize = CGSize(width: 22, height: 22)

        let statsInsets = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        let statsViewHeight: CGFloat = 17.0

        let progressViewHeight: CGFloat = 3
        let progressViewMainColor = UIColor.stepicGreen
        let progressViewSecondaryColor = UIColor.clear

        let tapProxyViewSize = CGSize(width: 60, height: 60)

        let enabledStateAlpha: CGFloat = 1.0
        let disabledStateAlpha: CGFloat = 0.5
    }
}

final class CourseInfoTabSyllabusCellView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var downloadButtonTapProxyView = TapProxyView(targetView: self.downloadButton)

    private lazy var downloadButton: DownloadControlView = {
        let view = DownloadControlView(initialState: .readyToDownloading)
        view.isHidden = true
        view.addTarget(self, action: #selector(self.downloadButtonClicked), for: .touchUpInside)
        return view
    }()

    private lazy var statsView = CourseInfoTabSyllabusCellStatsView()

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

    func configure(viewModel: CourseInfoTabSyllabusUnitViewModel?) {
        guard let viewModel = viewModel else {
            // Reset data (now it's only title)
            self.titleLabel.text = nil
            self.updateEnabledAppearance(isEnabled: true)
            return
        }

        self.titleLabel.text = viewModel.title
        self.progressIndicatorView.progress = viewModel.progress
        self.coverImageView.loadImage(url: viewModel.coverImageURL)

        self.statsView.progressLabelText = viewModel.progressLabelText
        self.statsView.learnersLabelText = viewModel.learnersLabelText
        self.statsView.likesCount = viewModel.likesCount

        self.updateDownloadState(newState: viewModel.downloadState)
        self.updateEnabledAppearance(isEnabled: viewModel.isSelectable)
    }

    func updateDownloadState(newState: CourseInfoTabSyllabus.DownloadState) {
        switch newState {
        case .notAvailable:
            self.downloadButton.isHidden = true
        case .available(let isCached):
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = isCached ? .readyToRemoving : .readyToDownloading
        case .waiting:
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .pending
        case .downloading(let progress):
            self.downloadButton.isHidden = false
            self.downloadButton.actionState = .downloading(progress: progress)
        }
    }

    func updateEnabledAppearance(isEnabled: Bool) {
        self.alpha = isEnabled
            ? self.appearance.enabledStateAlpha
            : self.appearance.disabledStateAlpha
    }

    func showLoading() {
        self.skeleton.viewBuilder = {
            CourseInfoTabSyllabusCellSkeletonView()
        }

        [
            self.coverImageView,
            self.titleLabel,
            self.downloadButton,
            self.progressIndicatorView,
            self.statsView
        ].forEach { $0.alpha = 0.0 }

        self.skeleton.show()
    }

    func hideLoading() {
        self.skeleton.hide()

        [
            self.coverImageView,
            self.titleLabel,
            self.downloadButton,
            self.progressIndicatorView,
            self.statsView
        ].forEach { $0.alpha = 1.0 }
    }

    @objc
    private func downloadButtonClicked() {
        self.onDownloadButtonClick?()
    }
}

extension CourseInfoTabSyllabusCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.downloadButton)
        self.addSubview(self.coverImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.statsView)
        self.addSubview(self.downloadButtonTapProxyView)

        self.progressIndicatorViewContainerView.addSubview(self.progressIndicatorView)
        self.addSubview(self.progressIndicatorViewContainerView)
    }

    func makeConstraints() {
        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.downloadButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.downloadButtonSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.downloadButtonInsets.right)
        }

        self.downloadButtonTapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.downloadButtonTapProxyView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.tapProxyViewSize)
            make.center.equalTo(self.downloadButton.snp.center)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.coverImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverImageViewSize)
            make.leading.equalToSuperview().offset(self.appearance.coverImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.coverImageViewInsets.top)
            make.bottom
                .lessThanOrEqualToSuperview()
                .offset(-self.appearance.coverImageViewInsets.bottom)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.titleLabel.snp.makeConstraints { make in
            make.leading
                .equalTo(self.coverImageView.snp.trailing)
                .offset(self.appearance.titleLabelInsets.left)
            make.trailing
                .equalTo(self.downloadButton.snp.leading)
                .offset(-self.appearance.titleLabelInsets.left)
            make.top.equalTo(self.coverImageView.snp.top)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.statsView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.statsViewHeight)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.lessThanOrEqualTo(self.titleLabel.snp.trailing)
            make.top
                .equalTo(self.titleLabel.snp.bottom)
                .offset(self.appearance.statsInsets.top)
            make.bottom
                .equalToSuperview()
                .offset(-self.appearance.statsInsets.bottom)
        }

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
    }
}
