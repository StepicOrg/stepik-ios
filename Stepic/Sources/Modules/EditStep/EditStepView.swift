import SnapKit
import UIKit

// MARK: Appearance -

extension EditStepView {
    struct Appearance {
        let backgroundColor = UIColor.white

        let loadingIndicatorColor = UIColor.mainDark

        let messageFont = UIFont.systemFont(ofSize: 12)
        let messageTextColor = UIColor(hex: 0x8E8E93)
        let messageLabelInsets = LayoutInsets(top: 16, left: 16, right: 16)

        let separatorInsets = LayoutInsets(top: 8)

        let textViewTextInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let textViewFont = UIFont.systemFont(ofSize: 16)
        let textViewTextColor = UIColor.mainDark
        let textViewPlaceholderColor = UIColor.mainDark.withAlphaComponent(0.4)
    }
}

// MARK: - EditStepViewDelegate: class -

protocol EditStepViewDelegate: AnyObject {
    func editStepView(_ view: EditStepView, didChangeText text: String)
}

// MARK: - EditStepView: UIView -

final class EditStepView: UIView {
    let appearance: Appearance

    weak var delegate: EditStepViewDelegate?

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("EditStepMessage", comment: "")
        label.font = self.appearance.messageFont
        label.textColor = self.appearance.messageTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView = SeparatorView()

    private lazy var textView: TableInputTextView = {
        let textView = TableInputTextView()
        textView.font = self.appearance.textViewFont
        textView.textColor = self.appearance.textViewTextColor
        textView.placeholderColor = self.appearance.textViewPlaceholderColor
        textView.placeholder = NSLocalizedString("EditStepPlaceholder", comment: "")
        textView.textInsets = self.appearance.textViewTextInsets
        // Enable scrolling
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        // Disable features
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.dataDetectorTypes = []

        textView.delegate = self

        return textView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = self.appearance.loadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.startAnimating()
        return loadingIndicatorView
    }()

    var text: String? {
        didSet {
            self.textView.text = self.text
        }
    }

    var isEnabled: Bool = true {
        didSet {
            self.textView.isEditable = self.isEnabled
            self.textView.isSelectable = self.isEnabled
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

    // MARK: Public API

    func showLoading() {
        self.loadingIndicator.startAnimating()
        self.setStepContentViewsHidden(true)
    }

    func hideLoading() {
        self.loadingIndicator.stopAnimating()
        self.setStepContentViewsHidden(false)
    }

    // MARK: Private API

    private func setStepContentViewsHidden(_ isHidden: Bool) {
        for view in self.subviews where view !== self.loadingIndicator {
            view.isHidden = isHidden
        }
    }
}

// MARK: - EditStepView: ProgrammaticallyInitializableViewProtocol -

extension EditStepView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.messageLabel)
        self.addSubview(self.separatorView)
        self.addSubview(self.textView)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(self.appearance.messageLabelInsets.left)
            make.top.equalToSuperview().offset(self.appearance.messageLabelInsets.top)
            make.trailing
                .equalTo(self.safeAreaLayoutGuide.snp.trailing)
                .offset(-self.appearance.messageLabelInsets.right)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.messageLabel.snp.bottom).offset(self.appearance.separatorInsets.top)
        }

        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(self.separatorView.snp.bottom)
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

// MARK: - EditStepView: UITextViewDelegate -

extension EditStepView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.editStepView(self, didChangeText: textView.text)
    }
}
