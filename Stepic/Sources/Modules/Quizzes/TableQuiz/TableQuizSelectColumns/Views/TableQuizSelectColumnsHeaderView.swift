import SnapKit
import UIKit

extension TableQuizSelectColumnsHeaderView {
    struct Appearance {
        let closeButtonWidthHeight: CGFloat = 32
        let closeButtonImageSize = CGSize(width: 24, height: 24)
        let closeButtonInsets = LayoutInsets(top: 8, right: 8)

        let promptFont = Typography.caption1Font
        let promptTextColor = UIColor.stepikSecondaryText

        let titleFont = Typography.bodyFont
        let titleTextColor = UIColor.stepikPrimaryText

        let contentStackViewSpacing: CGFloat = 16
        let contentStackViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let backgroundColor = UIColor.clear
    }
}

final class TableQuizSelectColumnsHeaderView: UIView {
    let appearance: Appearance

    private lazy var closeButton: SystemCloseButton = {
        let appearance = SystemCloseButton.Appearance(imageSize: self.appearance.closeButtonImageSize)
        let button = SystemCloseButton(appearance: appearance)
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.promptFont
        label.textColor = self.appearance.promptTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private lazy var titleProcessedContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.titleFont,
            labelTextColor: self.appearance.titleTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let contentProcessor = ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: self.appearance.titleFont),
                TextColorInjection(dynamicColor: self.appearance.titleTextColor)
            ]
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: contentProcessor,
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(font: self.appearance.titleFont)
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        return stackView
    }()

    private lazy var separatorView = SeparatorView()

    var onCloseClick: (() -> Void)?

    var prompt: String? {
        didSet {
            self.promptLabel.text = self.prompt
            self.promptLabel.isHidden = self.prompt?.isEmpty ?? true
        }
    }

    var title: String? {
        didSet {
            self.titleProcessedContentView.setText(self.title)
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentStackViewIntrinsicContentSize = self.contentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentStackViewHeightWithInsets = contentStackViewIntrinsicContentSize.height
            + self.appearance.contentStackViewInsets.top
            + self.appearance.contentStackViewInsets.bottom

        let height = contentStackViewHeightWithInsets.rounded(.up)

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
        self.invalidateIntrinsicContentSize()
    }

    @objc
    private func closeButtonClicked() {
        self.onCloseClick?()
    }
}

extension TableQuizSelectColumnsHeaderView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.contentStackView)
        self.contentStackView.addArrangedSubview(self.promptLabel)
        self.contentStackView.addArrangedSubview(self.titleProcessedContentView)

        self.addSubview(self.closeButton)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.contentStackViewInsets)
        }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(self.appearance.closeButtonWidthHeight)
            make.top.equalToSuperview().offset(self.appearance.closeButtonInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.closeButtonInsets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension TableQuizSelectColumnsHeaderView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.invalidateIntrinsicContentSize()
    }
}
