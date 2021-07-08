import SnapKit
import UIKit

extension CourseInfoTabReviewsReviewButton {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 18, height: 18)
        let iconImageViewTintColor = UIColor.white
        let iconImageViewInsets = LayoutInsets.default

        let titleLabelFont = Typography.bodyFont
        let titleLabelTextColor = UIColor.white

        let cornerRadius: CGFloat = 8
        let backgroundColor = UIColor.stepikVioletFixed
    }
}

final class CourseInfoTabReviewsReviewButton: UIControl {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "course-info-reviews-write")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = self.appearance.iconImageViewTintColor
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
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

extension CourseInfoTabReviewsReviewButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
        self.setRoundedCorners(cornerRadius: self.appearance.cornerRadius)
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.iconImageViewInsets.left)
            make.size.equalTo(self.appearance.iconImageViewSize)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
