import SnapKit
import UIKit

protocol NewMatchingQuizTitleViewDelegate: AnyObject {
    func newMatchingQuizTitleViewDidLoadContent(_ view: NewMatchingQuizTitleView)
    func newMatchingQuizTitleView(_ view: NewMatchingQuizTitleView, didRequestFullscreenImage url: URL)
    func newMatchingQuizTitleView(_ view: NewMatchingQuizTitleView, didRequestOpenURL url: URL)
}

extension NewMatchingQuizTitleView {
    struct Appearance {
        var containerInsets = LayoutInsets(top: 12, left: 16, bottom: 10, right: 64)
        let contentInsets = LayoutInsets(top: 12, left: 16, bottom: 12, right: 16)

        let shadowColor = UIColor.stepikShadowFixed
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4

        let contentTextViewFont = Typography.quizContent
        let contentTextViewTextColor = UIColor.stepikPrimaryText
    }
}

final class NewMatchingQuizTitleView: UIView {
    let appearance: Appearance
    weak var delegate: NewMatchingQuizTitleViewDelegate?

    private lazy var quizElementView = QuizElementView()

    private lazy var contentTextView: ProcessedContentView = {
        let appearance = ProcessedContentView.Appearance(
            labelFont: self.appearance.contentTextViewFont,
            labelTextColor: self.appearance.contentTextViewTextColor,
            activityIndicatorViewStyle: .stepikGray,
            activityIndicatorViewColor: nil,
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
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

    private lazy var shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.backgroundColor = .clear
        view.layer.shadowColor = self.appearance.shadowColor.cgColor
        view.layer.shadowOffset = self.appearance.shadowOffset
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = self.appearance.shadowRadius
        return view
    }()

    override var intrinsicContentSize: CGSize {
        let contentHeight = self.contentTextView.intrinsicContentSize.height
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: (self.appearance.containerInsets.top + self.appearance.containerInsets.bottom) * 2 + contentHeight
        )
    }

    var isShadowVisible: Bool = true {
        didSet {
            self.updateShadowVisibility()
        }
    }

    var title: String? {
        didSet {
            self.contentTextView.setText(self.title)
            self.invalidateIntrinsicContentSize()
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.invalidateIntrinsicContentSize()

        DispatchQueue.main.async {
            self.shadowView.layer.shadowPath = UIBezierPath(
                roundedRect: self.shadowView.bounds,
                cornerRadius: self.quizElementView.appearance.cornerRadius
            ).cgPath
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateShadowVisibility()
        }
    }

    private func updateShadowVisibility() {
        if self.isDarkInterfaceStyle {
            self.shadowView.isHidden = true
        } else {
            self.shadowView.isHidden = !self.isShadowVisible
        }
    }
}

extension NewMatchingQuizTitleView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.quizElementView.addSubview(self.contentTextView)

        self.addSubview(self.quizElementView)
        self.insertSubview(self.shadowView, belowSubview: self.quizElementView)
    }

    func makeConstraints() {
        self.quizElementView.translatesAutoresizingMaskIntoConstraints = false
        self.quizElementView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.containerInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.containerInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.containerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.containerInsets.right)
        }

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.center.equalTo(self.quizElementView)
            make.size.equalTo(self.quizElementView)
        }

        self.contentTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.contentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.contentInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.contentInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.contentInsets.right)
        }
    }
}

extension NewMatchingQuizTitleView: ProcessedContentViewDelegate {
    func processedContentViewDidLoadContent(_ view: ProcessedContentView) {
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()

        self.delegate?.newMatchingQuizTitleViewDidLoadContent(self)
    }

    func processedContentView(_ view: ProcessedContentView, didReportNewHeight height: Int) {
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }

    func processedContentView(_ view: ProcessedContentView, didOpenImageURL url: URL) {
        self.delegate?.newMatchingQuizTitleView(self, didRequestFullscreenImage: url)
    }

    func processedContentView(_ view: ProcessedContentView, didOpenLink url: URL) {
        self.delegate?.newMatchingQuizTitleView(self, didRequestOpenURL: url)
    }
}
