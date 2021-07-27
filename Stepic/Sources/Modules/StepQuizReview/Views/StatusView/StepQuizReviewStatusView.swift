import SnapKit
import UIKit

extension StepQuizReviewStatusView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
        let insets = LayoutInsets.default

        let circleViewSize = CGSize(width: 24, height: 24)

        let titleFont = Typography.caption1Font

        let separatorColor = UIColor.stepikSeparator
        let separatorHeight: CGFloat = 0.5
    }
}

final class StepQuizReviewStatusView: UIView {
    let appearance: Appearance

    private lazy var circleView = StepQuizReviewStatusCircleView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    var anchorView: UIView { self.circleView }

    var status = Status.pending {
        didSet {
            self.handleStatusUpdated()
        }
    }

    var position = 1 {
        didSet {
            self.handlePositionUpdated()
        }
    }

    var isLastPosition = false

    var title: String? {
        get {
            self.titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentHeight = max(self.appearance.circleViewSize.height, self.titleLabel.intrinsicContentSize.height)
        let height = self.appearance.insets.top + contentHeight + self.appearance.insets.bottom
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

        self.handleStatusUpdated()
        self.handlePositionUpdated()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func handleStatusUpdated() {
        let newCircleAppearance = StepQuizReviewStatusCircleView.Appearance(
            borderColor: self.status.circleTintColor,
            backgroundColor: self.status.circleBackgroundColor,
            textColor: self.status.circleTintColor
        )
        self.circleView.appearance = newCircleAppearance
        self.circleView.imageViewIsHidden = self.status != .completed
        self.circleView.textLabelIsHidden = self.status == .completed

        if !self.circleView.imageViewIsHidden {
            self.circleView.image = UIImage(named: "quiz-feedback-correct")?.withRenderingMode(.alwaysTemplate)
        }

        self.titleLabel.textColor = self.status.getTitleTextColor(isLastPosition: self.isLastPosition)
    }

    private func handlePositionUpdated() {
        self.circleView.text = "\(self.position)"
    }

    enum Status {
        case error
        case pending
        case inProgress
        case completed

        fileprivate var circleTintColor: UIColor {
            switch self {
            case .error:
                return .stepikDiscountPriceText
            case .pending:
                return .quizReviewPendingBorder
            case .inProgress:
                return .stepikGreen
            case .completed:
                return .stepikGreen
            }
        }

        fileprivate var circleBackgroundColor: UIColor {
            switch self {
            case .error, .pending, .inProgress:
                return .clear
            case .completed:
                return .stepikGreen
            }
        }

        fileprivate func getTitleTextColor(isLastPosition: Bool) -> UIColor {
            switch self {
            case .error, .inProgress:
                return .stepikMaterialPrimaryText
            case .pending:
                return .stepikMaterialDisabledText
            case .completed:
                return isLastPosition ? .stepikMaterialPrimaryText : .stepikMaterialDisabledText
            }
        }
    }
}

extension StepQuizReviewStatusView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.circleView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.circleView.translatesAutoresizingMaskIntoConstraints = false
        self.circleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(self.appearance.circleViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.circleView.snp.trailing).offset(self.appearance.insets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.insets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
