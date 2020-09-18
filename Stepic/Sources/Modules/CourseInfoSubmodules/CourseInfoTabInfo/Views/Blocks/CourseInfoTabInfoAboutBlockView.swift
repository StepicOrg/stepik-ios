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
        let contentTextViewFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let contentTextViewTextColor = UIColor.stepikSystemSecondaryText
        let contentTextViewLineSpacing: CGFloat = 2.6

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

    private lazy var processedContentTextView: ProcessedContentWebView = {
        var appearance = ProcessedContentWebView.Appearance(
            insets: LayoutInsets(insets: .zero),
            backgroundColor: self.appearance.backgroundColor
        )
        let view = ProcessedContentWebView(appearance: appearance)
        view.delegate = self
        return view
    }()

    private lazy var contentTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.contentTextViewFont
        label.textColor = self.appearance.contentTextViewTextColor
        return label
    }()

    private let isWebViewSupportNeeded: Bool

    var text: String? {
        didSet {
            if self.isWebViewSupportNeeded {
                self.processedContentTextView.loadHTMLText(self.text ?? "")
            } else {
                self.contentTextLabel.setTextWithHTMLString(
                    self.text ?? "",
                    lineSpacing: self.appearance.contentTextViewLineSpacing
                )
                self.delegate?.courseInfoTabInfoAboutBlockViewDidLoadContent(self)
            }
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        isWebViewSupportNeeded: Bool
    ) {
        self.appearance = appearance
        self.isWebViewSupportNeeded = isWebViewSupportNeeded
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

        if self.isWebViewSupportNeeded {
            self.addSubview(self.processedContentTextView)
        } else {
            self.addSubview(self.contentTextLabel)
        }
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.headerViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerViewInsets.right).priority(999)
        }

        let contentTextView = self.isWebViewSupportNeeded ? self.processedContentTextView : self.contentTextLabel
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.contentTextViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.contentTextViewInsets.bottom)
            make.trailing.equalTo(self.headerView).priority(999)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.contentTextViewInsets.top)
        }
    }
}

extension CourseInfoTabInfoAboutBlockView: ProcessedContentWebViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentWebView) {
        self.delegate?.courseInfoTabInfoAboutBlockViewDidLoadContent(self)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenImageURL url: URL) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenImageURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenNativeImage image: UIImage) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenImage: image)
    }

    func processedContentTextView(_ view: ProcessedContentWebView, didOpenLink url: URL) {
        self.delegate?.courseInfoTabInfoAboutBlockView(self, didOpenURL: url)
    }
}
