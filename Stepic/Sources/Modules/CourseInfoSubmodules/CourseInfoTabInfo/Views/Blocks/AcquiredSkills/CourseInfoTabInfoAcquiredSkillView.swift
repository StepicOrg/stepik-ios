import SnapKit
import UIKit

extension CourseInfoTabInfoAcquiredSkillView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 16, height: 16)
        let iconImageViewTintColor = UIColor.stepikGreenFixed

        var titleLabelAppearance = CourseInfoTabInfoLabel.Appearance(
            maxLinesCount: 0,
            font: Typography.subheadlineFont,
            textColor: UIColor.stepikMaterialSecondaryText
        )
        var titleLabelInsets = LayoutInsets(left: 16)
    }
}

final class CourseInfoTabInfoAcquiredSkillView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "quiz-feedback-correct")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageViewTintColor
        return imageView
    }()

    private lazy var titleLabel = CourseInfoTabInfoLabel(appearance: self.appearance.titleLabelAppearance)

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.iconImageViewSize.height, self.titleLabel.intrinsicContentSize.height)
        )
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

extension CourseInfoTabInfoAcquiredSkillView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(self.appearance.iconImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
        }
    }
}
