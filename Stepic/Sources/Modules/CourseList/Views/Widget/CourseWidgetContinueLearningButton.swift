import SnapKit
import UIKit

extension CourseWidgetContinueLearningButton {
    struct Appearance {
        let iconSize = CGSize(width: 11, height: 13)
        let iconInsets = LayoutInsets(left: 16)
        var iconTintColor = UIColor.stepikGreen

        let textFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        var textColor = UIColor.stepikGreen
    }
}

final class CourseWidgetContinueLearningButton: UIControl {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "step-next-navigation-icon")
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = self.appearance.iconTintColor
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.textColor
        label.textAlignment = .center
        label.text = NSLocalizedString("WidgetButtonLearn", comment: "")
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.iconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: .zero)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseWidgetContinueLearningButton: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.iconImageView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading
                .trailing
                .centerY
                .equalToSuperview()
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading
                .equalToSuperview()
                .offset(self.appearance.iconInsets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.iconSize)
        }
    }
}
