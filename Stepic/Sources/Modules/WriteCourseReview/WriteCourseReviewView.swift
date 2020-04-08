import SnapKit
import UIKit

protocol WriteCourseReviewViewDelegate: AnyObject {
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateText text: String)
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateScore score: Int)
}

extension WriteCourseReviewView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let starsViewInsets = LayoutInsets(top: 16, left: 16, right: 16)
        let starsClearColor = UIColor.stepikAccent
        let starsSpacing: CGFloat = 10
        let starsSize = CGSize(width: 31.5, height: 31.5)

        let starsHintLabelInsets = LayoutInsets(top: 8)
        let starsHintLabelFont = UIFont.systemFont(ofSize: 12)
        let starsHintLabelTextColor = UIColor.stepikPrimaryText

        let separatorViewInsets = LayoutInsets(top: 16, left: 16)

        let textViewInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let textViewFont = UIFont.systemFont(ofSize: 16)
        let textViewTextColor = UIColor.stepikPrimaryText
        let textViewPlaceholderColor = UIColor.stepikPlaceholderText
    }
}

final class WriteCourseReviewView: UIView {
    let appearance: Appearance

    weak var delegate: WriteCourseReviewViewDelegate?

    private lazy var starsView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.starClearColor = self.appearance.starsClearColor
        appearance.starsSpacing = self.appearance.starsSpacing
        appearance.starsSize = self.appearance.starsSize
        let view = CourseRatingView(appearance: appearance)
        view.delegate = self
        return view
    }()

    private lazy var starsContainerView = UIView()

    private lazy var starsHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = self.appearance.starsHintLabelFont
        label.textColor = self.appearance.starsHintLabelTextColor
        label.text = NSLocalizedString("WriteCourseReviewRatingHint", comment: "")
        return label
    }()

    private lazy var separatorView = SeparatorView()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.textViewFont
        textView.textColor = self.appearance.textViewTextColor
        textView.placeholderColor = self.appearance.textViewPlaceholderColor
        textView.placeholder = NSLocalizedString("WriteCourseReviewPlaceholder", comment: "")
        textView.textInsets = .zero

        // Disable features
        textView.dataDetectorTypes = []

        textView.delegate = self

        return textView
    }()

    private var starsCount: Int {
        get {
             self.starsView.starsCount
        }
        set {
            if newValue != self.starsView.starsCount {
                self.starsView.starsCount = newValue
                self.delegate?.writeCourseReviewView(self, didUpdateScore: newValue)
            }
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

    override func becomeFirstResponder() -> Bool {
        self.textView.becomeFirstResponder()
    }

    func configure(viewModel: WriteCourseReviewViewModel) {
        self.textView.text = viewModel.text
        self.starsCount = viewModel.score
    }
}

extension WriteCourseReviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.starsContainerView.addSubview(self.starsView)
        self.addSubview(self.starsContainerView)
        self.addSubview(self.starsHintLabel)
        self.addSubview(self.separatorView)
        self.addSubview(self.textView)
    }

    func makeConstraints() {
        self.starsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.starsContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.starsViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.starsViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.starsViewInsets.right)
            make.height.equalTo(self.appearance.starsSize.height)
        }

        self.starsView.translatesAutoresizingMaskIntoConstraints = false
        self.starsView.snp.makeConstraints { make in
            make.top.leading.greaterThanOrEqualToSuperview()
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerY.centerX.equalToSuperview()
        }

        self.starsHintLabel.translatesAutoresizingMaskIntoConstraints = false
        self.starsHintLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.starsContainerView.snp.leading)
            make.trailing.equalTo(self.starsContainerView.snp.trailing)
            make.top
                .equalTo(self.starsContainerView.snp.bottom)
                .offset(self.appearance.starsHintLabelInsets.top)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.separatorViewInsets.left)
            make.trailing.equalToSuperview()
            make.top
                .equalTo(self.starsHintLabel.snp.bottom)
                .offset(self.appearance.separatorViewInsets.top)
        }

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.textViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.textViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.textViewInsets.bottom)
            make.top
                .equalTo(self.separatorView.snp.bottom)
                .offset(self.appearance.textViewInsets.top)
        }
    }
}

// MARK: - WriteCourseReviewView: CourseRatingViewDelegate -

extension WriteCourseReviewView: CourseRatingViewDelegate {
    func courseRatingView(_ view: CourseRatingView, didSelectStarAtIndex index: Int) {
        self.starsCount = index + 1
    }
}

// MARK: - WriteCourseReviewView: UITextViewDelegate -

extension WriteCourseReviewView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.writeCourseReviewView(self, didUpdateText: textView.text)
    }
}
