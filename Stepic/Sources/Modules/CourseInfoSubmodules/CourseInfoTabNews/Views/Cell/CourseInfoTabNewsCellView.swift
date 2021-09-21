import SnapKit
import UIKit

extension CourseInfoTabNewsCellView {
    struct Appearance {
        let dateLabelInsets = LayoutInsets(top: 20, left: 16, right: 16)
        let dateLabelFont = Typography.caption1Font
        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText

        let processedContentTextColor = UIColor.stepikMaterialSecondaryText
        let processedContentFont = UIFont.systemFont(ofSize: 15)
        let processedContentInsets = LayoutInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
}

final class CourseInfoTabNewsCellView: UIView {
    let appearance: Appearance

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var processedContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.processedContentFont,
            labelTextColor: self.appearance.processedContentTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: ContentProcessor(),
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(
                font: self.appearance.processedContentFont,
                tagTransformers: [.brTransformer]
            )
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    var onContentLoaded: (() -> Void)?
    var onNewHeightUpdate: (() -> Void)?

    var onImageClick: ((URL) -> Void)?
    var onLinkClick: ((URL) -> Void)?

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

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textContentHeight: CGFloat = {
            let textContentWidth = size.width
                - self.appearance.processedContentInsets.left
                - self.appearance.processedContentInsets.right

            let specifiedSize = CGSize(width: textContentWidth, height: size.height)
            let bestFitsSize = self.processedContentView.sizeThatFits(specifiedSize)

            return bestFitsSize.height
        }()

        let height = (
            self.appearance.dateLabelInsets.top
            + self.dateLabel.intrinsicContentSize.height
            + self.appearance.processedContentInsets.top
            + textContentHeight
            + self.appearance.processedContentInsets.bottom
        ).rounded(.up)

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    func configure(viewModel: CourseInfoTabNewsViewModel?) {
        guard let viewModel = viewModel else {
            self.dateLabel.text = nil
            self.processedContentView.setText(nil)
            return
        }

        self.dateLabel.text = viewModel.formattedDate
        self.processedContentView.processedContent = viewModel.processedContent
    }
}

extension CourseInfoTabNewsCellView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.dateLabel)
        self.addSubview(self.processedContentView)
    }

    func makeConstraints() {
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.dateLabelInsets.edgeInsets)
        }

        self.processedContentView.translatesAutoresizingMaskIntoConstraints = false
        self.processedContentView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(self.appearance.processedContentInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.processedContentInsets.edgeInsets)
        }
    }
}

// MARK: - CourseInfoTabNewsCellView: ProcessedContentViewDelegate -

extension CourseInfoTabNewsCellView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.onContentLoaded?()
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.onNewHeightUpdate?()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.onImageClick?(url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.onLinkClick?(url)
    }
}
