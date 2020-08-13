import SnapKit
import UIKit

extension CourseInfoTryForFreeButton {
    struct Appearance {
        let iconSize = CGSize(width: 11, height: 13)
        let spacing: CGFloat = 8

        let mainColor = UIColor.stepikGreen

        let textColor = UIColor.stepikGreen
        let textFont = UIFont.systemFont(ofSize: 16)
    }
}

final class CourseInfoTryForFreeButton: UIControl {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "step-next-navigation-icon")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.mainColor
        label.text = NSLocalizedString("CourseInfoTryForFreeButtonTitle", comment: "")
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.iconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.iconSize.height, self.textLabel.intrinsicContentSize.height)
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

extension CourseInfoTryForFreeButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.width.equalTo(self.appearance.iconSize.width)
            make.height.equalTo(self.appearance.iconSize.height)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.spacing)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }
    }
}
