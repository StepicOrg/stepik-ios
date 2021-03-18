import SnapKit
import UIKit

extension FeedbackStoryFormView {
    struct Appearance {
        let cornerRadius: CGFloat = 13

        let titleLabelFont = UIFont.systemFont(ofSize: 22, weight: .bold)
        let titleLabelTextAlignment = NSTextAlignment.left
        let titleLabelMaxNumberOfLines = 2
        let titleLabelInsets = LayoutInsets(inset: 16)

        let iconImageViewSize = CGSize(width: 32, height: 32)
        let iconImageViewInsets = LayoutInsets(top: 16, right: 16)

        let inputTextViewFont = Typography.bodyFont
        let inputTextViewTextInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let inputTextViewInsets = LayoutInsets(inset: 16)
        let inputTextViewCornerRadius: CGFloat = 8
        let inputTextViewHeight: CGFloat = 112
    }
}

final class FeedbackStoryFormView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textAlignment = .left
        label.numberOfLines = self.appearance.titleLabelMaxNumberOfLines
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var inputTextView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.inputTextViewFont
        textView.textInsets = self.appearance.inputTextViewTextInsets
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = []
        textView.roundAllCorners(radius: self.appearance.inputTextViewCornerRadius)
        return textView
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.invalidateIntrinsicContentSize()
        }
    }

    var titleTextColor: UIColor {
        get {
            self.titleLabel.textColor
        }
        set {
            self.titleLabel.textColor = newValue
        }
    }

    var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = self.iconImage
        }
    }

    var inputBackgroundColor: UIColor? {
        didSet {
            self.inputTextView.backgroundColor = self.inputBackgroundColor
        }
    }

    var inputTextColor: UIColor? {
        didSet {
            self.inputTextView.textColor = self.inputTextColor
        }
    }

    var inputPlaceholderText: String? {
        didSet {
            self.inputTextView.placeholder = self.inputPlaceholderText
        }
    }

    var inputPlaceholderTextColor: UIColor {
        get {
            self.inputTextView.placeholderColor
        }
        set {
            self.inputTextView.placeholderColor = newValue
        }
    }

    var inputText: String {
        get {
            self.inputTextView.text
        }
        set {
            self.inputTextView.text = newValue
        }
    }

    override var isFirstResponder: Bool {
        self.inputTextView.isFirstResponder
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.titleLabelInsets.top
            + max(self.titleLabel.intrinsicContentSize.height, self.appearance.iconImageViewSize.height)
            + self.appearance.inputTextViewInsets.top
            + self.appearance.inputTextViewHeight
            + self.appearance.inputTextViewInsets.bottom
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

    override func resignFirstResponder() -> Bool {
        self.inputTextView.resignFirstResponder()
    }
}

extension FeedbackStoryFormView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.roundAllCorners(radius: self.appearance.cornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconImageView)
        self.addSubview(self.inputTextView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalTo(self.iconImageView.snp.leading).offset(-self.appearance.titleLabelInsets.right)
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.iconImageViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.iconImageViewInsets.right)
            make.size.equalTo(self.appearance.iconImageViewSize)
        }

        self.inputTextView.translatesAutoresizingMaskIntoConstraints = false
        self.inputTextView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.inputTextViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.inputTextViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.inputTextViewInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.inputTextViewInsets.right)
            make.height.equalTo(self.appearance.inputTextViewHeight)
        }
    }
}
