import SnapKit
import UIKit

extension CourseWidgetProgressView {
    struct Appearance {
        var progressTextLabelAppearance = CourseWidgetLabel.Appearance()
        let progressTextLabelInsets = LayoutInsets(bottom: 4)

        let progressBarHeight: CGFloat = 2
        let progressBarCornerRadius: CGFloat = 1.3
        var progressBarViewAppearance = CourseWidgetProgressBarView.Appearance()

        let certificateRegularThresholdPrimaryColor = UIColor.stepikGreenFixed
        let certificateRegularThresholdSecondaryColor = UIColor.stepikGreenFixed.withAlphaComponent(0.12)
        let certificateRegularThresholdValueViewTextLabelAppearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 1,
            font: Typography.caption1Font,
            textColor: .stepikGreenFixed
        )

        let certificateDistinctionThresholdPrimaryColor = UIColor.stepikOrangeFixed
        let certificateDistinctionThresholdSecondaryColor = UIColor.stepikOrangeFixed.withAlphaComponent(0.12)
        let certificateDistinctionThresholdValueViewTextLabelAppearance = CourseWidgetLabel.Appearance(
            maxLinesCount: 1,
            font: Typography.caption1Font,
            textColor: .stepikOrangeFixed
        )

        let certificateThresholdPointViewCenterYOffset: CGFloat = 0.5
        let certificateThresholdValueViewBottomOffset: CGFloat = 2
        let certificateThresholdValueViewHorizontalSpacing: CGFloat = 4
    }
}

final class CourseWidgetProgressView: UIView {
    let appearance: Appearance

    private lazy var progressTextLabel = CourseWidgetLabel(appearance: self.appearance.progressTextLabelAppearance)

    private lazy var progressBarView: CourseWidgetProgressBarView = {
        let view = CourseWidgetProgressBarView(appearance: self.appearance.progressBarViewAppearance)
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.progressBarCornerRadius
        return view
    }()

    private lazy var certificateRegularThresholdPointView = CourseWidgetProgressCertificateThresholdPointView(
        appearance: .init(backgroundColor: self.appearance.certificateRegularThresholdPrimaryColor)
    )

    private lazy var certificateRegularThresholdValueView = CourseWidgetProgressCertificateThresholdValueView(
        appearance: .init(
            iconImageViewTintColor: self.appearance.certificateRegularThresholdPrimaryColor,
            textLabelAppearance: self.appearance.certificateRegularThresholdValueViewTextLabelAppearance,
            backgroundColor: self.appearance.certificateRegularThresholdSecondaryColor
        )
    )

    private lazy var certificateDistinctionThresholdPointView = CourseWidgetProgressCertificateThresholdPointView(
        appearance: .init(backgroundColor: self.appearance.certificateDistinctionThresholdPrimaryColor)
    )

    private lazy var certificateDistinctionThresholdValueView = CourseWidgetProgressCertificateThresholdValueView(
        appearance: .init(
            iconImageViewTintColor: self.appearance.certificateDistinctionThresholdPrimaryColor,
            textLabelAppearance: self.appearance.certificateDistinctionThresholdValueViewTextLabelAppearance,
            backgroundColor: self.appearance.certificateDistinctionThresholdSecondaryColor
        )
    )

    private var certificateRegularThresholdPointViewLeadingConstraint: Constraint?
    private var certificateDistinctionThresholdPointViewLeadingConstraint: Constraint?

    private var configurationViewModel: CourseWidgetProgressViewModel?

    private var certificateRegularViews: [UIView] {
        [self.certificateRegularThresholdPointView, self.certificateRegularThresholdValueView]
    }

    private var certificateDistinctionViews: [UIView] {
        [self.certificateDistinctionThresholdPointView, self.certificateDistinctionThresholdValueView]
    }

    private var certificateViews: [UIView] { self.certificateRegularViews + self.certificateDistinctionViews }

    override var intrinsicContentSize: CGSize {
        let height = self.progressTextLabel.intrinsicContentSize.height
            + self.appearance.progressTextLabelInsets.bottom
            + self.appearance.progressBarHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateCertificateViewsConstraints()
    }

    func configure(viewModel: CourseWidgetProgressViewModel) {
        self.configurationViewModel = viewModel

        self.progressTextLabel.text = viewModel.progressLabelText

        self.progressBarView.progress = viewModel.progress
        if let certificateDistinctionThreshold = viewModel.certificateDistinctionThreshold {
            let distinctionThresholdProgress = viewModel.cost > 0
                ? Float(certificateDistinctionThreshold) / Float(viewModel.cost)
                : nil
            self.progressBarView.distinctionThresholdProgress = distinctionThresholdProgress
        } else {
            self.progressBarView.distinctionThresholdProgress = nil
        }

        self.configureCertificateViews(viewModel: viewModel)
        self.updateCertificateViewsConstraints()
    }

    // MARK: Private API

    private func configureCertificateViews(viewModel: CourseWidgetProgressViewModel) {
        guard viewModel.isWithCertificate else {
            self.certificateViews.forEach { $0.isHidden = true }
            return
        }

        if let certificateRegularThreshold = viewModel.certificateRegularThreshold {
            self.certificateRegularViews.forEach { $0.isHidden = false }

            self.certificateRegularThresholdPointView.isDone = viewModel.score >= Float(certificateRegularThreshold)
            self.certificateRegularThresholdValueView.text = "\(certificateRegularThreshold)"
        } else {
            self.certificateRegularViews.forEach { $0.isHidden = true }
        }

        if let certificateDistinctionThreshold = viewModel.certificateDistinctionThreshold {
            self.certificateDistinctionViews.forEach { $0.isHidden = false }

            self.certificateDistinctionThresholdPointView.isDone =
                viewModel.score >= Float(certificateDistinctionThreshold)
            self.certificateDistinctionThresholdValueView.text = "\(certificateDistinctionThreshold)"
        } else {
            self.certificateDistinctionViews.forEach { $0.isHidden = true }
        }
    }

    private func updateCertificateViewsConstraints() {
        guard let viewModel = self.configurationViewModel,
              viewModel.isWithCertificate,
              viewModel.cost > 0 else {
            return
        }

        let progressBarWidth = self.progressBarView.bounds.width
        guard progressBarWidth > 0 else {
            return
        }

        if let certificateRegularThreshold = viewModel.certificateRegularThreshold {
            let thresholdInProgress = Float(certificateRegularThreshold) / Float(viewModel.cost)
            let offset = progressBarWidth * CGFloat(thresholdInProgress)
            self.certificateRegularThresholdPointViewLeadingConstraint?.update(offset: offset)
        }

        if let certificateDistinctionThreshold = viewModel.certificateDistinctionThreshold {
            let thresholdInProgress = Float(certificateDistinctionThreshold) / Float(viewModel.cost)
            let offset = progressBarWidth * CGFloat(thresholdInProgress)
            self.certificateDistinctionThresholdPointViewLeadingConstraint?.update(offset: offset)
        }
    }
}

// MARK: - CourseWidgetProgressView: ProgrammaticallyInitializableViewProtocol -

extension CourseWidgetProgressView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.progressTextLabel)
        self.addSubview(self.progressBarView)
        self.addSubview(self.certificateRegularThresholdPointView)
        self.addSubview(self.certificateDistinctionThresholdPointView)
        self.addSubview(self.certificateRegularThresholdValueView)
        self.addSubview(self.certificateDistinctionThresholdValueView)
    }

    func makeConstraints() {
        self.progressTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressTextLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalTo(self.progressBarView.snp.top).offset(-self.appearance.progressTextLabelInsets.bottom)
        }

        self.progressBarView.translatesAutoresizingMaskIntoConstraints = false
        self.progressBarView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.progressBarHeight)
        }

        self.certificateRegularThresholdPointView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateRegularThresholdPointView.setContentHuggingPriority(.required, for: .horizontal)
        self.certificateRegularThresholdPointView.snp.makeConstraints { make in
            make.centerY
                .equalTo(self.progressBarView.snp.centerY)
                .offset(self.appearance.certificateThresholdPointViewCenterYOffset)
            self.certificateRegularThresholdPointViewLeadingConstraint = make.leading.equalToSuperview().constraint
        }

        self.certificateDistinctionThresholdPointView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateDistinctionThresholdPointView.setContentHuggingPriority(.required, for: .horizontal)
        self.certificateDistinctionThresholdPointView.snp.makeConstraints { make in
            make.centerY
                .equalTo(self.progressBarView.snp.centerY)
                .offset(self.appearance.certificateThresholdPointViewCenterYOffset)
            self.certificateDistinctionThresholdPointViewLeadingConstraint = make.leading.equalToSuperview().constraint
        }

        self.certificateRegularThresholdValueView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateRegularThresholdValueView.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.progressBarView.snp.top)
                .offset(-self.appearance.certificateThresholdValueViewBottomOffset)
            make.centerX
                .equalTo(self.certificateRegularThresholdPointView)
                .priority(.medium)

            make.leading
                .greaterThanOrEqualTo(self.progressTextLabel.snp.trailing)
                .offset(self.appearance.certificateThresholdValueViewHorizontalSpacing)
                .priority(.high)
        }

        self.certificateDistinctionThresholdValueView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateDistinctionThresholdValueView.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.progressBarView.snp.top)
                .offset(-self.appearance.certificateThresholdValueViewBottomOffset)
            make.centerX
                .equalTo(self.certificateDistinctionThresholdPointView)
                .priority(.medium)

            make.leading
                .greaterThanOrEqualTo(self.certificateRegularThresholdValueView.snp.trailing)
                .offset(self.appearance.certificateThresholdValueViewHorizontalSpacing)
                .priority(.high)
            make.trailing
                .lessThanOrEqualToSuperview()
                .priority(.high)
        }
    }
}
