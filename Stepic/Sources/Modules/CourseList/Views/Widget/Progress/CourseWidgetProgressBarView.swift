import SnapKit
import UIKit

extension CourseWidgetProgressBarView {
    struct Appearance {
        let regularProgressTintColor = UIColor.stepikGreenFixed
        let distinctionProgressTintColor = UIColor.stepikOrangeFixed

        var trackTintColor = UIColor.onSurface.withAlphaComponent(0.12)
    }
}

final class CourseWidgetProgressBarView: UIView {
    let appearance: Appearance

    private lazy var progressBarView: UIProgressView = {
        let view = UIProgressView()
        view.progressViewStyle = .bar
        view.trackTintColor = self.appearance.trackTintColor
        view.progressTintColor = self.appearance.regularProgressTintColor
        return view
    }()

    private lazy var distinctionProgressView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.distinctionProgressTintColor
        return view
    }()

    private var distinctionProgressViewLeadingConstraint: Constraint?

    private var distinctionProgressViewWidthConstraint: Constraint?

    var progress: Float {
        get {
            self.progressBarView.progress
        }
        set {
            self.progressBarView.progress = newValue
            self.updateDistinctionProgressView()
        }
    }

    var distinctionThresholdProgress: Float? {
        didSet {
            self.updateDistinctionProgressView()
        }
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
        self.updateDistinctionProgressView()
    }

    // MARK: Private API

    private func updateDistinctionProgressView() {
        guard let distinctionThresholdProgress = self.distinctionThresholdProgress,
              self.progress > distinctionThresholdProgress else {
            self.distinctionProgressView.isHidden = true
            return
        }

        self.distinctionProgressView.isHidden = false

        let width = self.bounds.width
        guard width > 0 else {
            return
        }

        let leadingOffset = width * CGFloat(distinctionThresholdProgress)
        self.distinctionProgressViewLeadingConstraint?.update(offset: leadingOffset)

        let distinctionProgressWidth = width * CGFloat(self.progress - distinctionThresholdProgress)
        self.distinctionProgressViewWidthConstraint?.update(offset: distinctionProgressWidth)
    }
}

extension CourseWidgetProgressBarView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.progressBarView)
        self.addSubview(self.distinctionProgressView)
    }

    func makeConstraints() {
        self.progressBarView.translatesAutoresizingMaskIntoConstraints = false
        self.progressBarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.distinctionProgressView.translatesAutoresizingMaskIntoConstraints = false
        self.distinctionProgressView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            self.distinctionProgressViewLeadingConstraint = make.leading.equalToSuperview().constraint
            self.distinctionProgressViewWidthConstraint = make.width.equalTo(0).constraint
        }
    }
}
