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

        let shadowColor = UIColor(hex6: 0xEAECF0)
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4
    }
}

final class NewMatchingQuizTitleView: UIView {
    let appearance: Appearance
    weak var delegate: NewMatchingQuizTitleViewDelegate?

    private lazy var quizElementView = QuizElementView()
    private lazy var contentTextView: ProcessedContentTextView = {
        var appearance = ProcessedContentTextView.Appearance(
            insets: LayoutInsets(insets: .zero),
            backgroundColor: .clear
        )
        let view = ProcessedContentTextView(appearance: appearance)
        view.isScrollEnabled = false
        view.delegate = self
        return view
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
            self.shadowView.isHidden = !self.isShadowVisible
        }
    }

    var title: String? {
        didSet {
            self.contentTextView.loadHTMLText(self.title ?? "")
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

extension NewMatchingQuizTitleView: ProcessedContentTextViewDelegate {
    func processedContentTextViewDidLoadContent(_ view: ProcessedContentTextView) {
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
        self.delegate?.newMatchingQuizTitleViewDidLoadContent(self)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenLink url: URL) {
        self.delegate?.newMatchingQuizTitleView(self, didRequestOpenURL: url)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImageURL url: URL) {
        self.delegate?.newMatchingQuizTitleView(self, didRequestFullscreenImage: url)
    }

    func processedContentTextView(_ view: ProcessedContentTextView, didOpenImage image: UIImage) {}
}
