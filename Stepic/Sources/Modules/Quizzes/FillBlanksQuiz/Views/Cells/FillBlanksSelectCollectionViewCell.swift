import UIKit

extension FillBlanksSelectCollectionViewCell {
    struct Appearance {
        let height: CGFloat = 36
        let minWidth: CGFloat = 90
        let cornerRadius: CGFloat = 18

        let textLabelInsets = LayoutInsets(left: 10, right: 8)
        let textLabelFont = UIFont.systemFont(ofSize: 16)
        let textLabelTextColor = UIColor.stepikPrimaryText

        let iconSize = CGSize(width: 14, height: 8)
        let iconTintColor = UIColor.quizElementSelectedBorder
        let iconInsets = LayoutInsets(left: 8, right: 10)
    }
}

final class FillBlanksSelectCollectionViewCell: UICollectionViewCell, Reusable {
    var appearance = Appearance()

    private lazy var inputContainerView: FillBlanksQuizInputContainerView = {
        let view = FillBlanksQuizInputContainerView(
            appearance: .init(cornerRadius: self.appearance.cornerRadius)
        )
        return view
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "code-quiz-arrow-down")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.iconTintColor
        return view
    }()

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var isEnabled: Bool = true {
        didSet {
            self.isUserInteractionEnabled = self.isEnabled
            self.imageView.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func calculatePreferredContentSize(text: String, maxWidth: CGFloat) -> CGSize {
        let appearance = Appearance()

        let widthOfIconWithInsets = appearance.iconInsets.left + appearance.iconSize.width + appearance.iconInsets.right

        let sizeOfString = appearance.textLabelFont.sizeOfString(
            string: text,
            constrainedToWidth: Double(maxWidth)
        )
        let widthOfStringWithInsets = appearance.textLabelInsets.left + sizeOfString.width.rounded(.up)

        let width = max(appearance.minWidth, min(maxWidth, (widthOfStringWithInsets + widthOfIconWithInsets)))

        return CGSize(width: width, height: appearance.height)
    }
}

extension FillBlanksSelectCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.contentView.addSubview(self.inputContainerView)
        self.inputContainerView.addSubview(self.textLabel)
        self.inputContainerView.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.inputContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.textLabelInsets.left)
            make.trailing.equalTo(self.imageView.snp.leading).offset(-self.appearance.textLabelInsets.right)
            make.centerY.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.width.equalTo(self.appearance.iconSize.width)
            make.height.equalTo(self.appearance.iconSize.height)
            make.trailing.equalToSuperview().offset(-self.appearance.iconInsets.right)
            make.centerY.equalTo(self.textLabel.snp.centerY)
        }
    }
}
