import SnapKit
import UIKit

extension NewChoiceQuizView {
    struct Appearance {
        let spacing: CGFloat = 16
        let insets = LayoutInsets(left: 16, right: 16)

        let separatorColor = UIColor(hex: 0xEAECF0)
        let separatorWidth: CGFloat = 1

        let titleColor = UIColor.mainDark
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

final class NewChoiceQuizView: UIView {
    let appearance: Appearance

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
        label.text = "Выберите один или несколько элементов"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.separatorView, self.titleLabelContainerView, self.choicesContainerView]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var choicesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = self.appearance.spacing
        return stackView
    }()

    private lazy var choicesContainerView = UIView()
    private lazy var titleLabelContainerView = UIView()

    var isSingleChoice = true

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

    // MARK: - Private API

    private func makeChoiceView() -> UIView {
        let view = ChoiceElementView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.choiceSelected(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }

    @objc
    private func choiceSelected(_ sender: UITapGestureRecognizer) {
        guard let choiceViewTag = sender.view?.tag else {
            return
        }

        guard let choiceView = self.choicesStackView.arrangedSubviews[safe: choiceViewTag] as? ChoiceElementView else {
            return
        }

        if choiceView.state == .default {
            choiceView.state = .selected
        } else if choiceView.state == .selected {
            choiceView.state = .default
        }

        if self.isSingleChoice {
            for view in self.choicesStackView.arrangedSubviews where view !== choiceView {
                (view as? ChoiceElementView)?.state = .default
            }
        }
    }
}

extension NewChoiceQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.choicesContainerView.addSubview(self.choicesStackView)
        self.titleLabelContainerView.addSubview(self.titleLabel)

        // Mock
        for i in 0..<4 {
            let choiceView = self.makeChoiceView()
            self.choicesStackView.addArrangedSubview(choiceView)
            choiceView.tag = i
        }
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorWidth)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.choicesStackView.translatesAutoresizingMaskIntoConstraints = false
        self.choicesStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
