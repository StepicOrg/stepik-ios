import SnapKit
import UIKit

extension NewProfileUserActivityCurrentStreakView {
    struct Appearance {
        let imageViewSize = CGSize(width: 13, height: 20)
        let imageViewColorStreak = UIColor.stepikGreen
        let imageViewColorNoStreak = UIColor.stepikYellow

        let labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        let labelTextColor = UIColor.stepikSystemPrimaryText
        let labelInsets = LayoutInsets(left: 8)
    }
}

final class NewProfileUserActivityCurrentStreakView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "new_profile_user_activity_light")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewColorNoStreak
        imageView.isHidden = true
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.labelTextColor
        label.font = self.appearance.labelFont
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    var didSolveToday: Bool = false {
        didSet {
            self.imageView.tintColor = self.didSolveToday
                ? self.appearance.imageViewColorStreak
                : self.appearance.imageViewColorNoStreak
            self.imageView.isHidden = false
        }
    }

    var text: String? {
        didSet {
            self.label.text = self.text
            self.imageView.isHidden = false
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.label.intrinsicContentSize.height, self.appearance.imageViewSize.height)
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

extension NewProfileUserActivityCurrentStreakView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.label)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(self.appearance.imageViewSize.width)
            make.height.equalTo(self.appearance.imageViewSize.height)
        }

        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.snp.makeConstraints { make in
            make.leading
                .equalTo(self.imageView.snp.trailing)
                .offset(self.appearance.labelInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.imageView.snp.centerY)
        }
    }
}
