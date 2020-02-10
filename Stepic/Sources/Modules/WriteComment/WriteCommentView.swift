import SnapKit
import UIKit

// MARK: WriteCommentViewDelegate: class -

protocol WriteCommentViewDelegate: AnyObject {
    func writeCommentView(_ view: WriteCommentView, didUpdateText text: String)
    func writeCommentViewDidSelectSolution(_ view: WriteCommentView)
}

// MARK: - Appearance -

extension WriteCommentView {
    struct Appearance {
        let backgroundColor = UIColor.white

        let solutionControlHeight: CGFloat = 44
        let solutionControlInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let textViewTextInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let textViewFont = UIFont.systemFont(ofSize: 16)
        let textViewTextColor = UIColor.mainDark
        let textViewPlaceholderColor = UIColor.mainDark.withAlphaComponent(0.4)
    }
}

// MARK: - WriteCommentView: UIView -

final class WriteCommentView: UIView {
    let appearance: Appearance

    weak var delegate: WriteCommentViewDelegate?

    private lazy var solutionControl: WriteCommentSolutionControl = {
        let control = WriteCommentSolutionControl()
        control.addTarget(self, action: #selector(self.solutionControlClicked), for: .touchUpInside)
        return control
    }()

    private lazy var solutionBottomSeparatorView = SeparatorView()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.textViewFont
        textView.textColor = self.appearance.textViewTextColor
        textView.placeholderColor = self.appearance.textViewPlaceholderColor
        textView.placeholder = NSLocalizedString("WriteCommentPlaceholder", comment: "")
        textView.textInsets = self.appearance.textViewTextInsets
        // Enable scrolling
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        // Disable features
        textView.dataDetectorTypes = []

        textView.delegate = self

        return textView
    }()

    private var textViewTopToSuperviewConstraint: Constraint?
    private var textViewTopToBottomOfSeparatorConstraint: Constraint?

    var isEnabled: Bool = true {
        didSet {
            self.textView.isEditable = self.isEnabled
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    override func becomeFirstResponder() -> Bool {
        self.textView.becomeFirstResponder()
    }

    func configure(viewModel: WriteCommentViewModel) {
        self.textView.text = viewModel.text

        if viewModel.isSolutionHidden {
            self.textViewTopToSuperviewConstraint?.activate()
            self.textViewTopToBottomOfSeparatorConstraint?.deactivate()

            self.solutionControl.isHidden = true
            self.solutionBottomSeparatorView.isHidden = true
        } else {
            self.textViewTopToSuperviewConstraint?.deactivate()
            self.textViewTopToBottomOfSeparatorConstraint?.activate()

            self.solutionControl.isHidden = false
            self.solutionBottomSeparatorView.isHidden = false

            self.solutionControl.configure(
                viewModel: .init(
                    title: viewModel.solutionTitle,
                    isCorrect: viewModel.isSolutionCorrect,
                    isSelected: viewModel.isSolutionSelected
                )
            )
        }
    }

    @objc
    private func solutionControlClicked() {
        self.delegate?.writeCommentViewDidSelectSolution(self)
    }
}

// MARK: - WriteCommentView: ProgrammaticallyInitializableViewProtocol -

extension WriteCommentView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.solutionControl)
        self.addSubview(self.solutionBottomSeparatorView)
        self.addSubview(self.textView)
    }

    func makeConstraints() {
        self.solutionControl.translatesAutoresizingMaskIntoConstraints = false
        self.solutionControl.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading
                .equalTo(self.safeAreaLayoutGuide.snp.leading)
                .offset(self.appearance.solutionControlInsets.left)
            make.trailing
                .equalTo(self.safeAreaLayoutGuide.snp.trailing)
                .offset(-self.appearance.solutionControlInsets.right)
            make.height.equalTo(self.appearance.solutionControlHeight)
        }

        self.solutionBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        self.solutionBottomSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(self.solutionControl.snp.bottom).priority(999)
            make.leading.equalTo(self.solutionControl.snp.leading)
            make.trailing.equalToSuperview()
        }

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            self.textViewTopToSuperviewConstraint = make.top.equalToSuperview().constraint
            self.textViewTopToBottomOfSeparatorConstraint = make.top
                .equalTo(self.solutionBottomSeparatorView.snp.bottom)
                .constraint
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)

            self.textViewTopToBottomOfSeparatorConstraint?.deactivate()
        }
    }
}

// MARK: - WriteCommentView: UITextViewDelegate -

extension WriteCommentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.writeCommentView(self, didUpdateText: textView.text)
    }
}
