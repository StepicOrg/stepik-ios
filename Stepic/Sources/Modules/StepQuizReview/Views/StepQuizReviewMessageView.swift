import SnapKit
import UIKit

extension StepQuizReviewMessageView {
    struct Appearance {
        let backgroundColor = UIColor.stepikOverlayViolet
        let cornerRadius: CGFloat = 6
        let tintColor = UIColor.dynamic(light: .stepikVioletFixed, dark: .stepikViolet05Fixed)
        let insets = LayoutInsets.default

        let titleFont = UIFont.systemFont(ofSize: 16)
        let imageViewSize = CGSize(width: 26, height: 26)
    }
}

final class StepQuizReviewMessageView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.tintColor
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.tintColor
        label.numberOfLines = 0
        return label
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let contentHeight = max(self.appearance.imageViewSize.height, self.titleLabel.intrinsicContentSize.height)
        let height = self.appearance.insets.top + contentHeight + self.appearance.insets.bottom
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
}

extension StepQuizReviewMessageView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.setRoundedCorners(cornerRadius: self.appearance.cornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.size.equalTo(self.appearance.imageViewSize)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.insets.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.insets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalToSuperview()
        }
    }
}
