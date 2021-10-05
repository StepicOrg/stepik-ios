import Intents
import IntentsUI
import SnapKit
import UIKit

extension ContinueLastStepView {
    struct Appearance {
        let mainInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        let contentInsets = UIEdgeInsets(top: 35, left: 19, bottom: 17, right: 19)
        let cornerRadius: CGFloat = 8.0

        let progressHeight: CGFloat = 3.0
        let progressFillColor = UIColor.stepikGreenFixed
        let progressBackgroundColor = UIColor.clear

        let lightModeBackgroundOverlayViewColor = UIColor.stepikAccentFixed.withAlphaComponent(0.85)
        let darkModeBackgroundOverlayViewColor = UIColor.stepikSecondaryBackground.withAlphaComponent(0.85)

        let coverCornerRadius: CGFloat = 3.0

        let courseLabelFont = UIFont.systemFont(ofSize: 16, weight: .light)
        let progressLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let courseLabelTextColor = UIColor.white
        let progressLabelTextColor = UIColor.white

        let coverSize = CGSize(width: 36, height: 36)
        let infoSpacing: CGFloat = 10.0
        let contentSpacing: CGFloat = 30.0

        let continueButtonHeight: CGFloat = 50
        let continueButtonWidthRatio: CGFloat = 0.65
    }
}

@available(iOS 12.0, *)
struct SiriButtonContentConfiguration {
    var shortcut: INShortcut?
    weak var delegate: INUIAddVoiceShortcutButtonDelegate?

    var isEmpty: Bool { self.shortcut == nil && self.delegate == nil }
}

final class ContinueLastStepView: UIView {
    let appearance: Appearance

    lazy var continueButton: UIButton = {
        let button = ContinueActionButton(mode: .default)
        button.setTitle(NSLocalizedString("ContinueLearningWidgetButtonTitle", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(self.continueButtonClicked), for: .touchUpInside)
        return button
    }()

    // Should use wrapped button cause we have stack view
    private lazy var continueButtonBlock = UIView()

    @available(iOS 12.0, *)
    private lazy var siriButton: INUIAddVoiceShortcutButton = {
        let button = INUIAddVoiceShortcutButton(style: .white)
        button.addTarget(self, action: #selector(self.siriButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var siriButtonContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    // Contains [continue button] and [info]
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = self.appearance.contentSpacing
        stackView.axis = .vertical
        return stackView
    }()

    // Contains [course name] and [progress label]
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    // Contains [cover] and [labels]
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.infoSpacing
        return stackView
    }()

    private lazy var courseNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.courseLabelTextColor
        label.font = self.appearance.courseLabelFont
        return label
    }()

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.progressLabelTextColor
        label.font = self.appearance.progressLabelFont
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverCornerRadius
        return view
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = self.appearance.progressFillColor
        view.trackTintColor = self.appearance.progressBackgroundColor
        view.progress = 0
        return view
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.lightModeBackgroundOverlayViewColor
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "new-coursepics-python-xl"),
            highlightedImage: nil
        )
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = self.appearance.cornerRadius
        return imageView
    }()

    var courseTitle: String? {
        didSet {
            self.courseNameLabel.text = self.courseTitle
        }
    }

    var progressText: String? {
        didSet {
            self.progressLabel.text = self.progressText
        }
    }

    var progress: Float = 0 {
        didSet {
            self.progressView.progress = self.progress
        }
    }

    var coverImageURL: URL? {
        didSet {
            self.coverImageView.loadImage(url: self.coverImageURL)
        }
    }

    var onContinueButtonClick: (() -> Void)?

    var onSiriButtonClick: (() -> Void)?

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

    override func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 13.0, *) {
            self.siriButton.cornerRadius = self.siriButton.intrinsicContentSize.height / 2
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateViewColor()
        }
    }

    @available(iOS 12.0, *)
    func configureSiriButton(contentConfiguration: SiriButtonContentConfiguration?) {
        guard let contentConfiguration = contentConfiguration, !contentConfiguration.isEmpty else {
            self.siriButtonContainerView.isHidden = true
            return
        }

        self.siriButtonContainerView.isHidden = false

        self.siriButton.shortcut = contentConfiguration.shortcut
        self.siriButton.delegate = contentConfiguration.delegate
    }

    private func updateViewColor() {
        self.progressView.progressTintColor = self.appearance.progressFillColor
        self.overlayView.backgroundColor = self.isDarkInterfaceStyle
            ? self.appearance.darkModeBackgroundOverlayViewColor
            : self.appearance.lightModeBackgroundOverlayViewColor
    }

    @objc
    private func continueButtonClicked() {
        self.onContinueButtonClick?()
    }

    @objc
    private func siriButtonClicked() {
        self.onSiriButtonClick?()
    }
}

extension ContinueLastStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.updateViewColor()
    }

    func addSubviews() {
        self.labelsStackView.addArrangedSubview(self.courseNameLabel)
        self.labelsStackView.addArrangedSubview(self.progressLabel)

        self.infoStackView.addArrangedSubview(self.coverImageView)
        self.infoStackView.addArrangedSubview(self.labelsStackView)

        self.continueButtonBlock.addSubview(self.continueButton)
        self.contentStackView.addArrangedSubview(self.continueButtonBlock)
        if #available(iOS 12.0, *) {
            self.contentStackView.addArrangedSubview(self.siriButtonContainerView)
            self.siriButtonContainerView.addSubview(self.siriButton)
        }
        self.contentStackView.addArrangedSubview(self.infoStackView)

        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)

        self.overlayView.addSubview(self.contentStackView)
        self.overlayView.addSubview(self.progressView)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.center.equalTo(self.overlayView)
            make.size.equalTo(self.overlayView)
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.mainInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.mainInsets.right)
            make.top.equalToSuperview().offset(self.appearance.mainInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.mainInsets.bottom)
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
        }

        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.progressHeight)
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.coverSize)
        }

        self.continueButtonBlock.translatesAutoresizingMaskIntoConstraints = false
        self.continueButtonBlock.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.continueButtonHeight)
        }

        self.continueButton.translatesAutoresizingMaskIntoConstraints = false
        self.continueButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(self.appearance.continueButtonWidthRatio)
        }

        if #available(iOS 12.0, *) {
            self.siriButton.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(self.snp.width).multipliedBy(self.appearance.continueButtonWidthRatio)
            }
        }
    }
}
