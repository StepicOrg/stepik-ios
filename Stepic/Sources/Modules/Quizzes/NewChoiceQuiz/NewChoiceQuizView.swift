import SnapKit
import UIKit

protocol NewChoiceQuizViewDelegate: class {
    func newChoiceQuizView(_ view: NewChoiceQuizView, didReport selectionMask: [Bool])
}

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
    weak var delegate: NewChoiceQuizViewDelegate?

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleColor
        label.font = self.appearance.titleFont
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

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var isSingleChoice = true
    private var isSelectionEnabled = true
    
    // swiftlint:disable:next discouraged_optional_collection
    private var selectionMask: [Bool]?

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

    // MARK: - Public API

    func markSelectedAsCorrect() {
        self.isSelectionEnabled = false
        self.updateSelected(state: .correct)
        self.updateEnabled(false)
    }

    func markSelectedAsWrong() {
        self.isSelectionEnabled = false
        self.updateSelected(state: .wrong)
        self.updateEnabled(false)
    }

    func reset() {
        // Reset if only view is in correct / wrong state
        if self.isSelectionEnabled {
            return
        }

        self.isSelectionEnabled = true
        self.updateSelected(state: .default)
        self.updateEnabled(true)
    }

    func set(choices: [(text: String, isSelected: Bool)]) {
        if !self.choicesStackView.arrangedSubviews.isEmpty {
            self.choicesStackView.removeAllArrangedSubviews()
        }

        for (index, choice) in choices.enumerated() {
            let view = self.makeChoiceView(text: choice.text)
            view.tag = index
            self.choicesStackView.addArrangedSubview(view)
        }

        self.selectionMask = choices.map { $0.isSelected }
        self.updateSelected(state: .selected)
    }

    // MARK: - Private API

    private func updateEnabled(_ isEnabled: Bool) {
        for view in self.choicesStackView.arrangedSubviews {
            if let elementView = view as? ChoiceElementView {
                elementView.isEnabled = isEnabled
            }
        }
    }

    private func updateSelected(state: ChoiceElementView.State) {
        guard let selectionMask = self.selectionMask else {
            return
        }

        assert(self.choicesStackView.arrangedSubviews.count == selectionMask.count)

        for (isSelected, view) in zip(selectionMask, self.choicesStackView.arrangedSubviews) {
            if let elementView = view as? ChoiceElementView, isSelected {
                elementView.state = state
            }
        }
    }

    private func makeChoiceView(text: String) -> ChoiceElementView {
        let view = ChoiceElementView()
        view.text = text
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.choiceSelected(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }

    @objc
    private func choiceSelected(_ sender: UITapGestureRecognizer) {
        guard self.isSelectionEnabled else {
            return
        }

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

        let selectionMask = self.choicesStackView.arrangedSubviews
            .map { $0 as? ChoiceElementView }
            .map { view -> Bool in
                if let view = view {
                    return view.state == .selected
                }
                return false
            }
        self.delegate?.newChoiceQuizView(self, didReport: selectionMask)
        self.selectionMask = selectionMask
    }
}

extension NewChoiceQuizView: ProgrammaticallyInitializableViewProtocol {
    func setupView() { }

    func addSubviews() {
        self.addSubview(self.stackView)

        self.choicesContainerView.addSubview(self.choicesStackView)
        self.titleLabelContainerView.addSubview(self.titleLabel)
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
