import Atributika
import SnapKit
import UIKit

extension CourseInfoPurchaseFeedbackView {
    struct Appearance {
        let tintColor = UIColor.white
        let backgroundColor = UIColor.white.withAlphaComponent(0.12)
        let cornerRadius: CGFloat = 6

        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleMinHeight: CGFloat = 18
        let titleInsets = LayoutInsets.default

        let iconImageViewInsets = LayoutInsets(horizontal: 16)
        let iconImageViewSize = CGSize(width: 24, height: 26)
    }
}

final class CourseInfoPurchaseFeedbackView: UIView {
    let appearance: Appearance

    private lazy var htmlToAttributedStringConverter = HTMLToAttributedStringConverter(font: self.appearance.titleFont)

    private lazy var titleLabel: AttributedLabel = {
        let label = AttributedLabel()
        label.textColor = self.appearance.tintColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 0
        return label
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.tintColor
        return imageView
    }()

    override var intrinsicContentSize: CGSize {
        let titleLabelHeight = self.titleLabel.sizeThatFits(CGSize(width: self.bounds.width, height: .infinity)).height
        let height = self.appearance.titleInsets.top
            + max(self.appearance.titleMinHeight, titleLabelHeight)
            + self.appearance.titleInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    func set(title: String) {
        self.titleLabel.attributedText = self.htmlToAttributedStringConverter.convertToAttributedText(htmlString: title)

        self.titleLabel.sizeToFit()
        self.titleLabel.setNeedsLayout()

        self.invalidateIntrinsicContentSize()
    }
}

extension CourseInfoPurchaseFeedbackView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconImageView)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.iconImageViewInsets.left)
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-self.appearance.iconImageViewInsets.right)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(self.appearance.iconImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
            make.centerY.equalToSuperview()
        }
    }
}
