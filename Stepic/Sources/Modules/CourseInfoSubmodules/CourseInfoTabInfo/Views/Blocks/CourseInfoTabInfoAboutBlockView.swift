import SnapKit
import UIKit

protocol CourseInfoTabInfoAboutBlockViewDelegate: AnyObject {
    func courseInfoTabInfoAboutBlockViewDidLoadContent(_ view: CourseInfoTabInfoAboutBlockView)
    func courseInfoTabInfoAboutBlockView(_ view: CourseInfoTabInfoAboutBlockView, didOpenURL url: URL)
    func courseInfoTabInfoAboutBlockView(_ view: CourseInfoTabInfoAboutBlockView, didOpenImageURL url: URL)
    func courseInfoTabInfoAboutBlockView(_ view: CourseInfoTabInfoAboutBlockView, didOpenImage image: UIImage)
}

extension CourseInfoTabInfoAboutBlockView {
    struct Appearance {
        var titleLabelAppearance = CourseInfoTabInfoLabel.Appearance(
            maxLinesCount: 1,
            font: Typography.headlineFont,
            textColor: UIColor.stepikMaterialPrimaryText
        )
        var titleLabelInsets = LayoutInsets(left: 16, right: 16)

        let contentTextViewInsets = LayoutInsets(top: 20, left: 16, right: 16)
        let contentTextViewFont = Typography.subheadlineFont
        let contentTextViewTextColor = UIColor.stepikMaterialSecondaryText

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoTabInfoAboutBlockView: UIView {
    let appearance: Appearance

    weak var delegate: CourseInfoTabInfoAboutBlockViewDelegate?

    private lazy var titleLabel = CourseInfoTabInfoLabel(appearance: self.appearance.titleLabelAppearance)

    private lazy var processedContentView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.contentTextViewFont,
            labelTextColor: self.appearance.contentTextViewTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: self.appearance.backgroundColor
        )

        let contentProcessor = ContentProcessor(
            rules: ContentProcessor.defaultRules,
            injections: ContentProcessor.defaultInjections + [
                FontInjection(font: self.appearance.contentTextViewFont),
                TextColorInjection(dynamicColor: self.appearance.contentTextViewTextColor)
            ]
        )

        let processedContentView = ProcessedContentView(
            frame: .zero,
            appearance: appearance,
            contentProcessor: contentProcessor,
            htmlToAttributedStringConverter: HTMLToAttributedStringConverter(font: self.appearance.contentTextViewFont)
        )
        processedContentView.delegate = self

        return processedContentView
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var text: String? {
        didSet {
            self.processedContentView.setText(self.text)
        }
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

extension CourseInfoTabInfoAboutBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.processedContentView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.titleLabelInsets.edgeInsets)
        }

        self.processedContentView.translatesAutoresizingMaskIntoConstraints = false
        self.processedContentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.contentTextViewInsets.top)
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.contentTextViewInsets.edgeInsets)
        }
    }
}

extension CourseInfoTabInfoAboutBlockView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.delegate?.courseInfoTabInfoAboutBlockViewDidLoadContent(self)
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenImageURL: url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenNativeImage image: UIImage) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenImage: image)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenURL: url)
    }
}
