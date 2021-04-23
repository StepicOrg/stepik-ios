import SnapKit
import UIKit

protocol LessonFinishedDemoPanModalViewDelegate: AnyObject {
    func lessonFinishedDemoPanModalViewDidClickCloseButton(_ view: LessonFinishedDemoPanModalView)
    func lessonFinishedDemoPanModalViewDidClickActionButton(_ view: LessonFinishedDemoPanModalView)
}

extension LessonFinishedDemoPanModalView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let headerImageViewHeight: CGFloat = 136

        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)

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

final class LessonFinishedDemoPanModalView: UIView {
    weak var delegate: LessonFinishedDemoPanModalViewDelegate?

    let appearance: Appearance

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "finished-demo-lesson-modal-header"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
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

    private lazy var actionButton: UIButton = {
        var appearance = NextStepButton.Appearance()
        appearance.font = self.appearance.actionButtonFont
        appearance.cornerRadius = self.appearance.actionButtonCornerRadius

        let button = NextStepButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)

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

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleLabel.text = self.subtitle
        }
    }

    var actionButtonTitle: String? {
        didSet {
            self.actionButton.setTitle(self.actionButtonTitle, for: .normal)
        }
    }

    override var intrinsicContentSize: CGSize {
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

    @objc
    private func closeButtonClicked() {
        self.delegate?.lessonFinishedDemoPanModalViewDidClickCloseButton(self)
    }

    @objc
    private func actionButtonClicked() {
        self.delegate?.lessonFinishedDemoPanModalViewDidClickActionButton(self)
    }
}

extension LessonFinishedDemoPanModalView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.closeButton)

        self.scrollableStackView.addArrangedView(self.headerImageView)

        self.contentStackViewContainerView.addSubview(self.contentStackView)
        self.scrollableStackView.addArrangedView(self.contentStackViewContainerView)

        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.subtitleLabel)
        self.contentStackView.addArrangedSubview(SeparatorView())
        self.contentStackView.addArrangedSubview(self.actionButton)
    }

    func makeConstraints() {
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

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { $0.height.equalTo(self.appearance.actionButtonHeight) }

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

extension LessonFinishedDemoPanModalView: PanModalScrollable {
    var panScrollable: UIScrollView? { self.scrollableStackView.panScrollable }
}
