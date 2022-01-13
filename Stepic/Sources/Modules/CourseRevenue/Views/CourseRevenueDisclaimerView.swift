import SnapKit
import UIKit

extension CourseRevenueDisclaimerView {
    struct Appearance {
        let imageViewSize = CGSize(width: 24, height: 24)
        let imageViewTintColor = UIColor.stepikVioletFixed

        let labelFont = Typography.caption1Font
        let labelTextColor = UIColor.stepikMaterialSecondaryText
        let labelInsets = LayoutInsets(left: 8)
    }
}

final class CourseRevenueDisclaimerView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "quiz-feedback-info")?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.numberOfLines = 0
        return label
    }()

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.imageViewSize.height, self.textLabel.intrinsicContentSize.height)
        )
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseRevenueDisclaimerView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.imageViewSize)
            make.centerY.equalTo(self.textLabel.snp.centerY)
            make.leading.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.labelInsets.left)
        }
    }
}
