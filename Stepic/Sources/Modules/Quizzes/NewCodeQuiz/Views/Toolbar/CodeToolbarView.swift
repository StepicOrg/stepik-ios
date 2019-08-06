import SnapKit
import UIKit

extension CodeToolbarView {
    struct Appearance {
        let insets = LayoutInsets(left: 16, right: 16)
        let containerHeight: CGFloat = 44
        let fullscreenButtonSize = CGSize(width: 20, height: 20)
        let horizontalSpacing: CGFloat = 16

        let mainColor = UIColor.mainDark
    }
}

final class CodeToolbarView: UIView {
    let appearance: Appearance

    private lazy var languagePickerButton: CodeToolbarLanguagePickerButton = {
        let languagePickerButton = CodeToolbarLanguagePickerButton()
        languagePickerButton.addTarget(self, action: #selector(self.languagePickerButtonClicked), for: .touchUpInside)
        return languagePickerButton
    }()

    private lazy var fullscreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "code-quiz-fullscreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = self.appearance.mainColor
        button.addTarget(self, action: #selector(self.fullscreenButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var containerView = UIView()

    var language: String? {
        didSet {
            self.languagePickerButton.language = self.language
        }
    }

    var isEnabled = true {
        didSet {
            self.languagePickerButton.isEnabled = self.isEnabled
            self.fullscreenButton.isEnabled = self.isEnabled
        }
    }

    var isLanguagePickerEnabled = true {
        didSet {
            self.languagePickerButton.isEnabled = self.isLanguagePickerEnabled
        }
    }

    var onPickLanguageButtonClick: (() -> Void)?
    var onFullscreenButtonClick: (() -> Void)?

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

    func collapseLanguagePickerButton() {
        self.languagePickerButton.collapse()
    }

    func toggleLanguagePickerButton() {
        if self.languagePickerButton.isCollapsed {
            self.languagePickerButton.expand()
        } else {
            self.languagePickerButton.collapse()
        }
    }

    // MARK: - Private API

    @objc
    private func languagePickerButtonClicked() {
        self.onPickLanguageButtonClick?()
    }

    @objc
    private func fullscreenButtonClicked() {
        self.onFullscreenButtonClick?()
    }
}

extension CodeToolbarView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.languagePickerButton)
        self.containerView.addSubview(self.fullscreenButton)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.appearance.containerHeight)
        }

        self.languagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        self.languagePickerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing
                .lessThanOrEqualTo(self.fullscreenButton.snp.leading)
                .offset(-self.appearance.horizontalSpacing)
            make.centerY.equalToSuperview()
        }

        self.fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.fullscreenButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.fullscreenButtonSize.width)
            make.height.equalTo(self.appearance.fullscreenButtonSize.height)
        }
    }
}
