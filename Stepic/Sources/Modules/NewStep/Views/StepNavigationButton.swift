import SnapKit
import UIKit

extension StepNavigationButton {
    struct Appearance {
        let iconSize = CGSize(width: 11, height: 13)
        let insets = LayoutInsets(left: 16, right: 16)

        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 6

        let backgroundColor = UIColor.white
        let mainColor = UIColor.stepicGreen

        let textColor = UIColor.stepicGreen
        let textFont = UIFont.systemFont(ofSize: 16)
    }
}

final class StepNavigationButton: UIControl {
    let appearance: Appearance
    let type: Type
    let isCentered: Bool

    private lazy var contentStackView: UIStackView = {
        let stackView: UIStackView
        switch self.type {
        case .previous:
            stackView = UIStackView(arrangedSubviews: [self.iconImageContainerView, self.textLabel])
        case .next:
            stackView = UIStackView(arrangedSubviews: [self.textLabel, self.iconImageContainerView])
        }
        stackView.axis = .horizontal
        stackView.clipsToBounds = false
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var iconImageContainerView = UIView()

    private lazy var iconImageView: UIImageView = {
        let image: UIImage?
        switch self.type {
        case .previous:
            image = UIImage(named: "step-previous-navigation-icon")
        case .next:
            image = UIImage(named: "step-next-navigation-icon")
        }
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.mainColor
        switch self.type {
        case .previous:
            label.text = NSLocalizedString("PreviousLessonNavigation", comment: "")
        case .next:
            label.text = NSLocalizedString("NextLessonNavigation", comment: "")
        }

        switch (self.type, self.isCentered) {
        case (_, true):
            label.textAlignment = .center
        case (.previous, false):
            label.textAlignment = .right
        case (.next, false):
            label.textAlignment = .left
        }
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.iconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    var isTitleHidden = false {
        didSet {
            self.textLabel.isHidden = self.isTitleHidden
        }
    }

    init(frame: CGRect = .zero, type: Type, isCentered: Bool, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.type = type
        self.isCentered = isCentered
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Enums

    enum `Type` {
        case previous
        case next
    }
}

extension StepNavigationButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius

        self.backgroundColor = self.appearance.backgroundColor
        self.layer.borderColor = self.appearance.mainColor.cgColor
        self.layer.borderWidth = self.appearance.borderWidth
    }

    func addSubviews() {
        if self.isCentered {
            self.addSubview(self.textLabel)
            self.addSubview(self.iconImageView)
        } else {
            self.iconImageContainerView.addSubview(self.iconImageView)
            self.addSubview(self.contentStackView)
        }
    }

    func makeConstraints() {
        if self.isCentered {
            self.textLabel.translatesAutoresizingMaskIntoConstraints = false
            self.textLabel.snp.makeConstraints { make in
                make.leading.trailing.centerY.equalToSuperview()
            }

            self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
            self.iconImageView.snp.makeConstraints { make in
                switch self.type {
                case .previous:
                    make.leading.equalToSuperview().offset(self.appearance.insets.left)
                case .next:
                    make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
                }
                make.centerY.equalToSuperview()
                make.size.equalTo(self.appearance.iconSize)
            }
        } else {
            self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
            self.contentStackView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(self.appearance.insets.left)
                make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
                make.centerY.equalToSuperview()
            }

            self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
            self.iconImageView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(self.appearance.iconSize.height)
            }

            self.iconImageContainerView.snp.makeConstraints { make in
                make.width.equalTo(self.appearance.iconSize.width)
            }
        }
    }
}
