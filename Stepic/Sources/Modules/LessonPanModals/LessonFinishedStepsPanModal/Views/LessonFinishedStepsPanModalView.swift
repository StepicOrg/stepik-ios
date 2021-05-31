import Atributika
import SnapKit
import UIKit

protocol LessonFinishedStepsPanModalViewDelegate: AnyObject {
    func lessonFinishedStepsPanModalViewDidClickCloseButton(_ view: LessonFinishedStepsPanModalView)
    func lessonFinishedStepsPanModalView(
        _ view: LessonFinishedStepsPanModalView,
        didClickButtonWith uniqueIdentifier: UniqueIdentifierType?,
        sourceView: UIView
    )
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

        let optionButtonImageSize = CGSize(width: 20, height: 20)
        let optionButtonTintColor = UIColor.stepikGreenFixed
        let optionButtonFont = UIFont.systemFont(ofSize: 17)
        let optionButtonTitleInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        let optionButtonHeight: CGFloat = 20

        let actionButtonHeight: CGFloat = 44

        let stackViewSpacing: CGFloat = 16
        let stackViewInsets = LayoutInsets(inset: 16)
    }
}

final class LessonFinishedStepsPanModalView: UIView {
    weak var delegate: LessonFinishedStepsPanModalViewDelegate?

    let appearance: Appearance
    private var storedViewModel: LessonFinishedStepsPanModalViewModel?

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
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var feedbackView = LessonFinishedStepsPanModalFeedbackView()

    private lazy var subtitleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.font = self.appearance.subtitleLabelFont
        label.textColor = self.appearance.subtitleLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var primaryOptionButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.optionButtonImageSize
        imageButton.tintColor = self.appearance.optionButtonTintColor
        imageButton.font = self.appearance.optionButtonFont
        imageButton.titleInsets = self.appearance.optionButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.primaryOptionButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var secondaryOptionButton: ImageButton = {
        let imageButton = ImageButton()
        imageButton.imageSize = self.appearance.optionButtonImageSize
        imageButton.tintColor = self.appearance.optionButtonTintColor
        imageButton.font = self.appearance.optionButtonFont
        imageButton.titleInsets = self.appearance.optionButtonTitleInsets
        imageButton.addTarget(self, action: #selector(self.secondaryOptionButtonClicked), for: .touchUpInside)
        return imageButton
    }()

    private lazy var primaryActionButton: UIButton = {
        let button = LessonPanModalActionButton()
        button.addTarget(self, action: #selector(self.primaryActionButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var secondaryActionButton: UIButton = {
        let button = LessonPanModalActionButton(style: .outline)
        button.addTarget(self, action: #selector(self.secondaryActionButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var optionButtonsStackView = UIStackView()

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

    private lazy var subtitleTextConverter = HTMLToAttributedStringConverter(font: self.appearance.subtitleLabelFont)

    override var intrinsicContentSize: CGSize {
        if self.loadingIndicator.isAnimating {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: self.loadingIndicator.intrinsicContentSize.height
            )
        }

        var verticalInsets: CGFloat = 0

        let titleHeight = self.titleLabel.isHidden ? 0 : self.titleLabel.intrinsicContentSize.height
        verticalInsets += self.titleLabel.isHidden ? 0 : self.appearance.stackViewSpacing

        let feedbackHeight = self.feedbackView.isHidden ? 0 : self.feedbackView.intrinsicContentSize.height
        verticalInsets += self.feedbackView.isHidden ? 0 : self.appearance.stackViewSpacing

        let subtitleHeight = self.subtitleLabel.isHidden
            ? 0
            : self.subtitleLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
        verticalInsets += self.subtitleLabel.isHidden ? 0 : self.appearance.stackViewSpacing

        let optionButtonsStackViewIntrinsicContentSize = self.optionButtonsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        verticalInsets += self.optionButtonsStackView.isHidden ? 0 : self.appearance.stackViewSpacing

        let separatorHeight = SeparatorView.Appearance().height
        verticalInsets += self.appearance.stackViewSpacing

        let secondaryActionButtonHeight = self.secondaryActionButton.isHidden ? 0 : self.appearance.actionButtonHeight
        verticalInsets += self.secondaryActionButton.isHidden ? 0 : self.appearance.stackViewSpacing

        let primaryActionButtonHeight = self.primaryActionButton.isHidden ? 0 : self.appearance.actionButtonHeight
        verticalInsets += self.primaryActionButton.isHidden ? 0 : self.appearance.stackViewSpacing

        let heightWithInsets = self.appearance.headerImageViewHeight
            + titleHeight
            + feedbackHeight
            + subtitleHeight
            + optionButtonsStackViewIntrinsicContentSize.height
            + separatorHeight
            + secondaryActionButtonHeight
            + primaryActionButtonHeight
            + verticalInsets
            + self.appearance.stackViewSpacing

        return CGSize(width: UIView.noIntrinsicMetric, height: heightWithInsets)
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

        self.titleLabel.text = viewModel.title
        self.titleLabel.isHidden = viewModel.title.isEmpty

        self.feedbackView.text = viewModel.feedbackText
        self.feedbackView.isHidden = viewModel.feedbackText.isEmpty

        self.subtitleLabel.attributedText = self.subtitleTextConverter.convertToAttributedText(
            htmlString: viewModel.subtitle
        )
        self.subtitleLabel.isHidden = viewModel.subtitle.isEmpty

        self.primaryOptionButton.title = viewModel.primaryOptionButtonDescription.title
        self.primaryOptionButton.isHidden = viewModel.primaryOptionButtonDescription.isHidden
        if let iconName = viewModel.primaryOptionButtonDescription.iconName {
            self.primaryOptionButton.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        }

        self.secondaryOptionButton.title = viewModel.secondaryOptionButtonDescription.title
        self.secondaryOptionButton.isHidden = viewModel.secondaryOptionButtonDescription.isHidden
        if let iconName = viewModel.secondaryOptionButtonDescription.iconName {
            self.secondaryOptionButton.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        }

        self.optionButtonsStackView.isHidden = self.primaryOptionButton.isHidden && self.secondaryOptionButton.isHidden
        self.updateOptionButtonsStackView()

        self.primaryActionButton.setTitle(viewModel.primaryActionButtonDescription.title, for: .normal)
        self.primaryActionButton.isHidden = viewModel.primaryActionButtonDescription.isHidden

        self.secondaryActionButton.setTitle(viewModel.secondaryActionButtonDescription.title, for: .normal)
        self.secondaryActionButton.isHidden = viewModel.secondaryActionButtonDescription.isHidden

        self.storedViewModel = viewModel
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateOptionButtonsStackView()
    }

    private func updateOptionButtonsStackView() {
        if self.optionButtonsStackView.isHidden {
            return
        }

        let primaryOptionButtonWidth = self.primaryOptionButton.isHidden
            ? 0
            : self.primaryOptionButton.intrinsicContentSize.width
        let secondaryOptionButtonWidth = self.secondaryOptionButton.isHidden
            ? 0
            : self.secondaryOptionButton.intrinsicContentSize.width
        let insets = primaryOptionButtonWidth > 0 && secondaryOptionButtonWidth > 0
            ? self.appearance.stackViewSpacing
            : 0
        let optionButtonsWidthWithInsets = primaryOptionButtonWidth + insets + secondaryOptionButtonWidth

        if optionButtonsWidthWithInsets <= self.contentStackView.frame.width {
            self.optionButtonsStackView.spacing = 0
            self.optionButtonsStackView.axis = .horizontal
            self.optionButtonsStackView.distribution = .equalSpacing
        } else {
            self.optionButtonsStackView.spacing = self.appearance.stackViewSpacing
            self.optionButtonsStackView.axis = .vertical
            self.optionButtonsStackView.distribution = .fillProportionally
            self.optionButtonsStackView.alignment = .leading
        }
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalViewDidClickCloseButton(self)
    }

    @objc
    private func primaryOptionButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalView(
            self,
            didClickButtonWith: self.storedViewModel?.primaryOptionButtonDescription.uniqueIdentifier,
            sourceView: self.primaryOptionButton
        )
    }

    @objc
    private func secondaryOptionButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalView(
            self,
            didClickButtonWith: self.storedViewModel?.secondaryOptionButtonDescription.uniqueIdentifier,
            sourceView: self.secondaryOptionButton
        )
    }

    @objc
    private func primaryActionButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalView(
            self,
            didClickButtonWith: self.storedViewModel?.primaryActionButtonDescription.uniqueIdentifier,
            sourceView: self.primaryActionButton
        )
    }

    @objc
    private func secondaryActionButtonClicked() {
        self.delegate?.lessonFinishedStepsPanModalView(
            self,
            didClickButtonWith: self.storedViewModel?.secondaryActionButtonDescription.uniqueIdentifier,
            sourceView: self.secondaryActionButton
        )
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

        self.optionButtonsStackView.addArrangedSubview(self.primaryOptionButton)
        self.optionButtonsStackView.addArrangedSubview(self.secondaryOptionButton)

        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.feedbackView)
        self.contentStackView.addArrangedSubview(self.subtitleLabel)
        self.contentStackView.addArrangedSubview(self.optionButtonsStackView)
        self.contentStackView.addArrangedSubview(SeparatorView())
        self.contentStackView.addArrangedSubview(self.secondaryActionButton)
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

        self.primaryOptionButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryOptionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.optionButtonHeight) }

        self.secondaryOptionButton.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryOptionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.optionButtonHeight) }

        self.secondaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryActionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }

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
