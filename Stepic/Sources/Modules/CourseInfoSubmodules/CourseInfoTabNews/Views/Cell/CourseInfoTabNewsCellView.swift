import SnapKit
import UIKit

extension CourseInfoTabNewsCellView {
    struct Appearance {
        let dateLabelFont = Typography.caption1Font
        let dateLabelTextColor = UIColor.stepikMaterialSecondaryText

        let subjectLabelFont = Typography.headlineFont
        let subjectLabelTextColor = UIColor.stepikMaterialPrimaryText

        let processedContentTextColor = UIColor.stepikMaterialSecondaryText
        let processedContentFont = UIFont.systemFont(ofSize: 15)

        let contentStackViewInsets = LayoutInsets(top: 20, left: 16, bottom: 16, right: 16)
        let contentStackViewSpacing: CGFloat = 8
    }
}

final class CourseInfoTabNewsCellView: UIView {
    let appearance: Appearance

    private lazy var badgesView: CourseInfoTabNewsBadgesView = {
        let view = CourseInfoTabNewsBadgesView()
        view.isHidden = true
        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var subjectLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subjectLabelFont
        label.textColor = self.appearance.subjectLabelTextColor
        label.numberOfLines = 0
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

    private lazy var statisticsView: CourseInfoTabNewsStatisticsView = {
        let view = CourseInfoTabNewsStatisticsView()
        view.isHidden = true
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.contentStackViewSpacing
        return stackView
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
                - self.appearance.contentStackViewInsets.left
                - self.appearance.contentStackViewInsets.right

            let specifiedSize = CGSize(width: textContentWidth, height: size.height)
            let bestFitsSize = self.processedContentView.sizeThatFits(specifiedSize)

            return bestFitsSize.height
        }()

        let height = (
            self.appearance.contentStackViewInsets.top
                + (self.badgesView.isHidden ? 0 : self.badgesView.intrinsicContentSize.height)
                + (self.badgesView.isHidden ? 0 : self.appearance.contentStackViewSpacing)
                + self.dateLabel.intrinsicContentSize.height
                + (self.subjectLabel.isHidden ? 0 : self.appearance.contentStackViewSpacing)
                + (self.subjectLabel.isHidden ? 0 : self.subjectLabel.intrinsicContentSize.height)
                + self.appearance.contentStackViewSpacing
                + textContentHeight
                + (self.statisticsView.isHidden ? 0 : self.appearance.contentStackViewSpacing)
                + (self.statisticsView.isHidden ? 0 : self.statisticsView.intrinsicContentSize.height)
                + self.appearance.contentStackViewInsets.bottom
        ).rounded(.up)

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    func configure(viewModel: CourseInfoTabNewsViewModel?) {
        guard let viewModel = viewModel else {
            self.badgesView.isHidden = true
            self.dateLabel.text = nil
            self.subjectLabel.text = nil
            self.processedContentView.setText(nil)
            self.statisticsView.isHidden = true
            return
        }

        if let badgeViewModel = viewModel.badge {
            self.badgesView.isHidden = false
            self.badgesView.configure(viewModel: badgeViewModel)
        } else {
            self.badgesView.isHidden = true
        }

        self.dateLabel.text = viewModel.formattedDate

        self.subjectLabel.text = viewModel.subject
        self.subjectLabel.isHidden = viewModel.subject.isEmpty

        self.processedContentView.processedContent = viewModel.processedContent

        if let statisticsViewModel = viewModel.statistics {
            self.statisticsView.isHidden = false
            self.statisticsView.configure(viewModel: statisticsViewModel)
        } else {
            self.statisticsView.isHidden = true
        }
    }
}

extension CourseInfoTabNewsCellView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.contentStackView)

        self.contentStackView.addArrangedSubview(self.badgesView)
        self.contentStackView.addArrangedSubview(self.dateLabel)
        self.contentStackView.addArrangedSubview(self.subjectLabel)
        self.contentStackView.addArrangedSubview(self.processedContentView)
        self.contentStackView.addArrangedSubview(self.statisticsView)
    }

    func makeConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.contentStackViewInsets.edgeInsets)
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
