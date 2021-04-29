import SnapKit
import UIKit

protocol LessonFinishedStepsPanModalViewDelegate: AnyObject {
    func lessonFinishedStepsPanModalViewDidClickCloseButton(_ view: LessonFinishedStepsPanModalView)
    func lessonFinishedStepsPanModalViewDidClickPrimaryActionButton(_ view: LessonFinishedStepsPanModalView)
}

extension LessonFinishedStepsPanModalView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)

        let headerImageViewHeight: CGFloat = 136

        let titleLabelFont = UIFont.systemFont(ofSize: 19, weight: .semibold)
        let titleLabelTextColor = UIColor.stepikMaterialPrimaryText

        let subtitleLabelFont = Typography.bodyFont
        let subtitleLabelTextColor = UIColor.stepikMaterialPrimaryText

        let actionButtonFont = Typography.bodyFont
        let actionButtonCornerRadius: CGFloat = 8
        let actionButtonHeight: CGFloat = 44

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(inset: 16)
    }
}

final class LessonFinishedStepsPanModalView: UIView {
    weak var delegate: LessonFinishedStepsPanModalViewDelegate?

    let appearance: Appearance

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var primaryActionButton: UIButton = {
        var appearance = NextStepButton.Appearance()
        appearance.font = self.appearance.actionButtonFont
        appearance.cornerRadius = self.appearance.actionButtonCornerRadius

        let button = NextStepButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.primaryActionButtonClicked), for: .touchUpInside)

        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()
    private lazy var contentStackViewContainerView = UIView()

    private lazy var scrollableStackView: ScrollableStackView = {
        let scrollableStackView = ScrollableStackView(orientation: .vertical)
        scrollableStackView.spacing = self.appearance.stackViewSpacing
        return scrollableStackView
    }()

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        let height = self.appearance.headerImageViewHeight
            + self.appearance.stackViewSpacing
            + self.titleLabel.intrinsicContentSize.height
            + self.appearance.stackViewSpacing
            + self.subtitleLabel.intrinsicContentSize.height
            + self.appearance.stackViewSpacing
            + SeparatorView.Appearance().height
            + self.appearance.stackViewSpacing
            + self.appearance.actionButtonHeight
            + self.appearance.stackViewSpacing

        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: height
        )
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

    func showLoading() {
        self.scrollableStackView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.scrollableStackView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func configure(viewModel: LessonFinishedStepsPanModalViewModel) {
        self.headerImageView.image = UIImage(named: viewModel.headerImageName)
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalViewDidClickCloseButton(self)
    }

    @objc
    private func primaryActionButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalViewDidClickPrimaryActionButton(self)
    }
}

extension LessonFinishedStepsPanModalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.closeButton)
        self.addSubview(self.loadingIndicator)

        self.scrollableStackView.addArrangedView(self.headerImageView)

        self.contentStackViewContainerView.addSubview(self.contentStackView)
        self.scrollableStackView.addArrangedView(self.contentStackViewContainerView)

        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.subtitleLabel)
        self.contentStackView.addArrangedSubview(SeparatorView())
        self.contentStackView.addArrangedSubview(self.primaryActionButton)
    }

    func makeConstraints() {
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.4)
        }

        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.headerImageView.translatesAutoresizingMaskIntoConstraints = false
        self.headerImageView.snp.makeConstraints { $0.height.equalTo(self.appearance.headerImageViewHeight) }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.closeButtonWidthHeight)
            make.top.equalToSuperview().offset(self.appearance.closeButtonInsets.top)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-self.appearance.closeButtonInsets.right)
        }

        self.primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryActionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading
                .equalTo(self.contentStackViewContainerView.safeAreaLayoutGuide)
                .offset(self.appearance.stackViewInsets.left)
            make.trailing
                .equalTo(self.contentStackViewContainerView.safeAreaLayoutGuide)
                .offset(-self.appearance.stackViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.stackViewInsets.bottom)
        }
    }
}

extension LessonFinishedStepsPanModalView: PanModalScrollable {
    var panScrollable: UIScrollView? { self.scrollableStackView.panScrollable }
}
