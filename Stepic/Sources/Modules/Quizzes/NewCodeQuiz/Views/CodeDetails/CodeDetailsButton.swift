import SnapKit
import UIKit

extension CodeDetailsButton {
    struct Appearance {
        let leftIconSize = CGSize(width: 16, height: 16)
        let rightIconSize = CGSize(width: 16, height: 16)
        let insets = LayoutInsets(left: 16, right: 16)
        let horizontalSpacing: CGFloat = 16

        let mainColor = UIColor.mainDark
        let textFont = UIFont.systemFont(ofSize: 16)
        let backgroundColor = UIColor(hex: 0xF6F6F6)
    }
}

// TODO: Animate rightIcon on touch
final class CodeDetailsButton: UIControl {
    let appearance: Appearance

    private lazy var leftIconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-details-arrows")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var rightIconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-arrow-down")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    override var isHighlighted: Bool {
        didSet {
            self.leftIconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.rightIconImageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    var title: String? {
        didSet {
            self.textLabel.text = self.title
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

extension CodeDetailsButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.leftIconImageView)
        self.addSubview(self.textLabel)
        self.addSubview(self.rightIconImageView)
    }

    func makeConstraints() {
        self.leftIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.leftIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalToSuperview()
            make.height.equalTo(self.appearance.leftIconSize.height)
            make.width.equalTo(self.appearance.leftIconSize.width)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.leftIconImageView.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.centerY.equalTo(self.leftIconImageView.snp.centerY)
        }

        self.rightIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.rightIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalToSuperview()
            make.height.equalTo(self.appearance.rightIconSize.height)
            make.width.equalTo(self.appearance.rightIconSize.width)
        }
    }
}
