import SnapKit
import UIKit

protocol WriteCourseReviewViewDelegate: class {
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateReview review: String)
    func writeCourseReviewView(_ view: WriteCourseReviewView, didUpdateRating rating: Int)
}

extension WriteCourseReviewView {
    struct Appearance {
        let backgroundColor = UIColor.white

        let starsViewInsets = LayoutInsets(top: 16, left: 16, right: 16)
        let clearStarsColor = UIColor.mainDark
        let starsSpacing: CGFloat = 10
        let starsSize = CGSize(width: 31.5, height: 31.5)

        let ratingMessageInsets = LayoutInsets(top: 8)
        let ratingMessageFont = UIFont.systemFont(ofSize: 12)
        let ratingMessageTextColor = UIColor.mainDark

        let separatorViewInsets = LayoutInsets(top: 16, left: 16)

        let textViewInsets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let textViewFont = UIFont.systemFont(ofSize: 16)
        let textViewTextColor = UIColor.mainDark
        let textViewPlaceholderColor = UIColor.mainDark.withAlphaComponent(0.4)
    }
}

final class WriteCourseReviewView: UIView {
    let appearance: Appearance

    weak var delegate: WriteCourseReviewViewDelegate?

    private lazy var starsRatingView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.statClearColor = self.appearance.clearStarsColor
        appearance.starsSpacing = self.appearance.starsSpacing
        appearance.starsSize = self.appearance.starsSize
        let view = CourseRatingView(appearance: appearance)
        view.delegate = self
        return view
    }()

    private lazy var starsRatingContainerView = UIView()

    private lazy var ratingMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = self.appearance.ratingMessageFont
        label.textColor = self.appearance.ratingMessageTextColor
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
            return self.starsRatingView.starsCount
        }
        set {
            if newValue != self.starsRatingView.starsCount {
                self.starsRatingView.starsCount = newValue
                self.delegate?.writeCourseReviewView(self, didUpdateRating: newValue)
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

    func configure(viewModel: WriteCourseReviewViewModel) {
        self.textView.text = viewModel.review
        self.starsCount = viewModel.rating
    }
}

extension WriteCourseReviewView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.starsRatingContainerView.addSubview(self.starsRatingView)
        self.addSubview(self.starsRatingContainerView)
        self.addSubview(self.ratingMessageLabel)
        self.addSubview(self.separatorView)
        self.addSubview(self.textView)
    }

    func makeConstraints() {
        self.starsRatingContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.starsRatingContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.starsViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.starsViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.starsViewInsets.right)
            make.height.equalTo(self.appearance.starsSize.height)
        }

        self.starsRatingView.translatesAutoresizingMaskIntoConstraints = false
        self.starsRatingView.snp.makeConstraints { make in
            make.top.leading.greaterThanOrEqualToSuperview()
            make.trailing.bottom.lessThanOrEqualToSuperview()
            make.centerY.centerX.equalToSuperview()
        }

        self.ratingMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.ratingMessageLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.starsRatingContainerView.snp.leading)
            make.trailing.equalTo(self.starsRatingContainerView.snp.trailing)
            make.top
                .equalTo(self.starsRatingContainerView.snp.bottom)
                .offset(self.appearance.ratingMessageInsets.top)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.separatorViewInsets.left)
            make.trailing.equalToSuperview()
            make.top
                .equalTo(self.ratingMessageLabel.snp.bottom)
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
        self.delegate?.writeCourseReviewView(self, didUpdateReview: textView.text)
    }
}
