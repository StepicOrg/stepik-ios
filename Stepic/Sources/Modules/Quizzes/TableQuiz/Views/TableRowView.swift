import SnapKit
import UIKit

extension TableRowView {
    struct Appearance {
        let titleFont = Typography.bodyFont
        let titleTextColor = UIColor.stepikPrimaryText

        let subtitleFont = Typography.subheadlineFont
        let subtitleTextColor = UIColor.stepikSecondaryText

        let labelsStackViewSpacing: CGFloat = 8
        let labelsStackViewInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 8)

        let showAllButtonInsets = LayoutInsets(left: 8, right: 16)
    }
}

final class TableRowView: UIControl {
    let appearance: Appearance

    private lazy var titleProcessedContentView: ProcessedContentView = {
        let processedContentView = self.makeProcessedContentView(
            font: self.appearance.titleFont,
            textColor: self.appearance.titleTextColor
        )
        processedContentView.delegate = self
        return processedContentView
    }()

    private lazy var subtitleProcessedContentView: ProcessedContentView = {
        let processedContentView = self.makeProcessedContentView(
            font: self.appearance.subtitleFont,
            textColor: self.appearance.subtitleTextColor
        )
        processedContentView.delegate = self
        return processedContentView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.labelsStackViewSpacing
        return stackView
    }()

    private lazy var showAllButton: ShowAllButton = {
        let button = ShowAllButton()
        button.title = nil
        return button
    }()

    private lazy var tapProxyView = TapProxyView(targetView: self)

    var title: String? {
        didSet {
            self.titleProcessedContentView.setText(self.title)
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleProcessedContentView.setText(self.subtitle)
            self.subtitleProcessedContentView.isHidden = self.subtitle?.isEmpty ?? true
        }
    }

    var onClick: (() -> Void)?

    override var isEnabled: Bool {
        didSet {
            self.updateContentSubviewsAlpha(self.isEnabled ? 1.0 : 0.5)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.updateContentSubviewsAlpha(self.isHighlighted ? 0.5 : 1.0)
        }
    }

    override var intrinsicContentSize: CGSize {
        let labelsStackViewIntrinsicContentSize = self.labelsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let labelsStackViewHeightWithInsets = labelsStackViewIntrinsicContentSize.height
            + self.appearance.labelsStackViewInsets.top
            + self.appearance.labelsStackViewInsets.bottom

        let height = labelsStackViewHeightWithInsets.rounded(.up)

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

    @objc
    private func clicked() {
        self.onClick?()
    }

    private func updateContentSubviewsAlpha(_ alpha: CGFloat) {
        self.titleProcessedContentView.alpha = alpha
        self.subtitleProcessedContentView.alpha = alpha
        self.showAllButton.alpha = alpha
    }

    private func makeProcessedContentView(font: UIFont, textColor: UIColor) -> ProcessedContentView {
        let appearance = ProcessedContentView.Appearance(
            labelFont: font,
            labelTextColor: textColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let contentProcessor = ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: font),
                TextColorInjection(dynamicColor: textColor)
            ]
        )

        return ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: contentProcessor,
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(font: font)
        )
    }
}

extension TableRowView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.addTarget(self, action: #selector(self.clicked), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.labelsStackView)
        self.labelsStackView.addArrangedSubview(self.titleProcessedContentView)
        self.labelsStackView.addArrangedSubview(self.subtitleProcessedContentView)

        self.addSubview(self.showAllButton)
        self.addSubview(self.tapProxyView)
    }

    func makeConstraints() {
        self.labelsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.labelsStackViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsStackViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.labelsStackViewInsets.bottom)
        }

        self.showAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.showAllButton.snp.makeConstraints { make in
            make.leading
                .equalTo(self.labelsStackView.snp.trailing)
                .offset(self.appearance.showAllButtonInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.showAllButtonInsets.right)
            make.centerY.equalToSuperview()
        }

        self.tapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.tapProxyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TableRowView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.invalidateIntrinsicContentSize()
    }
}
