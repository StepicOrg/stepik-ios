import SnapKit
import UIKit

extension StepDisabledView {
    struct Appearance {
        let placeholderImageSize = CGSize(width: 150, height: 120)
        let placeholderImageInsets = LayoutInsets(top: 32)

        let feedbackViewHeight: CGFloat = 52
        let feedbackViewInsets = LayoutInsets(top: 32, left: 16, right: 16)

        let descriptionLabelFont = Typography.bodyFont
        let descriptionLabelTextColor = UIColor.stepikMaterialPrimaryText
        let descriptionLabelInsets = LayoutInsets(inset: 16)

        let stepControlsInsets = LayoutInsets(inset: 16)

        let backgroundColor = UIColor.stepikBackground
    }
}

final class StepDisabledView: UIView {
    let appearance: Appearance

    private lazy var placeholderImageView: UIImageView = {
        let image = UIImage(named: "placeholder-sleepy")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var feedbackView: QuizFeedbackView = {
        let view = QuizFeedbackView()
        view.update(
            state: .validation,
            title: NSLocalizedString("StepDisabledTitle", comment: "")
        )
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionLabelFont
        label.textColor = self.appearance.descriptionLabelTextColor
        label.numberOfLines = 0
        label.text = NSLocalizedString("StepDisabledMessage", comment: "")
        return label
    }()

    private lazy var stepControlsView: StepControlsView = {
        let view = StepControlsView()
        view.isDiscussionsButtonVisible = false
        view.solutionsTitle = nil
        view.passedByCount = nil
        view.correctRatio = nil
        return view
    }()

    var hasNextStepButton: Bool? {
        didSet {
            self.stepControlsView.hasNextStepButton = self.hasNextStepButton ?? false
        }
    }

    var unitNavigationState: StepControlsView.UnitNavigationState? {
        didSet {
            self.stepControlsView.unitNavigationState = self.unitNavigationState
        }
    }

    var onNextStepButtonClick: (() -> Void)? {
        get {
            self.stepControlsView.onNextStepButtonClick
        }
        set {
            self.stepControlsView.onNextStepButtonClick = newValue
        }
    }

    var onPreviousUnitButtonClick: (() -> Void)? {
        get {
            self.stepControlsView.onPreviousUnitButtonClick
        }
        set {
            self.stepControlsView.onPreviousUnitButtonClick = newValue
        }
    }

    var onNextUnitButtonClick: (() -> Void)? {
        get {
            self.stepControlsView.onNextUnitButtonClick
        }
        set {
            self.stepControlsView.onNextUnitButtonClick = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.placeholderImageInsets.top
            + self.appearance.placeholderImageSize.height
            + self.appearance.feedbackViewInsets.top
            + self.appearance.feedbackViewHeight
            + self.appearance.descriptionLabelInsets.top
            + self.descriptionLabel.intrinsicContentSize.height
            + self.appearance.stepControlsInsets.top
            + self.stepControlsView.intrinsicContentSize.height
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
}

extension StepDisabledView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.placeholderImageView)
        self.addSubview(self.feedbackView)
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.stepControlsView)
    }

    func makeConstraints() {
        self.placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.placeholderImageInsets.top)
            make.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.placeholderImageSize)
        }

        self.feedbackView.translatesAutoresizingMaskIntoConstraints = false
        self.feedbackView.snp.makeConstraints { make in
            make.top.equalTo(self.placeholderImageView.snp.bottom).offset(self.appearance.feedbackViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.feedbackViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.feedbackViewInsets.right)
            make.height.equalTo(self.appearance.feedbackViewHeight)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.feedbackView.snp.bottom).offset(self.appearance.descriptionLabelInsets.top)
            make.leading.trailing.equalTo(self.feedbackView)
        }

        self.stepControlsView.translatesAutoresizingMaskIntoConstraints = false
        self.stepControlsView.snp.makeConstraints { make in
            make.top
                .greaterThanOrEqualTo(self.descriptionLabel.snp.bottom)
                .offset(self.appearance.stepControlsInsets.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
