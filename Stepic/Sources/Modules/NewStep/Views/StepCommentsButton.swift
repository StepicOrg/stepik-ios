import SnapKit
import UIKit

extension StepCommentsButton {
    struct Appearance {
        let iconSize = CGSize(width: 16, height: 17)
        let insets = LayoutInsets(left: 16, right: 16)
        let spacing: CGFloat = 19

        let mainColor = UIColor.mainDark
        let textFont = UIFont.systemFont(ofSize: 16)
        let backgroundColor = UIColor(hex: 0xF6F6F6)
    }
}

final class StepCommentsButton: UIControl {
    let appearance: Appearance

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.iconImageContainerView, self.textLabel])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.spacing
        stackView.clipsToBounds = false
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var iconImageContainerView = UIView()

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "comments-icon")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.mainColor
        label.text = "Написать первый комментарий"
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
}

extension StepCommentsButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.iconImageContainerView.addSubview(self.iconImageView)
        self.addSubview(self.contentStackView)
    }

    func makeConstraints() {
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
