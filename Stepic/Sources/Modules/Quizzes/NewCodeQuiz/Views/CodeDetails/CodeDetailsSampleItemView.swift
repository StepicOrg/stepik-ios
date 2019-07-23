import SnapKit
import UIKit

extension CodeDetailsSampleItemView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(top: 16, left: 16, bottom: 16, right: 16)
        let horizontalSpacing: CGFloat = 16
        let iconSize = CGSize(width: 16, height: 16)

        let backgroundColor = UIColor(hex: 0xF6F6F6)
        let mainColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 16)
        let detailFont = UIFont.systemFont(ofSize: 14, weight: .light)
    }
}

final class CodeDetailsSampleItemView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.titleContainerView,
                self.inputContainerView,
                self.outputContainerView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var inputIconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-sample-input")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var outputIconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-sample-output")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var inputLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.detailFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var outputLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.detailFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var titleContainerView = UIView()
    private lazy var inputContainerView = UIView()
    private lazy var outputContainerView = UIView()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var inputText: String? {
        didSet {
            self.inputLabel.text = self.inputText
        }
    }

    var outputText: String? {
        didSet {
            self.outputLabel.text = self.outputText
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

extension CodeDetailsSampleItemView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.titleContainerView.addSubview(self.titleLabel)

        self.inputContainerView.addSubview(self.inputIconImageView)
        self.inputContainerView.addSubview(self.inputLabel)

        self.outputContainerView.addSubview(self.outputIconImageView)
        self.outputContainerView.addSubview(self.outputLabel)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview()
        }

        self.inputIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.inputIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalToSuperview()
            make.height.equalTo(self.appearance.iconSize.height)
            make.width.equalTo(self.appearance.iconSize.width)
        }

        self.inputLabel.translatesAutoresizingMaskIntoConstraints = false
        self.inputLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.inputIconImageView.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.trailing.top.bottom.equalToSuperview()
        }

        self.outputIconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.outputIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalTo(self.outputLabel.snp.centerY)
            make.height.equalTo(self.appearance.iconSize.height)
            make.width.equalTo(self.appearance.iconSize.width)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }

        self.outputLabel.translatesAutoresizingMaskIntoConstraints = false
        self.outputLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.outputIconImageView.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
