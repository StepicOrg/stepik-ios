import SnapKit
import UIKit

extension CodeLanguagePickerView {
    struct Appearance {
        let separatorColor = UIColor(hex: 0xEAECF0)
        let separatorHeight: CGFloat = 1

        let insets = LayoutInsets(left: 16, right: 16)
        let iconSize = CGSize(width: 16, height: 16)
        let horizontalSpacing: CGFloat = 16
        let headerHeight: CGFloat = 44

        let mainColor = UIColor.mainDark
        let titleTextFont = UIFont.systemFont(ofSize: 16)
    }
}

final class CodeLanguagePickerView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "code-quiz-select-language")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleTextFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var headerContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.makeSeparatorView(),
                self.headerContainerView,
                self.makeSeparatorView()
            ]
        )
        stackView.axis = .vertical
        return stackView
    }()

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
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

    private func makeSeparatorView() -> UIView {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
        return view
    }
}

extension CodeLanguagePickerView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.title = NSLocalizedString("SelectLanguage", comment: "")
    }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.headerContainerView.addSubview(self.iconImageView)
        self.headerContainerView.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerHeight)
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.iconSize.width)
            make.height.equalTo(self.appearance.iconSize.height)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }
    }
}
