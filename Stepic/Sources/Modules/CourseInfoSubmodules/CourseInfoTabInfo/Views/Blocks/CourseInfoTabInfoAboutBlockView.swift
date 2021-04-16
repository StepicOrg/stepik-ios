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
        var headerViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 47)

        let contentTextViewInsets = UIEdgeInsets(top: 16, left: 47, bottom: 30, right: 47)
        let contentTextViewFont = Typography.subheadlineFont
        let contentTextViewTextColor = UIColor.stepikMaterialSecondaryText

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoTabInfoAboutBlockView: UIView {
    let appearance: Appearance

    weak var delegate: CourseInfoTabInfoAboutBlockViewDelegate?

    private lazy var headerView: CourseInfoTabInfoHeaderBlockView = {
        let view = CourseInfoTabInfoHeaderBlockView()
        view.icon = CourseInfoTabInfoView.Block.about.icon
        view.title = CourseInfoTabInfoView.Block.about.title
        return view
    }()

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
        self.addSubview(self.headerView)
        self.addSubview(self.processedContentView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right).priority(999)
        }

        self.processedContentView.translatesAutoresizingMaskIntoConstraints = false
        self.processedContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.contentTextViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.contentTextViewInsets.bottom)
            make.trailing.equalTo(self.headerView).priority(999)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.contentTextViewInsets.top)
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
