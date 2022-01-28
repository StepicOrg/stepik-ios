import SnapKit
import UIKit

extension CourseWidgetProgressView {
    struct Appearance {
        var progressTextLabelAppearance = CourseWidgetLabel.Appearance()
        let progressTextLabelInsets = LayoutInsets(bottom: 4)

        let progressBarHeight: CGFloat = 2
        let progressBarProgressTintColor = UIColor.stepikGreenFixed
        var progressBarTrackTintColor = UIColor.onSurface.withAlphaComponent(0.12)
        let progressBarCornerRadius: CGFloat = 1.3

        let certificateRegularThresholdPointViewBackgroundColor = UIColor.stepikGreenFixed
        let certificateDistinctionThresholdPointViewBackgroundColor = UIColor.stepikOrangeFixed
        let certificateThresholdPointViewCenterYOffset: CGFloat = 0.5
    }
}

final class CourseWidgetProgressView: UIView {
    let appearance: Appearance

    private lazy var progressTextLabel = CourseWidgetLabel(appearance: self.appearance.progressTextLabelAppearance)

    private lazy var progressBarView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = self.appearance.progressBarTrackTintColor
        view.progressTintColor = self.appearance.progressBarProgressTintColor
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.progressBarCornerRadius
        return view
    }()

    private lazy var certificateRegularThresholdPointView = CourseWidgetProgressCertificateThresholdPointView(
        appearance: .init(backgroundColor: self.appearance.certificateRegularThresholdPointViewBackgroundColor)
    )

    private lazy var certificateDistinctionThresholdPointView = CourseWidgetProgressCertificateThresholdPointView(
        appearance: .init(backgroundColor: self.appearance.certificateDistinctionThresholdPointViewBackgroundColor)
    )

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

    func configure(viewModel: CourseWidgetProgressViewModel) {
        self.progressTextLabel.text = viewModel.progressLabelText
        self.progressBarView.progress = viewModel.progress

        self.certificateRegularThresholdPointView.isHidden = false
        self.certificateDistinctionThresholdPointView.isHidden = false

        self.certificateRegularThresholdPointView.isDone = true

//        guard viewModel.isWithCertificate else {
//            self.certificateRegularThresholdPointView.isHidden = true
//            self.certificateDistinctionThresholdPointView.isHidden = true
//            return
//        }
//
//        if let certificateRegularThreshold = viewModel.certificateRegularThreshold {
//            self.certificateRegularThresholdPointView.isHidden = false
//            self.certificateRegularThresholdPointView.isDone = true
//            print(certificateRegularThreshold)
//        } else {
//            self.certificateRegularThresholdPointView.isHidden = true
//        }
//
//        if let certificateDistinctionThreshold = viewModel.certificateDistinctionThreshold {
//            self.certificateDistinctionThresholdPointView.isHidden = false
//            print(certificateDistinctionThreshold)
//        } else {
//            self.certificateDistinctionThresholdPointView.isHidden = true
//        }
    }
}

extension CourseWidgetProgressView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.progressTextLabel)
        self.addSubview(self.progressBarView)
        self.addSubview(self.certificateRegularThresholdPointView)
        self.addSubview(self.certificateDistinctionThresholdPointView)
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
        self.certificateRegularThresholdPointView.snp.makeConstraints { make in
            make.centerY
                .equalTo(self.progressBarView.snp.centerY)
                .offset(self.appearance.certificateThresholdPointViewCenterYOffset)
            make.leading.equalToSuperview().offset(60)
        }

        self.certificateDistinctionThresholdPointView.translatesAutoresizingMaskIntoConstraints = false
        self.certificateDistinctionThresholdPointView.snp.makeConstraints { make in
            make.centerY
                .equalTo(self.progressBarView.snp.centerY)
                .offset(self.appearance.certificateThresholdPointViewCenterYOffset)
            make.leading.equalToSuperview().offset(100)
        }
    }
}
