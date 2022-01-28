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
    }
}

extension CourseWidgetProgressView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.progressTextLabel)
        self.addSubview(self.progressBarView)
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
    }
}
