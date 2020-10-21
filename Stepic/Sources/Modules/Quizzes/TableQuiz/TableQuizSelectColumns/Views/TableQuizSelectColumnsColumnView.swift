import BEMCheckBox
import SnapKit
import UIKit

extension TableQuizSelectColumnsColumnView {
    struct Appearance {
        let checkBoxLineWidth: CGFloat = 2
        let checkBoxAnimationDuration: CGFloat = 0.5
        let checkBoxTintColor = UIColor.stepikAccentFixed
        let checkBoxOnCheckColor = UIColor.white
        let checkBoxOnFillColor = UIColor.stepikAccentFixed
        let checkBoxOnTintColor = UIColor.stepikAccentFixed
        let checkBoxWidthHeight: CGFloat = 20
        let checkBoxInsets = LayoutInsets(left: 16)

        let titleFont = Typography.bodyFont
        let titleTextColor = UIColor.stepikPrimaryText
        let titleInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)

        let contentViewMinHeight: CGFloat = 44

        let backgroundColor = UIColor.stepikBackground
    }
}

final class TableQuizSelectColumnsColumnView: UIControl {
    let appearance: Appearance

    private lazy var checkBox: BEMCheckBox = {
        let checkBox = BEMCheckBox()
        checkBox.lineWidth = self.appearance.checkBoxLineWidth
        checkBox.hideBox = false
        checkBox.boxType = .circle
        checkBox.tintColor = self.appearance.checkBoxTintColor
        checkBox.onCheckColor = self.appearance.checkBoxOnCheckColor
        checkBox.onFillColor = self.appearance.checkBoxOnFillColor
        checkBox.onTintColor = self.appearance.checkBoxOnTintColor
        checkBox.animationDuration = self.appearance.checkBoxAnimationDuration
        checkBox.onAnimationType = .fill
        checkBox.offAnimationType = .fill
        return checkBox
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

    private lazy var contentView = UIView()

    private lazy var tapProxyView = TapProxyView(targetView: self)

    var isOn: Bool { self.checkBox.on }

    var onValueChanged: ((Bool) -> Void)?

    override var isHighlighted: Bool {
        didSet {
            self.titleProcessedContentView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let titleProcessedContentViewIntrinsicContentSize = self.titleProcessedContentView.intrinsicContentSize
        let titleProcessedContentViewHeightWithInsets = titleProcessedContentViewIntrinsicContentSize.height
            + self.appearance.titleInsets.top
            + self.appearance.titleInsets.bottom

        let height = max(self.appearance.contentViewMinHeight, titleProcessedContentViewHeightWithInsets)

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

    func setOn(_ isOn: Bool, animated: Bool) {
        self.checkBox.setOn(isOn, animated: animated)
    }

    func setTitle(_ title: String) {
        self.titleProcessedContentView.setText(title)
    }

    @objc
    private func clicked() {
        let newValue = !self.checkBox.on
        self.onValueChanged?(newValue)
    }
}

extension TableQuizSelectColumnsColumnView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.contentView.backgroundColor = self.appearance.backgroundColor

        self.addTarget(self, action: #selector(self.clicked), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.checkBox)
        self.contentView.addSubview(self.titleProcessedContentView)

        self.addSubview(self.tapProxyView)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(self.appearance.contentViewMinHeight)
        }

        self.checkBox.translatesAutoresizingMaskIntoConstraints = false
        self.checkBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.checkBoxInsets.left)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(self.appearance.checkBoxWidthHeight)
        }

        self.titleProcessedContentView.translatesAutoresizingMaskIntoConstraints = false
        self.titleProcessedContentView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleInsets.top)
            make.leading.equalTo(self.checkBox.snp.trailing).offset(self.appearance.titleInsets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
            make.centerY.equalToSuperview()
        }

        self.tapProxyView.translatesAutoresizingMaskIntoConstraints = false
        self.tapProxyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TableQuizSelectColumnsColumnView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.invalidateIntrinsicContentSize()
    }
}
